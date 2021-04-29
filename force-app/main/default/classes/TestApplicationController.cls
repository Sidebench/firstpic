@isTest
public class TestApplicationController {
  static testMethod void test1() {
    Date dt = Date.today();

    Account a1 = new Account(
      FirstPic_Org_Code__c = 'UA',
      EIN__c = '98-7654321',
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a1;

    Account a2 = new Account(
      EIN__c = '98-1234567',
      Name = 'Name',
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
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    ApplicationClass ac = new ApplicationClass();
    List<Application__c> app_list = ac.getApplicationList();

    Application__c app1 = new Application__c(
      National_Organization_Id__c = a1.Id,
      EIN__c = '98-1234567',
      Grant_Start_Date__c = dt,
      Grant_End_Date__c = dt.addDays(100),
      Unmet_Needs_will_be_Met_Score__c = '3',
      How_Story_will_be_Amplified_Score__c = '2',
      How_Program_will_be_Delivered_Score__c = '4',
      Example_of_Unsuccessful_Program_Score__c = '1',
      CEO_Email__c = 'uaceo@test.com',
      CEO_First_Name__c = 'UA',
      CEO_Last_Name__c = 'CEO',
      Program_Contact_Email__c = 'uapc@test.com',
      Program_Contact_First_Name__c = 'UA',
      Program_Contact_Last_Name__c = 'PC',
      Grant_Admin_Email__c = 'uaga@test.com',
      Grant_Admin_First_Name__c = 'UA',
      Grant_Admin_Last_Name__c = 'GA',
      Finance_Admin_Email__c = 'uafa@test.com',
      Finance_Admin_First_Name__c = 'UA',
      Finance_Admin_Last_Name__c = 'FA'
    );
    insert app1;

    Application__c app2 = new Application__c(
      National_Organization_Id__c = a1.Id,
      EIN__c = '98-7654321',
      Grant_Start_Date__c = dt,
      Grant_End_Date__c = dt.addDays(100),
      Unmet_Needs_will_be_Met_Score__c = '3',
      How_Story_will_be_Amplified_Score__c = '2',
      How_Program_will_be_Delivered_Score__c = '4',
      Example_of_Unsuccessful_Program_Score__c = '1',
      CEO_Email__c = 'uaceo@test.com',
      CEO_First_Name__c = 'UA',
      CEO_Last_Name__c = 'CEO',
      Program_Contact_Email__c = 'uapc@test.com',
      Program_Contact_First_Name__c = 'UA',
      Program_Contact_Last_Name__c = 'PC'
    );
    insert app2;

    List<Application__c> apps = new List<Application__c>();
    for (Integer i = 0; i < 50; i++) {
      Application__c a = new Application__c(
        RecordTypeID = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
          .get('Ripken Baseball')
          .getRecordTypeId(),
        National_Organization__c = a1.Id
      );
      apps.add(a);
    }
    insert apps;

    Grant__c g = new Grant__c(
      Account__c = a2.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt
    );
    insert g;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'BBBS Finance User'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@commlogin.com',
      accountId = a2.Id
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'test@community.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'UA Admin'];
    Contact c2 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@UAAdmin.com',
      accountId = a2.Id
    );
    insert c2;
    User u2 = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p2.Id,
      UserName = 'test@UAAdmin.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;

    Profile p3 = [SELECT Id FROM Profile WHERE Name = 'Ripken Finance Admin'];
    Contact c3 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@ripken.com',
      accountId = a2.Id
    );
    insert c3;
    User u3 = new User(
      Alias = 'testu',
      Email = 'test@sadfasd.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p3.Id,
      UserName = 'asdf@ripken.com',
      Contact = c3,
      ContactId = c3.Id
    );
    insert u3;

    System.runAs(u1) {
      Test.setCurrentPageReference(
        new PageReference('Page.NationalApplication')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      System.currentPageReference().getParameters().put('AccountId', a2.Id);
      NationalApplicationController controller1 = new NationalApplicationController();
      controller1.Submit();

      Test.setCurrentPageReference(
        new PageReference('Page.SubGrantApplication')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      System.currentPageReference().getParameters().put('AccountId', a2.Id);
      SubGrantApplicationController controller2 = new SubGrantApplicationController();
      controller2.Submit();
    }

    System.runAs(u2) {
      Test.setCurrentPageReference(new PageReference('Page.UAApplication'));
      System.currentPageReference().getParameters().put('AppId', app1.Id);
      ApplicationCtrl ctrl3 = new ApplicationCtrl();
      ctrl3.submit();
      ctrl3.scorePopup();
      ctrl3.scorePopup();
      ctrl3.score();
      ctrl3.awardPopup();
      ctrl3.awardPopup();
      ctrl3.award();
      ctrl3.notEligible();

      Test.setCurrentPageReference(new PageReference('Page.UAApplication'));
      System.currentPageReference().getParameters().put('AppId', app2.Id);
      ApplicationCtrl ctrl4 = new ApplicationCtrl();
      ctrl4.award();

      Test.setCurrentPageReference(new PageReference('Page.UAApplicationList'));
      ApplicationListCtrl ctrl5 = new ApplicationListCtrl();
      List<SelectOption> list1 = ctrl5.getFilterByStatusOptions();
      List<SelectOption> list2 = ctrl5.getFilterByLocationOptions();
      ctrl5.getMap();
      ctrl5.getList();
    }

    System.runAs(u3) {
      Test.setCurrentPageReference(new PageReference('Page.RipkenApplication'));
      System.currentPageReference().getParameters().put('appId', app1.Id);
      ApplicationCtrl ctrl6 = new ApplicationCtrl();
      ctrl6.getAcct();
      ctrl6.getGrantOptions();
      ctrl6.sendBack();
      ctrl6.upsertGrant();
      ctrl6.showApprovePopup();
      ctrl6.hideApprovePopup();
      ctrl6.showNotEligiblePopup();
      ctrl6.showSendBackPopup();
      ctrl6.hideNotesPopup();

      Test.setCurrentPageReference(new PageReference('Page.Applications'));
      ApplicationsCtrl ctrl7 = new ApplicationsCtrl();
      ctrl7.next();
      ctrl7.previous();
      ctrl7.last();
    }
  }
}
