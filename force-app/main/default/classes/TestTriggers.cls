@istest
class TestTriggers {
  /*
    static testmethod void test() {
system.Test.startTest();
        
        Account a = new Account();
        a.Name = 'Today Test';
        insert a;
        
        Contact c = new Contact(
            accountId = a.Id
            ,lastName = 'Contact'
            ,firstName = 'Test1'
            ,Email = 'newtest1@example.com'
        );
        insert c;
        
        Session__c s = new Session__c(
            Name = 'Test Session'
            ,Site__c = a.Id
            ,RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName().get('Session').getRecordTypeId()
        );
        insert s;
        
        Session__c co = new Session__c(
            Name = 'Test Cohort'
            ,Site__c = a.Id
            ,Session__c = s.Id
            ,RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName().get('Cohort').getRecordTypeId()
        );
        insert co;
        
        c.Cohort__c = co.Id;
        update c;
        delete c;
            
        Decimal d = 0;
        Account[] accts = [SELECT Number_of_Cohorts__c FROM Account WHERE Id = :a.Id];
        if(accts.size() > 0) {
            d = accts[0].Number_of_Cohorts__c;
        }
        system.debug('decimal = ' + d);
        //System.assertEquals(1, d);
        
        // Schedule the test job
        String jobId = System.schedule('testBasicScheduledApex', DailyDateUpdate.CRON_EXP, new DailyDateUpdate());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(DailyDateUpdate.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        Date dt = date.today();
        Date t = dt.addDays(1);
        System.assertEquals(string.valueOf(t) + ' 00:00:00', String.valueOf(ct.NextFireTime));
        System.assertNotEquals(dt,
                               [SELECT id, Today__c FROM account WHERE id = :a.id].Today__c);
        
        system.Test.stopTest();
        
        System.assertEquals(dt,
                            [SELECT Id, Today__c FROM Account WHERE Id = :a.Id].Today__c);
        
    }
	*/
}
