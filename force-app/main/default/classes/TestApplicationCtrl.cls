@isTest
public class TestApplicationCtrl {
  static testMethod void testUAapps() {
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
      Status__c = 'Submitted',
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
      Organization_Name__c = 'Test',
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
      Status__c = 'Submitted',
      R1_First_Name__c = 'test',
      R1_Last_Name__c = 'test',
      R1_Email__c = 'test@test.com',
      R1_Phone__c = '5555555555',
      R1_Relationship__c = 'test',
      R2_First_Name__c = 'test',
      R2_Last_Name__c = 'test',
      R2_Email__c = 'test@test.com',
      R2_Phone__c = '5555555555',
      R2_Relationship__c = 'test',
      R3_First_Name__c = 'test',
      R3_Last_Name__c = 'test',
      R3_Email__c = 'test@test.com',
      R3_Phone__c = '5555555555',
      R3_Relationship__c = 'test'
    );
    insert app1;

    Application__c app2 = new Application__c(
      RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('UA Catalyst')
        .getRecordTypeId(),
      National_Organization_Id__c = a1.Id,
      Organization__c = a2.Id,
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
      Program_Contact_Last_Name__c = 'PC',
      Status__c = 'Submitted'
    );
    insert app2;

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

    system.Test.startTest();
    System.runAs(u1) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.NationalApplication')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      System.currentPageReference().getParameters().put('AccountId', a2.Id);
      NationalApplicationController controller1 = new NationalApplicationController();
      controller1.Submit();

      system.Test.setCurrentPageReference(
        new PageReference('Page.SubGrantApplication')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      System.currentPageReference().getParameters().put('AccountId', a2.Id);
      SubGrantApplicationController controller2 = new SubGrantApplicationController();
      controller2.Submit();

      system.Test.setCurrentPageReference(
        new PageReference('Page.UAApplicationList')
      );
      ApplicationListCtrl ctrl5 = new ApplicationListCtrl();
      List<SelectOption> list1 = ctrl5.getFilterByStatusOptions();
      List<SelectOption> list2 = ctrl5.getFilterByLocationOptions();
      ctrl5.getMap();
      //            ctrl5.getList();
    }

