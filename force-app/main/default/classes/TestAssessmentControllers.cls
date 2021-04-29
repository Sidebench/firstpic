@isTest
class TestAssessmentControllers {
  static testMethod void test1() {
    System.Test.startTest();
    Date dt = Date.today();

    Account a1 = new Account(
      EIN__c = '98-7654321',
      Name = 'Org Test',
      Status__c = 'Approved',
      Insurance_Provider__c = 'test',
      Insurance_Expiration_Date__c = dt,
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a1;

    Contact ceo = new Contact(
      accountId = a1.Id,
      lastName = 'CEO',
      firstName = 'Test1',
      Email = 'ceo@example.com'
    );
    insert ceo;

    Contact fl = new Contact(
      accountId = a1.Id,
      lastName = 'FL',
      firstName = 'Test1',
      Email = 'fl@example.com'
    );
    insert fl;

    a1.CEO__c = ceo.Id;
    a1.Finance_Lead__c = fl.Id;
    update a1;

    Assessment__c sa = new Assessment__c(
      Organization__c = a1.Id,
      S25_Standards__c = 'Out',
      S25_Standards_Text__c = 'test',
      Fiscal_Year_Ended__c = dt,
      Year__c = 2017,
      Assessment_Status__c = 'Incomplete'
    );
    insert sa;

    List<Document__c> doc_list = new List<Document__c>();
    Set<String> names = new Set<String>();
    names.add('Strategic Plan');
    names.add('Fund Development Plan');
    names.add('Code of Ethics');
    names.add('Whistleblowers');
    names.add('Separation of Duties for Fiscal Control');
    names.add('Board Development Plan');
    names.add('Written Succession Plan');
    names.add('Audit');
    names.add('Program Manual');
    names.add('Verification Letter');
    names.add('Affiliation Fee Form');
    names.add('AIM Fee Form');
    names.add('Proof of Insurance');
    names.add('Income Statement');
    names.add('Supporting Documentation');
    names.add('Organizational Chart');
    names.add('Bylaws');
    names.add('Advisory Plan');
    names.add('Network Growth Goals');
    names.add('Program Manual');
    names.add('Technology Licenses Form');

    for (String n : names) {
      Document__c d = new Document__c(
        Assessment__c = sa.Id,
        Organization__c = sa.Organization__c,
        Status__c = 'Requested',
        Name = n
      );
      doc_list.add(d);
    }
    insert doc_list;

    Blob body = Blob.valueOf('Test Body');
    Attachment att = new Attachment(
      Name = 'Strategic Plan',
      body = body,
      parentId = doc_list[0].id
    );
    insert att;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
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

    System.runAs(u1) {
      System.Test.setCurrentPageReference(
        new PageReference('Page.AssessmentPage1')
      );
      System.currentPageReference().getParameters().put('AssessmentID', sa.Id);
      AssessmentCtrl ctrl1 = new AssessmentCtrl();
      ctrl1.setParams();
      ctrl1.init();
      ctrl1.getOldAttList();
      ctrl1.saveAndContinue();
      ctrl1.saveAndExit();
      ctrl1.submit();
      ctrl1.attPopup();
      ctrl1.closeAttPopup();
      ctrl1.deleteAtt();
      ctrl1.getOptions();
      ctrl1.handleTabClick();
      ctrl1.deletePopup();
      ctrl1.updateAuditDate();
      ctrl1.assess.Fiscal_Year_Ended__c = null;
      ctrl1.updateAuditDate();
      ctrl1.upsertAssessment();
      ctrl1.saveAndRefresh();
      ctrl1.markAsReviewed();
      //   ctrl1.deleteAssessment();

      System.Test.setCurrentPageReference(new PageReference('Page.Compliance'));
      ComplianceCtrl ctrl2 = new ComplianceCtrl();
      ctrl2.getLists();
      ctrl2.assess = sa;
      ctrl2.keyword = 'Test';
      ctrl2.contactPopup();
      ctrl2.closeContactPopup();
      ctrl2.AssessmentId = sa.Id;
      ctrl2.testInnerClasses();

      System.Test.setCurrentPageReference(
        new PageReference('Page.ComplianceReportXLS')
      );
      System.currentPageReference().getParameters().put('type', 'incomplete');
      ComplianceCtrl ctrl3 = new ComplianceCtrl();
      ctrl3.getLists();
    }
    System.Test.stopTest();
  }
}
