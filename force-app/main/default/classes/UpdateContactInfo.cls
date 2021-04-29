public class UpdateContactInfo implements Schedulable {
  ContactUtilitiesClass util = new ContactUtilitiesClass();
  Set<Id> aIds = new Set<Id>();
  Map<Id, Contact> aIds_CEO_map = new Map<Id, Contact>();
  Map<Id, Contact> aIds_PC_map = new Map<Id, Contact>();

  public void execute(SchedulableContext sc) {
    for (Contact i : [
      SELECT AccountId, Role__c, Email
      FROM Contact
      WHERE
        AccountId != NULL
        AND Email != NULL
        AND (Role__c = 'CEO'
        OR Role__c = 'Program Coordinator')
    ]) {
      aIds.add(i.AccountId);
      if (i.Role__c == 'CEO')
        aIds_CEO_map.put(i.AccountId, i);
      if (i.Role__c == 'Program Coordinator')
        aIds_PC_map.put(i.AccountId, i);
    }
    util.updateEmailFields(aIds, aIds_CEO_map, null, aIds_PC_map);
  }
}
