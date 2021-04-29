trigger SessionTrigger on Session__c(after insert, after update, after delete) {
  Set<Id> siteIds = new Set<Id>();
  Map<Id, Account> acctMap = new Map<Id, Account>();

  if (Trigger.isDelete) {
    for (Session__c s : Trigger.old) {
      siteIds.add(s.Site__c);
    }
  } else {
    for (Session__c s : Trigger.new) {
      siteIds.add(s.Site__c);
      if (Trigger.oldMap != null) {
        siteIds.add(Trigger.oldMap.get(s.Id).Site__c);
      }
    }
  }

  Account[] accts = [
    SELECT Number_of_Cohorts__c
    FROM Account
    WHERE Id IN :siteIds
  ];
  if (accts.size() > 0) {
    for (Account a : accts) {
      a.Number_of_Cohorts__c = 0;
      acctMap.put(a.Id, a);
    }
  }

  for (AggregateResult ar : [
    SELECT Site__r.Id AcctId, Count(Id) CohortCount
    FROM Session__c
    WHERE
      Site__r.Id IN :siteIds
      AND RecordType.Name = 'Cohort'
      AND Site__r.Id != NULL
    GROUP BY Site__r.Id
  ]) {
    system.debug('ar = ' + ar);
    Account a = new Account();
    a.Id = (Id) ar.get('AcctId'); //---> set the id and update
    a.Number_of_Cohorts__c = 0;
    a.Number_of_Cohorts__c = (Integer) ar.get('CohortCount');
    acctMap.put(a.Id, a);
  }
  try {
    update acctMap.values();
  } catch (Exception e) {
    system.debug(e.getMessage());
  }
}
