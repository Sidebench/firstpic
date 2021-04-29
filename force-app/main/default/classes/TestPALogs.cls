@isTest
public class TestPALogs {
  static testMethod void testPAReports() {
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

    Account site = new Account(
      EIN__c = '00-2947562',
      National_Organization__c = no.Id,
      Local_Organization__c = lo.Id,
      Name = 'Site',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert site;

    Program_Report__c pr = new Program_Report__c(
      Name = 'PA Report',
      Status__c = 'Not Started',
      Site__c = site.Id,
      RecordTypeID = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
        .get('Monthly PA Logs')
        .getRecordTypeId(),
      Grant_Year__c = '1'
    );
    insert pr;

    PA_Log__c pa1 = new PA_Log__c(
      Date__c = dt,
      Monthly_PA_Report__c = pr.Id,
      Site__c = site.Id
    );
    insert pa1;

    PA_Log__c pa2 = new PA_Log__c(
      Date__c = dt.addDays(1),
      Monthly_PA_Report__c = pr.Id,
      Site__c = site.Id
    );
    insert pa2;

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
      system.test.setCurrentPageReference(new PageReference('Page.PAReports'));
      PALogCtrl ctrl1 = new PALogCtrl();
      ctrl1.getDropdowns();
      ctrl1.getPALists();
      ctrl1.save();
      ctrl1.submit();
      ctrl1.showSendBackPopup();
      ctrl1.hideSendBackPopup();
      ctrl1.sendBack();
      ctrl1.showApprovePopup();
      ctrl1.hideApprovePopup();
      ctrl1.approve();
    }
  }
}
