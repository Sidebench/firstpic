public without sharing class ProgressReportCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  //BEGIN BJAG Code
  private FieldLabelClass flc = new FieldLabelClass();
  public Map<String, String> fields { get; set; }
  //END BJAG Code

  private ProgressReportClass prc = new ProgressReportClass();
  private AttachmentClass ac = new AttachmentClass();
  private PaginationClass pc = new PaginationClass();
  private GetIdFromString gifs = new GetIdFromString();
  private SchemaPicklistFields spf = new SchemaPicklistFields();
  private SelectOptionsClass soc = new SelectOptionsClass();

  private Date dt = date.today();
  private String fdt = dt.format();

  public Id orgId { get; set; }
  public List<Progress_Report__c> allItems { get; set; }
  public List<Progress_Report__c> items { get; set; }
  public Progress_Report__c report { get; set; }
  public List<Attachment> atts { get; set; }

  public String orgName { get; set; }
  public String siteId { get; set; }
  public String reportId { get; set; }
  public String grantId { get; set; }
  public String grantStatus { get; set; }
  public String month { get; set; }
  public List<SelectOption> monthOptions { get; set; }
  public Integer year { get; set; }
  public List<SelectOption> yearOptions { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }

  public Boolean showOnlyNeedsAttention { get; set; }
  public Boolean showOnlyNeedsReview { get; set; }
  public Boolean showOnlyOverdue { get; set; }
  public Boolean readOnly { get; set; }

  public Boolean displayAttPopup { get; set; }
  public Boolean displaySendBackPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public String errorMessage { get; set; }
  public String successMessage { get; set; }
  public String url { get; set; }
  public String reportingPeriod { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public ProgressReportCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    portalName = uc.userProfile;

    String urlSiteId = ApexPages.currentPage().getParameters().get('siteId');
    siteId = gifs.getId(urlSiteId);
    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);
    grantStatus = ApexPages.currentPage().getParameters().get('grantStatus');
    status = ApexPages.currentPage().getParameters().get('status');
    month = ApexPages.currentPage().getParameters().get('month');

    showOnlyNeedsAttention = false;
    showOnlyNeedsReview = false;
    showOnlyOverdue = false;
    String overdueUrl = ApexPages.currentPage().getParameters().get('overdue');
    if (overdueUrl == 'true')
      showOnlyOverdue = true;

    allItems = new List<Progress_Report__c>();
    items = new List<Progress_Report__c>();
    report = new Progress_Report__c();
    atts = new List<Attachment>();
  }

  public void getOptions() {
    orgId = null;
    if (userAcctType == 'Site')
      orgId = userAcct.Id;
    String urlOrgId = ApexPages.currentPage().getParameters().get('orgId');
    orgId = gifs.getId(urlOrgId);

    Date dt = date.today();
    monthOptions = new List<SelectOption>();
    monthOptions = spf.getPicklistOptions(
      'Progress_Report__c',
      'Month__c',
      'View All'
    );

    yearOptions = new List<SelectOption>();
    if (portalName == 'DMV')
      yearOptions = spf.getPicklistOptions('Progress_Report__c', 'Year__c', '');
    else
      yearOptions = soc.getGrantYearOptions(userAcct.Id, userAcctType);
    if (year == null && yearOptions.size() > 0)
      year = Integer.valueOf(
        yearOptions.get(yearOptions.size() - 1).getValue()
      );

    statusOptions = new List<SelectOption>();
    statusOptions = spf.getPicklistOptions(
      'Progress_Report__c',
      'Status__c',
      'All Reports'
    );
    if (status == '' || status == null)
      status = 'All Reports';

    sortByOptions = new List<SelectOption>();
    sortByOptions.add(new SelectOption('Name', 'Report Id'));
    if (userAcctType != 'Site')
      sortByOptions.add(
        new SelectOption('Organization_Name__c', 'Organization')
      );
    sortByOptions.add(new SelectOption('Status__c', 'Status'));
    sortByOptions.add(new SelectOption('Submitted_Date__c', 'Submitted Date'));
    sortBy = 'Name';

    getLists();
  }

  public void getLists() {
    String soqlAND = '';
    if (showOnlyOverdue)
      soqlAND += ' AND Is_Overdue__c = true';
    if (showOnlyNeedsReview)
      soqlAND += ' AND Needs_Additional_Review__c = true';
    if (showOnlyNeedsAttention)
      soqlAND += ' AND Needs_Attention__c = true';
    if (grantId != null)
      soqlAND += ' AND Grant__c = \'' + grantId + '\'';
    if (grantStatus == 'Closed')
      soqlAND += ' AND Grant_Status__c = \'Closed\'';
    else
      soqlAND += ' AND Grant_Status__c != \'Closed\'';
    if (portalName == 'DMV')
      soqlAND += ' AND Year__c = \'' + String.valueOf(year) + '\'';
    else
      soqlAND += ' AND Grant_Year__c = \'' + String.valueOf(year) + '\'';
    allItems = prc.getRelatedReportList(
      userAcct.Id,
      orgId,
      userAcctType,
      orgName,
      reportId,
      month,
      null,
      status,
      sortBy,
      soqlAND
    );
    totalSize = allItems.size();
    first();
  }

  public void getReport() {
    String urlReportId = ApexPages.currentPage()
      .getParameters()
      .get('reportId');
    reportId = gifs.getId(urlReportId);
    report = prc.getReport(reportId, null, null);
    report.Previous_Status__c = report.Status__c;
    if (portalName == 'DMV')
      url = '/DMVProgressReports';
    else if (report.RecordType.Name == 'Quarterly')
      url = '/QuarterlyProgressReports';
    else
      url = '/MonthlyProgressReports';
    if (
      userAcctType == 'National Organization' ||
      report.Status__c == 'Submitted' ||
      report.Grant_Status__c == 'Closed'
    )
      readOnly = true;
    getAtts();
  }

  public void getAtts() {
    atts.clear();
    //Set<String> names = new Set<String>();
    Id rId;
    if (report.Id != null)
      rId = report.Id;
    else if (reportId != null)
      rId = reportId;
    for (Attachment a : ac.getAttachments(rId, null)) {
      //if(!names.contains(a.Name)) {
      atts.add(a);
      //names.add(a.Name);
      //}
    }
  }

  public void edit() {
    report.Status__c = 'In Progress';
    prc.upsertReport(report);
  }

  public void save() {
    errorMessage = '';
    successMessage = '';
    if (report.Status__c == 'Not Started' || report.Status__c == null)
      report.Status__c = 'In Progress';
    prc.upsertReport(report);
    if (ApexPages.hasMessages())
      errorMessage += string.valueOf(ApexPages.getMessages());
    else
      successMessage = 'Save successful.';
  }

  public PageReference sendBack() {
    errorMessage = '';
    successMessage = '';
    report.Status__c = 'Revisions Needed';
    report.Sent_Back_By__c = currentUser.ContactId;
    report.Modification_History__c = getModHist('Sent Back');
    prc.upsertReport(report);

    if (ApexPages.hasMessages()) {
      errorMessage += string.valueOf(ApexPages.getMessages());
      return null;
    }

    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  public void markAsReviewed() {
    errorMessage = '';
    successMessage = '';
    report.Reviewed_By__c = currentUser.ContactId;
    report.Reviewed_Date__c = date.today();
    report.Modification_History__c = getModHist('Reviewed');
    prc.upsertReport(report);
    if (ApexPages.hasMessages())
      errorMessage += string.valueOf(ApexPages.getMessages());
    else
      successMessage = 'Save successful.';
  }

  public PageReference approve() {
    errorMessage = '';
    successMessage = '';
    report.Status__c = 'Approved';
    report.Modification_History__c = getModHist('Approved');
    prc.upsertReport(report);

    if (ApexPages.hasMessages()) {
      errorMessage += string.valueOf(ApexPages.getMessages());
      return null;
    }

    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  // BEGIN fieldValidation
  public PageReference monthlyFieldValidation() {
    errorMessage = '';
    successMessage = '';

    if (report.Youth_Served__c == null)
      errorMessage += 'Question 1 is Required <br />';
    if (report.Number_of_Mentors__c == null)
      errorMessage += 'Question 3 is Required <br />';
    if (report.Number_of_Mentors_Left_Program__c == null)
      errorMessage += 'Question 4 is Required <br />';
    if (report.Number_of_New_Mentors_this_Month__c == null)
      errorMessage += 'Question 5 is Required <br />';
    if (
      report.Background_Checks__c == null ||
      report.Background_Checks__c == ''
    )
      errorMessage += 'Question 6 is Required <br />';
    if (
      report.Problems_Barriers_Encountered__c == null ||
      report.Problems_Barriers_Encountered__c == ''
    )
      errorMessage += 'Question 7 is Required <br />';
    if (
      report.Problems_Barriers_Encountered__c == 'Yes' &&
      report.Problems_Barriers_Encountered_Details__c == null
    )
      errorMessage += 'Question 7a is Required <br />';
    if (
      report.Assistance_Needed__c == null ||
      report.Assistance_Needed__c == ''
    )
      errorMessage += 'Question 8 is Required <br />';
    if (
      report.Assistance_Needed__c == 'Yes' &&
      report.Assistance_Needed_Details__c == null
    )
      errorMessage += 'Question 8a is Required <br />';

    Boolean hasAtt1 = false;
    for (Attachment a : atts) {
      if (a.Name == 'Attendance Report')
        hasAtt1 = true;
    }
    if (hasAtt1 == false)
      errorMessage += 'Attendance Report is Required <br />';
    if (errorMessage != '') {
      successMessage = '';
      return null;
    } else {
      setStatusToSubmitted();
      prc.upsertReport(report);
    }
    if (ApexPages.hasMessages())
      return null;
    else
      return new PageReference(url);
  }

  public PageReference quarterlyFieldValidation() {
    errorMessage = '';
    successMessage = '';
    if (report.Current_Module_Name__c == null)
      errorMessage += 'Question 1 is Required <br />';
    if (report.Recently_Completed_Session__c == null)
      errorMessage += 'Question 2 is Required <br />';
    if (report.Days_and_Times_Running_Program__c == null)
      errorMessage += 'Question 3 is Required <br />';
    if (report.Number_Mentees_Currently_Participating__c == null)
      errorMessage += 'Question 4 is Required <br />';
    if (report.Number_of_Adult_Mentors__c == null)
      errorMessage += 'Question 5 is Required <br />';
    if (report.Number_of_Teen_Mentors__c == null)
      errorMessage += 'Question 6 is Required <br />';
    if (report.Planning_Required_Enrichment_Activity__c == null)
      errorMessage += 'Question 7 is Required <br />';
    if (report.Planned_Enrichment_Activity_Description__c == null)
      errorMessage += 'Question 8 is Required <br />';
    if (report.Accomplishments_this_Reporting_Period__c == null)
      errorMessage += 'Question 9 is Required <br />';
    if (report.Greatest_Challenge_this_Reporting_Period__c == null)
      errorMessage += 'Question 10 is Required <br />';
    if (report.Assistance_Needed_Details__c == null)
      errorMessage += 'Question 11 is Required <br />';

    if (atts.size() == 0)
      errorMessage += 'Mentoring match tracking sheet is Required';
    if (errorMessage != '')
      successMessage = '';
    else {
      setStatusToSubmitted();
      prc.upsertReport(report);
    }
    if (ApexPages.hasMessages() || errorMessage != '')
      return null;
    else
      return new PageReference(url);
  }

  public PageReference dmvFieldValidation() {
    errorMessage = '';

    if (
      report.Youth_Successfully_Completed_Program__c == null ||
      report.Number_of_Mentors__c == null ||
      report.Number_of_Sessions_Attended__c == null ||
      report.Projects_Effectiveness__c == null ||
      report.Progress_of_Completed_Goals__c == null ||
      report.Problems_Barriers_Encountered_Details__c == null ||
      report.Reason_Requesting_Funds__c == null
    ) {
      errorMessage += 'All fields are required.';
    }
    if (errorMessage != '') {
      successMessage = '';
      return null;
    } else {
      setStatusToSubmitted();
      prc.upsertReport(report);
    }
    if (ApexPages.hasMessages())
      return null;
    else
      return new PageReference(url);
  }

  public void setStatusToSubmitted() {
    report.Status__c = 'Submitted';
    report.Submitted_By__c = currentUser.ContactId;
    report.Submitted_Date__c = date.today();

    String mh =
      fdt +
      ': Submitted by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (report.Modification_History__c == null) {
      report.Modification_History__c = '';
    }
    report.Modification_History__c += ' \r\n' + mh;
  }
  // END fieldValidation

  // BEGIN modHist
  public String getModHist(String status) {
    Date dt = date.today();
    String fdt = dt.format();
    String modHist = '';
    if (report.Modification_History__c != null) {
      modHist = report.Modification_History__c;
    }
    modHist +=
      ' \r\n' +
      fdt +
      ': Report ' +
      status +
      ' by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    return modHist;
  }
  // END modHist

  // BEGIN popups
  public void showAttPopup() {
    displayAttPopup = true;
  }
  public void hideAttPopup() {
    displayAttPopup = false;
    getAtts();
  }

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

  // BEGIN Pagination
  public void first() {
    counter = 0;
    items = pc.first(allItems, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = true;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void next() {
    counter = counter + limitSize;
    items = pc.next(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void previous() {
    counter = counter - limitSize;
    items = pc.previous(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = pc.getDisablePrevious(counter);
    disableNext = false;
  }

  public void last() {
    counter = pc.getLastCounter(counter, limitSize, totalSize);
    items = pc.last(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = true;
  }
  // END Pagination

  // BEGIN BJAG method
  public void setBJAG() {
    report.Organization__r = [
      SELECT Id
      FROM Account
      WHERE Name = 'BJAG Placeholder'
      LIMIT 1
    ];
    report.Grant__r = [
      SELECT Id
      FROM Grant__c
      WHERE Name = 'BJAG Placeholder'
      LIMIT 1
    ];

    fields = new Map<String, String>();
    fields = flc.getFieldLabelMap(
      'Progress_Report__c',
      'BJAG',
      null,
      ' AND Year__c includes (\'2021\')'
    );
  }
  // END BJAG Method
}
