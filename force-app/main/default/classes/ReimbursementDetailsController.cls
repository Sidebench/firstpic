public with sharing class ReimbursementDetailsController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public Boolean displayApprovalButtons { get; set; }
  public String portalName { get; set; }
  public AccountClass ac = new AccountClass();

  public GrantClass grantClass = new GrantClass();
  public ReimbursementClass requestClass = new ReimbursementClass();
  public ReimbursementItemClass requestItemClass = new ReimbursementItemClass();

  public Account acct { get; set; }
  public ID RequestID { get; set; }
  public Reimbursement_Request__c request { get; set; }
  public Grant__c grant { get; set; }
  public Map<String, List<Reimbursement_Item__c>> labor_map { get; set; }
  public Map<String, List<Reimbursement_Item__c>> expense_map { get; set; }

  public Boolean displayPopupBg { get; set; }
  public Boolean displayLaborNotesPopup { get; set; }
  public Boolean displayExpenseNotesPopup { get; set; }
  public Boolean displayRequestNotesPopup { get; set; }
  public Boolean displayDeletePopup { get; set; }

  public Boolean isNationalRequest { get; set; }
  public Boolean approve { get; set; }
  public Boolean deny { get; set; }
  public Boolean sendBack { get; set; }
  public String statusColor { get; set; }
  public String errorMessage { get; set; }
  public Boolean amountError { get; set; }

  public Decimal laborRequestedAmount { get; set; }
  public Decimal expenseRequestedAmount { get; set; }
  public Decimal totalRequestedAmount { get; set; }
  public Decimal totalApprovedAmount { get; set; }

  public Decimal requestSub { get; set; }
  public Decimal fICASub { get; set; }
  public Decimal medicalSub { get; set; }
  public Decimal dentalSub { get; set; }
  public Decimal shortTermSub { get; set; }
  public Decimal longTermSub { get; set; }
  public Decimal lifeSub { get; set; }
  public Decimal otherSub { get; set; }
  public Decimal benefitsSub { get; set; }
  public Decimal requstedBenefitsSub { get; set; }

  public Attachment att { get; set; }
  public List<Attachment> request_att_list { get; set; }
  public List<Attachment> att_list { get; set; }

  public DateTime dt = dateTime.now();
  public String fdt = dt.formatLong();

  // BEGIN Constructor
  public ReimbursementDetailsController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    displayApprovalButtons = false;
    portalName = userClass.userProfile;
    if (portalName == 'BBBS')
      portalName = '';

    isNationalRequest = false;
    approve = false;
    deny = false;
    sendBack = false;
    statusColor = '';

    labor_map = new Map<String, List<Reimbursement_Item__c>>();
    expense_map = new Map<String, List<Reimbursement_Item__c>>();

    displayPopupBg = false;
    displayLaborNotesPopup = false;
    displayExpenseNotesPopup = false;
    displayRequestNotesPopup = false;
    displayDeletePopup = false;

    laborRequestedAmount = 0;
    expenseRequestedAmount = 0;
    totalRequestedAmount = 0;
    totalApprovedAmount = 0;

    requestSub = 0;
    fICASub = 0;
    medicalSub = 0;
    dentalSub = 0;
    shortTermSub = 0;
    longTermSub = 0;
    lifeSub = 0;
    otherSub = 0;
    benefitsSub = 0;
    requstedBenefitsSub = 0;

    att = new Attachment();
    request_att_list = new List<Attachment>();
    att_list = new List<Attachment>();

    RequestID = ApexPages.currentPage().getParameters().get('RequestID');
    request = requestClass.getRequest(RequestId);

    grant = grantClass.getGrant(request.Grant__c);
    acct = ac.getAccount(grant.Account__r.Id); //[SELECT ID, Name, RecordType.Name, Primary_Approver__c, Secondary_Approver__c, Primary_Approver_On_Leave__c FROM Account WHERE ID = :grant.Account__r.Id];

    request.Previous_Status__c = request.Status__c;
    if (request.Status__c == 'Incomplete') {
      statusColor = 'text-warning';
    }
    if (request.Status__c == 'Denied') {
      statusColor = 'text-danger';
    }
    if (request.Status__c == 'Approved' || request.Status__c == 'Paid') {
      statusColor = 'text-success';
    }
    init();
  }
  // END Constructor

  public Boolean initalized = false;
  public void init() {
    if (!initalized) {
      if (
        userAcctType == 'National Organization' &&
        request.Grant__r.Account__r.Id == userAcct.Id
      ) {
        isNationalRequest = true;
      }
      System.debug('Request: ' + request);
      if (request.Status__c == 'Pending First Approval') {
        if (
          acct.Primary_Approver__c == currentUser.ContactId &&
          acct.Primary_Approver_On_Leave__c == false
        ) {
          displayApprovalButtons = true;
        } else if (
          acct.Secondary_Approver__c == currentUser.ContactId &&
          acct.Primary_Approver_On_Leave__c == true
        ) {
          displayApprovalButtons = true;
        } else if (approverLevel == 'Finance Admin') {
          displayApprovalButtons = true;
        } else if (portalName == 'NPAL' || portalName == 'DMV') {
          displayApprovalButtons = true;
        } else if (
          portalName == 'MDGO' &&
          userAcctType == 'National Organization'
        ) {
          displayApprovalButtons = true;
        }
      }
      if (
        request.Status__c == 'Pending Second Approval' &&
        (approverLevel.contains('Level Two') ||
        approverLevel == 'Finance Admin' ||
        (approverLevel == 'Level Three' &&
        (portalName == 'NPAL' ||
        portalName == 'DMV')))
      ) {
        if (isNationalRequest == false)
          displayApprovalButtons = true;
      }
      if (
        request.Status__c == 'Pending Final Approval' &&
        (approverLevel.contains('Level Three') ||
        approverLevel == 'Finance Admin')
      ) {
        displayApprovalButtons = true;
      }

      Set<String> att_name_set = new Set<String>();
      for (Attachment a : request.Attachments) {
        if (!att_name_set.contains(a.Name)) {
          request_att_list.add(a);
        }
        for (Attachment ra : request_att_list) {
          att_name_set.add(ra.Name);
        }
      }

      Set<Id> riId_set = new Set<Id>();
      for (
        Reimbursement_Item__c ri : requestItemClass.getRequestItems(
          RequestId,
          null
        )
      ) {
        riId_set.add(ri.Id);
        if (ri.RecordType.Name == 'Expense') {
          if (ri.Requested_Amount__c != null) {
            expenseRequestedAmount += ri.Requested_Amount__c;
            if (ri.Approved_Amount__c == null)
              ri.Approved_Amount__c = ri.Requested_Amount__c;
          }
          if (expense_map.containsKey(ri.Budget_Item__r.Category__c)) {
            List<Reimbursement_Item__c> ri_list = expense_map.get(
              ri.Budget_Item__r.Category__c
            );
            ri_list.add(ri);
            expense_map.put(ri.Budget_Item__r.Category__c, ri_list);
          } else {
            expense_map.put(
              ri.Budget_Item__r.Category__c,
              new List<Reimbursement_Item__c>{ ri }
            );
          }
        } else {
          if (ri.Requested_Salary__c != null) {
            laborRequestedAmount += ri.Requested_Salary__c;
            if (ri.Approved_Salary__c == null)
              ri.Approved_Salary__c = ri.Requested_Salary__c;
            if (ri.Requested_Benefits__c != null) {
              laborRequestedAmount += ri.Requested_Benefits__c;
              if (ri.Approved_Benefits__c == null)
                ri.Approved_Benefits__c = ri.Requested_Benefits__c;
            }
          } else if (ri.Requested_Amount__c != null) {
            laborRequestedAmount += ri.Requested_Amount__c;
            if (ri.Approved_Amount__c == null)
              ri.Approved_Amount__c = ri.Requested_Amount__c;
          }
          //if(ri.Requested_Benefits__c != null) {
          //    laborRequestedAmount += ri.Requested_Benefits__c;
          //}
          if (labor_map.containsKey(ri.Budget_Item__r.Category__c)) {
            List<Reimbursement_Item__c> ri_list = labor_map.get(
              ri.Budget_Item__r.Category__c
            );
            ri_list.add(ri);
            labor_map.put(ri.Budget_Item__r.Category__c, ri_list);
          } else {
            labor_map.put(
              ri.Budget_Item__r.Category__c,
              new List<Reimbursement_Item__c>{ ri }
            );
          }

          Decimal fb = 0;
          if (ri.FICA__c != null) {
            fb += ri.FICA__c;
            ficaSub += ri.FICA__c;
          }
          if (ri.Medical__c != null) {
            fb += ri.Medical__c;
            medicalSub += ri.Medical__c;
          }
          if (ri.Dental__c != null) {
            fb += ri.Dental__c;
            dentalSub += ri.Dental__c;
          }
          if (ri.Short_Term_Disability__c != null) {
            fb += ri.Short_Term_Disability__c;
            shortTermSub += ri.Short_Term_Disability__c;
          }
          if (ri.Long_Term_Disability__c != null) {
            fb += ri.Long_Term_Disability__c;
            longTermSub += ri.Long_Term_Disability__c;
          }
          if (ri.Life__c != null) {
            fb += ri.Life__c;
            lifeSub += ri.Life__c;
          }
          if (ri.Other_Benefits__c != null) {
            fb += ri.Other_Benefits__c;
            otherSub += ri.Other_Benefits__c;
          }
          if (fb > 0) {
            benefitsSub += fb;
          }
          if (ri.Requested_Benefits__c != null) {
            requstedBenefitsSub += ri.Requested_Benefits__c;
          }
          if (ri.Requested_Amount__c > 0 && ri.Requested_Salary__c != null) {
            requestSub += ri.Requested_Salary__c;
          }
        }
      }
      for (Attachment att : [
        SELECT ID, ParentID, Name
        FROM Attachment
        WHERE ParentId IN :riId_set
        ORDER BY LastModifiedDate DESC
      ]) {
        att_list.add(att);
      }
      getTotals();
      initalized = true;
    }
  }

  public void updateItems() {
    List<Reimbursement_Item__c> update_list = new List<Reimbursement_Item__c>();

    // COMPARE EXISTING REIMBURSEMENT ITEMS TO NEW ITEMS
    List<List<Reimbursement_Item__c>> labor_list = labor_map.values();
    for (Integer i = 0; i < labor_list.size(); i++) {
      for (Reimbursement_Item__c ri : labor_list.get(i)) {
        update_list.add(ri);
      }
    }
    List<List<Reimbursement_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Reimbursement_Item__c ri : expense_list.get(i)) {
        update_list.add(ri);
      }
    }
    try {
      requestItemClass.upsertItems(update_list);
      System.Debug(
        '>>>> Reimbursement list update successful. update_list = ' +
        update_list
      );
      displayLaborNotesPopup = false;
      displayExpenseNotesPopup = false;
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
    }
  }

  public void getTotals() {
    amountError = false;

    Decimal balance = grant.Balance__c; //[SELECT Balance__c FROM Grant__c WHERE Id = :grant.Id].Balance__c;
    if (grant.Use_Indirect_Rate__c == 'Yes') {
      grant.Indirect_Rate_Amount__c = ((laborRequestedAmount +
        expenseRequestedAmount) *
        grant.Indirect_Rate__c /
        100)
        .setScale(2);
      totalRequestedAmount =
        laborRequestedAmount +
        expenseRequestedAmount +
        grant.Indirect_Rate_Amount__c;
    } else {
      totalRequestedAmount = (laborRequestedAmount + expenseRequestedAmount)
        .setScale(2);
    }
    if (portalName == 'BBBSA' && totalRequestedAmount > balance) {
      errorMessage = 'Requested amount exceeds Sub-Grant balance.';
      amountError = true;
    }

    totalApprovedAmount = 0;
    List<List<Reimbursement_Item__c>> labor_list = labor_map.values();
    for (Integer i = 0; i < labor_list.size(); i++) {
      for (Reimbursement_Item__c ri : labor_list.get(i)) {
        if (ri.Approved_Salary__c != null)
          totalApprovedAmount += ri.Approved_Salary__c;
        if (ri.Approved_Benefits__c != null)
          totalApprovedAmount += ri.Approved_Benefits__c;
      }
    }
    List<List<Reimbursement_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Reimbursement_Item__c ri : expense_list.get(i)) {
        if (ri.Approved_Amount__c != null)
          totalApprovedAmount += ri.Approved_Amount__c;
      }
    }
    if (
      request.Status__c.contains('Pending') &&
      portalName != 'BBBSA' &&
      totalApprovedAmount > balance
    ) {
      errorMessage = 'Approved amount exceeds Sub-Grant balance.';
      amountError = true;
    }
  }

  public PageReference editRequest() {
    PageReference pr = new PageReference(
      '/' +
      portalName +
      'RequestForm?RequestID=' +
      RequestID
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference deleteRequest() {
    requestClass.deleteRequest(request);
    PageReference pr = new PageReference('/Reimbursements');
    pr.setRedirect(true);
    return pr;
  }

  public void save() {
    try {
      requestClass.upsertRequest(request);
      requestNotesPopup();
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
    }
  }

  public PageReference saveAndClose() {
    updateItems();

    if (ApexPages.hasMessages() || errorMessage != '')
      return null;
    PageReference pr = new PageReference('/Reimbursements');
    pr.setRedirect(true);
    return pr;
  }

  public void resetApprovedAmount() {
    List<Reimbursement_Item__c> update_list = new List<Reimbursement_Item__c>();
    List<List<Reimbursement_Item__c>> labor_list = labor_map.values();
    for (Integer i = 0; i < labor_list.size(); i++) {
      for (Reimbursement_Item__c ri : labor_list.get(i)) {
        ri.Approved_Amount__c = null;
        ri.Approved_Salary__c = null;
        ri.Approved_Benefits__c = null;
        update_list.add(ri);
      }
    }
    List<List<Reimbursement_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Reimbursement_Item__c ri : expense_list.get(i)) {
        ri.Approved_Amount__c = null;
        ri.Approved_Salary__c = null;
        ri.Approved_Benefits__c = null;
        update_list.add(ri);
      }
    }
    requestItemClass.upsertItems(update_list);
  }

  public PageReference sendBack() {
    resetApprovedAmount();
    String mh =
      fdt +
      ': Returned for corrections by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (request.Modification_History__c == null) {
      request.Modification_History__c = '';
    }
    request.Modification_History__c += ' \r\n' + mh;

    request.Status__c = 'Revisions Needed';
    if (request.Level_One_Sent_Back_Count__c == null) {
      request.Level_One_Sent_Back_Count__c = 1;
    } else {
      request.Level_One_Sent_Back_Count__c += 1;
    }
    request.Level_One_Sent_Back_Date__c = date.today();
    request.Approved_Amount__c = 0;
    requestClass.upsertRequest(request);
    //updateItems();

    if (ApexPages.hasMessages())
      return null;
    else
      return new PageReference('/Reimbursements');
  }

  public PageReference sendBackToLevelOne() {
    resetApprovedAmount();
    String mh =
      fdt +
      ': Returned to Level One Approver by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (request.Modification_History__c == null) {
      request.Modification_History__c = '';
    }
    request.Modification_History__c += ' \r\n' + mh;

    request.Status__c = 'Pending First Approval';
    if (request.Level_Two_Sent_Back_Count__c == null) {
      request.Level_Two_Sent_Back_Count__c = 1;
    } else {
      request.Level_Two_Sent_Back_Count__c += 1;
    }
    request.Level_Two_Sent_Back_Date__c = date.today();
    request.Approved_Amount__c = 0;
    requestClass.upsertRequest(request);
    //updateItems();

    if (ApexPages.hasMessages())
      return null;
    else
      return new PageReference('/Reimbursements');
  }

  public PageReference sendBackToLevelTwo() {
    resetApprovedAmount();
    String mh =
      fdt +
      ': Returned to Level Two Approver by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (request.Modification_History__c == null) {
      request.Modification_History__c = '';
    }
    request.Modification_History__c += ' \r\n' + mh;

    request.Status__c = 'Pending Second Approval';
    if (request.Level_Three_Sent_Back_Count__c == null) {
      request.Level_Three_Sent_Back_Count__c = 1;
    } else {
      request.Level_Three_Sent_Back_Count__c += 1;
    }
    request.Level_Three_Sent_Back_Date__c = date.today();
    request.Approved_Amount__c = 0;
    requestClass.upsertRequest(request);
    //updateItems();

    if (ApexPages.hasMessages())
      return null;
    else
      return new PageReference('/Reimbursements');
  }

  public PageReference denyRequest() {
    resetApprovedAmount();
    request.Status__c = 'Denied';
    String mh =
      fdt +
      ': Denied by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (request.Modification_History__c == null) {
      request.Modification_History__c = '';
    }
    request.Modification_History__c += ' \r\n' + mh;
    request.Approved_Amount__c = 0;
    requestClass.upsertRequest(request);
    //updateItems();

    if (ApexPages.hasMessages())
      return null;
    else
      return new PageReference('/Reimbursements');
  }

  public PageReference approveRequest() {
    errorMessage = '';

    if (portalName == 'MDGO') {
      request.Status__c = 'Approved';
      request.Level_One_Approver__c = userClass.currentUser.ContactId;
      request.Level_One_Approved_Date__c = Date.today();
    } else {
      if (approverLevel == 'Level One') {
        request.Status__c = 'Pending Second Approval';
        request.Level_One_Approver__c = userClass.currentUser.ContactId;
        request.Level_One_Approved_Date__c = Date.today();
      }
      if (approverLevel.contains('Level Two')) {
        request.Status__c = 'Pending Final Approval';
        request.Level_Two_Approver__c = userClass.currentUser.ContactId;
        request.Level_Two_Approved_Date__c = Date.today();
      }
      if (
        approverLevel.contains('Level Three') ||
        approverLevel == 'Finance Admin'
      ) {
        request.Status__c = 'Approved';
        request.Level_Three_Approver__c = userClass.currentUser.ContactId;
        request.Level_Three_Approved_Date__c = Date.today();
      }
    }

    displayRequestNotesPopup = false;
    if (errorMessage != '')
      return null;

    String mh =
      fdt +
      ': Approved by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (request.Modification_History__c == null) {
      request.Modification_History__c = '';
    }
    request.Modification_History__c += ' \r\n' + mh;
    requestClass.upsertRequest(request);

    if (portalName != 'MDGO') {
      updateItems();
    }

    PageReference pr = new PageReference('/Reimbursements');
    pr.setRedirect(true);
    return pr;
  }

  public void laborNotesPopup() {
    if (displayLaborNotesPopup == true) {
      displayLaborNotesPopup = false;
    } else {
      displayLaborNotesPopup = true;
    }
  }

  public void expenseNotesPopup() {
    if (displayExpenseNotesPopup == true) {
      displayExpenseNotesPopup = false;
    } else {
      displayExpenseNotesPopup = true;
    }
  }

  public void requestNotesPopup() {
    sendBack = false;
    deny = false;
    approve = false;
    if (displayRequestNotesPopup == true) {
      displayRequestNotesPopup = false;
    } else {
      displayRequestNotesPopup = true;
    }
  }

  public void sendBackPopup() {
    sendBack = true;
    deny = false;
    approve = false;
    if (displayRequestNotesPopup == true) {
      displayRequestNotesPopup = false;
    } else {
      displayRequestNotesPopup = true;
    }
  }

  public void denyPopup() {
    sendBack = false;
    deny = true;
    approve = false;
    if (displayRequestNotesPopup == true) {
      displayRequestNotesPopup = false;
    } else {
      displayRequestNotesPopup = true;
    }
  }

  public void approvePopup() {
    errorMessage = '';
    getTotals();

    List<Reimbursement_Item__c> item_list = new List<Reimbursement_Item__c>();
    List<List<Reimbursement_Item__c>> labor_list = labor_map.values();
    for (Integer i = 0; i < labor_list.size(); i++) {
      for (Reimbursement_Item__c ri : labor_list.get(i)) {
        if (portalName != '') {
          if (
            ri.Approved_Salary__c != null &&
            ri.Approved_Salary__c > ri.Requested_Salary__c
          )
            errorMessage = 'Approved salary must not exceed requested salary';
          if (
            ri.Approved_Benefits__c != null &&
            ri.Approved_Benefits__c > ri.Requested_Benefits__c
          )
            errorMessage = 'Approved benefits must not exceed requested benefits';
          if (
            ri.Approved_Salary__c != null &&
            ri.Approved_Benefits__c != null &&
            ri.Response__c == null &&
            (ri.Approved_Salary__c < ri.Requested_Salary__c ||
            ri.Approved_Benefits__c < ri.Requested_Benefits__c)
          )
            errorMessage = 'A note is required for ' + ri.Title__c;
        }
        item_list.add(ri);
      }
    }
    List<List<Reimbursement_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Reimbursement_Item__c ri : expense_list.get(i)) {
        if (portalName != '' && ri.Approved_Amount__c != null) {
          if (ri.Approved_Amount__c > ri.Requested_Amount__c)
            errorMessage = 'Approved amount must not exceed requested amount';
          else if (
            ri.Approved_Amount__c < ri.Requested_Amount__c &&
            ri.Response__c == null
          )
            errorMessage = 'A note is required for ' + ri.Title__c;
        }
        item_list.add(ri);
      }
    }
    if (errorMessage == '') {
      try {
        requestItemClass.upsertItems(item_list);
        System.Debug(
          '>>>> Reimbursement items update successful. item_list = ' + item_list
        );
      } catch (Exception e) {
        errorMessage = e.getMessage();
        system.debug('error = ' + e.getMessage());
      }
      request.Approved_Amount__c = request.Total_Requested_Amount__c;

      sendBack = false;
      deny = false;
      approve = true;
      if (displayRequestNotesPopup == true) {
        displayRequestNotesPopup = false;
      } else {
        displayRequestNotesPopup = true;
      }
    }
  }

  public void deleteRequestPopup() {
    if (displayDeletePopup == true) {
      displayDeletePopup = false;
    } else {
      displayDeletePopup = true;
    }
  }
}