    System.runAs(u2) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.UAApplication')
      );
      System.currentPageReference().getParameters().put('AppId', app1.Id);
      UAApplicationCtrl ctrl3 = new UAApplicationCtrl();
      ctrl3.submit();
      ctrl3.scorePopup();
      ctrl3.scorePopup();
      ctrl3.score();
      ctrl3.awardPopup();
      ctrl3.awardPopup();
      ctrl3.award();
      ctrl3.notEligible();
      ctrl3.getGrantOptions();
      ctrl3.save();
      ctrl3.upsertGrant();
      ctrl3.showNotEligiblePopup();
      ctrl3.appType = 'freedom';
      ctrl3.fieldValidation();
      ctrl3.createReview();
      ctrl3.hideNotesPopup();

      system.Test.setCurrentPageReference(
        new PageReference('Page.UAApplication')
      );
      System.currentPageReference().getParameters().put('AppId', app2.Id);
      UAApplicationCtrl ctrl4 = new UAApplicationCtrl();
      ctrl4.award();
    }
    system.Test.stopTest();
  }

  static testMethod void testRipkenApps() {
    Date dt = Date.today();

    Account a1 = new Account(
      FirstPic_Org_Code__c = 'Ripken',
      EIN__c = '98-2183619',
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a1;

    Account a2 = new Account(
      FirstPic_Org_Code__c = 'Ripken',
      EIN__c = '98-1835629',
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    Contact c = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'ceo@ripken.com',
      accountId = a2.Id
    );
    insert c;

    ApplicationClass ac = new ApplicationClass();
    List<Application__c> app_list = ac.getApplicationList();

    Application__c app1 = new Application__c(
      RecordTypeID = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('Ripken Baseball')
        .getRecordTypeId(),
      National_Organization_Id__c = a1.Id,
      Organization__c = a2.Id,
      Organization_Name__c = 'Test',
      Status__c = 'Submitted',
      EIN__c = '98-1234567',
      Grant_Start_Date__c = dt,
      Grant_End_Date__c = dt.addDays(100),
      Unmet_Needs_will_be_Met_Score__c = '3',
      How_Story_will_be_Amplified_Score__c = '2',
      How_Program_will_be_Delivered_Score__c = '4',
      Example_of_Unsuccessful_Program_Score__c = '1',
      CEO_Email__c = 'ripkenceo@test.com',
      CEO_First_Name__c = 'Ripken',
      CEO_Last_Name__c = 'CEO',
      Program_Contact_Email__c = 'ripkenpc@test.com',
      Program_Contact_First_Name__c = 'Ripken',
      Program_Contact_Last_Name__c = 'PC',
      Grant_Admin_Email__c = 'ripkenga@test.com',
      Grant_Admin_First_Name__c = 'Ripken',
      Grant_Admin_Last_Name__c = 'GA',
      Finance_Admin_Email__c = 'ripkenfa@test.com',
      Finance_Admin_First_Name__c = 'Ripken',
      Finance_Admin_Last_Name__c = 'FA',
      Website__c = 'test',
      Phone__c = '3105555555',
      Address__c = 'test',
      City__c = 'test',
      State__c = 'California',
      Postal_Zip_Code__c = '90035',
      Total_Budget__c = 10000,
      Number_of_Sites__c = 10,
      Urban__c = 100,
      Type__c = 'Academic',
      Additional_Org_Classification__c = 'Youth Sports League',
      Mission_Statement__c = 'test',
      Number_of_Youth_Served_per_Year__c = 10,
      Min_Age_of_Youth__c = 5,
      Max_Age_of_Youth__c = 10,
      Percent_Eligible_Free_Reduced_Lunch__c = 10,
      Percent_Youth_in_Single_Parent_Homes__c = 10,
      Youth_Living_at_or_below_Poverty_Level__c = 10,
      Program_Number_of_Youth_Served__c = 10,
      Program_Min_Age_of_Youth__c = 5,
      Program_Max_Age_of_Youth__c = 10,
      Program_Percent_Male__c = 50,
      Program_Percent_Female__c = 50,
      Program_Number_of_Sites__c = 50,
      Program_Percent_Eligible_Reduced_Lunch__c = 10,
      Program_Percent_Youth_Single_Parent_Home__c = 10,
      Program_Percent_at_below_Poverty_Level__c = 10,
      Program_Number_of_Parent_in_Military__c = 10,
      Number_Participating_in_HCHC_Sessions__c = 10,
      Number_of_Staff_Instructors__c = 10,
      Healthy_Choices_Implementation_Plan__c = 'test',
      Timeline_for_Plans__c = 'test',
      Team_Sports_Implementation_Plan__c = 'test',
      School_Opening_and_Closing_Dates__c = 'test',
      Percent_Male__c = 10,
      Percent_Female__c = 10,
      Plan_to_Connect_Youth_with_Adult_Mentors__c = 'test',
      Orgs_Knowledge_of_Military__c = 'test',
      Additional_Information__c = 'test'
    );
    insert app1;

    Application__c app2 = new Application__c(
      RecordTypeID = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('Ripken Baseball')
        .getRecordTypeId(),
      National_Organization_Id__c = a1.Id,
      Organization_Name__c = 'New Site Test',
      Status__c = 'Submitted',
      EIN__c = '98-9283743',
      CEO_Email__c = 'ripkenceo@test.com',
      CEO_First_Name__c = 'Ripken',
      CEO_Last_Name__c = 'CEO'
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

    Profile p3 = [SELECT Id FROM Profile WHERE Name = 'Ripken Finance Admin'];
    Contact c3 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@ripken.com',
      accountId = a1.Id
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

    system.Test.startTest();
    System.runAs(u3) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.RipkenApplication')
      );
      System.currentPageReference().getParameters().put('appId', app1.Id);
      ApplicationCtrl ctrl6 = new ApplicationCtrl();
      ctrl6.submit();
      ctrl6.getAcct();
      ctrl6.getGrantOptions();
      ctrl6.sendBack();
      ctrl6.upsertGrant();
      ctrl6.showApprovePopup();
      ctrl6.hideApprovePopup();
      ctrl6.showNotEligiblePopup();
      ctrl6.showSendBackPopup();
      ctrl6.hideNotesPopup();
      ctrl6.award();
      ctrl6.deleteSites();

      ctrl6.notEligible();
      ctrl6.score();

      ctrl6.appType = 'New';
      ctrl6.getScoreTotals();

      ctrl6.appType = 'Existing';
      ctrl6.getScoreTotals();

      system.Test.setCurrentPageReference(
        new PageReference('Page.RipkenApplication')
      );
      System.currentPageReference().getParameters().put('appId', app2.Id);
      ApplicationCtrl ctrl7 = new ApplicationCtrl();
      ctrl7.portalName = 'Ripken';
      ctrl7.award();
      //            User u = [SELECT Alias, Profile.Name FROM User WHERE Id = :ctrl7.acct.OwnerId];
      //            system.assertEquals('System Administrator', u.Profile.Name);

      system.Test.setCurrentPageReference(
        new PageReference('Page.Applications')
      );
      ApplicationsCtrl ctrl9 = new ApplicationsCtrl();
      ctrl9.getSOIs();
      ctrl9.getApps();
      ctrl9.first();
      ctrl9.next();
      ctrl9.previous();
      ctrl9.last();
    }
    system.Test.stopTest();
  }

  static testMethod void testTRAILApps() {
    Date dt = Date.today();

    Account a1 = new Account(
      EIN__c = '98-2183619',
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a1;

    Account a2 = new Account(
      EIN__c = '98-1835629',
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    Account a3 = new Account(
      Local_Organization__c = a2.Id,
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert a3;

    ApplicationClass ac = new ApplicationClass();
    List<Application__c> app_list = ac.getApplicationList();

    Application__c app1 = new Application__c(
      RecordTypeID = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('Ripken Baseball')
        .getRecordTypeId(),
      National_Organization_Id__c = a1.Id,
      Organization__c = a2.Id,
      Organization_Name__c = 'Test',
      Status__c = 'Submitted',
      EIN__c = '98-1234567',
      Grant_Start_Date__c = dt,
      Grant_End_Date__c = dt.addDays(100),
      Unmet_Needs_will_be_Met_Score__c = '3',
      How_Story_will_be_Amplified_Score__c = '2',
      How_Program_will_be_Delivered_Score__c = '4',
      Example_of_Unsuccessful_Program_Score__c = '1',
      CEO_Email__c = 'ripkenceo@test.com',
      CEO_First_Name__c = 'Ripken',
      CEO_Last_Name__c = 'CEO',
      Program_Contact_Email__c = 'ripkenpc@test.com',
      Program_Contact_First_Name__c = 'Ripken',
      Program_Contact_Last_Name__c = 'PC',
      Grant_Admin_Email__c = 'ripkenga@test.com',
      Grant_Admin_First_Name__c = 'Ripken',
      Grant_Admin_Last_Name__c = 'GA',
      Finance_Admin_Email__c = 'ripkenfa@test.com',
      Finance_Admin_First_Name__c = 'Ripken',
      Finance_Admin_Last_Name__c = 'FA',
      Website__c = 'test',
      Phone__c = '3105555555',
      Address__c = 'test',
      City__c = 'test',
      State__c = 'California',
      Postal_Zip_Code__c = '90035',
      Total_Budget__c = 10000,
      Number_of_Sites__c = 10,
      Urban__c = 100,
      Type__c = 'Academic',
      Additional_Org_Classification__c = 'Youth Sports League',
      Mission_Statement__c = 'test',
      Number_of_Youth_Served_per_Year__c = 10,
      Min_Age_of_Youth__c = 5,
      Max_Age_of_Youth__c = 10,
      Percent_Eligible_Free_Reduced_Lunch__c = 10,
      Percent_Youth_in_Single_Parent_Homes__c = 10,
      Youth_Living_at_or_below_Poverty_Level__c = 10,
      Program_Number_of_Youth_Served__c = 10,
      Program_Min_Age_of_Youth__c = 5,
      Program_Max_Age_of_Youth__c = 10,
      Program_Percent_Male__c = 50,
      Program_Percent_Female__c = 50,
      Program_Number_of_Sites__c = 50,
      Program_Percent_Eligible_Reduced_Lunch__c = 10,
      Program_Percent_Youth_Single_Parent_Home__c = 10,
      Program_Percent_at_below_Poverty_Level__c = 10,
      Program_Number_of_Parent_in_Military__c = 10,
      Number_Participating_in_HCHC_Sessions__c = 10,
      Number_of_Staff_Instructors__c = 10,
      Healthy_Choices_Implementation_Plan__c = 'test',
      Timeline_for_Plans__c = 'test',
      Team_Sports_Implementation_Plan__c = 'test',
      School_Opening_and_Closing_Dates__c = 'test'
    );
    insert app1;

    Application_Site__c s = new Application_Site__c(
      Name = 'Test Site',
      Application__c = app1.Id,
      Is_Active__c = true
    );
    insert s;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level One'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@trail.com',
      accountId = a1.Id
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'test@sadfasd.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'asdf@trail.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    system.Test.startTest();
    System.runAs(u1) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.TRAILApplication')
      );
      System.currentPageReference().getParameters().put('appId', app1.Id);
      ApplicationCtrl ctrl1 = new ApplicationCtrl();
      ctrl1.portalName = 'TRAIL';
      ctrl1.getFields();
      ctrl1.addSite();
      ctrl1.save();
      ctrl1.createContacts();
      ctrl1.submit();
      ctrl1.getFieldsAndAtt();
      ctrl1.getTotal();
      ctrl1.approve();
      ctrl1.createReview();
      ctrl1.saveScore();
      ctrl1.ovcReviewValidation();
      ctrl1.awardOVC();
      ctrl1.trailFieldValidation();
      ctrl1.ovcFieldValidation();
      ctrl1.scorePopup();
      ctrl1.awardPopup();
      ctrl1.showAttPopup();
      ctrl1.hideAttPopup();
      ctrl1.showReviewNotesPopup();
      ctrl1.hideReviewNotesPopup();
    }
    system.Test.stopTest();
  }
}
