@isTest
public class TestSiteDetailsCtrl {
  static testMethod void testSiteDetails() {
    system.test.startTest();
    Date dt = Date.today();

    Account a1 = new Account(
      EIN__c = '00-7654321',
      Name = 'Cal Ripken Sr. Foundation',
      Phone = '5555555555',
      BillingStreet = 'Street',
      BillingCity = 'City',
      BillingState = 'CA',
      BillingPostalCode = '12345',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a1;

    Account a2 = new Account(
      EIN__c = '00-2837563',
      National_Organization__c = a1.Id,
      Name = 'Local',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    Account a3 = new Account(
      EIN__c = '00-2947562',
      National_Organization__c = a1.Id,
      Local_Organization__c = a2.Id,
      Name = 'Site',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert a3;

    List<Account> accts = new List<Account>();
    for (Integer i = 0; i < 30; i++) {
      Account a = new Account(
        Name = 'Local ' + i,
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Local Organization')
          .getRecordTypeId()
      );
      accts.add(a);
    }
    insert accts;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'NCAI Level Three'];
    Contact c1 = new Contact(
      accountId = a1.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com',
      Role__c = 'CEO'
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

    System.runAs(u1) {
      system.test.setCurrentPageReference(
        new PageReference('Page.SiteDetails')
      );
      SiteDetailsCtrl ctrl1 = new SiteDetailsCtrl();
      ctrl1.getLists();
      ctrl1.upsertOrg();
      ctrl1.selectedContactId = c1.Id;
      ctrl1.showEditRelatedContactPopup();
      ctrl1.selectedContact.FirstName = 'Updated';
      ctrl1.upsertContact();
      Contact c1test = [SELECT FirstName FROM Contact WHERE Id = :c1.Id];
      system.assert(c1test.FirstName == 'Updated');
      ctrl1.hideEditRelatedContactPopup();
      ctrl1.showDeleteContactPopup();
      ctrl1.hideDeleteContactPopup();
      ctrl1.showEditOrgPopup();
      ctrl1.hideEditOrgPopup();
      ctrl1.deleteContact();

      ctrl1.getRelatedAccountList();
      ctrl1.siteFirst();
      ctrl1.siteNext();
      ctrl1.sitePrevious();
      ctrl1.siteLast();

      ctrl1.youthFirst();
      ctrl1.youthNext();
      ctrl1.youthPrevious();
      ctrl1.youthLast();

      ctrl1.selectedSiteId = a3.Id;
      ctrl1.showSendApplicationPopup();
      ctrl1.sendApplication();
    }
    system.test.stopTest();
  }
}
