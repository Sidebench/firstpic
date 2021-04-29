public with sharing class ReimbursementListsCtrl {
  public UserClass userClass = new UserClass();
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }

  private ReimbursementClass requestClass = new ReimbursementClass();

  public List<Reimbursement_Request__c> incomplete_list { get; set; }
  public List<Reimbursement_Request__c> revisions_list { get; set; }
  public List<Reimbursement_Request__c> pending_first_list { get; set; }
  public List<Reimbursement_Request__c> pending_second_list { get; set; }
  public List<Reimbursement_Request__c> pending_third_list { get; set; }
  public List<Reimbursement_Request__c> pending_fourth_list { get; set; }
  public Boolean more_incomplete { get; set; }
  public Boolean more_revisions { get; set; }
  public Boolean more_pending_first { get; set; }
  public Boolean more_pending_second { get; set; }
  public Boolean more_pending_third { get; set; }
  public Boolean more_pending_fourth { get; set; }

  public Integer listLimit { get; set; }
  public Boolean runGetLists { get; set; }

  public ReimbursementListsCtrl() {
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;

    listLimit = 6;
    runGetLists = true;

    incomplete_list = new List<Reimbursement_Request__c>();
    revisions_list = new List<Reimbursement_Request__c>();
    pending_first_list = new List<Reimbursement_Request__c>();
    pending_second_list = new List<Reimbursement_Request__c>();
    pending_third_list = new List<Reimbursement_Request__c>();
    pending_fourth_list = new List<Reimbursement_Request__c>();
  }

  public void getRelatedReimbursments() {
    if (runGetLists) {
      for (
        Reimbursement_Request__c r : requestClass.getRelatedRequests(
          userAcct.Id,
          null,
          '',
          null,
          null,
          null,
          null,
          null
        )
      ) {
        String status = '';
        if (r.Status__c != null)
          status = r.Status__c;

        if (status == '' || status.contains('Incomplete')) {
          if (incomplete_list.size() < listLimit) {
            incomplete_list.add(r);
          } else {
            more_incomplete = true;
          }
        } else if (
          status == 'Revisions Needed' ||
          status == 'Revision in Progress'
        ) {
          if (revisions_list.size() < listLimit) {
            revisions_list.add(r);
          } else {
            more_revisions = true;
          }
        } else if (status.contains('Approval')) {
          if (userAcctType != 'National Organization')
            r.Status__c = 'Pending Approval';
          if (status.contains('First')) {
            if (pending_first_list.size() < listLimit) {
              pending_first_list.add(r);
            } else {
              more_pending_first = true;
            }
          } else if (status.contains('Second')) {
            if (pending_second_list.size() < listLimit) {
              pending_second_list.add(r);
            } else {
              more_pending_second = true;
            }
          } else if (status.contains('Third')) {
            if (pending_third_list.size() < listLimit) {
              pending_third_list.add(r);
            } else {
              more_pending_third = true;
            }
          } else if (status.contains('Fourth')) {
            if (pending_fourth_list.size() < listLimit) {
              pending_fourth_list.add(r);
            } else {
              more_pending_fourth = true;
            }
          }
        }
      }
      runGetLists = false;
    }
  }
}
