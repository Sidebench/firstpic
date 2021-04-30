public with sharing class RequestFormController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  private BudgetItemClass budgetItemClass = new BudgetItemClass();
  private ReimbursementClass requestClass = new ReimbursementClass();
  private ReimbursementItemClass requestItemClass = new ReimbursementItemClass();

  public Account acct { get; set; }
  public ID grantId { get; set; }
  public List<SelectOption> grant_list { get; set; }
  public Grant__c grant { get; set; }
  public List<Budget_Item__c> bi_list { get; set; }

  public ID RequestID { get; set; }
  public Reimbursement_Request__c request { get; set; }
  public List<Reimbursement_Item__c> ri_list { get; set; }
  public Id laborId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
    .get('Labor')
    .getRecordTypeId();
  public Id expenseId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
    .get('Expense')
    .getRecordTypeId();

  public Date startDate { get; set; }
  public Date endDate { get; set; }

  public Boolean factorConfirm { get; set; }
  public String errorMessage { get; set; }

  // BEGIN Constructor
  public RequestFormController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;
    if (portalName == 'BBBS')
      portalName = '';

    grantId = ApexPages.currentPage().getParameters().get('GrantId');
    RequestID = ApexPages.currentPage().getParameters().get('RequestID');

    grant_list = new List<SelectOption>();
    request = new Reimbursement_Request__c();
    bi_list = new List<Budget_Item__c>();
    ri_list = new List<Reimbursement_Item__c>();

    factorConfirm = false;
    errorMessage = '';

    if (RequestID != null) {
      Reimbursement_Request__c[] requests = [
        SELECT
          Grant__c,
          Previous_Status__c,
          Status__c,
          Request_Notes__c,
          Start_Date__c,
          End_Date__c,
          Total_FTE_at_Affiliate__c,
          Youth_Served__c,
          Youth_Served_with_Grant_Funding__c
        FROM Reimbursement_Request__c
        WHERE Id = :RequestID
      ];
      if (requests.size() > 0) {
        request = requests[0];
        startDate = request.Start_Date__c;
        endDate = request.End_Date__c;
        grantId = request.Grant__c;
      }
    }

    if (grantId == null) {
      grant_list.add(new SelectOption('', '-- Select a Sub-Grant --'));
      for (Grant__c g : [
        SELECT Id, Name
        FROM Grant__c
        WHERE Account__c = :userAcct.Id AND Grant_Status__c = 'Approved'
      ]) {
        grant_list.add(new SelectOption(g.Id, g.Name));
      }
    } else {
      getGrant();
    }
  }

  public void getGrant() {
    if (grantId != null) {
      Grant__c[] grants = [
        SELECT
          Account__r.Id,
          Name,
          Balance__c,
          Use_Indirect_Rate__c,
          Account__r.RecordType.Name
        FROM Grant__c
        WHERE Id = :GrantId
      ];
      if (grants.size() > 0) {
        grant = grants[0];
      }
      acct = [
        SELECT ID, Name, RecordType.Name
        FROM Account
        WHERE ID = :grant.Account__r.Id
      ];
    }
  }

  public void getItemList() {
    for (Budget_Item__c bi : [
      SELECT
        Id,
        Name,
        RecordType.Name,
        Is_Active__c,
        Hourly_Rate__c,
        Monthly_Rate__c,
        Other_Factor_Percent__c,
        Factor_Type__c
      FROM Budget_Item__c
      WHERE Grant__c = :GrantId
    ]) {
      if (bi.Name != 'Benefits' && bi.Is_Active__c == true) {
        bi_list.add(bi);
      }
    }
    system.debug('>>> bi_list = ' + bi_list);

    system.debug('>>> request = ' + request);
    if (request.Id != null) {
      //ri_list = ric.getRequestItems(request.Id);
      ri_list = [
        SELECT Id
        FROM Reimbursement_Item__c
        WHERE Reimbursement_Request__c = :request.Id
      ];
      system.debug('>>> ri_list = ' + ri_list);

      if (
        (ri_list == null ||
        ri_list.size() == 0) &&
        bi_list != null &&
        bi_list.size() > 0
      ) {
        for (Budget_Item__c bi : bi_list) {
          if (bi.Is_Active__c) {
            Reimbursement_Item__c r = new Reimbursement_Item__c();
            r.Reimbursement_Request__c = request.Id;
            r.Budget_Item__c = bi.Id;
            if (bi.RecordType.Name == 'Labor') {
              r.RecordTypeId = laborId;
              if (bi.Hourly_Rate__c != null) {
                r.Rate__c = (bi.Hourly_Rate__c).setScale(2);
              }
            } else {
              r.RecordTypeId = expenseId;
              if (bi.Monthly_Rate__c != null) {
                r.Rate__c = bi.Monthly_Rate__c;
              }
              if (bi.Factor_Type__c == 'Other') {
                if (
                  bi.Other_Factor_Percent__c > 0 &&
                  r.Factor_Percent__c <= 100
                ) {
                  r.Factor_Percent__c = bi.Other_Factor_Percent__c;
                } else {
                  r.Factor_Percent__c = 100;
                }
              }
            }
            ri_list.add(r);
          }
        }
        requestItemClass.upsertItems(ri_list);
      }
    }
  }

  public PageReference next() {
    errorMessage = '';

    if (portalName == 'BBBS') {
      if (factorConfirm == false) {
        errorMessage = 'Please confirm that you\'d like to proceed using current indirect rate or factor value';
      }
      //if(request.Youth_Served__c == null || request.Youth_Served_with_Grant_Funding__c == null || request.Youth_Served_with_Grant_Funding__c > request.Youth_Served__c) {
      if (
        request.Youth_Served_with_Grant_Funding__c > request.Youth_Served__c
      ) {
        errorMessage = 'The number of youth served with grant funding should not exceed total number of youth served';
      }
      //if(request.Youth_Served_with_Grant_Funding__c == 0 || request.Youth_Served_with_Grant_Funding__c == null) {
      //    errorMessage = 'The number of youth served with grant funding should not be zero';
      //}
      if (
        request.Total_FTE_at_Affiliate__c == 0 ||
        request.Total_FTE_at_Affiliate__c == null
      ) {
        errorMessage = 'The total employee hours at affiliate should not be zero';
      }
    }

    if (String.isBlank(errorMessage)) {
      Date dt = date.today();
      String fdt = dt.format();
      if (request.Id == null) {
        request.Grant__c = grant.ID;
        request.Modification_History__c =
          fdt +
          ': Request Submitted by ' +
          currentUser.Contact.Name +
          ' (' +
          currentUser.Id +
          ')';
      }

      if (grant.Account__r.RecordType.Name == 'National Organization') {
        request.Is_National_Request__c = true;
      }

      request.Request_Date__c = dt;
      if (portalName == 'MDGO') {
        if (startDate != null)
          request.Start_Date__c = startDate;
        if (endDate != null)
          request.End_Date__c = endDate;
      }
      request.Previous_Status__c = request.Status__c;
      if (request.Status__c == 'Revisions Needed') {
        request.Status__c = 'Revision in Progress';
      } else if (request.Status__c == null) {
        request.Status__c = 'Incomplete';
      }
      if (
        request.Youth_Served_with_Grant_Funding__c > 0 &&
        request.Youth_Served__c > 0
      ) {
        request.Youth_Served_Percent__c =
          request.Youth_Served_with_Grant_Funding__c /
          request.Youth_Served__c *
          100;
      } else {
        request.Youth_Served_Percent__c = 0;
      }
      if (request.Youth_Served_Percent__c > 100) {
        errorMessage = 'The projected # of children served with grant funding during the Grant performance period should not exceed the total # of children served.';
      }
      try {
        RequestClass.upsertRequest(request);
        getItemList();
      } catch (Exception e) {
        errorMessage =
          'An error occurred whil upserting the request: ' + e.getMessage();
        system.debug('error = ' + e.getMessage());
        return null;
      }
    }
    PageReference pr = new PageReference(
      '/' +
      portalName +
      'RequestPersonnelForm?RequestID=' +
      request.Id
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference cancel() {
    PageReference pr = new PageReference('/Reimbursements');
    pr.setRedirect(true);
    return pr;
  }
}
