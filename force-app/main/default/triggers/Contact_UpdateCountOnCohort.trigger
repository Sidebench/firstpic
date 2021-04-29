trigger Contact_UpdateCountOnCohort on Contact(
  after insert,
  after update,
  after delete,
  after undelete
) {
  Set<Id> acctIds = new Set<Id>();
  List<Account> acctsToRollup = new List<Account>();
  Set<Id> cohortIds = new Set<Id>();
  List<Session__c> cohortsToRollup = new List<Session__c>();

  if (Trigger.isDelete) {
    for (Contact c : Trigger.old) {
      acctIds.add(c.AccountId);
      cohortIds.add(c.Cohort__c);
    }
  } else if (Trigger.isInsert) {
    for (Contact c : Trigger.new) {
      acctIds.add(c.AccountId);
      cohortIds.add(c.Cohort__c);
    }
  } else {
    for (Contact c : Trigger.new) {
      acctIds.add(c.AccountId);
      acctIds.add(Trigger.oldMap.get(c.Id).AccountId);
      cohortIds.add(c.Cohort__c);
      cohortIds.add(Trigger.oldMap.get(c.Id).Cohort__c);
    }
  }
  system.debug('>>> cohortIds = ' + cohortIds);

  for (AggregateResult ar : [
    SELECT Cohort__c CohortId, Count(id) ContactCount
    FROM Contact
    WHERE Cohort__c IN :cohortIds AND RecordType.Name = 'Youth'
    GROUP BY Cohort__c
  ]) {
    Session__c s = new Session__c();
    s.Id = (Id) ar.get('CohortId'); //---> set the id and update
    s.Cohort_Size__c = (Integer) ar.get('ContactCount');
    if (s.Id != null) {
      cohortsToRollup.add(s);
    }
  }
  try {
    update cohortsToRollup;
    system.debug('>>> cohortsToRollup = ' + cohortsToRollup);
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
    a.Id = (Id) ar.get('AcctId'); //---> set the id and update
    a.Youth_Served__c = (Integer) ar.get('ContactCount');
    acctsToRollup.add(a);
  }
  try {
    update acctsToRollup;
    system.debug('>>> acctsToRollup = ' + acctsToRollup);
  } catch (Exception e) {
    system.debug(e.getMessage());
  }
}
