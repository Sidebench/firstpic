public with sharing class DCTATReportCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  private DCTATReportClass rc = new DCTATReportClass();
  private FieldLabelClass flc = new FieldLabelClass();

  public Id reportId { get; set; }
  public Grantee_Report__c report { get; set; }
  public List<Field_Label__c> fields { get; set; }
  public Map<String, String> labels { get; set; }

  public Boolean readOnly { get; set; }
  public Boolean displaySendBackPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public String errorMessage { get; set; }
  public String successMessage { get; set; }
  public String url { get; set; }

  public DCTATReportCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    portalName = uc.userProfile;
    url = '/DCTATReports';
    if (portalName == 'STEM')
      url = '/QuarterlyProgressReports';

    report = new Grantee_Report__c();
    String urlReportId = ApexPages.currentPage()
      .getParameters()
      .get('reportId');
    if (urlReportId != '' && urlReportId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlReportId)
          .matches()
      ) {
        reportId = Id.valueOf(urlReportId);
      }
    }
    report = rc.getReport(reportId);
    if (report != null) {
      String grantType = report.Grant_Type__c;
      if (report.Grant_Type__c == null)
        grantType = portalName;
      String soqlAND =
        ' AND (Year__c  INCLUDES(\'' +
        String.valueOf(report.Year__c) +
        '\') OR Year__c = \'All\' OR Year__c = null)';
      if (report.FirstPic_National_Org_Code__c == 'Ripken') {
        if (report.Quarter__c == 'Q2') {
          soqlAND += ' AND (Report_Type__c = \'Mid-Year\' OR Report_Type__c = \'All\')';
        } else if (report.Quarter__c == 'Q4') {
          soqlAND += ' AND (Report_Type__c = \'Final\' OR Report_Type__c = \'All\')';
        }
      }
      fields = flc.getFields('Grantee_Report__c', grantType, null, soqlAND);
      labels = flc.getFieldLabelMap(
        'Grantee_Report__c',
        grantType,
        null,
        soqlAND
      );
      system.debug(fields);
      if (
        userAcctType == 'National Organization' ||
        report.Report_Status__c == 'Submitted' ||
        report.Report_Status__c == 'Approved' ||
        report.Grant_Status__c == 'Closed'
      )
        readOnly = true;
    }
  }

  public void save() {
    errorMessage = '';
    successMessage = '';
    if (
      report.Report_Status__c == 'Requested' ||
      report.Report_Status__c == null
    )
      report.Report_Status__c = 'In Progress';
    report.Contact__c = currentUser.ContactId;
    rc.upsertReport(report);
    if (ApexPages.hasMessages())
      errorMessage += string.valueOf(ApexPages.getMessages());
    else
      successMessage = 'Save successful.';
  }

  public PageReference submit() {
    errorMessage = '';
    successMessage = '';

    if (portalName == 'Ripken')
      ripkenFieldValidation();
    else if (portalName == 'STEM')
      stemFieldValidation();
    if (errorMessage != '')
      return null;

    report.Report_Status__c = 'Submitted';
    report.Submitted_By__c = currentUser.ContactId;
    report.Submitted_Date__c = date.today();
    report.Modification_History__c = getModHist('Submitted');
    rc.upsertReport(report);
    if (ApexPages.hasMessages()) {
      errorMessage += string.valueOf(ApexPages.getMessages());
      return null;
    }
    return new PageReference(url);
  }

  public PageReference sendBack() {
    errorMessage = '';
    successMessage = '';
    report.Report_Status__c = 'Revisions Needed';
    report.Sent_Back_By__c = currentUser.ContactId;
    report.Sent_Back_Date__c = date.today();
    report.Modification_History__c = getModHist('Sent Back');
    rc.upsertReport(report);

    if (ApexPages.hasMessages()) {
      errorMessage += string.valueOf(ApexPages.getMessages());
      return null;
    }
    return new PageReference(url);
  }

  public PageReference approve() {
    errorMessage = '';
    successMessage = '';
    report.Report_Status__c = 'Approved';
    report.Modification_History__c = getModHist('Approved');
    rc.upsertReport(report);

    if (ApexPages.hasMessages()) {
      errorMessage += string.valueOf(ApexPages.getMessages());
      return null;
    }
    return new PageReference(url);
  }

  public void ripkenFieldValidation() {
    for (Field_Label__c i : fields) {
      if (i.Required__c == true && i.Field_API__c != null) {
        if (
          report.get(i.Field_API__c) == null ||
          report.get(i.Field_API__c) == ''
        )
          errorMessage +=
            'Missing field is required: ' +
            labels.get(i.Field_API__c) +
            '<br />';
      }
    }

    if (report.Certified_By__c == null || report.Certified_Date__c == null) {
      errorMessage += 'Please certify that the progress report numbers and statements of program progress are true.';
    }

    if (report.Quarter__c == 'Q4') {
      for (
        Grantee_Report__c r : rc.getRelatedReportList(
          userAcct.Id,
          null,
          null,
          null,
          ' AND Grant__c = \'' +
          report.Grant__c +
          '\''
        )
      ) {
        if (
          r.Year__c == report.Year__c &&
          r.Quarter__c == 'Q2' &&
          (r.Report_Status__c == 'Not Started' ||
          r.Report_Status__c == 'In Progress' ||
          r.Report_Status__c == 'Revisions Needed')
        ) {
          errorMessage += 'You must have a submitted and approved Mid-Year report for this grant before you can submit your Final Report. <br />';
        }
      }
    }
  }

  public void stemFieldValidation() {
    if (
      report.Race_Ethnicity__c == null ||
      report.Justice__c == null ||
      report.Gender__c == null ||
      report.Age__c == null ||
      report.Geography__c == null ||
      report.Other__c == null ||
      report.Previous_Youth_Served__c == null ||
      report.New_Youth_Served__c == null ||
      report.Youth_with_Parents_Actively_Serving__c == null ||
      report.Youth_with_Increased_Social_Support__c == null ||
      report.Youth_with_Delinquent_Offenses__c == null ||
      report.Youth_Recommitted_to_Juvenile_Facility__c == null ||
      report.Youth_Sentenced_to_Adult_Prison__c == null ||
      report.Youth_Received_Additional_Sentence__c == null ||
      report.Youth_Completed_20_or_More_Sessions__c == null ||
      report.Youth_Completed_Less_Than_20_Sessions__c == null ||
      report.Youth_Exited_Program__c == null ||
      report.Participated_More_Than_6_Months__c == null ||
      report.Participated_Fewer_Than_6_Months__c == null ||
      report.Participated_More_Than_4_Hours_per_Month__c == null ||
      report.Participated_Less_Than_4_Hours_per_Month__c == null ||
      report.Previous_Mentors__c == null ||
      report.New_Mentors_Began_Training__c == null ||
      report.New_Mentors__c == null ||
      report.New_Mentors_Completed_Training__c == null ||
      report.Mentors_with_Increased_Knowledge__c == null ||
      report.Mentors_Left_the_Program__c == null ||
      report.Programs_with_Active_Partners__c == null ||
      report.Accomplishments__c == null ||
      report.Describe_How_Plan_Was_Implemented__c == null ||
      report.Problems_Barriers__c == null ||
      report.Program_on_Track__c == null ||
      report.Major_Activities_Planned__c == null
    ) {
      errorMessage = 'All fields are required. <br />';
    }
  }

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
