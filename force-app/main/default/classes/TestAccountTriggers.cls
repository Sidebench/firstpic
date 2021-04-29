@isTest
class TestAccountTriggers {
  static testMethod void testAccountUpdateDate() {
    System.Test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    // Schedule the test job
    String jobId = System.schedule(
      'testBasicScheduledApex',
      AccountUpdateDate.CRON_EXP,
      new AccountUpdateDate()
    );

    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];

    // Verify the expressions are the same
    System.assertEquals(AccountUpdateDate.CRON_EXP, ct.CronExpression);

    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);

    // Verify the next time the job will run
    Date dt = date.today();
    Date t = dt.addDays(1);
    System.assertEquals(
      string.valueOf(t) + ' 00:00:00',
      String.valueOf(ct.NextFireTime)
    );
    System.assertNotEquals(
      dt,
      [SELECT id, Today__c FROM account WHERE id = :a.id]
      .Today__c
    );

    System.Test.stopTest();

    System.assertEquals(
      dt,
      [SELECT Id, Today__c FROM Account WHERE Id = :a.Id]
      .Today__c
    );
  }

  static testMethod void testUpdateAccountContacts() {
    system.Test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Account a2 = new Account(Name = 'Test Site', Local_Organization__c = a.id);
    insert a2;

    Assessment__c ass = new Assessment__c(Organization__c = a.Id);
    insert ass;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Name = 'Test Grant',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g;

    Reimbursement_Request__c r = new Reimbursement_Request__c(Grant__c = g.Id);
    insert r;

    Program_Report__c pm = new Program_Report__c(Site__c = a2.Id);
    insert pm;

    Progress_Report__c ps = new Progress_Report__c(
      Organization__c = a2.Id,
      Grant__c = g.Id
    );
    insert ps;

    Session_Report__c ses = new Session_Report__c(Site__c = a2.Id);
    insert ses;

    Grantee_Report__c gr = new Grantee_Report__c(
      Organization__c = a.Id,
      Grant__c = g.Id
    );
    insert gr;

    Contact ceo = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'CEO',
      Email = 'ceo@test.com',
      Role__c = 'CEO'
    );
    insert ceo;

    Assessment__c ass2 = [SELECT CEO__c FROM Assessment__c WHERE Id = :ass.Id];
    system.assertEquals(ceo.id, ass2.CEO__c);
    Grant__c g2 = [SELECT CEO__c, CEO_Email__c FROM Grant__c WHERE Id = :g.Id];
    system.assertEquals(ceo.id, g2.CEO__c);
    system.assertEquals('ceo@test.com', g2.CEO_Email__c);
    Reimbursement_Request__c r2 = [
      SELECT CEO__c, CEO_Email__c
      FROM Reimbursement_Request__c
      WHERE Id = :r.Id
    ];
    system.assertEquals(ceo.id, r2.CEO__c);
    system.assertEquals('ceo@test.com', r2.CEO_Email__c);
    Program_Report__c pm2 = [
      SELECT CEO__c, CEO_Email__c
      FROM Program_Report__c
      WHERE Id = :pm.Id
    ];
    system.assertEquals(ceo.id, pm2.CEO__c);
    system.assertEquals('ceo@test.com', pm2.CEO_Email__c);
    Progress_Report__c ps2 = [
      SELECT CEO__c, CEO_Email__c
      FROM Progress_Report__c
      WHERE Id = :ps.Id
    ];
    system.assertEquals(ceo.id, ps2.CEO__c);
    system.assertEquals('ceo@test.com', ps2.CEO_Email__c);
    Grantee_Report__c gr2 = [
      SELECT CEO__c, CEO_Email__c
      FROM Grantee_Report__c
      WHERE Id = :gr.Id
    ];
    system.assertEquals(ceo.id, gr2.CEO__c);
    system.assertEquals('ceo@test.com', gr2.CEO_Email__c);

    system.Test.stopTest();
  }
}
