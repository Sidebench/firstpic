public with sharing class PALogCtrl {
  private UserClass userClass = new UserClass();
  private ProgramReportClass prc = new ProgramReportClass();
  private PALogClass plc = new PALogClass();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public Id acctId { get; set; }

  public Program_Report__c report { get; set; }
  public List<Program_Report__c> report_list { get; set; }

  public Id reportId { get; set; }
  public List<PA_Log__c> log_list { get; set; }

  public String site { get; set; }
  public String month { get; set; }
  public List<SelectOption> months { get; set; }
  public String year { get; set; }
  public List<SelectOption> years { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }

  public Decimal paLogCount { get; set; }
  public Decimal daysReportedOpen { get; set; }
  public Decimal minutes { get; set; }
  public Decimal miutesAverage { get; set; }
  public Decimal boys { get; set; }
  public Decimal boysAverage { get; set; }
  public Decimal girls { get; set; }
  public Decimal girlsAverage { get; set; }

  public Date dt = Date.today();
  public Integer currentYear = dt.year();

  public Boolean displaySendBackPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public String sizeErrorMessage { get; set; }
  public String errorMessage { get; set; }

  public PALogCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    report = new Program_Report__c();
    log_list = new List<PA_Log__c>();
    report_list = new List<Program_Report__c>();

    String urlrReportId = ApexPages.currentPage()
      .getParameters()
      .get('reportId');
    if (urlrReportId != '' && urlrReportId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlrReportId)
          .matches()
      ) {
        reportId = Id.valueOf(urlrReportId);
      }
    }
  }

  public void getDropdowns() {
    String urlAcctId = ApexPages.currentPage().getParameters().get('acctId');
    if (urlAcctId != '' && urlAcctId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlAcctId)
          .matches()
      ) {
        acctId = Id.valueOf(urlAcctId);
      }
    }
    if (acctId == null)
      acctId = userAcct.Id;

    months = new List<SelectOption>();
    months.add(new SelectOption('', ''));
    Schema.DescribeFieldResult m = Program_Report__c.Month__c.getDescribe();
    for (Schema.PicklistEntry f : m.getPicklistValues()) {
      months.add(new SelectOption(f.getLabel(), f.getValue()));
    }

    years = new List<SelectOption>();
    years = spf.getPicklistOptions('Program_Report__c', 'Year__c', null);
    year = string.valueOf(currentYear);

    status = '';
    statusOptions = new List<SelectOption>();
    statusOptions = spf.getPicklistOptions(
      'Program_Report__c',
      'Status__c',
      'View All'
    );

    sortByOptions = new List<SelectOption>();
    if (userAcctType != 'Site')
      sortByOptions.add(new SelectOption('Name', 'Report Title'));
    sortByOptions.add(new SelectOption('Site__r.Name', 'Site'));
    sortByOptions.add(new SelectOption('Grant_Name__c', 'Grant Name'));
    sortByOptions.add(new SelectOption('Month__c', 'Month'));
    sortBy = 'Name';

    getReportLists();
  }

  public void getReportLists() {
    sizeErrorMessage = '';
    errorMessage = '';
    Decimal days = 0;
    paLogCount = 0;
    daysReportedOpen = 0;
    minutes = 0;
    miutesAverage = 0;
    boys = 0;
    boysAverage = 0;
    girls = 0;
    girlsAverage = 0;

    report_list.clear();

    String soqlAND = ' AND RecordType.Name = \'Monthly PA Logs\'';
    if (month != null && month != '')
      soqlAND += ' AND Month__c = \'' + month + '\'';
    if (year != null && year != '')
      soqlAND += ' AND Year__c = \'' + year + '\'';
    if (status != null && status != 'View All')
      soqlAND += ' AND Status__c = \'' + status + '\'';
    if (site != null && site != '')
      soqlAND +=
        ' AND (Site_Name__c LIKE \'%' +
        site +
        '%\' OR Org_Name__c LIKE \'%' +
        site +
        '%\')';
    soqlAND += ' ORDER BY ' + sortBy;

    List<Program_Report__c> reports = prc.getRelatedReportList(
      acctId,
      userAcctType,
      null,
      null,
      null,
      soqlAND
    );
    if (reports.size() > 999)
      sizeErrorMessage = 'List of results is too large to display. Please narrow search criteria and refresh results.';
    else {
      for (Program_Report__c pr : reports) {
        if (site != null && site != '')
          String name = pr.Site__r.Name.toLowerCase();
        report_list.add(pr);
      }

      for (Program_Report__c pr : report_list) {
        paLogCount++;
        if (pr.Total_Days_Reported_Open__c != null)
          daysReportedOpen += pr.Total_Days_Reported_Open__c;
        if (pr.Total_Daily_Minutes__c != null)
          minutes += pr.Total_Daily_Minutes__c;
        if (pr.Total_Number_of_Boys__c != null)
          boys += pr.Total_Number_of_Boys__c;
        if (pr.Total_Number_of_Girls__c != null)
          girls += pr.Total_Number_of_Girls__c;
        if (pr.Days_in_Month__c != null)
          days += pr.Days_in_Month__c;
      }
      if (days > 0) {
        miutesAverage = (minutes / days).setScale(2);
        boysAverage = (boys / days).setScale(2);
        girlsAverage = (girls / days).setScale(2);
      }
    }
  }

  public void getPALists() {
    if (reportId != null) {
      report = prc.getReport(reportId);
      log_list = plc.getLogs(reportId);
    }
  }

  public void updateStatus() {
    for (PA_Log__c p : log_list) {
      if (
        p.Activity_Status__c == 'No Activity' ||
        p.Activity_Status__c == 'Club Closed'
      ) {
        p.Number_of_Boys__c = 0;
        p.Number_of_Girls__c = 0;
        p.Minutes_of_Activity__c = 0;
      }
    }
  }

  public void save() {
    errorMessage = '';
    plc.upsertLogs(log_list);

    report.Status__c = 'In Progress';
    prc.upsertReport(report);
  }

  public void submit() {
    errorMessage = '';
    plc.upsertLogs(log_list);
    for (PA_Log__c p : log_list) {
      if (
        p.Activity_Status__c == null ||
        p.Number_of_Boys__c == null ||
        p.Number_of_Girls__c == null ||
        p.Minutes_of_Activity__c == null
      ) {
        errorMessage = 'All fields are required';
      }
    }

    if (errorMessage == '') {
      report.Status__c = 'Submitted';
      report.Submitted_Date__c = date.today();
      report.Submitted_By__c = currentUser.ContactID;
      prc.upsertReport(report);
    }
  }

  // BEGIN sendBack
  public void sendBack() {
    report.Status__c = 'Revisions Needed';
    prc.upsertReport(report);
    hideSendBackPopup();
  }
  // END sendBack

  // BEGIN approve
  public void approve() {
    report.Status__c = 'Approved';
    prc.upsertReport(report);
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
