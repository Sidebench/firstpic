@isTest
public class TestNPALDashboardControllers {
  static testMethod void test1() {
    system.test.startTest();
    Date dt = Date.today();

    Account a1 = new Account(
      EIN__c = '98-7654321',
      Name = 'Name',
      Status__c = 'Approved',
      Insurance_Provider__c = 'test',
      Insurance_Expiration_Date__c = dt,
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a1;

    Account a2 = new Account(
      EIN__c = '12-2938475',
      National_Organization__c = a1.Id,
      Name = 'Local Name',
      Status__c = 'Application Submitted',
      Application_Submitted_Date__c = dt,
      Phone = '5555555555',
      BillingStreet = 'Street',
      BillingCity = 'City',
      BillingState = 'CA',
      BillingPostalCode = '12345',
      Youth_Served__c = 100,
      Number_of_Mentors__c = 10,
      Number_of_Sites__c = 10,
      Names_of_Sites__c = 'Names of Sites',
      Insurance_Expiration_Date__c = date.today(),
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    Grant__c grant = new Grant__c(
      Account__c = a1.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt
    );
    insert grant;

    Grant__c subgrant = new Grant__c(
      Account__c = a1.Id,
      National_Grant__c = grant.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt
    );
    insert subgrant;

    Budget_Item__c bi1 = new Budget_Item__c(
      Grant__c = grant.Id,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = true
    );
    insert bi1;

    Reimbursement_Request__c r = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt,
      Status__c = 'Incomplete',
      Total_FTE_at_Affiliate__c = 50,
      Approved_Amount__c = 10000
    );
    insert r;

    Reimbursement_Request__c r2 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt,
      Status__c = 'Pending First Approval'
    );
    insert r2;

    Reimbursement_Request__c r3 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt,
      Status__c = 'Pending Second Approval'
    );
    insert r3;

    Reimbursement_Request__c r4 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt,
      Status__c = 'Pending Final Approval'
    );
    insert r4;

    Reimbursement_Request__c r5 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt,
      Status__c = 'Revisions Needed'
    );
    insert r5;

    Reimbursement_Request__c r6 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt,
      Status__c = 'Denied'
    );
    insert r6;

    Reimbursement_Item__c ri1 = new Reimbursement_Item__c(
      Reimbursement_Request__c = r.Id,
      Budget_Item__c = bi1.Id,
      Quantity__c = 100,
      Rate__c = 10,
      Percent_Towards_Grant__c = .50,
      Requested_Amount__c = 1000
    );
    insert ri1;

    Grantee_Report__c gr = new Grantee_Report__c(
      Grant__c = grant.Id,
      Report_Status__c = 'In Progress'
    );
    insert gr;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'NPAL Level One'];
    Contact c1 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com'
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'levelthree@test1.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'NPAL Level Two'];
    Contact c2 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test2',
      Email = 'newtest2@example.com',
      Role__c = 'CEO'
    );
    insert c2;
    User u2 = new User(
      Alias = 'testu',
      Email = 'test2@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test2',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p2.Id,
      UserName = 'test2@asldkjfa.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;

    Profile p3 = [SELECT Id FROM Profile WHERE Name = 'NPAL Level Three'];
    Contact c3 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test3',
      Email = 'newtest3@example.com',
      Role__c = 'Finance Lead'
    );
    insert c3;
    User u3 = new User(
      Alias = 'testu',
      Email = 'test3@asdfajd.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test3',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p3.Id,
      UserName = 'test3@aoiadnoiw.com',
      Contact = c3,
      ContactId = c3.Id
    );
    insert u3;

    Profile p4 = [SELECT Id FROM Profile WHERE Name = 'PAL Community Login'];
    Contact c4 = new Contact(
      accountId = a2.Id,
      lastName = 'Contact',
      firstName = 'Test4',
      Email = 'newtest4@example.com',
      Role__c = 'Finance Lead'
    );
    insert c4;
    User u4 = new User(
      Alias = 'testu',
      Email = 'test4@asdfajd.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test4',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p4.Id,
      UserName = 'test4@ajen.com',
      Contact = c4,
      ContactId = c4.Id
    );
    insert u4;

    Profile p5 = [SELECT Id FROM Profile WHERE Name = 'NPAL Report Builder'];
    Contact c5 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test5',
      Email = 'newtest5@example.com'
    );
    insert c5;
    User u5 = new User(
      Alias = 'testu',
      Email = 'test5@asdfajd.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test5',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p5.Id,
      UserName = 'test5@asdfadf.com',
      Contact = c5,
      ContactId = c5.Id
    );
    insert u5;

    Profile p6 = [SELECT Id FROM Profile WHERE Name = 'DMV Level One'];
    Contact c6 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test6',
      Email = 'newtest6@example.com'
    );
    insert c6;
    User u6 = new User(
      Alias = 'testu',
      Email = 'test6@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test6',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p6.Id,
      UserName = 'levelthree@test6.com',
      Contact = c6,
      ContactId = c6.Id
    );
    insert u6;

    System.runAs(u1) {
      system.test.setCurrentPageReference(
        new PageReference('Page.NPALDashboard')
      );
      NPALDashboardCtrl db1 = new NPALDashboardCtrl();
      db1.getLists();
    }
    System.runAs(u2) {
      system.test.setCurrentPageReference(
        new PageReference('Page.NPALDashboard')
      );
      NPALDashboardCtrl db2 = new NPALDashboardCtrl();
      db2.getLists();
    }
    System.runAs(u3) {
      system.test.setCurrentPageReference(
        new PageReference('Page.NPALDashboard')
      );
      NPALDashboardCtrl db3 = new NPALDashboardCtrl();
      db3.getLists();
    }
    System.runAs(u4) {
      system.test.setCurrentPageReference(
        new PageReference('Page.NPALDashboard')
      );
      NPALDashboardCtrl db4 = new NPALDashboardCtrl();
      db4.getLists();
    }
    System.runAs(u5) {
      system.test.setCurrentPageReference(
        new PageReference('Page.NPALDashboard')
      );
      NPALDashboardCtrl db5 = new NPALDashboardCtrl();
      db5.init();
      db5.getLists();
      db5.getOverdueInfo();
    }
    System.runAs(u6) {
      system.test.setCurrentPageReference(
        new PageReference('Page.DMVDashboard')
      );
      DMVDashboardCtrl db6 = new DMVDashboardCtrl();
      db6.init();
      db6.getLists();
    }

    system.test.stopTest();
  }
}
