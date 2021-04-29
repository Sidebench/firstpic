@isTest
public class TestMiscLEGOControllers {
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
        .get('Site')
        .getRecordTypeId()
    );
    insert a2;

    Session__c season = new Session__c(
      Name = 'Test season',
      Is_Active__c = true,
      Site__c = a2.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Season')
        .getRecordTypeId()
    );
    insert season;

    Session__c s = new Session__c(
      Name = 'Test Session',
      Season__c = season.Id,
      Is_Active__c = true,
      Site__c = a2.Id,
      Finance_Report_Status__c = 'Not Started',
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Session')
        .getRecordTypeId()
    );
    insert s;

    Session__c c = new Session__c(
      Name = 'Test Cohort',
      Is_Active__c = true,
      Site__c = a2.Id,
      Session__c = s.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Cohort')
        .getRecordTypeId()
    );
    insert c;

    Session__c m = new Session__c(
      Name = 'Test Meeting',
      Is_Active__c = true,
      Site__c = a2.Id,
      Session__c = s.Id,
      Cohort__c = c.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Meeting')
        .getRecordTypeId()
    );
    insert m;

    Session_Report__c r = new Session_Report__c(
      Session__c = season.Id,
      Site__c = a2.Id
    );
    insert r;

    Contact youth = new Contact(
      accountId = a2.Id,
      lastName = 'youth',
      firstName = 'Test',
      Cohort__c = c.Id
    );
    insert youth;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'FLL JR Admin'];
    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'LEGO Community Login'];
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
      accountId = a2.Id,
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

    System.runAs(u1) {
      system.test.setCurrentPageReference(
        new PageReference('Page.LEGODashboard')
      );
      LEGODashboardCtrl db1 = new LEGODashboardCtrl();
      List<AggregateResult> list1 = db1.youthByRace;

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOFinanceReport?SiteId=' + a2.Id)
      );
      LEGOFinanceReportCtrl ctrl2 = new LEGOFinanceReportCtrl();
      ctrl2.save();
      ctrl2.sendBack();
      ctrl2.submit();
      ctrl2.attPopup();
      ctrl2.closeAttPopup();
      ctrl2.deleteAtt();

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOProgramReport?ReportId=' + r.Id)
      );
      LEGOProgramReportCtrl ctrl3 = new LEGOProgramReportCtrl();
      ctrl3.save();
      ctrl3.sendBack();
      ctrl3.submit();
      ctrl3.attPopup();
      ctrl3.closeAttPopup();
      ctrl3.deleteAtt();

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOExpoReport?SessionId=' + s.Id)
      );
      LEGOExpoReportCtrl ctrl4 = new LEGOExpoReportCtrl();
      ctrl4.save();
      ctrl4.sendBack();
      ctrl4.submit();
      ctrl4.attPopup();
      ctrl4.closeAttPopup();
      ctrl4.deleteAtt();
    }

    System.runAs(u2) {
      system.test.setCurrentPageReference(
        new PageReference('Page.LEGODashboard')
      );
      LEGODashboardCtrl db2 = new LEGODashboardCtrl();
      List<AggregateResult> list2 = db2.youthByRace;

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOFinanceReport')
      );
      LEGOFinanceReportCtrl ctrl5 = new LEGOFinanceReportCtrl();
      ctrl5.save();
      ctrl5.sendBack();
      ctrl5.submit();
      ctrl5.attPopup();
      ctrl5.closeAttPopup();
      ctrl5.deleteAtt();

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOProgramReport')
      );
      LEGOProgramReportCtrl ctrl6 = new LEGOProgramReportCtrl();
      ctrl6.save();
      ctrl6.sendBack();
      ctrl6.submit();
      ctrl6.attPopup();
      ctrl6.closeAttPopup();
      ctrl6.deleteAtt();

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOExpoReport')
      );
      LEGOExpoReportCtrl ctrl7 = new LEGOExpoReportCtrl();
      ctrl7.save();
      ctrl7.sendBack();
      ctrl7.submit();
      ctrl7.attPopup();
      //ctrl7.closeAttPopup();
      //ctrl7.deleteAtt();
    }
    system.test.stopTest();
  }
}
