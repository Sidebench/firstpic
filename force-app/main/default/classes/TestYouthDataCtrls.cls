@isTest
public class TestYouthDataCtrls {
  static testMethod void testYouthData() {
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

    Contact youth1 = new Contact(
      AccountId = site.Id,
      LastName = '11',
      FirstName = 'Test1',
      Gender__c = 'M',
      Birth_Month__c = 'January',
      Birth_Year__c = '2010',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Youth')
        .getRecordTypeId()
    );
    insert youth1;

    Contact youth2 = new Contact(
      AccountId = site.Id,
      LastName = '2',
      FirstName = 'Test2',
      Gender__c = 'F',
      Birth_Month__c = 'January',
      Birth_Year__c = '2010',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Youth')
        .getRecordTypeId()
    );
    insert youth2;

    Grant__c g = new Grant__c(
      Account__c = no.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert g;

    Grant__c sg = new Grant__c(
      Account__c = lo.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId(),
      Grant_Status__c = 'Pending Final Approval'
    );
    insert sg;

    Date sd = Date.newInstance(2018, 1, 1);
    Date ed = Date.newInstance(2018, 12, 13);
    Program_Report__c pr1 = new Program_Report__c(
      Name = 'Youth Data Report Y1',
      Status__c = 'Not Started',
      Site__c = site.Id,
      Grant__c = sg.Id,
      Start_Date__c = sd,
      End_Date__c = ed,
      RecordTypeID = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
        .get('Youth Data')
        .getRecordTypeId(),
      Grant_Year__c = '1'
    );
    insert pr1;

    Survey__c pre = new Survey__c(
      Contact__c = youth1.Id,
      Type__c = 'Pre-Test',
      Status__c = 'Not Started'
    );
    insert pre;

    Survey__c post = new Survey__c(
      Contact__c = youth1.Id,
      Type__c = 'Post-Test',
      Status__c = 'Not Started'
    );
    insert post;

    Youth_in_Program_Report__c ypr1 = new Youth_in_Program_Report__c(
      Contact__c = youth1.Id,
      Program_Report__c = pr1.Id,
      Pre_Test__c = pre.Id,
      Post_Test__c = post.Id
    );
    insert ypr1;

    Chapter_Report__c cr1 = new Chapter_Report__c(
      Youth_in_Program_Report__c = ypr1.Id
    );
    insert cr1;

    PA_Challenge__c pac = new PA_Challenge__c(
      Youth_in_Program_Report__c = ypr1.Id,
      Title__c = 'Physical Activity Strength Challenge 2 – Push-ups'
    );
    insert pac;

    system.test.startTest();
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
      system.test.setCurrentPageReference(
        new PageReference(
          'Page.YouthData?localOrgId=' +
          lo.Id +
          '&siteId=' +
          site.Id +
          '&grantId=' +
          sg.Id +
          '&year=1'
        )
      );
      YouthDataCtrl ctrl1 = new YouthDataCtrl();
      ctrl1.getLists();
      ctrl1.getPACList();
      ctrl1.getReport();
      ctrl1.getYouth();
      ctrl1.clear();

      system.test.setCurrentPageReference(
        new PageReference('Page.YouthForm?youthId=' + youth1.Id)
      );
      YouthDataCtrl ctrl2 = new YouthDataCtrl();
      ctrl2.youthId = youth1.Id;
      ctrl2.getYouth();
      ctrl2.getYouthYPRList();
      ctrl2.youth.LastName = 'a';
      ctrl2.saveYouth();
      ctrl2.showFindYouthPopup();
      ctrl2.hideFindYouthPopup();
      ctrl2.youthDupCheck();
      ctrl2.yprDupCheck();
      ctrl2.updateExistingYouth();
      ctrl2.saveYouthDetails();
      //ctrl2.selectYouth();
      ctrl2.showSendBackPopup();
      ctrl2.hideSendBackPopup();
      ctrl2.showApprovePopup();
      ctrl2.hideApprovePopup();
      ctrl2.hideConfirmPopup();
      ctrl2.clearYouthForm();
      //Survey__c[] surveys = [SELECT Id FROM Survey__c WHERE Contact__c = :youth1.Id];
      //system.assert(surveys.size() > 0);
    }
    system.test.stopTest();
  }

