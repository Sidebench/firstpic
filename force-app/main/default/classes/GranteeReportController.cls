public with sharing class GranteeReportController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  public DCTATReportClass reportClass = new DCTATReportClass();

  public Account acct { get; set; }
  public ID GrantID { get; set; }
  public ID ReportID { get; set; }
  public Grant__c grant { get; set; }
  public Grantee_Report__c report { get; set; }

  public Decimal currentPage { get; set; }
  public Decimal totalYouthServed { get; set; }
  public Decimal youthAdded { get; set; }
  public Decimal youthCompleted { get; set; }
  public Decimal youthExited { get; set; }
  public Decimal matchLength8 { get; set; }
  public Decimal matchLengthMoreThan8 { get; set; }
  public Decimal matchLengthLessThan8 { get; set; }
  public Decimal parentsMilitary { get; set; }
  public Decimal parentsIncarcerated { get; set; }
  public Decimal nativeAmerican { get; set; }

  public Attachment att { get; set; }
  public List<Attachment> att_list { get; set; }
  public Id deleteAttId { get; set; }
  public Boolean displayAttPopup { get; set; }
  public Boolean displaySendBackPopup { get; set; }

  public Date dt = date.today();
  public String fdt = dt.format();
  public Date startDate { get; set; }
  public Date endDate { get; set; }
  public String errorMessage { get; set; }

  public GranteeReportController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;

    GrantID = ApexPages.currentPage().getParameters().get('GrantId');
    ReportID = ApexPages.currentPage().getParameters().get('ReportID');
    String PageId = ApexPages.currentPage().getParameters().get('currentPage');
    if (PageId != null) {
      currentPage = Integer.valueOf(PageId);
    } else {
      currentPage = 0;
    }
    errorMessage = '';

    report = new Grantee_Report__c();
    grant = new Grant__c();
    acct = new Account();

    att = new Attachment();
    att_list = new List<Attachment>();

    totalYouthServed = 0;
    youthAdded = 0;
    youthCompleted = 0;
    youthExited = 0;
    matchLength8 = 0;
    matchLengthMoreThan8 = 0;
    matchLengthLessThan8 = 0;

    parentsMilitary = 0;
    parentsIncarcerated = 0;
    nativeAmerican = 0;

    if (ReportID != null) {
      report = reportClass.getReport(ReportId);
      grant = [
        SELECT
          ID,
          Account__r.Id,
          Account__r.Name,
          RecordType.Name,
          Name,
          Youth_Served__c,
          Start_Date__c,
          End_Date__c
        FROM Grant__c
        WHERE ID = :report.Grant__c
      ];
      GrantId = grant.Id;
      startDate = report.Start_Date__c;
      endDate = report.End_Date__c;
    } else if (GrantID != null) {
      grant = [
        SELECT
          ID,
          Account__r.Id,
          Account__r.Name,
          RecordType.Name,
          Name,
          Youth_Served__c
        FROM Grant__c
        WHERE ID = :GrantID
      ];
    }
    for (Attachment a : report.Attachments) {
      att_list.add(a);
    }
    acct = [
      SELECT ID, Name, Youth_Served__c, RecordType.Name
      FROM Account
      WHERE ID = :grant.Account__r.Id
    ];

    getTotals();
    getTotalYouthServerd();
    errorCheck();
  }

  public ApexPages.PageReference init() {
    if ((ReportID == null || report == null) && GrantID == null) {
      PageReference pr = new PageReference('/ReportList');
      pr.setRedirect(true);
      return pr;
    }
    /*
        if(userAcctType == 'Local Organization' && grant.Account__c != userAcct.Id){
            PageReference pr = new PageReference('/Error');
            pr.setRedirect(true);
            return pr;
        }
        */
    return null;
  }

  public void getTotals() {
    for (Contact c : [
      SELECT
        Name,
        AccountId,
        Active_Status__c,
        Active_Date__c,
        Exited_Date__c,
        Parent_Guardian_is_Active_Military__c,
        Parent_is_Currently_Incarcerated__c,
        Ethnicity__c,
        Race__c
      FROM Contact
      WHERE AccountId = :acct.Id AND RecordType.Name = 'Youth'
      ORDER BY Name
    ]) {
      if (
        report.Start_Date__c != null &&
        report.End_Date__c != null &&
        c.Active_Date__c != null
      ) {
        if (
          c.Active_Date__c >= report.Start_Date__c &&
          c.Active_Date__c <= report.End_Date__c
        ) {
          youthAdded++;
        }
        if (
          c.Exited_Date__c != null &&
          c.Exited_Date__c >= report.Start_Date__c &&
          c.Exited_Date__c <= report.End_Date__c
        ) {
          youthExited++;
          if (
            c.Active_Status__c == 'Inactive - Successfully Completed Program'
          ) {
            youthCompleted++;
          }
          if (
            c.Exited_Date__c >= c.Active_Date__c.addDays(+224) &&
            c.Exited_Date__c <= c.Active_Date__c.addDays(+252)
          ) {
            matchLength8++;
          } else if (c.Exited_Date__c > c.Active_Date__c.addDays(+252)) {
            matchLengthMoreThan8++;
          } else if (c.Exited_Date__c < c.Active_Date__c.addDays(+224)) {
            matchLengthLessThan8++;
          }
        } else if (c.Exited_Date__c == null) {
          if (
            report.End_Date__c >= c.Active_Date__c.addDays(+224) &&
            report.End_Date__c <= c.Active_Date__c.addDays(+252)
          ) {
            matchLength8++;
          } else if (report.End_Date__c > c.Active_Date__c.addDays(+252)) {
            matchLengthMoreThan8++;
          }
        }
      }
      if (c.Parent_Guardian_is_Active_Military__c) {
        parentsMilitary++;
      }
      if (c.Parent_is_Currently_Incarcerated__c) {
        parentsIncarcerated++;
      }
      if (c.Race__c == 'American Indian or Alaska Native') {
        nativeAmerican++;
      }
    }
    system.debug('matchLength8 = ' + matchLength8);
    system.debug('matchLengthMoreThan8 = ' + matchLengthMoreThan8);
    system.debug('matchLengthLessThan8 = ' + matchLengthLessThan8);

    String period = '';
    String year = '';
    String previousPeriod = '';
    if (report.Reporting_Period__c != null) {
      period = report.Reporting_Period__c;
      year = period.substring(0, 4);
      previousPeriod = year + ' Q2';
    }
    if (period.contains('Q3') || period.contains('Q4')) {
      Grantee_Report__c[] previous = [
        SELECT ID, Total_Youth_Served__c, Youth_Exited_Program__c
        FROM Grantee_Report__c
        WHERE
          Grant__c = :report.Grant__c
          AND Reporting_Period__c = :previousPeriod
      ];
      if (previous.size() > 0) {
        report.Previous_Youth_Served__c = String.valueOf(
          previous[0].Total_Youth_Served__c
        );
        if (previous[0].Youth_Exited_Program__c != null)
          report.Previous_Youth_Served__c = String.valueOf(
            previous[0].Total_Youth_Served__c -
            Integer.valueOf(previous[0].Youth_Exited_Program__c)
          );
      }
    }
    if (report.New_Youth_Served__c == null && youthAdded > 0) {
      report.New_Youth_Served__c = String.valueOf(youthAdded);
    }
    if (report.Youth_Exited_Program__c == null && youthExited > 0) {
      report.Youth_Exited_Program__c = String.valueOf(youthExited);
    }
    if (report.Youth_Completed_Program__c == null && youthCompleted > 0) {
      report.Youth_Completed_Program__c = String.valueOf(youthCompleted);
    }

    if (report.Match_Met_Minimum_Match_Length__c == null && matchLength8 > 0) {
      report.Match_Met_Minimum_Match_Length__c = matchLength8;
    }
    if (
      report.Match_Exceeded_Minimum_Match_Length__c == null &&
      matchLengthMoreThan8 > 0
    ) {
      report.Match_Exceeded_Minimum_Match_Length__c = matchLengthMoreThan8;
    }
    if (report.Match_Closed_Early__c == null && matchLengthLessThan8 > 0) {
      report.Match_Closed_Early__c = matchLengthLessThan8;
    }

    if (report.Youth_with_Parents_Actively_Serving__c == null) {
      report.Youth_with_Parents_Actively_Serving__c = String.valueOf(
        parentsMilitary
      );
    }
    if (report.Youth_with_Incarcerate_Parent__c == null) {
      report.Youth_with_Incarcerate_Parent__c = String.valueOf(
        parentsIncarcerated
      );
    }
    if (report.Youth_Identify_as_Native_American__c == null) {
      report.Youth_Identify_as_Native_American__c = nativeAmerican;
    }

    if (
      report.Youth_with_Delinquent_Offenses__c == null ||
      report.Youth_Recommitted_to_Juvenile_Facility__c == null ||
      report.Youth_Sentenced_to_Adult_Prison__c == null ||
      report.Youth_Received_Additional_Sentence__c == null
    ) {
      report.Have_Youth_Offended__c = false;
    }
  }

  public void getTotalYouthServerd() {
    //report.New_Youth_Served__c = youthAdded;
    if (
      report.Previous_Youth_Served__c != null &&
      report.New_Youth_Served__c != null
    ) {
      totalYouthServed =
        Integer.valueOf(report.Previous_Youth_Served__c) +
        Integer.valueOf(report.New_Youth_Served__c);
    }
    system.debug('>>> totalYouthServed = ' + totalYouthServed);
    report.Youth_Served_via_Evidence_Based_Program__c = totalYouthServed;
    report.Youth_with_Social_Support_Mentoring__c = totalYouthServed;
    report.Youth_Tracked_for_Juvenile_Offenses__c = totalYouthServed;
  }

  public void resetOutputs() {
    report.New_Youth_Served__c = String.valueOf(youthAdded);
    report.Youth_Exited_Program__c = String.valueOf(youthExited);
    report.Youth_Completed_Program__c = String.valueOf(youthCompleted);
    report.Youth_with_Parents_Actively_Serving__c = String.valueOf(
      parentsMilitary
    );
    report.Youth_with_Incarcerate_Parent__c = String.valueOf(
      parentsIncarcerated
    );
    report.Youth_Identify_as_Native_American__c = nativeAmerican;
  }

  public void resetMatchDetails() {
    report.Match_Met_Minimum_Match_Length__c = matchLength8;
    report.Match_Exceeded_Minimum_Match_Length__c = matchLengthMoreThan8;
    report.Match_Closed_Early__c = matchLengthLessThan8;
  }

  // BEGIN getAttList
  public void getAttList() {
    att_list.clear();
    Grantee_Report__c g = [
      SELECT
        Id,
        (
          SELECT Id, Name, Description
          FROM Attachments
          ORDER BY LastModifiedDate DESC
        )
      FROM Grantee_Report__c
      WHERE Id = :report.Id
    ];
    for (Attachment a : g.Attachments) {
      att_list.add(a);
    }
  }
  // END getAttList

  // BEGIN deleteAtt
  public void deleteAtt() {
    if (deleteAttId != null) {
      Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteAttId];
      if (a != null) {
        delete a;
      }
    }
    getAttList();
  }
  // END deleteAtt

  public PageReference previous() {
    //CurrentPage = CurrentPage - 1;
    PageReference pr = new PageReference(
      '/' +
      portalName +
      'GranteeReportForm?ReportId=' +
      report.Id +
      '&currentPage=' +
      (currentPage - 1)
    );
    pr.setRedirect(true);
    return pr;
  }

  public void errorCheck() {
    errorMessage = '';
    if (
      report.Programs_with_Active_Partners__c != null &&
      report.Mentoring_Programs_Operated__c != null &&
      Integer.valueOf(report.Programs_with_Active_Partners__c) >
      report.Mentoring_Programs_Operated__c
    ) {
      errorMessage = 'Outcomes 1A: Number of mentoring programs with active partners should not exceed number of mentoring programs.';
    }
  }

  public PageReference saveReport() {
    getTotals();
    getTotalYouthServerd();
    errorCheck();
    if (errorMessage == '') {
      if (report.Report_Status__c == null) {
        report.Report_Status__c = 'In Progress';
      }
      if (report.Grant__c == null && GrantId != null) {
        report.Grant__c = GrantId;
      }
      report.Start_Date__c = startDate;
      report.End_Date__c = endDate;

      try {
        reportClass.upsertReport(report);
        PageReference pr = new PageReference(
          '/' +
          portalName +
          'GranteeReportForm?ReportId=' +
          report.Id +
          '&currentPage=' +
          (currentPage + 1)
        );
        pr.setRedirect(true);
        return pr;
      } catch (Exception e) {
        errorMessage = e.getMessage();
        system.debug('error = ' + e.getMessage());
        return null;
      }
    }
    return null;
  }

  public PageReference submit() {
    report.Report_Status__c = 'Submitted';
    report.Submitted_Date__c = date.today();
    report.Submitted_By__c = currentUser.ContactID;

    String mh =
      fdt +
      ': Modification Submitted by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (report.Modification_History__c == null) {
      report.Modification_History__c = '';
    }
    report.Modification_History__c += ' \r\n' + mh;

    reportClass.upsertReport(report);

    PageReference pr = new PageReference('/' + portalName + 'ReportList');
    pr.setRedirect(true);
    return pr;
  }

  public PageReference sendBack() {
    report.Report_Status__c = 'Revisions Needed';

    String mh =
      fdt +
      ': Report Sent Back by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (report.Modification_History__c == null) {
      report.Modification_History__c = '';
    }
    report.Modification_History__c += ' \r\n' + mh;

    try {
      update report;
      system.debug('>>>> Report update successful. report = ' + report);
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
      return null;
    }

    PageReference pr = new PageReference('/' + portalName + 'ReportList');
    pr.setRedirect(true);
    return pr;
  }

  public PageReference approveReport() {
    report.Report_Status__c = 'Approved';
    report.Approved_Date__c = date.today();

    String mh =
      fdt +
      ': Report Approved by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (report.Modification_History__c == null) {
      report.Modification_History__c = '';
    }
    report.Modification_History__c += ' \r\n' + mh;

    try {
      update report;
      system.debug('>>>> Report update successful. report = ' + report);
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
      return null;
    }

    PageReference pr = new PageReference('/' + portalName + 'ReportList');
    pr.setRedirect(true);
    return pr;
  }

  public void attPopup() {
    getAttList();
    if (displayAttPopup == true) {
      displayAttPopup = false;
    } else {
      displayAttPopup = true;
    }
  }

  public void sendBackPopup() {
    if (displaySendBackPopup == true) {
      displaySendBackPopup = false;
    } else {
      displaySendBackPopup = true;
    }
  }
}
