public with sharing class SubGrantListCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }
  public String approverLevel { get; set; }

  private GrantClass grantClass = new GrantClass();
  public ID NPALGrantID { get; set; }
  public ID GrantID { get; set; }
  public ID SubGrantID { get; set; }
  public List<Grant__c> nationalGrant_list { get; set; }
  public List<Grant__c> grant_list { get; set; }
  public List<Grant__c> incomplete_list { get; set; }
  public List<Grant__c> pending_list { get; set; }
  public List<Grant__c> approved_list { get; set; }
  public Boolean more_incomplete { get; set; }
  public Boolean more_pending { get; set; }
  public Boolean more_approved { get; set; }

  public String listType { get; set; }
  public Integer listLimit { get; set; }
  public String keyword { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }
  public String errorMessage { get; set; }

  public SubGrantListCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    GrantId = ApexPages.currentPage().getParameters().get('GrantId');
    nationalGrant_list = new List<Grant__c>();
    grant_list = new List<Grant__c>();
    incomplete_list = new List<Grant__c>();
    pending_list = new List<Grant__c>();
    approved_list = new List<Grant__c>();

    listType = ApexPages.currentPage().getParameters().get('type');
    if (listType == '' || listType == null) {
      listType = '';
      listLimit = 10;
    } else {
      listLimit = 1000;
    }

    keyword = '';
    sortBy = '';
    sortByOptions = new List<SelectOption>();
    sortByOptions.add(new SelectOption('Name', 'Name'));
    sortByOptions.add(new SelectOption('Amount__c', 'Awarded'));
    sortByOptions.add(new SelectOption('Total_Budgeted__c', 'Total Budgeted'));
    sortByOptions.add(
      new SelectOption('Reimbursement_Requested_Amount__c', 'Requested Amount')
    );
    sortByOptions.add(
      new SelectOption('Reimbursement_Approved_Amount__c', 'Approved Amount')
    );
    sortByOptions.add(new SelectOption('Balance__c', 'Balance'));
    sortByOptions.add(new SelectOption('Grant_Status__c', 'Status'));

    /*
        if(portalName == 'NPAL') {
            Grant__c[] grants = [SELECT Id FROM Grant__c WHERE Account__r.Name = 'National PAL' AND RecordType.Name = 'Grant'];
            if(grants.size() > 0) NPALGrantID = grants[0].Id;
        }
        */
  }

  public void getLists() {
    grant_list.clear();

    String qry = 'SELECT Id, RecordType.Name, Name, Account__r.Id, Account__r.Name, Account__r.National_Organization__c, National_Grant__r.Account__c';
    qry += ', Start_Date__c, End_Date__c, LastModifiedDate, Amount__c, Total_Budgeted__c, Total_Item_Budget__c, Total_Item_Balance__c, Reimbursement_Requested_Amount__c, Reimbursement_Approved_Amount__c, Balance__c, Grant_Status__c';
    qry += ' FROM Grant__c WHERE RecordType.Name = \'Sub-Grant\'';
    if (listType == 'pending') {
      qry += ' AND (Grant_Status__c = \'Pending Review\' OR Grant_Status__c = \'Budget Submitted\')';
    }
    if (sortBy != '') {
      qry += ' ORDER BY ' + sortBy + ' ASC';
    }

    for (Grant__c g : Database.query(qry)) {
      if (userAcctType == 'National Organization') {
        if (g.Account__r.ID == userAcct.Id) {
          nationalGrant_list.add(g);
        }
        if (
          g.Account__r.National_Organization__c == userAcct.Id ||
          g.Account__c == userAcct.Id
        ) {
          if (g.National_Grant__r.Account__c == g.Account__c) {
            if (GrantId == null || g.National_Grant__r.Id == GrantID) {
              if (
                approverLevel == 'Level Two Admin' ||
                approverLevel == 'Level Three'
              ) {
                grant_list.add(g);
              }
            }
          } else if (GrantId != null) {
            if (g.National_Grant__r.Id == GrantID) {
              grant_list.add(g);
            }
          } else if (GrantId == null) {
            grant_list.add(g);
          }
        }
      } else if (g.Account__r.Id == userAcct.Id) {
        if (GrantId != null && g.National_Grant__r.Id == GrantID) {
          grant_list.add(g);
        } else if (GrantId == null) {
          grant_list.add(g);
        }
      }
    }

    if (keyword != null) {
      Integer i = 0;
      while (i < grant_list.size()) {
        String name = grant_list.get(i).Name;
        if (
          !name.toLowerCase().contains(String.valueOf(keyword).toLowerCase())
        ) {
          grant_list.remove(i);
        } else {
          i++;
        }
      }
    }
  }

  public void getRelatedGrants() {
    incomplete_list.clear();
    pending_list.clear();
    approved_list.clear();
    more_incomplete = false;
    more_pending = false;
    more_approved = false;

    for (
      Grant__c g : grantClass.getRelatedSubGrants(
        userAcct.Id,
        null,
        '',
        sortBy,
        '',
        keyword,
        null
      )
    ) {
      String status = '';
      if (g.Grant_Status__c != null)
        status = g.Grant_Status__c;

      if (
        status == '' ||
        status.contains('Incomplete') ||
        status == 'Revisions Needed'
      ) {
        if (incomplete_list.size() < listLimit) {
          incomplete_list.add(g);
        } else {
          more_incomplete = true;
        }
      } else if (status.contains('Approval')) {
        if (userAcctType != 'National Organization')
          g.Grant_Status__c = 'Pending Approval';
        if (pending_list.size() < listLimit) {
          pending_list.add(g);
        } else {
          more_pending = true;
        }
      } else if (status == 'Approved') {
        if (approved_list.size() < listLimit) {
          approved_list.add(g);
        } else {
          more_approved = true;
        }
      }
    }
  }
}
