public with sharing class DrawdownsCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private ReimbursementClass rc = new ReimbursementClass();
  private PaginationClass pc = new PaginationClass();

  public String reportId { get; set; }
  public String pendingReportId { get; set; }
  public String completedReportId { get; set; }
  public String reportsId { get; set; }
  public Id grantID { get; set; }
  public Grant__c grant { get; set; }

  private String soql { get; set; }
  public List<Reimbursement_Request__c> report_list { get; set; }
  public List<Reimbursement_Request__c> approved_list { get; set; }
  public List<Reimbursement_Request__c> approved_list_short { get; set; }
  public List<Reimbursement_Request__c> pending_list { get; set; }
  public List<Reimbursement_Request__c> completed_list { get; set; }
  public List<Reimbursement_Request__c> completed_list_short { get; set; }
  public List<innerClass> reports_list { get; set; }

  Set<String> rdates { get; set; }
  public Set<Id> rIds { get; set; }
  public Boolean selectAllApproved { get; set; }
  public Boolean selectAllInReport { get; set; }
  public Decimal reportTotal { get; set; }
  public Decimal pendingTotal { get; set; }
  public Decimal completedTotal { get; set; }

  public Date reportsStartDate { get; set; }
  public Date reportsEndDate { get; set; }
  public Date completedStartDate { get; set; }
  public Date completedEndDate { get; set; }

  public Boolean displayApproved { get; set; }
  public Boolean displayPending { get; set; }
  public Boolean displayCompleted { get; set; }
  public Boolean displayGetCompletedBtn { get; set; }
  public Boolean displaySuccess { get; set; }
  public String errorMessage { get; set; }
  public String completedSizeErrorMessage { get; set; }

  Integer approvedCounter = 0;
  Integer approvedLimitSize = 60;
  public Integer approvedTotalSize { get; set; }
  public String approvedRecordCount { get; set; }
  public Boolean approvedDisablePrevious { get; set; }
  public Boolean approvedDisableNext { get; set; }

  Integer completedCounter = 0;
  Integer completedLimitSize = 40;
  Integer completedTotalSize = 0;
  public String completedRecordCount { get; set; }
  public Boolean completedDisablePrevious { get; set; }
  public Boolean completedDisableNext { get; set; }

  public DrawdownsCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    approverLevel = uc.approverLevel;
    portalName = uc.userProfile;

    reportId = ApexPages.currentPage().getParameters().get('reportId');
    pendingReportId = '';
    completedReportId = '';
    reportsId = '';

    soql = '';
    report_list = new List<Reimbursement_Request__c>();
    approved_list = new List<Reimbursement_Request__c>();
    approved_list_short = new List<Reimbursement_Request__c>();
    pending_list = new List<Reimbursement_Request__c>();
    completed_list = new List<Reimbursement_Request__c>();
    completed_list_short = new List<Reimbursement_Request__c>();
    reports_list = new List<innerClass>();

    rIds = new Set<Id>();
    selectAllApproved = true;
    selectAllInReport = true;
    approvedTotalSize = 0;
    reportTotal = 0;
    pendingTotal = 0;
    completedTotal = 0;
    displaySuccess = false;
    completedSizeErrorMessage = 'Please enter a Report Id or Paid Date Range and click update to view completed requests.';

    getDisplayPermissions();

    grantID = ApexPages.currentPage().getParameters().get('grantId');
    if (grantId != null) {
      Grant__c[] grants = [SELECT Id, Name FROM Grant__c WHERE Id = :grantId];
      if (grants.size() > 0) {
        grant = grants[0];
      }
      soql = 'SELECT Id, Name, Organization__c, Address__c, Grant__r.Name, Status__c, Selected__c, Request_Month__c, Modification_History__c';
      soql += ', Drawdown_Status__c, Paid_Date__c, Total_Approved_Amount__c, Total_Requested_Amount__c, Report_Id__c, EFT__c, Drawndown_Date__c';
      soql +=
        ' FROM Reimbursement_Request__c WHERE Grant__r.National_Grant__c = \'' +
        grantId +
        '\'';
    }
  }

  public void getDisplayPermissions() {
    displayApproved = false;
    displayPending = false;
    displayCompleted = false;
    displayGetCompletedBtn = false;

    if (
      portalName.contains('NCAI') ||
      approverLevel.contains('Admin') ||
      approverLevel == 'Level Four' ||
      (approverLevel == 'Level Three' &&
      (portalName == 'STEM' ||
      portalName == 'NPAL')) ||
      (approverLevel == 'Level Two' &&
      portalName == 'Ripken')
    ) {
      displayApproved = true;
      displayPending = true;
      displayGetCompletedBtn = true;
    }
    if ((currentUser.Profile.Name).contains('Accounts Payable'))
      displayGetCompletedBtn = true;
  }

  public void getLists() {
    system.debug('BEGIN getLists');
    if (displayApproved)
      getApproved();
    if (displayPending)
      getPending();
    getReports();
  }

  public void getApproved() {
    system.debug('BEGIN getApproved');
    approved_list.clear();

    String approvedSOQL =
      soql +
      ' AND Status__c = \'Approved\' AND Report_Id__c = null AND Hold_Status__c != \'Hold\' LIMIT 1000';
    approved_list = database.query(approvedSOQL);
    system.debug('approvedSOQL = ' + approvedSOQL);
    approvedTotalSize = approved_list.size();
    approvedFirst();
  }

  public void getPending() {
    system.debug('BEGIN getPending');
    pending_list.clear();
    pendingTotal = 0;

    String pendingSOQL = soql;
    if (pendingReportId != null)
      pendingSOQL += ' AND Report_Id__c LIKE \'%' + pendingReportId + '%\'';
    pendingSOQL += ' AND Drawdown_Status__c = \'In Report\' LIMIT 1000';
    pending_list = database.query(pendingSOQL);
    system.debug('pendingSOQL = ' + pendingSOQL);
    for (Reimbursement_Request__c r : pending_list) {
      r.Selected__c = false;
      pendingTotal += r.Total_Approved_Amount__c;
    }
  }

  public void getCompleted() {
    system.debug('BEGIN getCompleted');
    completed_list.clear();
    completedTotal = 0;
    completedSizeErrorMessage = '';

    String completedSOQL = soql + ' AND Drawdown_Status__c = \'Drawndown\'';
    system.debug('completedReportId = ' + completedReportId);
    if (completedReportId != null)
      completedSOQL += ' AND Report_Id__c LIKE \'%' + completedReportId + '%\'';
    if (completedStartDate != null)
      completedSOQL += ' AND Paid_Date__c >= :completedStartDate';
    if (completedEndDate != null)
      completedSOQL += ' AND Paid_Date__c <= :completedEndDate';
    if (
      (completedReportId == null ||
      completedReportId == '') &&
      completedStartDate == null &&
      completedEndDate == null
    )
      completedSOQL += ' AND EFT__c = null';
    completedSOQL += ' LIMIT 1000';
    system.debug('completedSOQL = ' + completedSOQL);
    completed_list = database.query(completedSOQL);
    for (Reimbursement_Request__c r : completed_list) {
      completedTotal += r.Total_Approved_Amount__c;
    }
    completedTotalSize = completed_list.size();
    system.debug('completedTotalSize = ' + completedTotalSize);
    //if(completedReportId == null && completedStartDate == null && completedEndDate == null) completedSizeErrorMessage = 'Please enter a Report Id or Paid Date Range and click update to view completed requests.';
    //else
    if (completedTotalSize == 0)
      completedSizeErrorMessage = 'No Completed Reports Found';
    else if (completedTotalSize > 999)
      completedSizeErrorMessage = 'List is too large to display. Please narrow search criteria and refresh results';
    else
      completedFirst();
  }

  public void getReports() {
    system.debug('BEGIN getReports');
    reports_list.clear();
    Set<String> reportIdSet = new Set<String>();

    String reportsSOQL = soql + ' AND Drawdown_Status__c = \'Drawndown\'';
    if (reportsStartDate != null)
      reportsSOQL += ' AND Report_Id__c LIKE \'%' + reportsId + '%\'';
    if (reportsStartDate != null)
      reportsSOQL += ' AND Paid_Date__c >= :reportsStartDate';
    if (reportsEndDate != null)
      reportsSOQL += ' AND Paid_Date__c <= :reportsEndDate';
    reportsSOQL += ' LIMIT 1000';
    system.debug('reportsSOQL = ' + reportsSOQL);
    for (Reimbursement_Request__c r : database.query(reportsSOQL)) {
      if (!reportIdSet.contains(r.Report_Id__c)) {
        innerClass ic = new innerClass(r.Report_Id__c, r.Drawndown_Date__c);
        reports_list.add(ic);
        reportIdSet.add(r.Report_Id__c);
      }
    }
  }

  public void getReport() {
    system.debug('BEGIN getReport');
    report_list.clear();
    reportTotal = 0;

    if (reportId != null) {
      String reportSOQL = soql;
      reportSOQL += ' AND Report_Id__c LIKE \'%' + reportId + '%\'';
      report_list = database.query(reportSOQL);
      system.debug('reportSOQL = ' + reportSOQL);
      for (Reimbursement_Request__c r : report_list) {
        reportTotal += r.Total_Approved_Amount__c;
      }
    }
  }

  public void selectAllApproved() {
    system.debug('BEGIN selectAllApproved');
    if (selectAllApproved)
      selectAllApproved = false;
    else
      selectAllApproved = true;
    for (Reimbursement_Request__c r : approved_list_short)
      r.Selected__c = selectAllApproved;
  }

  public void selectAllInReport() {
    system.debug('BEGIN selectAllInReport');
    if (selectAllInReport)
      selectAllInReport = false;
    else
      selectAllInReport = true;
    for (Reimbursement_Request__c r : pending_list)
      r.Selected__c = selectAllInReport;
  }

  // BEGIN createReport (move Approved into Pending)
  public void createReport() {
    system.debug('BEGIN createReport');
    List<Reimbursement_Request__c> selected_list = new List<Reimbursement_Request__c>();
    String rId = createReportId();
    for (Reimbursement_Request__c r : approved_list_short) {
      system.debug('approved_list_short r = ' + r);
      if (r.Selected__c) {
        r.Drawdown_Status__c = 'In Report';
        r.Report_ID__c = rId;
        r.Selected__c = false;
        selected_list.add(r);
      }
    }
    rc.upsertRequestList(selected_list);
    getLists();
  }

  public void createAllApprovedReport() {
    system.debug('BEGIN createReport');
    List<Reimbursement_Request__c> selected_list = new List<Reimbursement_Request__c>();
    String rId = createReportId();
    for (Reimbursement_Request__c r : approved_list) {
      r.Drawdown_Status__c = 'In Report';
      r.Report_ID__c = rId;
      r.Selected__c = false;
      selected_list.add(r);
    }
    rc.upsertRequestList(selected_list);
    getLists();
  }

  public String createReportId() {
    RandomString randomString = new RandomString();
    String rId = randomString.randStr;
    DateTime d = Datetime.now();
    String dateStr = d.format('yyyy-MM-dd_h:mm');
    rId += '_' + dateStr;
    return rId;
  }
  // END createReport (move Approved into Pending)

  public void removeItems() {
    system.debug('BEGIN removeItems');
    for (Reimbursement_Request__c r : pending_list) {
      if (r.Selected__c) {
        r.Report_Id__c = null;
        r.Drawdown_Status__c = null;
        r.Selected__c = false;
      }
    }
    rc.upsertRequestList(pending_list);
    pendingReportId = null;
    getLists();
  }

  public void completeDrawdown() {
    system.debug('BEGIN completeDrawdown');
    errorMessage = '';
    for (Reimbursement_Request__c r : pending_list) {
      if (r.Selected__c) {
        r.Drawdown_Status__c = 'Drawndown';
        r.Drawndown_Date__c = Date.today();
        r.Selected__c = false;
        completedReportId = r.Report_Id__c;
      }
    }
    rc.upsertRequestList(pending_list);
    pendingReportId = null;
    getLists();
    //getCompleted();
  }

  public void processEFT() {
    system.debug('BEGIN processEFT');
    Date dt = date.today();
    String fdt = dt.format();

    for (Reimbursement_Request__c r : completed_list) {
      if (r.EFT__c != null) {
        if (r.Status__c != 'Paid') {
          if (r.Paid_Date__c == null)
            r.Paid_Date__c = date.today();
          r.Status__c = 'Paid';
        }
        String mh =
          fdt +
          ': Paid by ' +
          currentUser.Contact.Name +
          ' (' +
          currentUser.Id +
          ') - EFT: ' +
          r.EFT__c;
        if (r.Modification_History__c == null)
          r.Modification_History__c = '';
        r.Modification_History__c += ' \r\n' + mh;
      }
    }
    rc.upsertRequestList(completed_list);
    displaySuccess = true;
    getCompleted();
  }

  public void showCompleted() {
    displayApproved = false;
    displayPending = false;
    displayCompleted = true;
    completedReportId = null;
    getCompleted();
  }

  public void hideCompleted() {
    displaySuccess = false;
    getDisplayPermissions();
    getLists();
  }

  // BEGIN Inner Class
  public class innerClass {
    public String reportId { get; set; }
    public Date reportDate { get; set; }

    public innerClass(String rId, Date rDate) {
      reportId = rId;
      reportDate = rDate;
    }
  }
  // END inner Class

  // BEGIN pagination
  public void approvedFirst() {
    approvedCounter = 0;
    approved_list_short = pc.first(approved_list, approvedLimitSize);
    system.debug(
      'approvedFirst approved_list_short size = ' + approved_list_short.size()
    );
    approvedRecordCount = pc.getRecordCount(
      approvedCounter,
      approvedLimitSize,
      approvedTotalSize
    );
    approvedDisablePrevious = true;
    approvedDisableNext = pc.getDisableNext(
      approvedCounter,
      approvedLimitSize,
      approvedTotalSize
    );
  }

  public void approvedNext() {
    approvedCounter = approvedCounter + approvedLimitSize;
    approved_list_short = pc.next(
      approved_list,
      approvedCounter,
      approvedLimitSize
    );
    approvedRecordCount = pc.getRecordCount(
      approvedCounter,
      approvedLimitSize,
      approvedTotalSize
    );
    approvedDisablePrevious = false;
    approvedDisableNext = pc.getDisableNext(
      approvedCounter,
      approvedLimitSize,
      approvedTotalSize
    );
  }

  public void approvedPrevious() {
    approvedCounter = approvedCounter - approvedLimitSize;
    approved_list_short = pc.previous(
      approved_list,
      approvedCounter,
      approvedLimitSize
    );
    approvedRecordCount = pc.getRecordCount(
      approvedCounter,
      approvedLimitSize,
      approvedTotalSize
    );
    approvedDisablePrevious = pc.getDisablePrevious(approvedCounter);
    approvedDisableNext = false;
  }

  public void approvedLast() {
    approvedCounter = pc.getLastCounter(
      approvedCounter,
      approvedLimitSize,
      approvedTotalSize
    );
    approved_list_short = pc.last(
      approved_list,
      approvedCounter,
      approvedLimitSize
    );
    approvedRecordCount = pc.getRecordCount(
      approvedCounter,
      approvedLimitSize,
      approvedTotalSize
    );
    approvedDisablePrevious = false;
    approvedDisableNext = true;
  }

  public void completedFirst() {
    system.debug(
      'completedFirst approved_list_short size = ' + approved_list_short.size()
    );
    completedCounter = 0;
    completed_list_short = pc.first(completed_list, completedLimitSize);
    system.debug(
      'completedFirst completed_list_short size = ' +
      completed_list_short.size()
    );
    completedRecordCount = pc.getRecordCount(
      completedCounter,
      completedLimitSize,
      completedTotalSize
    );
    completedDisablePrevious = true;
    completedDisableNext = pc.getDisableNext(
      completedCounter,
      completedLimitSize,
      completedTotalSize
    );
    system.debug(
      'completedFirst approved_list_short size = ' + approved_list_short.size()
    );
  }

  public void completedNext() {
    completedCounter = completedCounter + completedLimitSize;
    completed_list_short = pc.next(
      completed_list,
      completedCounter,
      completedLimitSize
    );
    completedRecordCount = pc.getRecordCount(
      completedCounter,
      completedLimitSize,
      completedTotalSize
    );
    completedDisablePrevious = false;
    completedDisableNext = pc.getDisableNext(
      completedCounter,
      completedLimitSize,
      completedTotalSize
    );
  }

  public void completedPrevious() {
    completedCounter = completedCounter - completedLimitSize;
    completed_list_short = pc.previous(
      completed_list,
      completedCounter,
      completedLimitSize
    );
    completedRecordCount = pc.getRecordCount(
      completedCounter,
      completedLimitSize,
      completedTotalSize
    );
    completedDisablePrevious = pc.getDisablePrevious(completedCounter);
    completedDisableNext = false;
  }

  public void completedLast() {
    completedCounter = pc.getLastCounter(
      completedCounter,
      completedLimitSize,
      completedTotalSize
    );
    completed_list_short = pc.last(
      completed_list,
      completedCounter,
      completedLimitSize
    );
    completedRecordCount = pc.getRecordCount(
      completedCounter,
      completedLimitSize,
      completedTotalSize
    );
    completedDisablePrevious = false;
    completedDisableNext = true;
  }
  // END pagination
}