  static testMethod void testSurveys() {
    Account site = new Account(
      EIN__c = '00-2947562',
      Name = 'Site',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert site;

    Contact youth1 = new Contact(
      AccountId = site.Id,
      LastName = '11',
      FirstName = 'Test1',
      Gender__c = 'M',
      Birth_Month__c = 'January',
      Birth_Year__c = '2010',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Youth')
        .getRecordTypeId()
    );
    insert youth1;

    Date sd = Date.newInstance(2018, 1, 1);
    Date ed = Date.newInstance(2018, 12, 13);
    Program_Report__c pr1 = new Program_Report__c(
      Name = 'Youth Data Report Y1',
      Status__c = 'Not Started',
      Site__c = site.Id,
      Start_Date__c = sd,
      End_Date__c = ed,
      RecordTypeID = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
        .get('Youth Data')
        .getRecordTypeId(),
      Grant_Year__c = '1'
    );
    insert pr1;

    Survey__c pre = new Survey__c(
      Contact__c = youth1.Id,
      Type__c = 'Pre-Test',
      Status__c = 'Not Started'
    );
    insert pre;

    Survey__c post = new Survey__c(
      Contact__c = youth1.Id,
      Type__c = 'Post-Test',
      Status__c = 'Not Started'
    );
    insert post;

    Youth_in_Program_Report__c ypr1 = new Youth_in_Program_Report__c(
      Contact__c = youth1.Id,
      Program_Report__c = pr1.Id,
      Pre_Test__c = pre.Id,
      Post_Test__c = post.Id
    );
    insert ypr1;

    Chapter_Report__c cr1 = new Chapter_Report__c(
      Youth_in_Program_Report__c = ypr1.Id
    );
    insert cr1;

    PA_Challenge__c pac = new PA_Challenge__c(
      Youth_in_Program_Report__c = ypr1.Id,
      Title__c = 'Physical Activity Strength Challenge 2 – Push-ups'
    );
    insert pac;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'NCAI Level One'];
    Contact sc = new Contact(
      accountId = site.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com',
      Role__c = 'CEO'
    );
    insert sc;
    User su = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p.Id,
      UserName = 'test1@qerjda.com',
      Contact = sc,
      ContactId = sc.Id
    );
    insert su;

    system.test.startTest();
    System.runAs(su) {
      system.test.setCurrentPageReference(
        new PageReference('Page.Survey?surveyId=' + pre.Id)
      );
      YouthDataCtrl ctrl3 = new YouthDataCtrl();
      ctrl3.getURLParams();
      ctrl3.getSurvey();
      ctrl3.saveSurvey();
      ctrl3.submitSurvey();

      system.test.setCurrentPageReference(
        new PageReference('Page.PAChallenges?yprId=yprId=' + ypr1.Id)
      );
      YouthDataCtrl ctrl4 = new YouthDataCtrl();
      ctrl4.yprId = ypr1.Id;
      ctrl4.getPACList();
      ctrl4.savePACs();
      ctrl4.saveAndExitPACs();
      ctrl4.submitPACs();
      ctrl4.sendBackPACs();
      ctrl4.approvePACs();

      Youth_in_Program_Report__c updatedYPR = [
        SELECT Pre_Test_Status__c, Post_Test_Status__c, PA_Challenge_Status__c
        FROM Youth_in_Program_Report__c
        WHERE Id = :ypr1.Id
      ];
      //system.assertEquals('Complete', updatedYPR.Pre_Test_Status__c);
      //system.assertEquals('Complete', updatedYPR.PA_Challenge_Status__c);
    }
    system.test.stopTest();
  }

  static testMethod void testYouthDataLists() {
    system.test.startTest();
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

    Contact youth1 = new Contact(
      AccountId = site.Id,
      LastName = '11',
      FirstName = 'Test1',
      Gender__c = 'M',
      Birth_Month__c = 'January',
      Birth_Year__c = '2010',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Youth')
        .getRecordTypeId()
    );
    insert youth1;

    Grant__c g = new Grant__c(
      Account__c = no.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert g;

    Grant__c sg = new Grant__c(
      Account__c = lo.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId(),
      Grant_Status__c = 'Pending Final Approval'
    );
    insert sg;

    List<Program_Report__c> prs = new List<Program_Report__c>();
    for (Integer i = 0; i < 50; i++) {
      Program_Report__c pr = new Program_Report__c(
        Name = 'Youth Data Report Y1',
        Site__c = site.Id,
        Grant__c = sg.Id,
        RecordTypeID = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
          .get('Youth Data')
          .getRecordTypeId()
      );
      prs.add(pr);
    }
    insert prs;

    List<Youth_in_Program_Report__c> yprs = new List<Youth_in_Program_Report__c>();
    for (Program_Report__c pr : prs) {
      Youth_in_Program_Report__c ypr = new Youth_in_Program_Report__c(
        Contact__c = youth1.Id,
        Program_Report__c = pr.Id
      );
      yprs.add(ypr);
    }
    insert yprs;

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
      system.test.setCurrentPageReference(
        new PageReference(
          'Page.YouthData?localOrgId=' +
          lo.Id +
          '&siteId=' +
          site.Id +
          '&grantId=' +
          sg.Id +
          '&year=1'
        )
      );
      YouthDataCtrl ctrl1 = new YouthDataCtrl();
      ctrl1.next();
      ctrl1.previous();
      ctrl1.last();
      ctrl1.clear();

      system.test.setCurrentPageReference(
        new PageReference('Page.ChapterReports')
      );
      ChapterReportCtrl ctrl2 = new ChapterReportCtrl();
      ctrl2.getLists();
      //ctrl2.reportId = cr1.Id;
      ctrl2.getReport();
      ctrl2.save();
      ctrl2.next();
      ctrl2.previous();
      ctrl2.last();
    }
    system.test.stopTest();
  }
}
