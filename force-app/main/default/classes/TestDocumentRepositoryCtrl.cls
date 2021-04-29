@isTest
class TestDocumentRepositoryCtrl {
  static testMethod void test1() {
    system.Test.startTest();
    Date dt = Date.today();

    Account a = new Account(
      EIN__c = '98-7654321',
      Name = 'Org Test',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Name = 'Test Grant',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
    Contact c1 = new Contact(
      accountId = a.Id,
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

    System.runAs(u1) {
      system.Test.setCurrentPageReference(
        new PageReference('Page.DocumentRepository')
      );
      DocumentRepositoryCtrl ctrl1 = new DocumentRepositoryCtrl();
      ctrl1.getLists();
      ctrl1.orgId = a.Id;
      ctrl1.getLists();
      ctrl1.grantId = g.Id;
      ctrl1.getLists();
      ctrl1.dunsExpDate = date.today();
      ctrl1.updateDuns();
      ctrl1.updateHold();
      ctrl1.showEditDunsPopup();
      ctrl1.hideEditDunsPopup();
      ctrl1.showOnHoldPopup();
      ctrl1.hideOnHoldPopup();
      ctrl1.showContactPopup();
      ctrl1.hideContactPopup();
    }

    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Three'];
    Contact c2 = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'Test2',
      Email = 'newtest2@example.com'
    );
    insert c2;
    User u2 = new User(
      Alias = 'testu2',
      Email = 'test2@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test2',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p2.Id,
      UserName = 'levelthree@test2.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;

    System.runAs(u2) {
      DocumentRepositoryCtrl ctrl2 = new DocumentRepositoryCtrl();
      ctrl2.getLists();
    }
    system.Test.stopTest();
  }
}
