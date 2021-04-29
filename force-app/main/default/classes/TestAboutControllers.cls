@isTest
public class TestAboutControllers {
  static testMethod void test1() {
    Date dt = Date.today();

    Account a1 = new Account(
      EIN__c = '98-7654321',
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
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a1;

    Account a2 = new Account(
      EIN__c = '98-2837563',
      National_Organization__c = a1.Id,
      Name = 'Local Test',
      Status__c = 'Application Submitted',
      Application_Submitted_Date__c = dt,
      Phone = '12345678980',
      BillingStreet = 'Street',
      BillingCity = 'City',
      BillingState = 'CA',
      BillingPostalCode = '54321',
      Youth_Served__c = 100,
      Number_of_Mentors__c = 10,
      Number_of_Sites__c = 10,
      Names_of_Sites__c = 'Names of Sites',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    Session__c s = new Session__c(
      Name = 'Test Session',
      Is_Active__c = true,
      Site__c = a1.Id,
      Finance_Report_Status__c = 'Not Started',
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Session')
        .getRecordTypeId()
    );
    insert s;

    Session__c c = new Session__c(
      Name = 'Test Cohort',
      Is_Active__c = true,
      Site__c = a1.Id,
      Session__c = s.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Cohort')
        .getRecordTypeId()
    );
    insert c;

    Session__c m = new Session__c(
      Name = 'Test Cohort',
      Is_Active__c = true,
      Site__c = a1.Id,
      Session__c = s.Id,
      Cohort__c = c.Id,
      RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
        .get('Meeting')
        .getRecordTypeId()
    );
    insert m;

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

    Profile p = [SELECT Id FROM Profile WHERE Name = 'NPAL Level Three'];
    Contact c1 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com',
      Role__c = 'Finance Lead'
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
      ProfileId = p.Id,
      UserName = 'test1@qerjda.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    a1.Primary_Approver__c = c1.Id;
    a1.Primary_Approver_On_Leave__c = true;
    update a1;

    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level One'];
    Contact c2 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test2',
      Email = 'newtest2@example.com',
      Role__c = 'CEO',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Coach')
        .getRecordTypeId()
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
      ProfileId = p.Id,
      UserName = 'test2@asdfe.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;

    Profile p3 = [SELECT Id FROM Profile WHERE Name = 'LEGO Community Login'];
    Contact c3 = new Contact(
      accountId = a2.Id,
      lastName = 'Contact',
      firstName = 'Test3',
      Email = 'newtest3@example.com',
      //            ,Current_Session__c = s.Id
      Active_Status__c = 'Active',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Youth')
        .getRecordTypeId()
    );
    insert c3;
    User u3 = new User(
      Alias = 'testu',
      Email = 'test3@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test4',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p3.Id,
      UserName = 'test3@eindn.com',
      Contact = c3,
      ContactId = c3.Id
    );
    insert u3;

    Contact del1 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Delete',
      Email = 'newtest1@example.com'
    );
    insert del1;
    Contact del2 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Delete',
      Email = 'newtest2@example.com'
    );
    insert del2;
    Contact del3 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Delete',
      Email = 'newtest3@example.com'
    );
    insert del3;
    User del4 = new User(
      Alias = 'testu',
      Email = 'test3@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test4',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p3.Id,
      UserName = 'test3@delete.com',
      Contact = del3,
      ContactId = del3.Id
    );
    insert del4;

