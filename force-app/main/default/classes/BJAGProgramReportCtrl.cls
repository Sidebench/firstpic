public without sharing class BJAGProgramReportCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  private FieldLabelClass flc = new FieldLabelClass();
  private ProgressReportClass prc = new ProgressReportClass();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  private Date dt = date.today();
  private String fdt = dt.format();

  public Progress_Report__c report { get; set; }
  public Map<String, String> fields { get; set; }

  public String reportId { get; set; }
  public String errorMessage { get; set; }
  public String successMessage { get; set; }
  public Boolean readOnly { get; set; }
  public Boolean review { get; set; }

  public List<SelectOption> topicOptions {
    get {
      return spf.getPicklistOptions(
        'Progress_Report__c',
        'Topics_Surveyed__c',
        null
      );
    }
    set;
  }

  public String[] topics {
    get {
      String[] selected = new List<String>();
      List<SelectOption> sos = this.topicOptions;
      for (SelectOption s : sos) {
        if (
          this.report.Topics_Surveyed__c != null &&
          this.report.Topics_Surveyed__c.contains(s.getValue())
        )
          selected.add(s.getValue());
      }
      return selected;
    }
    public set {
      String selectedConcat = '';
      for (String s : value) {
        if (selectedConcat == '')
          selectedConcat += s;
        else
          selectedConcat += ';' + s;
      }
      report.Topics_Surveyed__c = selectedConcat;
    }
  }

  public BJAGProgramReportCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    portalName = uc.userProfile;

    reportId = ApexPages.currentPage().getParameters().get('report');
    initBJAG();

    review = false;
    readOnly = true;

    if (
      (report.Status__c == 'Not Started' ||
      report.Status__c == 'In Progress' ||
      report.Status__c == 'Revisions Needed') &&
      userAcctType == 'Local Organization'
    ) {
      readOnly = false;
    }

    if (
      report.Status__c == 'Submitted' &&
      userAcctType == 'National Organization'
    ) {
      review = true;
    }
  }

  // BEGIN BJAG method
  public void initBJAG() {
    fields = new Map<String, String>();
    fields = flc.getFieldLabelMap(
      'Progress_Report__c',
      'MDGO',
      null,
      ' AND Year__c includes (\'2021\')'
    );

    if (reportId == null || reportId == '') {
      Account acct = [
        SELECT Id
        FROM Account
        WHERE Name = 'BJAG Placeholder'
        LIMIT 1
      ];
      report.Organization__c = acct.Id;
      Grant__c grant = [
        SELECT Id
        FROM Grant__c
        WHERE Name = 'BJAG Placeholder'
        LIMIT 1
      ];
      report.Grant__c = grant.Id;
      report.Year__c = '2021';
      report.Quarter__c = 'Q2';
    } else {
      report = prc.getReport(reportId, null, null);
    }
  }
  // END BJAG Method

  public void validation() {
    if (report.DUNS_Number__c == null || report.DUNS_Number__c == '')
      errorMessage += 'DUNS Number is required.<br/>';

    if (report.DUNS_Number__c != null && !report.DUNS_Number__c.isNumeric())
      errorMessage += 'DUNS Number must contain numbers only.<br/>';
    if (report.DUNS_Number__c != null && report.DUNS_Number__c.length() != 9)
      errorMessage += 'DUNS Number must be 9 digits.<br/>';

    if (
      report.Organization_Name_Text__c == null ||
      report.Organization_Name_Text__c == ''
    )
      errorMessage += 'Organization Name is required.<br/>';
    if (
      report.Submitted_By_Text__c == null ||
      report.Submitted_By_Text__c == ''
    )
      errorMessage += 'Submitted By is required.<br/>';

    if (report.Youth_Served__c == null)
      errorMessage += 'Youth Served is required.<br/>';
    if (report.Number_Activities__c == null)
      errorMessage += 'Number of Activities is required.<br/>';
    if (report.Youth_Wellbeing_Increase__c == null)
      errorMessage += 'Number of Youth Reporting an Increased Wellbeing is required.<br/>';
    if (report.Number_of_Mentors__c == null)
      errorMessage += 'Number of Youth Receiving Mentorship is required.<br/>';
    if (report.Law_Enforcement_Engaged__c == null)
      errorMessage += 'Number of Law Enforement Engaged is required.<br/>';
    if (report.Increase_in_Perception_of_Social_Support__c == null)
      errorMessage += 'Number of Youth Reporting an Improved Opinion is required.<br/>';
    if (report.Law_Enforcement_Improved_Knowledge__c == null)
      errorMessage += 'Number of Law Enforcement Increased Knowledge is required.<br/>';
    if (report.Laptops_Utilized__c == null)
      errorMessage += 'Number of Laptops is required.<br/>';
    if (report.Chromebooks_Utilized__c == null)
      errorMessage += 'Number of Chromebooks is required.<br/>';

    if (
      report.Projects_Effectiveness__c == null ||
      report.Projects_Effectiveness__c == ''
    )
      errorMessage += 'Brief Narrative of Effectiveness is required.<br/>';
    if (
      report.Problems_Barriers_Encountered_Details__c == null ||
      report.Problems_Barriers_Encountered_Details__c == ''
    )
      errorMessage += 'Barriers/Challenges is required.<br/>';
    if (
      report.Reason_Requesting_Funds__c == null ||
      report.Reason_Requesting_Funds__c == ''
    )
      errorMessage += 'No or Minimal Funds Expended is required.<br/>';
    if (
      report.Major_Activities_Planned__c == null ||
      report.Major_Activities_Planned__c == ''
    )
      errorMessage += 'Activities Planned is required.<br/>';
    if (
      report.Accomplishments_this_Reporting_Period__c == null ||
      report.Accomplishments_this_Reporting_Period__c == ''
    )
      errorMessage += 'Success and/or Best Practices is required.<br/>';
    if (
      report.Innovative_Programs_Accomplishments__c == null ||
      report.Innovative_Programs_Accomplishments__c == ''
    )
      errorMessage += 'Explanation of Award Helping Reduce Crime is required.<br/>';
    if (
      report.Cooperation_Collaboration__c == null ||
      report.Cooperation_Collaboration__c == ''
    )
      errorMessage += 'Level of Cooperation and Collaboration is required.<br/>';
    if (
      report.Progress_of_Completed_Goals__c == null ||
      report.Progress_of_Completed_Goals__c == ''
    )
      errorMessage += 'Summarize the Progress is required.<br/>';
    if (
      report.Performance_Measurement__c == null ||
      report.Performance_Measurement__c == ''
    )
      errorMessage += 'Brief Narrative of Quarterly Performance is required.<br/>';

    if (topics.isEmpty())
      errorMessage += 'Topics Surveyed is required.<br/>';

    if (report.Hosted_Meetings__c == null)
      errorMessage += 'Hosted Meetings is required.<br/>';
    if (report.Attended_Meetings__c == null)
      errorMessage += 'Attended Meetings is required.<br/>';
    if (report.Distributed_Newsletter__c == null)
      errorMessage += 'Distributed Newsletters is required<br/>';
    if (report.Attended_Events__c == null)
      errorMessage += 'Attended Events is required.<br/>';
    if (report.Social_Media_Activities__c == null)
      errorMessage += 'Social Media Activities is required.<br/>';
    if (report.Conducted_Outreach__c == null)
      errorMessage += 'Conducted Outreach is required.<br/>';
    if (report.Other__c == null)
      errorMessage += 'Other is required.<br/>';
    if (
      (report.Other__c != null && report.Other__c != 'Not Applicable') &&
      (report.Other_Describe__c == null ||
      report.Other_Describe__c == '')
    )
      errorMessage += 'Other Description is required.<br/>';
  }

  public void submit() {
    errorMessage = '';
    successMessage = '';
    report.Submitted_By__c = currentUser.Contact.Id;
    report.Submitted_By_Text__c = currentUser.Contact.Name;
    report.DOD_Email__c = currentUser.Contact.Email;
    report.Organization_Name_Text__c = uc.userAcct.Name;
    report.DUNS_Number__c = [
      SELECT DUNS_Number__c
      FROM Account
      WHERE Id = :uc.userAcct.Id
    ][0]
    .DUNS_Number__c;
    validation();
    if (errorMessage == '') {
      report.Status__c = 'Submitted';
      report.Submitted_Date__c = date.today();

      prc.upsertReport(report);

      if (ApexPages.hasMessages())
        errorMessage += string.valueOf(ApexPages.getMessages());
      else
        successMessage = 'Save successful.';
    }
  }

  public PageReference approve() {
    report.Status__c = 'Approved';
    prc.upsertReport(report);
    PageReference pr = new PageReference(
      '/MDGOProgramReport?report=' + report.Id
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference sendBack() {
    report.Status__c = 'Revisions Needed';
    prc.upsertReport(report);
    PageReference pr = new PageReference(
      '/MDGOProgramReport?report=' + report.Id
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference save() {
    if (userAcctType == 'Local Organization')
      report.Status__c = 'In Progress';
    prc.upsertReport(report);
    PageReference pr = new PageReference('/MDGOProgramReports');
    pr.setRedirect(true);
    return pr;
  }
}
