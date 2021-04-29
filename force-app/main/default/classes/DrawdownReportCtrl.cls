public with sharing class DrawdownReportCtrl {
  // DEPRECATED. Used only for BBBSA.
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String approverLevel { get; set; }

  public ReimbursementClass requestClass = new ReimbursementClass();

  public String reportId { get; set; }
  public String pendingReportId { get; set; }
  public Id GrantID { get; set; }
  public Grant__c grant { get; set; }

  public List<Reimbursement_Request__c> approved_list { get; set; }
  public List<Reimbursement_Request__c> inPending_list { get; set; }
  public List<Reimbursement_Request__c> inReport_list { get; set; }
  public List<Reimbursement_Request__c> completed_list { get; set; }
  //public Map<String, Date> report_map { get; set; }
  public List<innerClass> report_list { get; set; }
  Set<String> rdates { get; set; }
  public Set<Id> rIds { get; set; }
  public Boolean selectAllApproved { get; set; }
  public Boolean selectAllInReport { get; set; }
  public Decimal reportTotal { get; set; }
  public Decimal drawdownTotal { get; set; }

  public Date startDate { get; set; }
  public Date endDate { get; set; }

  public Boolean displaySuccess { get; set; }
  public String errorMessage { get; set; }

  public DrawdownReportCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    approverLevel = userClass.approverLevel;

    reportId = '';
    pendingReportId = '';
    reportId = ApexPages.currentPage().getParameters().get('reportId');
    if (reportId != null)
      pendingReportId = reportId;
    GrantID = ApexPages.currentPage().getParameters().get('grantId');

    approved_list = new List<Reimbursement_Request__c>();
    inPending_list = new List<Reimbursement_Request__c>();
    inReport_list = new List<Reimbursement_Request__c>();
    completed_list = new List<Reimbursement_Request__c>();
    //report_map = new Map<String, Date>();
    report_list = new List<innerClass>();
    rIds = new Set<Id>();
    selectAllApproved = true;
    selectAllInReport = true;
    reportTotal = 0;
    drawdownTotal = 0;
    displaySuccess = false;

    //endDate = date.today();
    //startDate = endDate.addDays(-30);

    if (grantId != null) {
      Grant__c[] grants = [
        SELECT Id, Name, BBBS_Grant_ID__c
        FROM Grant__c
        WHERE Id = :grantId
      ];
      if (grants.size() > 0) {
        grant = grants[0];
      }
    } else {
      for (Grant__c g : [
        SELECT Id, Account__r.ID, Name, BBBS_Grant_ID__c
        FROM Grant__c
      ]) {
        if (userAcct != null && g.Account__r.ID == userAcct.Id) {
          grant = g;
          grantId = g.Id;
        }
      }
    }
  }

  public void getLists() {
    approved_list.clear();
    inPending_list.clear();
    inReport_list.clear();
    completed_list.clear();
    //report_map.clear();
    report_list.clear();
    reportTotal = 0;
    drawdownTotal = 0;
    displaySuccess = false;

    Set<String> reportIdSet = new Set<String>();
    for (Reimbursement_Request__c r : [
      SELECT
        Id,
        Name,
        Grant__r.Name,
        Grant__r.National_Grant__c,
        Status__c,
        Selected__c,
        Drawdown_Status__c,
        Paid_Date__c,
        Total_Requested_Amount__c,
        Report_Id__c,
        EFT__c,
        Drawndown_Date__c,
        Request_Month__c,
        Modification_History__c,
        Hold_Status__c
      FROM Reimbursement_Request__c
      WHERE Grant__r.National_Grant__c = :grantId
    ]) {
      if (
        (reportId != null && reportId != '') ||
        (pendingReportId != null &&
        pendingReportId != '')
      ) {
        string rId = r.Report_Id__c;
        system.debug('rId = ' + rId);
        system.debug('reportId = ' + reportId);
        system.debug('pendingReportId = ' + pendingReportId);
        if (
          rId != null &&
          (reportId != null && reportId != '' &&
          rId.toLowerCase().contains(reportId.toLowerCase()) ||
          (pendingReportId != null &&
          pendingReportId != '' &&
          rId.toLowerCase().contains(pendingReportId.toLowerCase())))
        ) {
          if (r.Drawdown_Status__c != 'Drawndown')
            inPending_list.add(r);
          else {
            if (r.EFT__c == null) {
              completed_list.add(r);
              drawdownTotal += r.Total_Requested_Amount__c;
            } else if (
              (r.Paid_Date__c >= startDate &&
              endDate == null) ||
              (r.Paid_Date__c <= endDate &&
              startDate == null) ||
              (r.Paid_Date__c >= startDate &&
              r.Paid_Date__c <= endDate)
            ) {
              completed_list.add(r);
              drawdownTotal += r.Total_Requested_Amount__c;
            }
          }
          inReport_list.add(r);
          reportTotal += r.Total_Requested_Amount__c;
        }
      } else {
        if (r.Drawdown_Status__c == 'In Report') {
          inPending_list.add(r);
          reportTotal += r.Total_Requested_Amount__c;
        } else if (r.Drawdown_Status__c == 'Drawndown') {
          if (r.EFT__c == null) {
            completed_list.add(r);
            drawdownTotal += r.Total_Requested_Amount__c;
          } else if (
            (r.Paid_Date__c >= startDate &&
            endDate == null) ||
            (r.Paid_Date__c <= endDate &&
            startDate == null) ||
            (r.Paid_Date__c >= startDate &&
            r.Paid_Date__c <= endDate)
          ) {
            completed_list.add(r);
            drawdownTotal += r.Total_Requested_Amount__c;
          }
        }
      }
      if (r.Status__c == 'Approved' && r.Hold_Status__c != 'Hold') {
        r.Selected__c = true;
        if (r.Drawdown_Status__c == '' || r.Drawdown_Status__c == null)
          approved_list.add(r);
      }
      if (
        !reportIdSet.contains(r.Report_Id__c) &&
        r.Drawdown_Status__c == 'Drawndown' &&
        r.Drawndown_Date__c != null
      ) {
        if (
          (startDate == null &&
          endDate == null) ||
          (r.Drawndown_Date__c >= startDate &&
          endDate == null) ||
          (r.Drawndown_Date__c <= endDate &&
          startDate == null) ||
          (r.Drawndown_Date__c >= startDate &&
          r.Drawndown_Date__c <= endDate)
        ) {
          //report_map.put(r.Report_Id__c, r.Drawndown_Date__c);
          innerClass ic = new innerClass(r.Report_Id__c, r.Drawndown_Date__c);
          report_list.add(ic);
          reportIdSet.add(r.Report_Id__c);
        }
      }
    }
  }

  public void selectAllApproved() {
    if (selectAllApproved)
      selectAllApproved = false;
    else
      selectAllApproved = true;
    for (Reimbursement_Request__c r : approved_list)
      r.Selected__c = selectAllApproved;
  }

  public void selectAllInReport() {
    if (selectAllInReport)
      selectAllInReport = false;
    else
      selectAllInReport = true;
    for (Reimbursement_Request__c r : inPending_list)
      r.Selected__c = selectAllInReport;
  }

  public void createReport() {
    List<Reimbursement_Request__c> selected_list = new List<Reimbursement_Request__c>();
    RandomString randomString = new RandomString();
    if (grant.BBBS_Grant_ID__c != null)
      reportId = grant.BBBS_Grant_ID__c;
    else
      reportId = randomString.randStr;

    DateTime d = Datetime.now();
    String dateStr = d.format('yyyy-MM-dd_h:mm');
    reportId += '_' + dateStr;

    for (Reimbursement_Request__c r : approved_list) {
      system.debug('approved_list r = ' + r);
      if (r.Selected__c != null && r.Selected__c) {
        r.Drawdown_Status__c = 'In Report';
        r.Report_ID__c = reportId;
        rIds.add(r.Id);
      }
    }
    try {
      requestClass.upsertRequestList(approved_list);
      getLists();
    } catch (Exception e) {
      system.debug(e);
    }
  }

  public void updateReport() {
    for (Reimbursement_Request__c r : inPending_list) {
      if (!r.Selected__c) {
        r.Report_Id__c = null;
        r.Drawdown_Status__c = null;
      }
    }
    try {
      requestClass.upsertRequestList(inPending_list);
    } catch (Exception e) {
      system.debug(e);
    }
    reportId = null;
    getLists();
  }

  public void completeDrawdown() {
    errorMessage = '';
    Integer size = 0;
    for (Reimbursement_Request__c r : inPending_list)
      if (r.Selected__c)
        size++;
    if (size == 0)
      errorMessage = 'No Requests in Pending Drawdown Report';
    else {
      for (Reimbursement_Request__c r : inPending_list) {
        if (r.Selected__c) {
          r.Drawdown_Status__c = 'Drawndown';
          r.Drawndown_Date__c = Date.today();
          size++;
        } else {
          r.Report_Id__c = null;
          r.Drawdown_Status__c = null;
        }
      }
      try {
        requestClass.upsertRequestList(inPending_list);
      } catch (Exception e) {
        system.debug(e);
      }
      reportId = null;
      getLists();
    }
  }

  public void processEFT() {
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
    try {
      requestClass.upsertRequestList(completed_list);
      getLists();
      displaySuccess = true;
    } catch (Exception e) {
      system.debug(e);
      errorMessage = e.getMessage();
    }
  }

  public void saveAttach() {
    Attachment a = new Attachment();
    a.ParentId = grant.ID;
    a.Name = 'Drawdown Report ' + reportId;
    if (System.Test.IsRunningTest())
      a.Body = Blob.valueOf('TEST');
    else
      a.Body = ApexPages.currentPage().getcontentAsPdf();
    a.ContentType = 'application/pdf';
    try {
      insert a;
      System.Debug('>>>> attachment insert successful. a = ' + a);
    } catch (Exception e) {
      ApexPages.addmessage(
        new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())
      );
    }
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
}
