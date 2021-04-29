trigger Site_NumberOfCohorts on Session__c(
  after insert,
  after update,
  after delete,
  after undelete
) {
  Set<Id> cohortIds = new Set<Id>();
  Set<Id> siteIds = new Set<Id>();
  List<Account> acctsToRollup = new List<Account>();

  if (Trigger.isDelete) {
    for (Session__c s : Trigger.old) {
      cohortIds.add(s.Site__c);
    }
  } else if (Trigger.isInsert) {
    for (Session__c s : Trigger.new) {
      cohortIds.add(s.Site__c);
    }
  } else {
    for (Session__c s : Trigger.new) {
      cohortIds.add(s.Site__c);
      cohortIds.add(Trigger.oldMap.get(s.Id).Site__c);
    }
  }

  for (Session__c s : [
    SELECT Id, Site__r.Id
    FROM Session__c
    WHERE Id IN :cohortIds
  ]) {
    siteIds.add(s.Site__r.Id);
  }

  for (AggregateResult ar : [
    SELECT Site__r.Id AcctId, Count(Id) CohortCount
    FROM Session__c
    WHERE Site__r.Id IN :siteIds AND RecordType.Name = 'Cohort'
    GROUP BY Site__r.Id
  ]) {
    Account a = new Account();
    a.Id = (Id) ar.get('AcctId'); //---> set the id and update
    a.Number_of_Cohorts__c = (Integer) ar.get('CohortCount');
    acctsToRollup.add(a);
  }
  try {
    update acctsToRollup;
    system.debug('>>> acctsToRollup = ' + acctsToRollup);
  } catch (Exception e) {
    system.debug(e.getMessage());
  }
}
