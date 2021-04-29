@isTest
public class TestTALogs {
  static testMethod void testTALogCtrl() {
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

    Account site1 = new Account(
      EIN__c = '11-2947562',
      National_Organization__c = no.Id,
      Local_Organization__c = lo.Id,
      Name = 'Site',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert site1;

    Account site2 = new Account(
      EIN__c = '22-2947562',
      National_Organization__c = no.Id,
      Local_Organization__c = lo.Id,
      Name = 'Site2',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert site2;

    TA_Log__c ta1 = new TA_Log__c(
      Organization__c = site1.Id,
      Date__c = dt,
      Additional_TA_Provider__c = 'asdf',
      Flagged_for_Follow_Up__c = true,
      Grantee_Attendee__c = 'asdf',
      Is_Follow_Up__c = false,
      Notes__c = 'asdf'
      //TA_By__c = 'asdf'
    );
    insert ta1;

    List<TA_Log__c> logs = new List<TA_Log__c>();
    for (Integer i = 0; i < 50; i++) {
      TA_Log__c ta = new TA_Log__c(Organization__c = site2.Id, Date__c = dt);
      logs.add(ta);
    }
    insert logs;

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
      system.test.setCurrentPageReference(new PageReference('Page.TALogs'));
      TALogCtrl ctrl1 = new TALogCtrl();
      ctrl1.siteId = site2.Id;
      ctrl1.next();
      ctrl1.previous();
      ctrl1.last();

      ctrl1.selectedLogId = ta1.Id;
      ctrl1.siteId = site1.Id;
      ctrl1.getTALog();
      ctrl1.getOriginalTALog();
      ctrl1.getFollowUpTALog();
      ctrl1.showTALogPopup();
      ctrl1.selectedLogId = ta1.Id;
      ctrl1.showTAFollowUpPopup();
      ctrl1.selectedLog.Notes__c = 'Follow Up Test';
      ctrl1.upsertTALog();
      //            TA_Log__c test1 = [SELECT Original_TA_Log__c FROM TA_Log__c WHERE Is_Follow_Up__c = true];
      //            TA_Log__c test2 = [SELECT Follow_Up_TA_Log__c, Flagged_for_Follow_Up__c FROM TA_Log__c WHERE Id = :ta1.Id];
      //            system.assert(test2.Follow_Up_TA_Log__c != null);
      //            system.assert(test2.Flagged_for_Follow_Up__c == false);
      ctrl1.hideTALogPopup();
    }
  }
}