    system.test.startTest();
    System.runAs(u1) {
      system.test.setCurrentPageReference(new PageReference('Page.NPALAbout'));
      AboutCtrl ctrl1 = new AboutCtrl();
      ctrl1.newContact.LastName = 'Test';
      ctrl1.newContact.Email = 'test123@test123.com';
      ctrl1.newCohort.Name = 'Test';
      ctrl1.addContact();
      ctrl1.addContactPopup();
      ctrl1.cancelAddContactPopup();
      ctrl1.updateContacts();
      ctrl1.editContactPopup();
      ctrl1.cancelEditContactPopup();
      ctrl1.updateOrg();
      ctrl1.editOrgPopup();
      ctrl1.editOrgPopup();
      ctrl1.addCohort();
      ctrl1.addCohortPopup();
      ctrl1.addCohortPopup();
      //ctrl1.deleteYouthPopup();
      //ctrl1.deleteYouthPopup();
      ctrl1.deleteYouth();

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOContactForm')
      );
      System.currentPageReference().getParameters().put('ContactID', c1.Id);
      ContactFormCtrl ctrl2 = new ContactFormCtrl();
      ctrl2.ParentId = c1.Id;
      ctrl2.cohortPopup();
      ctrl2.cohortPopup();
      ctrl2.contactPopup();
      ctrl2.contactPopup();
      ctrl2.contactSearch();
      ctrl2.returnToAbout();
      ctrl2.save();
      ctrl2.saveAndAdd();
      ctrl2.upsertParent();
      ctrl2.selectCohort();
      ctrl2.selectContact();

      system.test.setCurrentPageReference(
        new PageReference('Page.LEGOCohortDetails')
      );
      System.currentPageReference().getParameters().put('CohortID', c.Id);
      CohortDetailsCtrl ctrl3 = new CohortDetailsCtrl();
      ctrl3.getLists();
      ctrl3.addMeeting();
      ctrl3.addMeetingPopup();
      ctrl3.addMeetingPopup();
      ctrl3.editCohortPopup();
      ctrl3.editCohortPopup();
      ctrl3.editMeetingPopup();
      ctrl3.editMeetingPopup();
      ctrl3.updateCohort();
      ctrl3.meeting = m;
      ctrl3.deleteMeetingPopup();
      ctrl3.deleteMeetingPopup();
      ctrl3.deleteMeeting();

      system.test.setCurrentPageReference(
        new PageReference('Page.AffiliateList')
      );
      AffiliateListCtrl ctrl4 = new AffiliateListCtrl();
      ctrl4.keyword = 'Test';
      ctrl4.markAllOnLeave();
      ctrl4.filterLists();
      ctrl4.save();
      ctrl4.removeFromLeave();
    }

    System.runAs(u2) {
      system.test.setCurrentPageReference(new PageReference('Page.BBBSAbout'));
      BBBSAboutController ctrl2 = new BBBSAboutController();
      ctrl2.newContact.LastName = 'Test';
      ctrl2.newContact.Email = 'test123@test123.com';
      ctrl2.addContact();
      ctrl2.addContactPopup();
      //ctrl2.SubGrantId = subgrant.Id;
      ctrl2.updateContacts();
      ctrl2.editContactPopup();
      //ctrl2.createAssessment();
      ctrl2.cancelAddContactPopup();
      ctrl2.cancelEditContactPopup();
      ctrl2.showAssessmentPopup();
      ctrl2.hideAssessmentPopup();
      ctrl2.updateOrg();
      ctrl2.selectedUserId = del4.id;
      ctrl2.deactivateUserPopup();
      ctrl2.deactivateUser();
      ctrl2.cancelDeactivateUserPopup();
      ctrl2.selectedContactId = del3.id;
      ctrl2.deleteContactPopup();
      ctrl2.deleteContact();
      ctrl2.cancelDeleteContactPopup();
      ctrl2.showEditDUNSPopup();
      ctrl2.hideEditDUNSPopup();
    }

    System.runAs(u3) {
      system.test.setCurrentPageReference(new PageReference('Page.LEGOAbout'));
      AboutCtrl ctrl3 = new AboutCtrl();
      ctrl3.SessionId = s.id;
      ctrl3.init();
      ctrl3.getYouthList();
      ctrl3.selectedContactId = del1.Id;
      ctrl3.deleteContactPopup();
      ctrl3.deleteContact();
      ctrl3.cancelDeleteContactPopup();
      ctrl3.showEditAddressPopup();
      ctrl3.hideEditAddressPopup();
      ctrl3.YouthId = del2.Id;
      ctrl3.deleteYouthPopup();
    }
    system.test.stopTest();
  }
}
