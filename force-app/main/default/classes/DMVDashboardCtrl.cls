public with sharing class DMVDashboardCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public String userProfile { get; set; }
  public Account userAcct { get; set; }
  public String approverLevel { get; set; }
  public String userAcctType { get; set; }

  private GrantClass gc = new GrantClass();
  public List<Grant__c> grants_list { get; set; }
  public Boolean more_grants { get; set; }

  private ReimbursementClass rc = new ReimbursementClass();
  public List<Reimbursement_Request__c> incomplete_request_list { get; set; }
  public List<Reimbursement_Request__c> pending_approval_list { get; set; }
  public List<Reimbursement_Request__c> sentBack_request_list { get; set; }
  public Boolean more_incomplete_request { get; set; }
  public Boolean more_pending_approval { get; set; }
  public Boolean more_sentBack_request { get; set; }

  private ProgressReportClass prc = new ProgressReportClass();
  public List<Progress_Report__c> report_list { get; set; }
  public Boolean more_report { get; set; }

  public DMVDashboardCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    approverLevel = uc.approverLevel;
    userProfile = currentUser.Profile.Name;

    grants_list = new List<Grant__c>();
    incomplete_request_list = new List<Reimbursement_Request__c>();
    pending_approval_list = new List<Reimbursement_Request__c>();
    sentBack_request_list = new List<Reimbursement_Request__c>();
    report_list = new List<Progress_Report__c>();
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
    getLists();
    return null;
  }

  public void getLists() {
    Integer listLimit = 6;

    for (
      Grant__c g : gc.getRelatedSubGrants(
        userAcct.Id,
        null,
        null,
        'Total_Item_Balance__c',
        null,
        null,
        null
      )
    ) {
      if (grants_list.size() < listLimit) {
        grants_list.add(g);
      } else {
        more_grants = true;
      }
    }

    for (
      Reimbursement_Request__c r : rc.getRelatedRequests(
        userAcct.Id,
        null,
        null,
        null,
        null,
        null,
        null,
        null
      )
    ) {
      String status = r.Status__c;
      if (status == 'Incomplete') {
        if (incomplete_request_list.size() < listLimit) {
          incomplete_request_list.add(r);
        } else {
          more_incomplete_request = true;
        }
      } else if (status.contains('Pending')) {
        if (pending_approval_list.size() < listLimit) {
          pending_approval_list.add(r);
        } else {
          more_pending_approval = true;
        }
      } else if (status.contains('Revision')) {
        if (sentBack_request_list.size() < listLimit) {
          sentBack_request_list.add(r);
        } else {
          more_sentBack_request = true;
        }
      }
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
        ''
      )
    ) {
      if (report_list.size() < listLimit)
        report_list.add(pr);
      else
        more_report = true;
    }
  }
}
