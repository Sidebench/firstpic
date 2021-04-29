@isTest
class TestSessionTriggers {
  static testMethod void testUpdateCohortCount() {
    system.test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Session__c session = new Session__c(
      Name = 'Test Session',
      Site__c = a.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Session')
        .getRecordTypeId()
    );
    insert session;

    Session__c cohort = new Session__c(
      Name = 'Test Cohort',
      //Site__c = a.Id,
      Session__c = session.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Cohort')
        .getRecordTypeId()
    );
    insert cohort;

    // Test INSERT
    //Account acctInsertTest = [SELECT Number_of_Cohorts__c FROM Account WHERE Id = :a.Id];
    //system.assertEquals(0, acctInsertsystem.test.Number_of_Cohorts__c);

    // Test UPDATE
    cohort.Site__c = a.Id;
    update cohort;
    //Account acctUpdateTest = [SELECT Number_of_Cohorts__c FROM Account WHERE Id = :a.Id];
    //system.assertEquals(1, acctUpdatesystem.test.Number_of_Cohorts__c);

    // Test DELETE
    delete cohort;
    //Account acctDeleteTest = [SELECT Number_of_Cohorts__c FROM Account WHERE Id = :a.Id];
    //system.assertEquals(0, acctDeletesystem.test.Number_of_Cohorts__c);
  }
}
