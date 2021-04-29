public with sharing class ReimbursementListCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private ReimbursementClass requestClass = new ReimbursementClass();
  public String request { get; set; }
  public ID accountId { get; set; }
  public ID GrantID { get; set; }
  public ID SubGrantID { get; set; }
  public ID ReimID { get; set; }
  public String errorMessage { get; set; }

  public List<Reimbursement_Request__c> request_list { get; set; }
  public List<Reimbursement_Request__c> pending_list { get; set; }
  public List<Reimbursement_Request__c> pending_first_list { get; set; }
  public List<Reimbursement_Request__c> pending_second_list { get; set; }
  public List<Reimbursement_Request__c> pending_third_list { get; set; }
  public List<Reimbursement_Request__c> incomplete_list { get; set; }
  public List<Reimbursement_Request__c> revisions_list { get; set; }
  public List<Reimbursement_Request__c> national_request_list { get; set; }
  public List<Reimbursement_Request__c> approved_list { get; set; }
  public List<Reimbursement_Request__c> paid_list { get; set; }
  public List<Reimbursement_Request__c> denied_list { get; set; }
  public Boolean more_request { get; set; }
  public Boolean more_pending { get; set; }
  public Boolean more_pending_first { get; set; }
  public Boolean more_pending_second { get; set; }
  public Boolean more_pending_third { get; set; }
  public Boolean more_incomplete { get; set; }
  public Boolean more_revisions { get; set; }
  public Boolean more_approved { get; set; }
  public Boolean more_paid { get; set; }
  public Boolean more_denied { get; set; }
  public Boolean more_national_request { get; set; }

  public String keyword { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }
  public String listType { get; set; }
  public Integer listLimit { get; set; }
  public Boolean runGetLists { get; set; }

  public ReimbursementListCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    if (urlGrantId != '' && urlGrantId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlGrantId)
          .matches()
      ) {
        grantId = Id.valueOf(urlGrantId);
      }
    }

    listType = ApexPages.currentPage().getParameters().get('type');
    if (listType == null)
      listType = '';
    if (
      listType == '' ||
      listType == null ||
      (listType == 'completed' &&
      portalName == 'BBBS')
    ) {
      listLimit = 10;
    } else {
      listLimit = 1000;
    }
    runGetLists = true;

    request_list = new List<Reimbursement_Request__c>();
    pending_list = new List<Reimbursement_Request__c>();
    pending_first_list = new List<Reimbursement_Request__c>();
    pending_second_list = new List<Reimbursement_Request__c>();
    pending_third_list = new List<Reimbursement_Request__c>();
    incomplete_list = new List<Reimbursement_Request__c>();
    revisions_list = new List<Reimbursement_Request__c>();
    national_request_list = new List<Reimbursement_Request__c>();
    approved_list = new List<Reimbursement_Request__c>();
    paid_list = new List<Reimbursement_Request__c>();
    denied_list = new List<Reimbursement_Request__c>();

    keyword = '';
    sortBy = 'Request_Date__c';
    sortByOptions = new List<SelectOption>();
    if (portalName != 'NPAL') {
      sortByOptions.add(new SelectOption('Id', 'Request Id'));
    }
    sortByOptions.add(new SelectOption('Request_Date__c', 'Request Date'));
    sortByOptions.add(new SelectOption('Grant__r.Name', 'Sub-Grant Name'));
  }

  public void getLists() {
    request_list.clear();
    pending_list.clear();
    pending_first_list.clear();
    pending_second_list.clear();
    pending_third_list.clear();
    incomplete_list.clear();
    revisions_list.clear();
    national_request_list.clear();
    approved_list.clear();
    paid_list.clear();
    denied_list.clear();

    if (listType == 'pending') {
      if (approverLevel == 'Level One')
        listType = 'pendingfirst';
      if (approverLevel == 'Level Two' || approverLevel == 'Level Two Admin')
        listType = 'pendingsecond';
      if (approverLevel == 'Level Three')
        listType = 'pendingfinal';
    }
    system.debug(' listType = ' + listType);

    for (
      Reimbursement_Request__c r : requestClass.getRelatedRequests(
        userAcct.Id,
        grantId,
        '',
        sortBy,
        '',
        keyword,
        null,
        null
      )
    ) {
      String status = r.Status__c;
      if (
        (listType == '' ||
        listType == 'national') &&
        userAcctType == 'National Organization' &&
        r.Grant__r.Account__r.Id == userAcct.Id
      ) {
        if (
          approverLevel == 'Level Two Admin' ||
          approverLevel == 'Level Three'
        ) {
          if (national_request_list.size() < listLimit) {
            national_request_list.add(r);
          } else {
            more_national_request = true;
          }
        }
      } else if (
        (listType == '' ||
        listType == 'pendingapproval') &&
        status.contains('Approval') &&
        userAcctType == 'Local Organization'
      ) {
        if (pending_list.size() < listLimit) {
          pending_list.add(r);
        } else {
          more_pending = true;
        }
      }
      if (!r.Is_National_Request__c) {
        if (userAcctType == 'National Organization' || portalName == 'NPAL') {
          if (
            (listType == '' ||
            listType == 'pendingapproval' ||
            listType == 'pendingfirst') && status == 'Pending First Approval'
          ) {
            if (pending_first_list.size() < listLimit) {
              pending_first_list.add(r);
            } else {
              more_pending_first = true;
            }
          } else if (
            (listType == '' ||
            listType == 'pendingapproval' ||
            listType == 'pendingsecond') && status == 'Pending Second Approval'
          ) {
            if (pending_second_list.size() < listLimit) {
              pending_second_list.add(r);
            } else {
              more_pending_second = true;
            }
          } else if (
            (listType == '' ||
            listType == 'pendingapproval' ||
            listType == 'pendingfinal') && status == 'Pending Final Approval'
          ) {
            if (pending_third_list.size() < listLimit) {
              pending_third_list.add(r);
            } else {
              more_pending_third = true;
            }
          }
        }
        if (
          (listType == '' || listType == 'incomplete') && status == 'Incomplete'
        ) {
          if (incomplete_list.size() < listLimit) {
            incomplete_list.add(r);
          } else {
            more_incomplete = true;
          }
        } else if (
          (listType == '' || listType == 'sentback') &&
          (status == 'Revisions Needed' ||
          status == 'Revision in Progress')
        ) {
          if (revisions_list.size() < listLimit) {
            revisions_list.add(r);
          } else {
            more_revisions = true;
          }
        } else if (
          (listType == '' || listType == 'completed') &&
          (portalName == 'NPAL' ||
          userAcctType == 'Local Organization')
        ) {
          if (status == 'Approved' || status == 'Paid' || status == 'Denied') {
            if (request_list.size() < listLimit) {
              request_list.add(r);
            } else {
              more_request = true;
            }
          }
        } else if (listType != null && listType.contains('completed')) {
          if (
            (listType == 'completed' || listType == 'completedapproved') &&
            status == 'Approved'
          ) {
            if (approved_list.size() < listLimit) {
              approved_list.add(r);
            } else {
              more_approved = true;
            }
          }
          if (
            (listType == 'completed' || listType == 'completedpaid') &&
            status == 'Paid'
          ) {
            if (paid_list.size() < listLimit) {
              paid_list.add(r);
            } else {
              more_paid = true;
            }
          }
          if (
            (listType == 'completed' || listType == 'completeddenied') &&
            status == 'Denied'
          ) {
            if (denied_list.size() < listLimit) {
              denied_list.add(r);
            } else {
              more_denied = true;
            }
          }
        }
      }
    }
  }

  public void getRelatedReimbursments() {
    if (runGetLists) {
      for (
        Reimbursement_Request__c r : requestClass.getRelatedRequests(
          userAcct.Id,
          grantId,
          '',
          sortBy,
          '',
          keyword,
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
          if (pending_list.size() < listLimit) {
            pending_list.add(r);
          } else {
            more_pending = true;
          }
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
          } else if (status.contains('Final')) {
            if (pending_third_list.size() < listLimit) {
              pending_third_list.add(r);
            } else {
              more_pending_third = true;
            }
          }
        } else if (status == 'Approved') {
          if (approved_list.size() < listLimit) {
            approved_list.add(r);
          } else {
            more_approved = true;
          }
        }
      }
      runGetLists = false;
    }
  }
}
