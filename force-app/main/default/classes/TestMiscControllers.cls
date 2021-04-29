@isTest
public class TestMiscControllers {
  static testMethod void test1() {
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

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level One'];
    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Two'];
    Profile p3 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
    Profile p4 = [SELECT Id FROM Profile WHERE Name = 'BBBS Program User'];
    Profile p5 = [SELECT Id FROM Profile WHERE Name = 'BBBS Finance User'];
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
      Email = 'test3@asdfajd.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test3',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p4.Id,
      UserName = 'test4@ajen.com',
      Contact = c4,
      ContactId = c4.Id
    );
    insert u4;

    Contact c5 = new Contact(
      accountId = a2.Id,
      lastName = 'Contact',
      firstName = 'Test5',
      Email = 'newtest5@example.com',
      Role__c = 'Finance Lead'
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
      UserName = 'test5@ajen.com',
      Contact = c5,
      ContactId = c5.Id
    );
    insert u5;

    a2.CEO__c = c2.Id;
    a2.Finance_Lead__c = c3.Id;
    update a2;

    system.Test.startTest();
    System.runAs(u4) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.AttachmentUpload')
      );
      AttachmentUploadController ctrl1 = new AttachmentUploadController();
      System.currentPageReference().getParameters().put('filename', 'test');
      ctrl1.filename = 'test';
      ctrl1.att.Body = Blob.valueOf('Unit Test Attachment Body');
      ctrl1.contentType = 'application/pdf';
      ctrl1.ProcessAttachment();

      system.Test.setCurrentPageReference(new PageReference('Page.BBBSError'));
      BBBSErrorController ctrl3 = new BBBSErrorController();
      ctrl3.subject = 'test email';
      ctrl3.body = 'test email body';
      //ctrl3.send();

      system.Test.setCurrentPageReference(new PageReference('Page.BBBSHelp'));
      BBBSHelpController ctrl4 = new BBBSHelpController();

      system.Test.setCurrentPageReference(
        new PageReference('Page.NationalOrganizationsTab')
      );
      AccountListViewController ctrl5 = new AccountListViewController();
      ctrl5.listName = 'NationalOrganizations';
      //System.assert(ctrl5.listId != null);

      system.Test.setCurrentPageReference(
        new PageReference('Page.LocalOrganizationsTab')
      );
      AccountListViewController ctrl6 = new AccountListViewController();
      ctrl6.listName = 'Local Organizations';

      system.Test.setCurrentPageReference(new PageReference('Page.NPALHelp'));
      GetUserAcctCtrl ctrl7 = new GetUserAcctCtrl();

      system.Test.setCurrentPageReference(
        new PageReference('Page.BBBSDashboard')
      );
      BBBSDashboardCtrl db4 = new BBBSDashboardCtrl();
      db4.init();
      db4.getLists();
      //List<AggregateResult> list1 = db1.grantsByStatus;
      //List<AggregateResult> list2 = db1.grantsByAmount;
      //List<AggregateResult> list3 = db1.requestsByAmount;
      List<AggregateResult> list4 = db4.requestsByStatus;

      system.Test.setCurrentPageReference(
        new PageReference('Page.UADashboard')
      );
      UADashboardCtrl db9 = new UADashboardCtrl();
    }
    System.runAs(u1) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.BBBSDashboard')
      );
      BBBSDashboardCtrl db1 = new BBBSDashboardCtrl();
      db1.getLists();
    }
    System.runAs(u2) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.BBBSDashboard')
      );
      BBBSDashboardCtrl db2 = new BBBSDashboardCtrl();
      db2.getLists();
    }
    System.runAs(u3) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.BBBSDashboard')
      );
      BBBSDashboardCtrl db3 = new BBBSDashboardCtrl();
      db3.getLists();
    }
    System.runAs(u5) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.BBBSDashboard')
      );
      BBBSDashboardCtrl db5 = new BBBSDashboardCtrl();
      db5.getLists();
    }

    system.Test.stopTest();
  }
}
