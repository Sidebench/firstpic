@isTest
public class TestSOICtrl {
  static testMethod void testSOI() {
    Date dt = Date.today();

    Account a1 = new Account(
      FirstPic_Org_Code__c = 'NCAI',
      EIN__c = '98-9827462',
      Name = 'NCAI',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a1;

    Account a2 = new Account(
      National_Organization__c = a1.Id,
      EIN__c = '98-9827462',
      DUNS__c = 123456789,
      Name = 'NCAI',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    Application__c app1 = new Application__c(
      National_Organization__c = a1.Id,
      Organization_Name__c = 'Test'
    );
    insert app1;

    Application__c app2 = new Application__c(
      National_Organization__c = a1.Id,
      Organization_Name__c = 'Test',
      Organization_Type__c = 'Consortium',
      DUNS_Number__c = '123456789',
      Address__c = 'Test',
      City__c = 'Test',
      State__c = 'Test',
      Postal_Zip_Code__c = '12345',
      Grant_Admin_First_Name__c = 'Test',
      Grant_Admin_Last_Name__c = 'Test',
      Grant_Admin_Email__c = 'test@ga.com',
      Grant_Admin_Phone__c = '5556667777',
      POC_Can_Receive_Communication__c = false,
      Program_Contact_First_Name__c = 'Test',
      Program_Contact_Last_Name__c = 'Test',
      Program_Contact_Email__c = 'test@pc.com',
      Program_Contact_Phone__c = '5554443333',
      New_or_Existing__c = 'Existing',
      Existing_Services__c = 'Test',
      Strategic_Plan__c = 'Test',
      Eligibility_Notice_Received__c = false,
      Needs_Assessment__c = 'Test',
      Funding_to_Purchase_Vehicle__c = true,
      Strategic_Plan_Victim_Services__c = false,
      Authority_to_Apply__c = true,
      Tribe_Represented__c = 'Test'
    );
    insert app2;

    system.Test.startTest();
    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'NCAI Level One'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@login.com',
      accountId = a1.Id
    );
    insert c1;
    User u1 = new User(
      Alias = 'ksienf',
      Email = 'test@example3467.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'test@ncailevelone23456.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    System.runAs(u1) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.StatementOfInterest')
      );
      StatementOfInterestCtrl ctrl1 = new StatementOfInterestCtrl();
      ctrl1.app = app1;
      ctrl1.submit();
      system.assert(ctrl1.errorMessage != '');
      ctrl1.app = app2;
      ctrl1.submit();
      system.assert(ctrl1.errorMessage == '');
      ctrl1.notEligible();
      ctrl1.save();
      ctrl1.approve();
      Account test1 = [
        SELECT National_Grants__c
        FROM Account
        WHERE Id = :a2.Id
      ];
      system.assertEquals('OVC', test1.National_Grants__c);
    }
    system.Test.stopTest();
  }
}
