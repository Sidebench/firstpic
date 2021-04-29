@isTest
public class TestDashboards {
  static testMethod void test() {
    system.test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Grant__c g1 = new Grant__c(
      Account__c = a.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId(),
      Grant_Status__c = 'Pending First Approval'
    );
    insert g1;

    Grant__c g2 = new Grant__c(
      Account__c = a.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId(),
      Grant_Status__c = 'Pending Second Approval'
    );
    insert g2;

    Grant__c g3 = new Grant__c(
      Account__c = a.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId(),
      Grant_Status__c = 'Pending Third Approval'
    );
    insert g3;

    Reimbursement_Request__c rr1 = new Reimbursement_Request__c(
      Grant__c = g1.Id,
      Status__c = 'Pending First Approval'
    );
    insert rr1;

    Reimbursement_Request__c rr2 = new Reimbursement_Request__c(
      Grant__c = g1.Id,
      Status__c = 'Pending Second Approval'
    );
    insert rr2;

    Reimbursement_Request__c rr3 = new Reimbursement_Request__c(
      Grant__c = g1.Id,
      Status__c = 'Pending Third Approval'
    );
    insert rr3;

    Session_Report__c r1 = new Session_Report__c(Site__c = a.Id);
    insert r1;

    Session_Report__c r2 = new Session_Report__c(
      Site__c = a.Id,
      Status__c = 'Submitted'
    );
    insert r2;

    Progress_Report__c pg1 = new Progress_Report__c(
      Organization__c = a.Id,
      Grant__c = g1.Id,
      Status__c = 'Revisions Needed'
    );
    insert pg1;

    Progress_Report__c pg2 = new Progress_Report__c(
      Organization__c = a.Id,
      Grant__c = g1.Id,
      Status__c = 'Submitted'
    );
    insert pg2;

    Program_Report__c pr1 = new Program_Report__c(
      RecordTypeId = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
        .get('Monthly PA Logs')
        .getRecordTypeId(),
      Name = 'Test PA Logs',
      Grant__c = g1.Id,
      Site__c = a.Id,
      Status__c = 'Not Started'
    );
    insert pr1;

    Program_Report__c pr2 = new Program_Report__c(
      RecordTypeId = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
        .get('Monthly PA Logs')
        .getRecordTypeId(),
      Name = 'Test PA Logs',
      Grant__c = g1.Id,
      Site__c = a.Id,
      Status__c = 'Submitted'
    );
    insert pr2;

    Grantee_Report__c gr1 = new Grantee_Report__c(
      Grant__c = g1.Id,
      Report_Status__c = 'In Progress'
    );
    insert gr1;

    Grantee_Report__c gr2 = new Grantee_Report__c(
      Grant__c = g1.Id,
      Report_Status__c = 'Submitted'
    );
    insert gr2;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level One'];
    Contact c1 = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com'
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'test1@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'levelone@test1.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;
    System.runAs(u1) {
      system.test.setCurrentPageReference(new PageReference('Page.Dashboard'));
      DashboardCtrl ctrl1 = new DashboardCtrl();
      ctrl1.getLists();
    }

    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Two'];
    Contact c2 = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'Test2',
      Email = 'newtest2@example.com'
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
      UserName = 'leveltwo@test2.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;
    System.runAs(u2) {
      system.test.setCurrentPageReference(new PageReference('Page.Dashboard'));
      DashboardCtrl ctrl2 = new DashboardCtrl();
      ctrl2.getLists();
    }

    Profile p3 = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Three'];
    Contact c3 = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'Test3',
      Email = 'newtest3@example.com'
    );
    insert c3;
    User u3 = new User(
      Alias = 'testu',
      Email = 'test3@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test3',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p3.Id,
      UserName = 'levelthree@test1.com',
      Contact = c3,
      ContactId = c3.Id
    );
    insert u3;
    System.runAs(u3) {
      system.test.setCurrentPageReference(new PageReference('Page.Dashboard'));
      DashboardCtrl ctrl3 = new DashboardCtrl();
      ctrl3.init();
      ctrl3.getLists();
    }

    system.test.stopTest();
  }
}
