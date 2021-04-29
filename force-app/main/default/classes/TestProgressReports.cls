@isTest
public class TestProgressReports {
  static testMethod void testSessionReports() {
    system.test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Session_Report__c r1 = new Session_Report__c(
      Site__c = a.Id,
      Status__c = 'In Progress',
      Number_of_Youth_Participated__c = 10,
      Number_Participants_Completed_Pre_Test__c = 1,
      Number_Participants_Completed_Post_Test__c = 2,
      Youth_Participated_in_Physical_Activity__c = 3,
      Number_of_Physical_Activity_Challenges__c = 4,
      Number_of_Sessions_Completed__c = 'test',
      Activities_Hosted_or_Participated__c = 'test',
      How_Curriculum_was_Adapted__c = 'test',
      How_Healthy_Food_Choices_Implemented__c = 'test',
      Healthy_Snack_Preparation_Implemented__c = 'test',
      Average_Club_Wide_Participation__c = 10,
      Type_of_Club_Wide_Physical_Activit__c = 'test',
      Parents_Guardians_Recruited_to_Volunteer__c = 1,
      How_Parents_Guardians_Recruited__c = 'test',
      Type_Activities_Guardians_Participated__c = 'test',
      Number_of_Volunteers_Recruited__c = 1,
      How_Volunteers_Recruited__c = 'test',
      Type_of_Volunteer_Activities__c = 'test',
      Has_Signed_Memorandum_of_Agreement__c = 'Yes',
      Community_Health_Partner_Involvement__c = 'test',
      Additional_Community_Partners_Recruited__c = 1,
      How_Community_Partners_Recruited__c = 'test',
      Type_of_Support_From_Community_Partners__c = 'test',
      Status_of_Community_Service_Project_Plan__c = 'test',
      How_Community_Service_Project_Supports__c = 'test',
      What_are_People_Saying_About_Program__c = 'test',
      Describe_Program_Successes__c = 'test',
      Describe_Program_Challenges__c = 'test',
      Feedback_on_Program_Curriculum__c = 'test',
      Plans_for_Continuing_Program__c = 'test'
    );
    insert r1;

    Session_Report__c r2 = new Session_Report__c(
      Site__c = a.Id,
      Status__c = 'Submitted'
    );
    insert r2;

    Session_Report__c r3 = new Session_Report__c(
      Site__c = a.Id,
      Status__c = 'Approved'
    );
    insert r3;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Three'];
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
      system.test.setCurrentPageReference(
        new PageReference('Page.ProgressReport?reportId=' + r1.Id)
      );
      SessionReportCtrl ctrl1 = new SessionReportCtrl();
      ctrl1.init();
      ctrl1.getAcct();
      ctrl1.next();
      ctrl1.currentTab = 2;
      ctrl1.next();
      ctrl1.previous();
      ctrl1.submit();
      ctrl1.showSendBackPopup();
      ctrl1.showApprovePopup();
      ctrl1.approve();
      ctrl1.sendBack();

      system.test.setCurrentPageReference(
        new PageReference('Page.ProgressReports')
      );
      SessionReportsCtrl ctrl2 = new SessionReportsCtrl();
      ctrl2.getLists();
    }

    system.test.stopTest();
  }

  static testMethod void testProgressReports() {
    system.test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Name = 'Test Grant',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g;

    Progress_Report__c r1 = new Progress_Report__c(
      Organization__c = a.Id,
      Grant__c = g.Id,
      Status__c = 'In Progress',
      Month__c = 'June',
      Updated_Youth_Data__c = 'Yes',
      Number_of_Mentors__c = 1,
      Number_of_Mentors_Left_Program__c = 2,
      Number_of_New_Mentors_this_Month__c = 3,
      Number_of_Mentors_Completed_Training__c = 4,
      Mentor_Training_Survey_Completed__c = 'Yes',
      Accomplishments_this_Reporting_Period__c = 'test',
      Problems_Barriers_Encountered__c = 'No',
      Problems_Barriers_Encountered_Details__c = 'test',
      Assistance_Needed__c = 'No',
      Assistance_Needed_Details__c = 'test',
      On_Track_to_Complete_Program__c = 'Yes',
      On_Track_to_Complete_Program_Details__c = 'test',
      Major_Activities_Planned__c = 'test',
      Innovative_Programs_Accomplishments__c = 'test',
      Quarter__c = 'Q1',
      Year__c = '2018'
    );
    insert r1;

    Progress_Report__c r2 = new Progress_Report__c(
      Organization__c = a.Id,
      Grant__c = g.Id,
      Status__c = 'Submitted',
      Quarter__c = 'Q3',
      Year__c = '2018',
      RecordTypeId = Schema.SObjectType.Progress_Report__c.getRecordTypeInfosByName()
        .get('Quarterly')
        .getRecordTypeId()
    );
    insert r2;

    List<Progress_Report__c> prs = new List<Progress_Report__c>();
    for (Integer i = 0; i < 50; i++) {
      Progress_Report__c pr = new Progress_Report__c(
        Organization__c = a.Id,
        Grant__c = g.Id,
        Status__c = 'Submitted',
        Quarter__c = 'Q3',
        Year__c = '2018',
        RecordTypeId = Schema.SObjectType.Progress_Report__c.getRecordTypeInfosByName()
          .get('Quarterly')
          .getRecordTypeId()
      );
      prs.add(pr);
    }
    insert prs;

    Grantee_Report__c dctat = new Grantee_Report__c(
      Grant__c = g.Id,
      Quarter__c = 'Q2',
      Year__c = '2018'
    );
    insert dctat;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'NPAL Level Three'];
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
      system.test.setCurrentPageReference(
        new PageReference('Page.MonthlyProgressReport?reportId=' + r1.Id)
      );
      ProgressReportCtrl ctrl1 = new ProgressReportCtrl();
      ctrl1.getOptions();
      ctrl1.getLists();
      ctrl1.getReport();
      ctrl1.next();
      ctrl1.previous();
      ctrl1.last();
      ctrl1.edit();
      ctrl1.save();
      ctrl1.markAsReviewed();
      ctrl1.showApprovePopup();
      ctrl1.hideApprovePopup();
      ctrl1.approve();
      ctrl1.monthlyFieldValidation();
      ctrl1.quarterlyFieldValidation();
      ctrl1.showAttPopup();
      ctrl1.hideAttPopup();
      ctrl1.showSendBackPopup();
      ctrl1.hideSendBackPopup();
      ctrl1.sendBack();

      system.test.setCurrentPageReference(
        new PageReference('Page.QuarterlyProgressReports')
      );
      QuarterlyProgressReportsCtrl ctrl2 = new QuarterlyProgressReportsCtrl();
      ctrl2.year = '';
      ctrl2.getLists();
      ctrl2.getDCTATLists();
      ctrl2.siteId = a.Id;
      ctrl2.getLists();
      ctrl2.next();
      ctrl2.previous();
      ctrl2.last();
      /*
system.test.setCurrentPageReference(new PageReference('Page.MonthlyProgressReports')); 
ProgressReportsCtrl ctrl3 = new ProgressReportsCtrl(); 
ctrl3.getLists();
ctrl3.next();
ctrl3.previous();
ctrl3.last();
*/
    }

    system.test.stopTest();
  }
}
