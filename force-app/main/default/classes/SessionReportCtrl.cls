public with sharing class SessionReportCtrl {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public Id siteId { get; set; }
  public Account acct { get; set; }

  private SessionReportClass src = new SessionReportClass();
  public Id reportId { get; set; }
  public Session_Report__c report { get; set; }

  public Integer currentTab { get; set; }
  public String tabTitle { get; set; }
  public Boolean isQ1 { get; set; }
  public Boolean showForm { get; set; }
  public Boolean readOnly { get; set; }
  public String statusColor { get; set; }
  public String errorMessage { get; set; }
  public String successMessage { get; set; }
  public Boolean displaySendBackPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public String action { get; set; }

  public Date dt = date.today();
  public String fdt = dt.format();

  public SessionReportCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    if (userAcct != null)
      siteId = userAcct.Id;
    String urlSiteId = ApexPages.currentPage().getParameters().get('siteId');
    if (urlSiteId != '' && urlSiteId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlSiteId)
          .matches()
      ) {
        siteId = Id.valueOf(urlSiteId);
      }
    }

    acct = new Account();
    reportId = ApexPages.currentPage().getParameters().get('reportId');
    report = new Session_Report__c();

    String tab = ApexPages.currentPage().getParameters().get('tab');
    if (tab == null || tab == '') {
      currentTab = 1;
    } else {
      currentTab = Integer.valueOf(tab);
    }
    readOnly = true;
    errorMessage = '';
    isQ1 = false;
    getTabTitle();
  }

  public PageReference init() {
    if (siteId != null && reportId == null) {
      getAcct();
      reportId = src.getLatestReportId(siteId);
      getReport();
    } else if (reportId != null) {
      getReport();
    }
    if (report.Id == null) {
      PageReference pr = new PageReference('/ProgressReportList');
      pr.setRedirect(true);
      return pr;
    }
    if (
      userAcctType != 'National Organization' &&
      report.Status__c != 'Submitted' &&
      report.Status__c != 'Approved'
    ) {
      readOnly = false;
    }
    showForm = true;
    return null;
  }

  public Account getAcct() {
    Account[] accts = [SELECT Id, Name FROM Account WHERE Id = :siteId];
    if (accts.size() > 0) {
      acct = accts[0];
    }
    return acct;
  }

  public void getReport() {
    report = src.getReport(reportId, null, null);
    if (report.Status__c == null || report.Status__c == 'Not Started') {
      statusColor = 'text-danger';
    }
    if (report.Status__c == 'Submitted' || report.Status__c == 'Approved') {
      statusColor = 'text-success';
    } else {
      statusColor = 'text-warning';
    }

    String rp = '';
    if (report.Reporting_Period__c != null)
      rp = report.Reporting_Period__c;
    if (rp.contains('Q1') && report.Year__c < '2019')
      isQ1 = true;

    if (siteId == null) {
      siteId = report.Site__c;
      getAcct();
    }
  }

  // BEGIN getTabTitle
  public void getTabTitle() {
    if (currentTab == 1) {
      tabTitle = 'IMPLEMENTATION REPORTING';
    }
    if (currentTab == 2) {
      tabTitle = 'ADDITIONAL INFO & COMMENTS ';
    }
    //if(currentTab == 3) {
    //    tabTitle = 'QUARTERLY ADMIN/FISCAL REPORT';
    //}
    if (currentTab == 3) {
      tabTitle = 'ATTACHMENTS & NOTES ';
    }
  }
  // END getTabTitle

  // BEGIN fieldValidation
  public void fieldValidation() {
    errorMessage = '';
    if (currentTab == 1) {
      if (!isQ1) {
        if (
          report.Number_of_Youth_Participated__c == null ||
          report.Number_of_Youth_Never_Participated__c == null ||
          report.Serving_More_Youth_Than_Required__c == null ||
          report.Number_of_Youth_in_Addition_to_Required__c == null ||
          report.Number_Participants_Completed_Pre_Test__c == null ||
          report.Number_Participants_Completed_Post_Test__c == null ||
          report.Youth_Participated_in_Physical_Activity__c == null ||
          report.Number_of_Physical_Activity_Challenges__c == null
        ) {
          errorMessage = 'All Fields are Required';
        }
      }
      if (
        report.Number_of_Sessions_Completed__c == null ||
        report.Activities_Hosted_or_Participated__c == null ||
        report.How_Curriculum_was_Adapted__c == null ||
        report.How_Healthy_Food_Choices_Implemented__c == null ||
        report.Healthy_Snack_Preparation_Implemented__c == null ||
        //report.Average_Club_Wide_Participation__c == null ||
        report.Type_of_Club_Wide_Physical_Activit__c == null ||
        report.Parents_Guardians_Recruited_to_Volunteer__c == null ||
        report.How_Parents_Guardians_Recruited__c == null ||
        report.Type_Activities_Guardians_Participated__c == null ||
        report.Number_of_Volunteers_Recruited__c == null ||
        report.How_Volunteers_Recruited__c == null ||
        report.Type_of_Volunteer_Activities__c == null ||
        report.Has_Signed_Memorandum_of_Agreement__c == null ||
        report.Community_Health_Partner_Involvement__c == null ||
        report.Additional_Community_Partners_Recruited__c == null ||
        report.How_Community_Partners_Recruited__c == null ||
        report.Type_of_Support_From_Community_Partners__c == null ||
        report.Status_of_Community_Service_Project_Plan__c == null ||
        report.How_Community_Service_Project_Supports__c == null
      ) {
        errorMessage = 'All Fields are Required';
      }
    }
    if (currentTab == 2) {
      if (
        report.What_are_People_Saying_About_Program__c == null ||
        report.Describe_Program_Successes__c == null ||
        report.Describe_Program_Challenges__c == null ||
        report.Feedback_on_Program_Curriculum__c == null ||
        report.Plans_for_Continuing_Program__c == null
      ) {
        errorMessage = 'All Fields are Required';
      }
    }
    if (errorMessage != '')
      successMessage = '';
  }
  // END fieldValidation

  // BEGIN next
  public PageReference next() {
    errorMessage = '';
    save();
    fieldValidation();
    if (ApexPages.hasMessages() || errorMessage != '')
      return null;
    Integer tab = currentTab + 1;
    PageReference pr = new PageReference(
      '/ProgressReport?reportId=' +
      report.Id +
      '&tab=' +
      tab
    );
    pr.setRedirect(true);
    return pr;
  }
  // END next

  // BEGIN previous
  public PageReference previous() {
    save();
    if (ApexPages.hasMessages())
      return null;
    Integer tab = currentTab - 1;
    PageReference pr = new PageReference(
      '/ProgressReport?reportId=' +
      report.Id +
      '&tab=' +
      tab
    );
    pr.setRedirect(true);
    return pr;
  }
  // END previous

  // BEGIN save
  public void save() {
    errorMessage = '';
    successMessage = '';
    if (report.Id != null) {
      report.Status__c = 'In Progress';
      src.upsertReport(report);
      if (ApexPages.hasMessages()) {
        errorMessage = string.valueOf(ApexPages.getMessages());
      } else {
        successMessage = 'Save Successful';
      }
    }
  }
  // END save

  // BEGIN submit
  public PageReference submit() {
    String mh = '';
    if (
      report.Status__c == 'Not Started' ||
      report.Status__c == 'In Progress'
    ) {
      report.Submitted_Date__c = dt;
      report.Submitted_By__c = currentUser.ContactID;
      mh =
        fdt +
        ': Progress Report submitted by ' +
        currentUser.Contact.Name +
        ' (' +
        currentUser.Id +
        ')';
    } else {
      mh =
        fdt +
        ': Modification submitted by ' +
        currentUser.Contact.Name +
        ' (' +
        currentUser.Id +
        ')';
    }
    if (report.Modification_History__c == null) {
      report.Modification_History__c = '';
    }
    report.Modification_History__c += ' \r\n' + mh;

    report.Status__c = 'Submitted';
    src.upsertReport(report);

    if (ApexPages.hasMessages())
      return null;
    showForm = false;
    successMessage = 'Thank you for submitting your progress report.';
    return null;
  }
  // END submit

  // BEGIN sendBack
  public void sendBack() {
    report.Status__c = 'Revisions Needed';
    String mh =
      fdt +
      ': Progress Report sent back by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (report.Modification_History__c == null) {
      report.Modification_History__c = '';
    }
    report.Modification_History__c += ' \r\n' + mh;
    src.upsertReport(report);
    hideSendBackPopup();
  }
  // END sendBack

  // BEGIN approve
  public void approve() {
    report.Status__c = 'Approved';
    String mh =
      fdt +
      ': Progress Report approved by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (report.Modification_History__c == null) {
      report.Modification_History__c = '';
    }
    report.Modification_History__c += ' \r\n' + mh;
    src.upsertReport(report);
    hideApprovePopup();
  }
  // END approve

  // BEGIN popups
  public void showSendBackPopup() {
    displaySendBackPopup = true;
  }
  public void hideSendBackPopup() {
    displaySendBackPopup = false;
  }

  public void showApprovePopup() {
    displayApprovePopup = true;
  }
  public void hideApprovePopup() {
    displayApprovePopup = false;
  }
  // END popups
}
