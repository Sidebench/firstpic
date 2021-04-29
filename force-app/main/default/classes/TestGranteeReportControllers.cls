@isTest
public class TestGranteeReportControllers {
  static testMethod void test() {
    Date dt = Date.today();

    Account a = new Account(
      EIN__c = '98-7654321',
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a;

    Contact y = new Contact(
      accountId = a.Id,
      lastName = 'Youth',
      firstName = 'Test',
      Active_Date__c = dt,
      Exited_Date__c = dt
    );
    insert y;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Grant_Type__c = 'Badges for Baseball',
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt
    );
    insert g;

    Grantee_Report__c r = new Grantee_Report__c(
      Start_Date__c = dt.addDays(-100),
      End_Date__c = dt.addDays(100),
      Accomplishments__c = 'test',
      Age__c = 'test',
      Assistance_Needed__c = 'test',
      Gender__c = 'test',
      Geography__c = 'test',
      Grant__c = g.Id,
      Innovative_Programs_Accomplishments__c = 'test',
      Justice__c = 'test',
      Major_Activities_Planned__c = 'test',
      Mentoring_Programs_Operated__c = 10,
      Mentors_Left_the_Program__c = '10',
      Mentors_with_Increased_Knowledge__c = '10',
      New_Mentors__c = '10',
      New_Mentors_Began_Training__c = '10',
      New_Mentors_Completed_Training__c = '10',
      New_Youth_Served__c = '10',
      Notes__c = 'test',
      Other__c = 'test',
      Previous_Mentors__c = '10',
      Previous_Youth_Served__c = '10',
      Problems_Barriers__c = 'test',
      Program_on_Track__c = 'test',
      Programs_with_Active_Partners__c = '10',
      Race_Ethnicity__c = 'test',
      Report_Status__c = 'In Progress',
      Type__c = 'test',
      Youth_Completed_Program__c = '10',
      Youth_Exited_Program__c = '10',
      Youth_Identify_as_Native_American__c = 10,
      Youth_Received_Additional_Sentence__c = '10',
      Youth_Recommitted_to_Juvenile_Facility__c = '10',
      Youth_Sentenced_to_Adult_Prison__c = '10',
      Youth_Served_via_Evidence_Based_Program__c = 10,
      Youth_Tracked_for_Juvenile_Offenses__c = 10,
      Youth_with_Delinquent_Offenses__c = '10',
      Youth_with_Incarcerate_Parent__c = '10',
      Youth_with_Increased_School_Attendance__c = 10,
      Youth_with_Increased_Social_Support__c = '10',
      Youth_with_Juvenile_Offenses__c = 10,
      Youth_with_Parents_Actively_Serving__c = '10',
      Youth_with_School_Attendance_Mentoring__c = 10,
      Youth_with_Social_Support_Mentoring__c = 10,
      Youth_Completed_20_or_More_Sessions__c = '10',
      Youth_Completed_Less_Than_20_Sessions__c = '10',
      Participated_More_Than_6_Months__c = '10',
      Participated_Fewer_Than_6_Months__c = '10',
      Participated_More_Than_4_Hours_per_Month__c = '10',
      Participated_Less_Than_4_Hours_per_Month__c = '10',
      Describe_How_Plan_Was_Implemented__c = '10'
    );
    insert r;

    Blob bodyBlob1 = Blob.valueOf('Attachment Test Body');
    Attachment att = new Attachment(
      Name = 'Test',
      body = bodyBlob1
      //,parentId = r.id
    );
    //insert att;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Ripken Local Admin'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@example.com',
      accountId = a.Id
    );
    insert c1;
    User u = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p.Id,
      UserName = 'test@example.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u;

    System.runAs(u) {
      System.Test.setCurrentPageReference(
        new PageReference('Page.GranteeReport')
      );
      System.currentPageReference().getParameters().put('ReportID', r.Id);
      GranteeReportController ctrl1 = new GranteeReportController();
      ctrl1.init();
      ctrl1.getTotalYouthServerd();
      ctrl1.resetOutputs();
      ctrl1.resetMatchDetails();
      ctrl1.getAttList();
      ctrl1.errorCheck();
      ctrl1.attPopup();
      ctrl1.attPopup();
      ctrl1.previous();
      ctrl1.saveReport();
      ctrl1.submit();
      ctrl1.attPopup();
      ctrl1.attPopup();
      ctrl1.sendBackPopup();
      ctrl1.sendBackPopup();
      ctrl1.sendBack();
      ctrl1.approveReport();
      ctrl1.deleteAtt();

      System.Test.setCurrentPageReference(
        new PageReference('Page.GranteeReport')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      GranteeReportController ctrl2 = new GranteeReportController();
      ctrl2.init();

      System.Test.setCurrentPageReference(new PageReference('Page.ReportList'));
      ReportListCtrl ctrl4 = new ReportListCtrl();
      ctrl4.getLists();
      ctrl4.deleteReport();
      ctrl4.getSessionReports();

      System.Test.setCurrentPageReference(
        new PageReference('Page.NPALReportList')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      ReportListCtrl ctrl5 = new ReportListCtrl();
      ctrl5.ReportID = r.Id;
      ctrl5.getLists();
      ctrl5.deleteReport();
      ctrl5.deleteReportPopup();
      ctrl5.deleteReportPopup();

      System.Test.setCurrentPageReference(
        new PageReference('Page.UAGranteeReport')
      );
      System.currentPageReference().getParameters().put('GrantId', g.Id);
      GranteeReportCtrl ctrl6 = new GranteeReportCtrl();
      ctrl6.save();

      System.Test.setCurrentPageReference(
        new PageReference('Page.RipkenDCTATReport')
      );
      System.currentPageReference().getParameters().put('reportId', r.Id);
      DCTATReportCtrl ctrl7 = new DCTATReportCtrl();
      ctrl7.save();
      ctrl7.submit();
      ctrl7.sendBack();
      ctrl7.approve();
      ctrl7.showSendBackPopup();
      ctrl7.hideSendBackPopup();
      ctrl7.showApprovePopup();
      ctrl7.hideApprovePopup();

      System.Test.setCurrentPageReference(
        new PageReference('Page.SemiAnnualReport')
      );
      System.currentPageReference().getParameters().put('reportId', r.Id);
      DCTATReportCtrl ctrl8 = new DCTATReportCtrl();
      ctrl8.stemFieldValidation();
      ctrl8.submit();
    }
  }
}
