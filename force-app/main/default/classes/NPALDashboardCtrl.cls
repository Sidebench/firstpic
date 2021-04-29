public with sharing class NPALDashboardCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public String userProfile { get; set; }
  public Account userAcct { get; set; }
  public String approverLevel { get; set; }
  public String userAcctType { get; set; }

  public ID GrantId { get; set; }
  public Boolean showDemoAlert { get; set; }
  public Boolean showRequestAlert { get; set; }
  public Boolean showDUNSAlert { get; set; }
  public String DUNSAlert { get; set; }

  public List<Grant__c> pending_grant_list { get; set; }
  public Boolean more_pending_grant { get; set; }
  public List<Grant__c> sentBack_grant_list { get; set; }
  public Boolean more_sentBack_grant { get; set; }
  public Map<Id, String> missingAtt_map { get; set; }
  public Boolean hasMissingAtt { get; set; }

  public ID RequestId { get; set; }
  public List<Reimbursement_Request__c> incomplete_request_list { get; set; }
  public List<Reimbursement_Request__c> first_approval_list { get; set; }
  public List<Reimbursement_Request__c> second_approval_list { get; set; }
  public List<Reimbursement_Request__c> third_approval_list { get; set; }
  public List<Reimbursement_Request__c> sentBack_request_list { get; set; }
  public List<Reimbursement_Request__c> denied_request_list { get; set; }
  public Boolean more_incomplete_request { get; set; }
  public Boolean more_first_approval { get; set; }
  public Boolean more_second_approval { get; set; }
  public Boolean more_third_approval { get; set; }
  public Boolean more_sentBack_request { get; set; }
  public Boolean more_denied_request { get; set; }

  public Id ReportId { get; set; }
  public List<Grantee_Report__c> incomplete_report_list { get; set; }
  public List<Grantee_Report__c> complete_report_list { get; set; }
  public Boolean more_incomplete_report { get; set; }
  public Boolean more_complete_report { get; set; }

  private ProgressReportClass prc = new ProgressReportClass();
  public List<Progress_Report__c> progress_overdue { get; set; }
  public Boolean more_progress_overdue { get; set; }

  public Map<Id, Date> gId_map = new Map<Id, Date>();
  public List<Date> date_list = new List<Date>();
  public Date dateToday = Date.today();
  public Integer lastMonth = dateToday.month();

  public Integer overdueCount { get; set; }
  public String errorMessage { get; set; }

  public NPALDashboardCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    userProfile = currentUser.Profile.Name;

    pending_grant_list = new List<Grant__c>();
    sentBack_grant_list = new List<Grant__c>();
    missingAtt_map = new Map<Id, String>();

    incomplete_request_list = new List<Reimbursement_Request__c>();
    first_approval_list = new List<Reimbursement_Request__c>();
    second_approval_list = new List<Reimbursement_Request__c>();
    third_approval_list = new List<Reimbursement_Request__c>();
    sentBack_request_list = new List<Reimbursement_Request__c>();
    denied_request_list = new List<Reimbursement_Request__c>();

    incomplete_report_list = new List<Grantee_Report__c>();
    complete_report_list = new List<Grantee_Report__c>();

    progress_overdue = new List<Progress_Report__c>();

    errorMessage = '';
  }

  public ApexPages.PageReference init() {
    if (currentUser == null || userAcct == null) {
      PageReference pageRef = new PageReference('/login');
      return pageRef;
    }
    if (userProfile.contains('Report Builder')) {
      PageReference pageRef = new PageReference('/00O/o');
      return pageRef;
    }
    return null;
  }

  public void getLists() {
    Integer listLimit = 6;

    AccountClass ac = new AccountClass();
    Account a = ac.getAccount(userAcct.Id);

    if (a.DUNS_Exp_Date__c < dateToday) {
      showDUNSAlert = true;
      DUNSAlert = 'Your SAM.gov registration is overdue.  You will not receive any reimbursements until this has been resolved.  Updating SAM.gov does not automatically update this system. Please submit your updated registration date via the About tab. Please contact Angie Caffee with any questions at acaffee@nationalpal.org.';
    } else if (a.DUNS_Exp_Date__c < dateToday.addDays(60)) {
      showDUNSAlert = true;
      DUNSAlert = 'Your SAM.gov registration will expire within 60 days.  You must update the registration in order to remain in compliance with the grant and receive reimbursements. Updating SAM.gov does not automatically update this system. Please submit your updated registration date via the About tab.';
    } else if (a.DUNS_Exp_Date__c == null) {
      showDUNSAlert = true;
      DUNSAlert = 'You do not have a SAM.gov expiration in the system.  Please ensure that you have a DUNS number and that it is properly registered through SAM.gov.  Updating SAM.gov does not automatically update this system. Please submit your updated registration date via the About tab. Please contact Angie Caffee with any questions at acaffee@nationalpal.org';
    }

    Contact[] youth = [
      SELECT Id
      FROM Contact
      WHERE RecordType.Name = 'Youth' AND AccountId = :a.Id
    ];
    if (youth.size() == 0) {
      showDemoAlert = true;
    }

    Set<Id> gIds = new Set<Id>();
    for (Grant__c g : [
      SELECT
        Id,
        Name,
        LastModifiedDate,
        Account__r.National_Organization__c,
        Grant_Status__c
      FROM Grant__c
      WHERE Grant_Status__c != 'Closed'
      ORDER BY LastModifiedDate DESC
    ]) {
      gIds.add(g.Id);
      if (userAcctType == 'National Organization') {
        if (
          g.Grant_Status__c == 'Pending Review' ||
          g.Grant_Status__c == 'Budget Submitted'
        ) {
          if (pending_grant_list.size() < listLimit) {
            pending_grant_list.add(g);
          } else {
            more_pending_grant = true;
          }
        }
        if (g.Grant_Status__c == 'Revisions Needed') {
          if (sentBack_grant_list.size() < listLimit) {
            sentBack_grant_list.add(g);
          } else {
            more_sentBack_grant = true;
          }
        }
        gId_map.put(g.Id, date.newinstance(1900, 1, 1));
      }
    }
    for (Document__c d : [
      SELECT Grant__r.Id, Grant__r.Name
      FROM Document__c
      WHERE
        Grant__c IN :gIds
        AND (Status__c = 'Requested'
        OR Status__c = 'Sent Back')
        AND Required__c = TRUE
    ]) {
      missingAtt_map.put(d.Grant__r.Id, d.Grant__r.Name);
    }
    if (missingAtt_map.size() > 0)
      hasMissingAtt = true;

    for (Reimbursement_Request__c r : [
      SELECT
        Id,
        Name,
        CreatedDate,
        Grant__c,
        Grant__r.Account__r.Id,
        Grant__r.Account__r.National_Organization__c,
        Grant__r.Name,
        Request_Date__c,
        Status__c,
        Paid_Date__c,
        Level_Three_Approved_Date__c
      FROM Reimbursement_Request__c
      WHERE Grant_Status__c != 'Closed'
      ORDER BY CreatedDate ASC
    ]) {
      //if((userAcctType == 'National Organization' && r.Grant__r.Account__r.National_Organization__c == userAcct.Id) ||
      //   (userAcctType == 'Local Organization' && r.Grant__r.Account__c == userAcct.Id))
      //{
      if (r.Status__c == 'Incomplete') {
        if (incomplete_request_list.size() < listLimit) {
          incomplete_request_list.add(r);
        } else {
          more_incomplete_request = true;
        }
      } else if (r.Status__c == 'Pending First Approval') {
        if (first_approval_list.size() < listLimit) {
          first_approval_list.add(r);
          date_list.add(r.Request_Date__c);
        } else {
          more_first_approval = true;
        }
      } else if (r.Status__c == 'Pending Second Approval') {
        if (second_approval_list.size() < listLimit) {
          second_approval_list.add(r);
          date_list.add(r.Request_Date__c);
        } else {
          more_second_approval = true;
        }
      } else if (
        r.Status__c == 'Pending Final Approval' ||
        r.Status__c == 'Pending Third Approval'
      ) {
        if (third_approval_list.size() < listLimit) {
          third_approval_list.add(r);
          date_list.add(r.Request_Date__c);
        } else {
          more_third_approval = true;
        }
      } else if (
        r.Status__c == 'Revisions Needed' ||
        r.Status__c == 'Revision in Progress'
      ) {
        if (sentBack_request_list.size() < listLimit) {
          sentBack_request_list.add(r);
        } else {
          more_sentBack_request = true;
        }
      } else if (r.Status__c == 'Denied') {
        if (denied_request_list.size() < listLimit) {
          denied_request_list.add(r);
        } else {
          more_denied_request = true;
        }
      } else {
        date_list.add(r.Request_Date__c);
      }

      gId_map.put(r.Grant__c, r.Request_Date__c);
      //if(!gId_map.containsKey(r.Grant__c) && r.Request_Date__c > gId_map.get(r.Grant__c)) {
      //    gId_map.put(r.Grant__c, r.Request_Date__c);
      //}
      system.debug('gId_map');
      //}
    }

    for (Grantee_Report__c gr : [
      SELECT
        Name,
        Grant__r.Name,
        Report_Status__c,
        Reporting_Period__c,
        LastModifiedDate
      FROM Grantee_Report__c
      WHERE Grant_Status__c != 'Closed'
      ORDER BY LastModifiedDate DESC
    ]) {
      //if(gr.Grant__r.Account__c == userAcct.Id) {
      if (
        gr.Report_Status__c == 'In Progress' ||
        gr.Report_Status__c == 'Revisions Needed' ||
        gr.Report_Status__c == 'Revision in Progress'
      ) {
        if (incomplete_report_list.size() < listLimit) {
          incomplete_report_list.add(gr);
        } else {
          more_incomplete_report = true;
        }
      }
      if (
        gr.Report_Status__c == 'Approved' ||
        gr.Report_Status__c == 'Paid' ||
        gr.Report_Status__c == 'Submitted'
      ) {
        if (complete_report_list.size() < listLimit) {
          complete_report_list.add(gr);
        } else {
          more_complete_report = true;
        }
      }
      //}
    }

    for (
      Progress_Report__c pr : prc.getRelatedReportList(
        userAcct.Id,
        null,
        userAcctType,
        null,
        null,
        null,
        null,
        null,
        null,
        ' AND Is_Overdue__c = true AND Grant_Status__c != \'Closed\''
      )
    ) {
      if (progress_overdue.size() < listLimit)
        progress_overdue.add(pr);
      else
        more_progress_overdue = true;
    }
  }

  public void getOverdueInfo() {
    overdueCount = 0;
    showRequestAlert = true;

    for (Date d : date_list) {
      if (d > dateToday.addDays(-30)) {
        showRequestAlert = false;
      }
    }

    for (Date d : gId_map.values()) {
      if (d.month() < lastMonth) {
        overdueCount += 1;
      }
    }
  }

  public List<AggregateResult> requestsByStatus {
    get {
      return [
        SELECT count(Id) requestCount, Status__c
        FROM Reimbursement_Request__c
        WHERE
          Grant__r.Account__r.National_Organization__r.Id = :userAcct.Id
          AND Status__c != NULL
          AND Total_Requested_Amount__c != NULL
        GROUP BY Status__c
      ];
    }
  }
}
