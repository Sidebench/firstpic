@isTest
public class TestTAPlans {
  static testMethod void testListAndDetailsPages() {
    system.test.startTest();
    Date dt = date.today();

    Account no = new Account(
      EIN__c = '00-7654321',
      Name = 'National Congress of American Indians',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert no;

    Account lo = new Account(
      EIN__c = '00-2837563',
      National_Organization__c = no.Id,
      Name = 'Local',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert lo;

    TA_Plan__c ta1 = new TA_Plan__c(Organization__c = lo.Id);
    insert ta1;

    List<TA_Plan__c> plans = new List<TA_Plan__c>();
    for (Integer i = 0; i < 50; i++) {
      TA_Plan__c ta = new TA_Plan__c(Organization__c = lo.Id);
      plans.add(ta);
    }
    insert plans;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Three'];
    Contact noc = new Contact(
      accountId = no.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com',
      Role__c = 'CEO'
    );
    insert noc;
    User nou = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p.Id,
      UserName = 'test1@qerjda.com',
      Contact = noc,
      ContactId = noc.Id
    );
    insert nou;

    System.runAs(nou) {
      system.test.setCurrentPageReference(new PageReference('Page.TAPlans'));
      TAPlansCtrl ctrl1 = new TAPlansCtrl();
      ctrl1.getLists();
      ctrl1.next();
      ctrl1.previous();
      ctrl1.last();

      system.test.setCurrentPageReference(
        new PageReference('Page.TAPlan?orgId=' + lo.Id + 'planId=' + ta1.Id)
      );
      TAPlanCtrl ctrl2 = new TAPlanCtrl();
      ctrl2.updatePlan();
      ctrl2.savePlan();
    }
  }
}
