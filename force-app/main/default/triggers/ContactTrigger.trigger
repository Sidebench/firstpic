trigger ContactTrigger on Contact(after insert, after update, after delete) {
  ContactUtilitiesClass util = new ContactUtilitiesClass();
  List<Contact> contacts = new List<Contact>();
  Set<Id> aIds = new Set<Id>();
  Map<Id, Contact> aIds_CEO_map = new Map<Id, Contact>();
  Map<Id, String> aIds_DOD_map = new Map<Id, String>();
  Map<Id, Contact> aIds_PC_map = new Map<Id, Contact>();
  Map<Id, Id> aId_cId_map = new Map<Id, Id>();
  Map<Id, String> pa_map = new Map<Id, String>();
  Set<Id> acctIds = new Set<Id>();
  Set<Id> cohortIds = new Set<Id>();
  Id yId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
    .get('Youth')
    .getRecordTypeId();

  //if(Trigger.isBefore) util.preventDuplicate(Trigger.new);
  //if(!Trigger.isDelete) util.updateAccountLookups(Trigger.new, Trigger.oldMap);

  if (Trigger.isDelete) {
    for (Contact c : Trigger.old) {
      if (c.RecordTypeId == yId) {
        if (c.AccountId != null)
          acctIds.add(c.AccountId);
        if (c.Cohort__c != null)
          cohortIds.add(c.Cohort__c);
      }
    }
  } else {
    for (Contact c : Trigger.new) {
      if (
        (Trigger.isInsert &&
        (c.Role__c == 'CEO' ||
        c.Role__c == 'Finance Lead' ||
        c.Role__c == 'Program Coordinator')) ||
        (Trigger.isUpdate &&
        c.Role__c != Trigger.oldMap.get(c.Id).Role__c &&
        c.Role__c != null)
      ) {
        contacts.add(c);
      }

      if (
        Trigger.isInsert ||
        c.Role__c != Trigger.oldMap.get(c.Id).Role__c ||
        c.Email != Trigger.oldMap.get(c.Id).Email
      ) {
        if (c.Role__c == 'CEO' || c.Account.CEO__c == c.Id) {
          aIds.add(c.AccountId);
          aIds_CEO_map.put(c.AccountId, c);
        }
        if (c.Role__c == 'DOD' || c.Account.DOD__c == c.Id) {
          aIds.add(c.AccountId);
          aIds_DOD_map.put(c.AccountId, c.Email);
        }
        if (
          c.Role__c == 'Program Coordinator' ||
          c.Account.Program_Coordinator__c == c.Id
        ) {
          aIds.add(c.AccountId);
          aIds_PC_map.put(c.AccountId, c);
        }
        if (c.Is_Primary_Approver__c == true) {
          aId_cId_map.put(c.AccountId, c.Id);
          pa_map.put(c.Id, c.Email);
        }
      }

      if (
        c.RecordTypeId == yId &&
        (Trigger.isInsert || c.AccountId != Trigger.oldMap.get(c.Id).AccountId)
      ) {
        if (c.AccountId != null)
          acctIds.add(c.AccountId);
        if (c.Cohort__c != null)
          cohortIds.add(c.Cohort__c);
      }
    }
  }

  if (contacts.size() > 0)
    util.updateAccountLookups(contacts);
  if (
    aIds_CEO_map.size() > 0 ||
    aIds_DOD_map.size() > 0 ||
    aIds_PC_map.size() > 0
  )
    util.updateEmailFields(aIds, aIds_CEO_map, aIds_DOD_map, aIds_PC_map);
  if (acctIds.size() > 0 || cohortIds.size() > 0)
    util.updateYouthCounts(acctIds, cohortIds);
  if (pa_map.size() > 0) {
    List<Account> accts = [
      SELECT Id, Primary_Approver__c
      FROM Account
      WHERE Id IN :aId_cId_map.keyset()
    ];
    for (Account a : accts) {
      a.Primary_Approver__c = aId_cId_map.get(a.Id);
    }
    try {
      system.debug('ContactTrigger Accounts to update = ' + accts);
      update accts;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    util.updatePAEmailFields(pa_map, null);
  }
}
