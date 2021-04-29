public without sharing class ContactUtilitiesClass {
  // BEGIN preventDuplicate
  /*
    public void preventDuplicate(List<Contact> contactList) {
        Map<String, Contact> contactMap = new Map<String, Contact>();
        Set<String> emails = new Set<String>();
        
        for(Contact c : contactList) 
            emails.add(c.Email);
        
        for(Contact c : [SELECT Id, Name, Email FROM Contact WHERE Email IN :emails AND Email != null])
            contactMap.put(c.Email, c);
        
        for(Contact c : contactList) {
            if(contactMap.containsKey(c.Email) && c.Id != contactMap.get(c.Email).Id) {
                c.addError(
                    'There is already another Contact with the same Email. ' + 
                    'Refer: <a href=\'/' + contactMap.get(c.Email).Id + '\'>' + c.Email + '</a>',
                    false
                );  
            }
        }
    } 
	*/
  // END preventDuplicate

  // BEGIN updateAccountLookups
  public void updateAccountLookups(List<Contact> contacts) {
    system.debug(
      'ContactUtilitiesClass updateAccountLookups START; contacts = ' + contacts
    );

    Set<Id> aIdSet = new Set<Id>();
    Map<Id, Account> accts = new Map<Id, Account>();

    for (Contact c : [
      SELECT Id, AccountId, Role__c
      FROM Contact
      WHERE Id IN :contacts
    ]) {
      aIdSet.add(c.AccountId);
    }

    for (Account a : [
      SELECT CEO__c, Finance_Lead__c, Program_Coordinator__c
      FROM Account
      WHERE ID IN :aIdSet
    ]) {
      for (Contact c : contacts) {
        if (c.AccountId == a.Id) {
          if (c.Role__c == 'CEO')
            a.CEO__c = c.Id;
          if (c.Role__c == 'Finance Lead')
            a.Finance_Lead__c = c.Id;
          if (c.Role__c == 'Program Coordinator')
            a.Program_Coordinator__c = c.Id;
          accts.put(a.Id, a);
        }
      }
    }

    try {
      update accts.values();
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }
  // BEGIN updateAccountLookups

  // BEGIN updateEmailFields
  public void updateSiteEmailFeilds(Set<Id> aIds) {
    List<Account> accts = new List<Account>();

    for (Account i : [
      SELECT
        RecordType.Name,
        Name,
        Id,
        CEO__c,
        CEO_Email__c,
        CEO_Email_text__c,
        DOD__c,
        DOD_Email__c,
        DOD_Email_text__c,
        Local_Organization__r.CEO__c,
        Local_Organization__r.CEO_Email__c,
        Local_Organization__r.CEO_Email_text__c,
        Local_Organization__r.DOD__c,
        Local_Organization__r.DOD_Email__c,
        Local_Organization__r.DOD_Email_text__c
      FROM Account
      WHERE Id IN :aIds OR Local_Organization__c IN :aIds
    ]) {
      if (i.RecordType.Name == 'Site') {
        i.CEO__c = i.Local_Organization__r.CEO__c;
        i.CEO_Email__c = i.Local_Organization__r.CEO_Email_text__c;
        i.DOD__c = i.Local_Organization__r.DOD__c;
        i.DOD_Email__c = i.Local_Organization__r.DOD_Email_text__c;
        accts.add(i);
      } else {
        i.CEO_Email__c = i.CEO_Email_text__c;
        i.DOD_Email__c = i.DOD_Email_text__c;
        accts.add(i);
      }
    }

    try {
      system.debug('updateSiteEmailFeilds Accounts to update = ' + accts);
      update accts;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }

  public void updateEmailFields(
    Set<Id> aIds,
    Map<Id, Contact> aIds_CEO_map,
    Map<Id, String> aIds_DOD_map,
    Map<Id, Contact> aIds_PC_map
  ) {
    system.debug('ContactUtilitiesClass updateEmailFields START');
    system.debug('aIds = ' + aIds);
    system.debug('aIds_CEO_map = ' + aIds_CEO_map);
    system.debug('aIds_DOD_map = ' + aIds_DOD_map);
    system.debug('aIds_PC_map = ' + aIds_PC_map);

    List<Account> accts = new List<Account>();
    List<Assessment__c> assess = new List<Assessment__c>();
    List<Grant__c> grants = new List<Grant__c>();
    List<Reimbursement_Request__c> requests = new List<Reimbursement_Request__c>();
    List<Program_Report__c> program = new List<Program_Report__c>();
    List<Progress_Report__c> progress = new List<Progress_Report__c>();
    List<Session_Report__c> session = new List<Session_Report__c>();
    List<Grantee_Report__c> dctat = new List<Grantee_Report__c>();
    List<Document__c> doc = new List<Document__c>();

    for (Account i : [
      SELECT
        Id,
        CEO__c,
        CEO_Email__c,
        DOD_Email__c,
        Program_Coordinator__c,
        Program_Coordinator_Email__c
      FROM Account
      WHERE Id IN :aIds
    ]) {
      if (aIds_CEO_map.containsKey(i.Id)) {
        i.CEO__c = aIds_CEO_map.get(i.Id).Id;
        i.CEO_Email__c = aIds_CEO_map.get(i.Id).Email;
      }
      if (aIds_DOD_map != null && aIds_DOD_map.containsKey(i.Id))
        i.DOD_Email__c = aIds_DOD_map.get(i.Id);
      if (aIds_PC_map != null && aIds_PC_map.containsKey(i.Id)) {
        i.Program_Coordinator__c = aIds_PC_map.get(i.Id).Id;
        i.Program_Coordinator_Email__c = aIds_PC_map.get(i.Id).Email;
      }
      accts.add(i);
    }

    for (Assessment__c i : [
      SELECT Organization__r.Id, CEO__c
      FROM Assessment__c
      WHERE Organization__r.Id IN :aIds
    ]) {
      if (aIds_CEO_map.containsKey(i.Organization__r.Id))
        i.CEO__c = aIds_CEO_map.get(i.Organization__r.Id).Id;
      assess.add(i);
    }

    for (Grant__c i : [
      SELECT
        Account__r.Id,
        CEO__c,
        CEO_Email__c,
        DOD_Email__c,
        Program_Coordinator_Email__c
      FROM Grant__c
      WHERE Account__r.Id IN :aIds
    ]) {
      system.debug('grant: ' + i);
      system.debug(
        'aIds_CEO_map.containsKey(i.Account__r.Id): ' +
        aIds_CEO_map.containsKey(i.Account__r.Id)
      );
      if (aIds_CEO_map.containsKey(i.Account__r.Id)) {
        i.CEO__c = aIds_CEO_map.get(i.Account__r.Id).Id;
        i.CEO_Email__c = aIds_CEO_map.get(i.Account__r.Id).Email;
      }
      if (aIds_DOD_map != null && aIds_DOD_map.containsKey(i.Account__r.Id))
        i.DOD_Email__c = aIds_DOD_map.get(i.Account__r.Id);
      if (aIds_PC_map != null && aIds_PC_map.containsKey(i.Account__r.Id))
        i.Program_Coordinator_Email__c = aIds_PC_map.get(i.Account__r.Id).Email;
      grants.add(i);
    }

    for (Reimbursement_Request__c i : [
      SELECT
        Grant__r.Account__r.Id,
        CEO__c,
        CEO_Email__c,
        DOD_Email__c,
        Program_Coordinator_Email__c
      FROM Reimbursement_Request__c
      WHERE Grant__r.Account__r.Id IN :aIds
    ]) {
      if (aIds_CEO_map.containsKey(i.Grant__r.Account__r.Id)) {
        i.CEO__c = aIds_CEO_map.get(i.Grant__r.Account__r.Id).Id;
        i.CEO_Email__c = aIds_CEO_map.get(i.Grant__r.Account__r.Id).Email;
      }
      if (
        aIds_DOD_map != null &&
        aIds_DOD_map.containsKey(i.Grant__r.Account__r.Id)
      )
        i.DOD_Email__c = aIds_DOD_map.get(i.Grant__r.Account__r.Id);
      if (
        aIds_PC_map != null && aIds_PC_map.containsKey(i.Grant__r.Account__r.Id)
      )
        i.Program_Coordinator_Email__c = aIds_PC_map.get(
            i.Grant__r.Account__r.Id
          )
          .Email;
      requests.add(i);
    }

    for (Program_Report__c i : [
      SELECT
        Local_Organization_Id__c,
        CEO__c,
        CEO_Email__c,
        DOD_Email__c,
        Program_Coordinator__c,
        Program_Coordinator_Email__c
      FROM Program_Report__c
      WHERE Local_Organization_Id__c IN :aIds
    ]) {
      if (aIds_CEO_map.containsKey(i.Local_Organization_Id__c)) {
        i.CEO__c = aIds_CEO_map.get(i.Local_Organization_Id__c).Id;
        i.CEO_Email__c = aIds_CEO_map.get(i.Local_Organization_Id__c).Email;
      }
      if (
        aIds_DOD_map != null &&
        aIds_DOD_map.containsKey(i.Local_Organization_Id__c)
      )
        i.DOD_Email__c = aIds_DOD_map.get(i.Local_Organization_Id__c);
      if (
        aIds_PC_map != null &&
        aIds_PC_map != null &&
        aIds_PC_map != null &&
        aIds_PC_map != null &&
        aIds_PC_map.containsKey(i.Local_Organization_Id__c)
      ) {
        i.Program_Coordinator__c = aIds_PC_map.get(i.Local_Organization_Id__c)
          .Id;
        i.Program_Coordinator_Email__c = aIds_PC_map.get(
            i.Local_Organization_Id__c
          )
          .Email;
      }
      program.add(i);
    }

    for (Progress_Report__c i : [
      SELECT
        Local_Organization_Id__c,
        CEO__c,
        CEO_Email__c,
        DOD_Email__c,
        Program_Coordinator__c,
        Program_Coordinator_Email__c
      FROM Progress_Report__c
      WHERE Local_Organization_Id__c IN :aIds
    ]) {
      if (aIds_CEO_map.containsKey(i.Local_Organization_Id__c)) {
        i.CEO__c = aIds_CEO_map.get(i.Local_Organization_Id__c).Id;
        i.CEO_Email__c = aIds_CEO_map.get(i.Local_Organization_Id__c).Email;
      }
      if (
        aIds_DOD_map != null &&
        aIds_DOD_map.containsKey(i.Local_Organization_Id__c)
      )
        i.DOD_Email__c = aIds_DOD_map.get(i.Local_Organization_Id__c);
      if (
        aIds_PC_map != null &&
        aIds_PC_map.containsKey(i.Local_Organization_Id__c)
      ) {
        i.Program_Coordinator__c = aIds_PC_map.get(i.Local_Organization_Id__c)
          .Id;
        i.Program_Coordinator_Email__c = aIds_PC_map.get(
            i.Local_Organization_Id__c
          )
          .Email;
      }
      progress.add(i);
    }

    for (Session_Report__c i : [
      SELECT
        Local_Organization_Id__c,
        CEO__c,
        CEO_Email__c,
        DOD_Email__c,
        Program_Coordinator__c,
        Program_Coordinator_Email__c
      FROM Session_Report__c
      WHERE Local_Organization_Id__c IN :aIds
    ]) {
      if (aIds_CEO_map.containsKey(i.Local_Organization_Id__c)) {
        i.CEO__c = aIds_CEO_map.get(i.Local_Organization_Id__c).Id;
        i.CEO_Email__c = aIds_CEO_map.get(i.Local_Organization_Id__c).Email;
      }
      if (
        aIds_DOD_map != null &&
        aIds_DOD_map.containsKey(i.Local_Organization_Id__c)
      ) {
        system.debug('test');
        i.DOD_Email__c = aIds_DOD_map.get(i.Local_Organization_Id__c);
      }
      if (
        aIds_PC_map != null &&
        aIds_PC_map.containsKey(i.Local_Organization_Id__c)
      ) {
        i.Program_Coordinator__c = aIds_PC_map.get(i.Local_Organization_Id__c)
          .Id;
        i.Program_Coordinator_Email__c = aIds_PC_map.get(
            i.Local_Organization_Id__c
          )
          .Email;
      }
      session.add(i);
    }

    for (Grantee_Report__c i : [
      SELECT
        Organization_Id__c,
        CEO__c,
        CEO_Email__c,
        Program_Coordinator_Email__c
      FROM Grantee_Report__c
      WHERE Organization_Id__c IN :aIds
    ]) {
      if (aIds_CEO_map.containsKey(i.Organization_Id__c)) {
        i.CEO__c = aIds_CEO_map.get(i.Organization_Id__c).Id;
        i.CEO_Email__c = aIds_CEO_map.get(i.Organization_Id__c).Email;
      }
      if (
        aIds_PC_map != null &&
        aIds_PC_map != null &&
        aIds_PC_map != null &&
        aIds_PC_map.containsKey(i.Organization_Id__c)
      )
        i.Program_Coordinator_Email__c = aIds_PC_map.get(i.Organization_Id__c)
          .Email;
      dctat.add(i);
    }

    for (Document__c i : [
      SELECT Organization_Id__c, CEO_Email__c
      FROM Document__c
      WHERE Organization_Id__c IN :aIds_CEO_map.keyset()
    ]) {
      system.debug('ContactUtilitiesClass updateEmailFields doc = ' + i);
      if (aIds_CEO_map.containsKey(i.Organization_Id__c))
        i.CEO_Email__c = aIds_CEO_map.get(i.Organization_Id__c).Email;
      doc.add(i);
    }

    try {
      system.debug('Accounts to update = ' + accts);
      update accts;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      update assess;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      system.debug('Grants to update = ' + grants);
      update grants;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      update requests;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      update program;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      update progress;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      update session;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      update dctat;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
    try {
      update doc;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    system.debug('ContactUtilitiesClass updateEmailFields END');
  }
  // END updateEmailFields

  // BEGIN updatePAEmailFields
  public void updatePAEmailFields(
    Map<Id, String> pa_map,
    Map<Id, String> aId_pa_map
  ) {
    system.debug('ContactUtilitiesClass updatePAEmailFields START');
    system.debug('pa_map = ' + pa_map);
    system.debug('aId_pa_map = ' + aId_pa_map);

    Map<Id, String> aIds = new Map<Id, String>();
    List<Account> accts = new List<Account>();
    if (aId_pa_map != null) {
      for (Account i : [
        SELECT Id, Primary_Approver__r.Id, Primary_Approver_Email__c
        FROM Account
        WHERE Id IN :aId_pa_map.keyset()
      ]) {
        String email = aId_pa_map.get(i.Id);
        i.Primary_Approver_Email__c = email;
        accts.add(i);
        if (aId_pa_map != null)
          aIds.put(i.Id, email);
      }
    } else {
      for (Account i : [
        SELECT Id, Primary_Approver__r.Id, Primary_Approver_Email__c
        FROM Account
        WHERE Primary_Approver__c IN :pa_map.keyset()
      ]) {
        system.debug('Account = ' + i);
        String email = pa_map.get(i.Primary_Approver__r.Id);
        i.Primary_Approver_Email__c = email;
        accts.add(i);
        aIds.put(i.Id, email);
      }
    }
    try {
      system.debug('Accounts to update = ' + accts);
      update accts;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    List<Application__c> apps = new List<Application__c>();
    for (Application__c i : [
      SELECT Organization__r.Id, Primary_Approver_Email__c
      FROM Application__c
      WHERE Organization__r.Id IN :aIds.keyset()
    ]) {
      i.Primary_Approver_Email__c = aIds.get(i.Organization__r.Id);
      apps.add(i);
    }
    try {
      system.debug('Applications to update = ' + apps);
      update apps;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    List<Grant__c> grants = new List<Grant__c>();
    for (Grant__c i : [
      SELECT Account__r.Id, Primary_Approver_Email__c
      FROM Grant__c
      WHERE Account__r.Id IN :aIds.keyset()
    ]) {
      i.Primary_Approver_Email__c = aIds.get(i.Account__r.Id);
      grants.add(i);
    }
    try {
      system.debug('Grants to update = ' + grants);
      update grants;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    List<Reimbursement_Request__c> requests = new List<Reimbursement_Request__c>();
    for (Reimbursement_Request__c i : [
      SELECT Grant__r.Account__r.Id, Primary_Approver_Email__c
      FROM Reimbursement_Request__c
      WHERE Grant__r.Account__r.Id IN :aIds.keyset()
    ]) {
      i.Primary_Approver_Email__c = aIds.get(i.Grant__r.Account__r.Id);
      requests.add(i);
    }
    try {
      system.debug('Requests to update = ' + requests);
      update requests;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    List<Grantee_Report__c> dctat = new List<Grantee_Report__c>();
    for (Grantee_Report__c i : [
      SELECT Organization_Id__c, Primary_Approver_Email__c
      FROM Grantee_Report__c
      WHERE Organization_Id__c IN :aIds.keyset()
    ]) {
      i.Primary_Approver_Email__c = aIds.get(i.Organization_Id__c);
      dctat.add(i);
    }
    try {
      system.debug('DCTAT to update = ' + dctat);
      update dctat;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    system.debug('ContactUtilitiesClass updatePAEmailFields END');
  }
  // END updatePAEmailFields

  // BEGIN updateYouthCounts
  public void updateYouthCounts(Set<Id> acctIds, Set<Id> cohortIds) {
    system.debug('ContactUtilitiesClass updateYouthCounts START');

    Map<Id, Account> acctMap = new Map<Id, Account>();
    Map<Id, Session__c> cohortMap = new Map<Id, Session__c>();

    for (AggregateResult ar : [
      SELECT Cohort__c CohortId, Count(id) ContactCount
      FROM Contact
      WHERE Cohort__c IN :cohortIds AND RecordType.Name = 'Youth'
      GROUP BY Cohort__c
    ]) {
      Session__c s = new Session__c();
      s.Id = (Id) ar.get('CohortId');
      s.Cohort_Size__c = (Integer) ar.get('ContactCount');
      if (s.Id != null) {
        cohortMap.put(s.id, s);
      }
    }
    try {
      update cohortMap.values();
    } catch (Exception e) {
      system.debug(e.getMessage());
    }

    for (AggregateResult ar : [
      SELECT AccountId AcctId, Count(id) ContactCount
      FROM Contact
      WHERE AccountId IN :acctIds AND RecordType.Name = 'Youth'
      GROUP BY AccountId
    ]) {
      Account a = new Account();
      a.Id = (Id) ar.get('AcctId');
      a.Youth_Served__c = (Integer) ar.get('ContactCount');
      acctMap.put(a.Id, a);
    }
    try {
      update acctMap.values();
    } catch (Exception e) {
      system.debug(e.getMessage());
    }
    system.debug('ContactUtilitiesClass updateYouthCounts END');
  }
  // END updateYouthCounts
}
