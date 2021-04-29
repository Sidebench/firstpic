@isTest
class TestContactTriggers {
  static testMethod void testContactPreventDuplicate() {
    system.Test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Contact c1 = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'test1@test.com'
    );
    insert c1;

    Contact c2 = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'Test2',
      Email = 'test1@test.com'
    );

    try {
      insert c2;
    } catch (Exception e) {
      System.assert(
        e.getDmlMessage(0)
          .indexOf('There is already another Contact with the same Email.') > -1
      );
    }
    system.Test.stopTest();
  }

  static testMethod void testUpdateAccoutLookups() {
    system.Test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Name = 'Test Grant',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g;

    Document__c d = new Document__c(Name = 'Test Doc', Organization__c = a.Id);
    insert d;

    Contact ceo = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'CEO',
      Email = 'ceo@test.com',
      Role__c = 'CEO'
    );
    insert ceo;

    Contact fl = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'FL',
      Email = 'fl@test.com',
      Role__c = 'Finance Lead'
    );
    insert fl;

    Contact pc = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'PC',
      Email = 'pc@test.com',
      Role__c = 'Program Coordinator'
    );
    insert pc;

    // Test INSERT
    Account insertTest = [
      SELECT CEO__c, CEO_Email__c, Finance_Lead__c
      FROM Account
      WHERE Id = :a.Id
    ];
    system.assertEquals(ceo.Id, insertTest.CEO__c);
    system.assertEquals(ceo.Email, insertTest.CEO_Email__c);
    system.assertEquals(fl.Id, insertTest.Finance_Lead__c);

    Grant__c grant = [SELECT CEO_Email__c FROM Grant__c WHERE Id = :g.Id];
    system.assertEquals(ceo.Email, grant.CEO_Email__c);

    Document__c d1 = [SELECT CEO_Email__c FROM Document__c WHERE Id = :d.Id];
    system.assertEquals(a.CEO_Email__c, d1.CEO_Email__c);

    ceo.Role__c = null;
    update ceo;
    fl.Role__c = 'CEO';
    update fl;

    Account updateTest = [
      SELECT CEO__c, Finance_Lead__c, Program_Coordinator__c
      FROM Account
      WHERE Id = :a.Id
    ];
    system.assertEquals(fl.Id, updateTest.CEO__c);

    pc.Email = 'pc@update.com';
    update pc;

    Account emailTest = [
      SELECT Program_Coordinator_Email__c
      FROM Account
      WHERE Id = :a.Id
    ];
    system.assertEquals(pc.Email, emailTest.Program_Coordinator_Email__c);

    system.Test.stopTest();
  }

  static testMethod void testUpdateCount() {
    system.Test.startTest();

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
      Site__c = a.Id,
      Session__c = session.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Cohort')
        .getRecordTypeId()
    );
    insert cohort;

    Contact youth1 = new Contact(
      accountId = a.Id,
      Cohort__c = cohort.Id,
      lastName = 'Youth',
      firstName = 'Test1',
      Email = 'youth1@test.com',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Youth')
        .getRecordTypeId()
    );
    insert youth1;

    Contact youth2 = new Contact(
      lastName = 'Youth',
      firstName = 'Test1',
      Email = 'youth2@test.com',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Youth')
        .getRecordTypeId()
    );
    insert youth2;

    // Test INSERT
    Account acctInsertTest = [
      SELECT Youth_Served__c
      FROM Account
      WHERE Id = :a.Id
    ];
    //system.assertEquals(1, acctInsertTest.Youth_Served__c);

    Session__c cohortInsertTest = [
      SELECT Cohort_Size__c
      FROM Session__c
      WHERE Id = :cohort.Id
    ];
    //system.assertEquals(1, cohortInsertTest.Cohort_Size__c);

    // Test UPDATE
    youth2.AccountId = a.Id;
    youth2.Cohort__c = cohort.Id;
    update youth2;

    Account acctUpdateTest = [
      SELECT Youth_Served__c
      FROM Account
      WHERE Id = :a.Id
    ];
    //system.assertEquals(2, acctUpdateTest.Youth_Served__c);

    Session__c cohortUpdateTest = [
      SELECT Cohort_Size__c
      FROM Session__c
      WHERE Id = :cohort.Id
    ];
    //system.assertEquals(2, cohortUpdateTest.Cohort_Size__c);
    system.Test.stopTest();
  }

  static testMethod void testUpdatePAEmailFields() {
    system.Test.startTest();

    Account na = new Account(Name = 'Test National Account');
    insert na;

    Account a = new Account(Name = 'Test Account');
    insert a;

    Application__c app = new Application__c(
      Organization__c = a.Id,
      National_Organization__c = na.id
    );
    insert app;
    Application__c app1 = [
      SELECT Primary_Approver_Email__c
      FROM Application__c
      WHERE Id = :app.Id
    ];
    system.assertEquals(null, app1.Primary_Approver_Email__c);

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Name = 'Test Grant',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g;
    Grant__c g1 = [
      SELECT Primary_Approver_Email__c
      FROM Grant__c
      WHERE Id = :g.Id
    ];
    system.assertEquals(null, g1.Primary_Approver_Email__c);

    Reimbursement_Request__c r = new Reimbursement_Request__c(Grant__c = g.Id);
    insert r;
    Reimbursement_Request__c r1 = [
      SELECT Primary_Approver_Email__c
      FROM Reimbursement_Request__c
      WHERE Id = :r.Id
    ];
    system.assertEquals(null, r1.Primary_Approver_Email__c);

    Grantee_Report__c gr = new Grantee_Report__c(Grant__c = g.Id);
    insert gr;
    Grantee_Report__c gr1 = [
      SELECT Primary_Approver_Email__c
      FROM Grantee_Report__c
      WHERE Id = :gr.Id
    ];
    system.assertEquals(null, gr1.Primary_Approver_Email__c);

    Contact pa = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'PA',
      Email = 'pa@test.com',
      Role__c = 'Primary Approver',
      Is_Primary_Approver__c = true
    );
    insert pa;
    /*
        Application__c app2 = [SELECT Primary_Approver_Email__c FROM Application__c WHERE Id = :app.Id];
        system.assertEquals('pa@test.com', app2.Primary_Approver_Email__c);
        Grant__c g2 = [SELECT Primary_Approver_Email__c FROM Grant__c WHERE Id = :g.Id];
        system.assertEquals('pa@test.com', g2.Primary_Approver_Email__c);
        Reimbursement_Request__c r2 = [SELECT Primary_Approver_Email__c FROM Reimbursement_Request__c WHERE Id = :r.Id];
        system.assertEquals('pa@test.com', r2.Primary_Approver_Email__c);
        Grantee_Report__c gr2 = [SELECT Primary_Approver_Email__c FROM Grantee_Report__c WHERE Id = :gr.Id];
        system.assertEquals('pa@test.com', gr2.Primary_Approver_Email__c);
    	*/
    pa.Email = 'pa@update.com';
    update pa;
    /*
        Application__c app3 = [SELECT Primary_Approver_Email__c FROM Application__c WHERE Id = :app.Id];
        system.assertEquals('pa@update.com', app3.Primary_Approver_Email__c);
        Grant__c g3 = [SELECT Primary_Approver_Email__c FROM Grant__c WHERE Id = :g.Id];
        system.assertEquals('pa@update.com', g3.Primary_Approver_Email__c);
        Reimbursement_Request__c r3 = [SELECT Primary_Approver_Email__c FROM Reimbursement_Request__c WHERE Id = :r.Id];
        system.assertEquals('pa@update.com', r3.Primary_Approver_Email__c);
        Grantee_Report__c gr3 = [SELECT Primary_Approver_Email__c FROM Grantee_Report__c WHERE Id = :gr.Id];
        system.assertEquals('pa@update.com', gr3.Primary_Approver_Email__c);
        */
    system.Test.stopTest();
  }
}
