public with sharing class BBBSDashboardCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String userProfile { get; set; }
  public String approverLevelURL { get; set; }

  private AccountClass ac = new AccountClass();
  public Boolean showDUNSAlert { get; set; }
  public String DUNSAlert { get; set; }
  public List<Document__c> missingDocs { get; set; }
  public List<Account> onHold { get; set; }

  public ID GrantId { get; set; }
  public List<Grant__c> pending_grant_list { get; set; }
  public List<Grant__c> sentBack_grant_list { get; set; }
  public Boolean more_pending_grant { get; set; }
  public Boolean more_sentBack_grant { get; set; }

  public ID RequestId { get; set; }
  public List<Reimbursement_Request__c> pending_request_list { get; set; }
  public List<Reimbursement_Request__c> todo_request_list { get; set; }
  public List<Reimbursement_Request__c> incomplete_request_list { get; set; }
  public Boolean more_pending_request { get; set; }
  public Boolean more_todo_request { get; set; }
  public Boolean more_incomplete_request { get; set; }

  public ID ReportId { get; set; }
  public List<Grantee_Report__c> report_list { get; set; }
  public List<Grantee_Report__c> incomplete_report_list { get; set; }
  public Boolean more_report { get; set; }
  public Boolean more_incomplete_report { get; set; }

  public String rId { get; set; }
  public String rStatus { get; set; }
  public DateTime rDate { get; set; }
  public Integer rCount { get; set; }

  public Date dt = date.today();
  public Date ytd = dt.addDays(-365);
  public String errorMessage { get; set; }

  public BBBSDashboardCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    userProfile = currentUser.Profile.Name;

    Account a = ac.getAccount(userAcct.Id);
    if (a.DUNS_Exp_Date__c < dt) {
      showDUNSAlert = true;
      DUNSAlert = 'Your SAM.gov registration is overdue. Your agency will be on reimbursement hold status for all active Federal Grants until this has been resolved. Updating SAM.gov does not automatically update this system. Please submit your updated registration date via the Organization Info tab.Please update your SAM.gov registration here.';
    } else if (a.DUNS_Exp_Date__c < dt.addDays(45)) {
      showDUNSAlert = true;
      DUNSAlert = 'Your SAM.gov registration will expire within 45 days. You must update the registration in order to remain in compliance with the grant MOA terms and receive reimbursements. Updating SAM.gov does not automatically update this system. Please submit your updated registration date via the Organization Info tab.';
    }

    missingDocs = new List<Document__c>();
    for (Document__c d : [
      SELECT Name, Due_Date__c, Grant__c, Grant__r.Name
      FROM Document__c
      WHERE
        Organization__c = :userAcct.Id
        AND (Status__c = 'Requested'
        OR Status__c = 'Sent Back')
        AND Required__c = TRUE
        AND (Due_Date__c < :dt
        OR Due_Date__c < :dt.addDays(15))
        AND (Access_Mode__c = NULL
        OR Access_Mode__c = ''
        OR Access_Mode__c = 'Local Read Only')
    ]) {
      missingDocs.add(d);
      system.debug(d);
    }

    onHold = ac.getRelatedAccountList(
      userAcct.Id,
      'National Organization',
      null,
      null,
      ' AND Hold_Status__c = \'Hold\''
    );

    if (approverLevel == 'Level One') {
      approverLevelURL = 'First';
    }
    if (approverLevel == 'Level Two') {
      approverLevelURL = 'Second';
    }
    if (approverLevel.contains('Level Three')) {
      approverLevelURL = 'Final';
    }

    pending_grant_list = new List<Grant__c>();
    sentBack_grant_list = new List<Grant__c>();
    pending_request_list = new List<Reimbursement_Request__c>();
    todo_request_list = new List<Reimbursement_Request__c>();
    incomplete_request_list = new List<Reimbursement_Request__c>();
    report_list = new List<Grantee_Report__c>();
    incomplete_report_list = new List<Grantee_Report__c>();

    more_pending_grant = false;
    more_sentBack_grant = false;
    more_pending_request = false;
    more_todo_request = false;
    more_incomplete_request = false;
    more_report = false;
    more_incomplete_report = false;
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
    rCount = 0;

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
      if (
        (approverLevel.contains('Level Two') ||
        approverLevel.contains('Level Three')) &&
        (g.Grant_Status__c == 'Pending Review' ||
        g.Grant_Status__c == 'Budget Submitted')
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
    }

    for (Reimbursement_Request__c r : [
      SELECT
        Id,
        Name,
        LastModifiedDate,
        Is_National_Request__c,
        Grant__r.Account__r.Id,
        Grant__r.Account__r.Primary_Approver__c,
        Grant__r.Account__r.Secondary_Approver__c,
        Grant__r.Account__r.Primary_Approver_On_Leave__c,
        Grant__r.Account__r.National_Organization__c,
        Grant__r.Name,
        Request_Date__c,
        Status__c,
        Paid_Date__c,
        Level_Three_Approved_Date__c
      FROM Reimbursement_Request__c
      WHERE Grant_Status__c != 'Closed'
      ORDER BY LastModifiedDate DESC
    ]) {
      if (userAcctType == 'National Organization') {
        if (approverLevel == 'Level One') {
          if (r.Status__c == 'Pending First Approval') {
            if (
              r.Grant__r.Account__r.Primary_Approver__c ==
              currentUser.ContactId &&
              r.Grant__r.Account__r.Primary_Approver_On_Leave__c == false
            ) {
              if (todo_request_list.size() < listLimit) {
                todo_request_list.add(r);
              } else {
                more_todo_request = true;
              }
            } else if (
              r.Grant__r.Account__r.Secondary_Approver__c ==
              currentUser.ContactId &&
              r.Grant__r.Account__r.Primary_Approver_On_Leave__c == true
            ) {
              if (todo_request_list.size() < listLimit) {
                todo_request_list.add(r);
              } else {
                more_todo_request = true;
              }
            } else {
              if (pending_request_list.size() < listLimit) {
                pending_request_list.add(r);
              } else {
                more_pending_request = true;
              }
            }
          } else if (
            !r.Is_National_Request__c &&
            (r.Status__c == 'Pending Second Approval' ||
            r.Status__c == 'Pending Final Approval')
          ) {
            if (pending_request_list.size() < listLimit) {
              pending_request_list.add(r);
            } else {
              more_pending_request = true;
            }
          }
        }
        if (approverLevel.contains('Level Two')) {
          if (r.Status__c == 'Pending Second Approval') {
            if (todo_request_list.size() < listLimit) {
              todo_request_list.add(r);
            } else {
              more_todo_request = true;
            }
          } else if (
            !r.Is_National_Request__c &&
            (r.Status__c == 'Pending First Approval' ||
            r.Status__c == 'Pending Final Approval')
          ) {
            if (pending_request_list.size() < listLimit) {
              pending_request_list.add(r);
            } else {
              more_pending_request = true;
            }
          }
        }
        if (approverLevel.contains('Level Three')) {
          if (r.Status__c == 'Pending Final Approval') {
            if (todo_request_list.size() < listLimit) {
              todo_request_list.add(r);
            } else {
              more_todo_request = true;
            }
          } else if (
            r.Status__c == 'Pending First Approval' ||
            r.Status__c == 'Pending Second Approval'
          ) {
            if (pending_request_list.size() < listLimit) {
              pending_request_list.add(r);
            } else {
              more_pending_request = true;
            }
          }
        }
        if (
          r.Status__c == 'Incomplete' ||
          r.Status__c == 'Revisions Needed' ||
          r.Status__c == 'Revision in Progress'
        ) {
          if (incomplete_request_list.size() < listLimit) {
            incomplete_request_list.add(r);
          } else {
            more_incomplete_request = true;
          }
        }
        if (r.Status__c == 'Approved' || r.Status__c == 'Paid') {
          rCount += 1;
        }
      }

      if (userAcctType == 'Local Organization') {
        if (r.Status__c == 'Incomplete') {
          if (incomplete_request_list.size() < listLimit) {
            incomplete_request_list.add(r);
          } else {
            more_incomplete_request = true;
          }
        }
        if (
          r.Status__c == 'Revisions Needed' ||
          r.Status__c == 'Revision in Progress'
        ) {
          if (todo_request_list.size() < listLimit) {
            todo_request_list.add(r);
          } else {
            more_todo_request = true;
          }
        }
        if (
          rId == null && (r.Status__c == 'Approved' || r.Status__c == 'Paid')
        ) {
          rId = r.Name;
          rStatus = r.Status__c;
          if (r.Paid_Date__c != null) {
            rDate = r.Paid_Date__c;
          } else if (r.Level_Three_Approved_Date__c != null) {
            rDate = r.Level_Three_Approved_Date__c;
          } else {
            rDate = r.LastModifiedDate;
          }
        }
      }
    }

    for (Grantee_Report__c gr : [
      SELECT
        Grant__r.Name,
        Name,
        Report_Status__c,
        LastModifiedDate,
        Submitted_Date__c
      FROM Grantee_Report__c
      WHERE Grant_Status__c != 'Closed'
      ORDER BY LastModifiedDate DESC
    ]) {
      report_list.add(gr);
      if (gr.Report_Status__c == 'In Progress') {
        if (incomplete_report_list.size() < listLimit) {
          incomplete_report_list.add(gr);
        } else {
          more_incomplete_report = true;
        }
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
