public with sharing class RequestExpensesFormController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  public GrantClass grantClass = new GrantClass();
  public ReimbursementClass requestClass = new ReimbursementClass();
  public ReimbursementItemClass requestItemClass = new ReimbursementItemClass();
  public AttachmentClass attachClass = new AttachmentClass();

  public Account acct { get; set; }
  public ID GrantID { get; set; }
  public ID RequestID { get; set; }
  public Grant__c grant { get; set; }
  public Reimbursement_Request__c request { get; set; }
  public Set<ID> riId_set { get; set; }
  public Decimal laborRequestedAmount { get; set; }
  public Decimal expenseRequestedAmount { get; set; }
  public Decimal totalRequestedAmount { get; set; }
  public Boolean amountError { get; set; }
  public Boolean attachMissing { get; set; }
  public String errorMessage { get; set; }

  public Id expenseId { get; set; }
  public Map<String, List<Reimbursement_Item__c>> expense_map { get; set; }

  public Boolean displayPopupBg { get; set; }
  public Boolean displayExpenseNotesPopup { get; set; }
  public Boolean displayAttPopup { get; set; }
  public Boolean displayItemAttPopup { get; set; }

  public Attachment att { get; set; }
  public List<Attachment> att_list { get; set; }
  public List<Attachment> itemAtt_list { get; set; }
  public Id deleteAttId { get; set; }
  public Id deleteItemAttId { get; set; }

  public Date dt = date.today();
  public String fdt = dt.format();

  // BEGIN Constructor
  public RequestExpensesFormController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;
    if (portalName == 'BBBS')
      portalName = '';

    GrantID = ApexPages.currentPage().getParameters().get('GrantId');
    RequestID = ApexPages.currentPage().getParameters().get('RequestID');
    expenseId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
      .get('Expense')
      .getRecordTypeId();

    request = new Reimbursement_Request__c();
    riId_set = new Set<ID>();

    laborRequestedAmount = 0;
    expenseRequestedAmount = 0;
    totalRequestedAmount = 0;
    errorMessage = '';
    amountError = false;
    attachMissing = false;

    displayPopupBg = false;
    displayExpenseNotesPopup = false;
    displayAttPopup = false;
    displayItemAttPopup = false;

    expense_map = new Map<String, List<Reimbursement_Item__c>>();

    att_list = new List<Attachment>();
    itemAtt_list = new List<Attachment>();

    if (RequestID != null) {
      request = requestClass.getRequest(RequestId);
      request.Previous_Status__c = request.Status__c;
      GrantID = request.Grant__c;
      getAttList();
    }

    if (GrantID != null) {
      grant = grantClass.getGrant(GrantId);
      acct = [
        SELECT ID, Name, RecordType.Name
        FROM Account
        WHERE ID = :grant.Account__r.Id
      ];
    }
  }

  public Boolean initalized = false;
  public void getLists() {
    if (!initalized) {
      if (request.Id != null) {
        for (
          Reimbursement_Item__c ri : requestItemClass.getRequestItems(
            request.Id,
            'labor'
          )
        ) {
          if (ri.Requested_Amount__c != null) {
            laborRequestedAmount += ri.Requested_Amount__c;
          }
        }
        for (
          Reimbursement_Item__c ri : requestItemClass.getRequestItems(
            request.Id,
            'expense'
          )
        ) {
          riId_set.add(ri.Id);

          if (ri.Attachments.size() == 0) {
            Attachment a = new Attachment();
            a.ParentId = ri.Id;
            itemAtt_list.add(a);
          }

          if (
            portalName == 'NPAL' ||
            portalName == 'DMV' ||
            portalName == 'MDGO'
          )
            ri.Factor_Percent__c = 100;
          else {
            if (ri.Budget_Item__r.Factor_Type__c == 'FTE') {
              ri.Factor_Percent__c = request.FTE__c;
            } else if (ri.Budget_Item__r.Factor_Type__c == 'TCS') {
              ri.Factor_Percent__c = request.Youth_Served_Percent__c;
            }
          }
          /*
else if(ri.Budget_Item__r.Factor_Type__c == 'Other') {
ri.Factor_Percent__c = ri.Budget_Item__r.Other_Factor_Percent__c;
} 
*/
          if (ri.Factor_Percent__c > 100) {
            ri.Factor_Percent__c = 100;
          }

          if (ri.Rate__c > 0) {
            if (
              grant.Use_Indirect_Rate__c != 'Yes' &&
              ri.Factor_Percent__c > 0
            ) {
              ri.Requested_Amount__c = (ri.Rate__c *
                ri.Factor_Percent__c /
                100)
                .setScale(2);
            } else {
              ri.Requested_Amount__c = ri.Rate__c.setScale(2);
            }
          } else {
            ri.Requested_Amount__c = 0;
          }
          expenseRequestedAmount += ri.Requested_Amount__c;

          if (expense_map.containsKey(ri.Budget_Item__r.Category__c)) {
            List<Reimbursement_Item__c> item_list = expense_map.get(
              ri.Budget_Item__r.Category__c
            );
            item_list.add(ri);
            expense_map.put(ri.Budget_Item__r.Category__c, item_list);
          } else {
            expense_map.put(
              ri.Budget_Item__r.Category__c,
              new List<Reimbursement_Item__c>{ ri }
            );
          }
        }

        getTotals();

        for (Attachment att : [
          SELECT ID, ParentID, Name
          FROM Attachment
          WHERE ParentId IN :riId_set
          ORDER BY LastModifiedDate DESC
        ]) {
          itemAtt_list.add(att);
        }
      }
      initalized = true;
    }
  }

  // BEGIN getAttList
  public void getAttList() {
    att_list.clear();
    Reimbursement_Request__c r = [
      SELECT
        Id,
        (
          SELECT Id, Name, Description
          FROM Attachments
          ORDER BY LastModifiedDate DESC
        )
      FROM Reimbursement_Request__c
      WHERE Id = :request.Id
    ];
    Set<String> names = new Set<String>();
    for (Attachment a : r.Attachments) {
      if (
        a.Name == 'General Ledger' ||
        a.Name == 'TCS Report' ||
        a.Name == 'FTE Report'
      ) {
        if (!names.contains(a.Name)) {
          att_list.add(a);
          names.add(a.Name);
        }
      }
    }
  }
  // END getAttList

  // BEGIN deleteAtt
  public void deleteAtt() {
    if (deleteAttId != null) {
      Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteAttId];
      if (a != null) {
        attachClass.deleteAttachment(a);
      }
    }
    getAttList();
  }
  // END deleteAtt

  // BEGIN getItemAttList
  public void getItemAttList() {
    itemAtt_list.clear();

    List<Reimbursement_Item__c> ri_att_list = [
      SELECT
        ID,
        (
          SELECT ID, ParentID, Name
          FROM Attachments
          ORDER BY LastModifiedDate DESC
          LIMIT 1
        )
      FROM Reimbursement_Item__c
      WHERE
        Reimbursement_Request__c = :request.Id
        AND RecordType.Name = 'Expense'
    ];

    Set<Id> ri_att_Id_set = new Set<Id>();
    for (Reimbursement_Item__c ri : ri_att_list) {
      ri_att_Id_set.add(ri.Id);

      if (ri.Attachments.size() == 0) {
        Attachment a = new Attachment();
        a.ParentId = ri.Id;
        itemAtt_list.add(a);
      }
    }
    for (Attachment att : [
      SELECT ID, ParentID, Name
      FROM Attachment
      WHERE ParentId IN :ri_att_Id_set
      ORDER BY LastModifiedDate DESC
    ]) {
      itemAtt_list.add(att);
    }
  }
  // END getItemAttList

  // BEGIN deleteItemAtt
  public void deleteItemAtt() {
    if (deleteItemAttId != null) {
      Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteItemAttId];
      if (a != null) {
        attachClass.deleteAttachment(a);
      }
    }
    getItemAttList();
  }
  // END deleteItemAtt

  // BEGIN updateAmounts
  public void updateAmounts() {
    system.debug('>>> RequestExpensesFormController updateAmounts');
    errorMessage = '';
    attachMissing = false;
    expenseRequestedAmount = 0;
    totalRequestedAmount = laborRequestedAmount;

    List<Attachment> att_upsert_list = new List<Attachment>();
    List<List<Reimbursement_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Reimbursement_Item__c ri : expense_list.get(i)) {
        if (portalName != 'MDGO') {
          if (ri.Rate__c > 0) {
            if (
              ri.Factor_Percent__c != null &&
              grant.Use_Indirect_Rate__c != 'Yes'
            ) {
              ri.Requested_Amount__c = (ri.Rate__c *
                ri.Factor_Percent__c /
                100)
                .setScale(2);
            } else {
              ri.Requested_Amount__c = ri.Rate__c.setScale(2);
            }
          } else {
            ri.Requested_Amount__c = 0;
          }
        } else {
          ri.Requested_Amount__c = ri.Rate__c;
        }
        ri.Requested_Amount__c.setScale(2);
        expenseRequestedAmount += ri.Requested_Amount__c;
        totalRequestedAmount += ri.Requested_Amount__c;
      }
    }
    try {
      upsert att_upsert_list;
      getItemAttList();
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
    }

    if (totalRequestedAmount > grant.Balance__c) {
      amountError = true;
      errorMessage = 'Requested Amount Exceeds Sub-Grant Balance';
    } else {
      amountError = false;
    }
    getTotals();
  }

  public void getTotals() {
    if (grant.Use_Indirect_Rate__c == 'Yes') {
      request.Indirect_Rate_Amount__c = ((laborRequestedAmount +
        expenseRequestedAmount) *
        grant.Indirect_Rate__c /
        100)
        .setScale(2);
      totalRequestedAmount =
        laborRequestedAmount +
        expenseRequestedAmount +
        request.Indirect_Rate_Amount__c;
    } else {
      totalRequestedAmount = (laborRequestedAmount + expenseRequestedAmount)
        .setScale(2);
    }
    if (grant.Amount__c != null && totalRequestedAmount > grant.Amount__c) {
      amountError = true;
      errorMessage = 'Requested Amount Exceeds Sub-Grant Amount';
    } else {
      amountError = false;
    }
    system.debug(
      '>>> RequestExpensesFormController totalRequestedAmount = ' +
      totalRequestedAmount
    );
  }
  // END updateAmounts

  // BEGIN saveExpense
  public void saveExpense() {
    updateAmounts();
    requestClass.upsertRequest(request);

    Boolean hasLedger = false;
    for (Attachment a : att_list) {
      if (a.Name == 'General Ledger') {
        hasLedger = true;
      }
    }
    if (!hasLedger && portalName != 'NPAL' && portalName != 'MDGO') {
      errorMessage = 'A General Ledger document is required';
    }

    List<Reimbursement_Item__c> expense_update_list = new List<Reimbursement_Item__c>();
    List<List<Reimbursement_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Reimbursement_Item__c ri : expense_list.get(i)) {
        expense_update_list.add(ri);
      }
    }
    requestItemClass.upsertItems(expense_update_list);
  }
  // END saveExpense

  // BEGIN previous
  public PageReference previous() {
    saveExpense();

    PageReference pr = new PageReference(
      '/' +
      portalName +
      'RequestPersonnelForm?GrantID=' +
      GrantID +
      '&RequestID=' +
      RequestID
    );
    pr.setRedirect(true);
    return pr;
  }
  // END previous

  // BEGIN saveAndExit
  public PageReference saveAndExit() {
    saveExpense();

    PageReference pr = new PageReference('/Reimbursements');
    pr.setRedirect(true);
    return pr;
  }
  // END saveAndExit

  // BEGIN submit
  public PageReference submit() {
    saveExpense();

    system.debug('>>> errorMessage = ' + errorMessage);
    if (String.isBlank(errorMessage)) {
      String mh = '';
      if (request.Status__c == 'Incomplete') {
        request.Request_Date__c = dt;
        mh =
          fdt +
          ': Reimbursement Request Submitted by ' +
          currentUser.Contact.Name +
          ' (' +
          currentUser.Id +
          ')';
      } else {
        request.Modification_Last_Submitted_Date__c = dt;
        mh =
          fdt +
          ': Modification Submitted by ' +
          currentUser.Contact.Name +
          ' (' +
          currentUser.Id +
          ')';
      }
      if (request.Modification_History__c == null) {
        request.Modification_History__c = '';
      }
      request.Modification_History__c += ' \r\n' + mh;

      if (
        portalName == 'NPAL' &&
        grant.Account__r.RecordType.Name == 'National Organization'
      ) {
        request.Status__c = 'Approved';
      } else if (request.Is_National_Request__c) {
        request.Status__c = 'Pending Final Approval';
      } else {
        request.Status__c = 'Pending First Approval';
      }
      request.Primary_Contact__c = currentUser.ContactID;
      requestClass.upsertRequest(request);

      PageReference pr = new PageReference('/Reimbursements');
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }
  // END submit

  // BEGIN popups
  public void expenseNotesPopup() {
    if (displayExpenseNotesPopup == true) {
      displayPopupBg = false;
      displayExpenseNotesPopup = false;
    } else {
      displayPopupBg = true;
      displayExpenseNotesPopup = true;
    }
  }

  public void attPopup() {
    getAttList();
    if (displayAttPopup == true) {
      displayPopupBg = false;
      displayAttPopup = false;
    } else {
      displayPopupBg = true;
      displayAttPopup = true;
    }
  }

  public void itemAttPopup() {
    getItemAttList();
    if (displayItemAttPopup == true) {
      displayPopupBg = false;
      displayItemAttPopup = false;
    } else {
      displayPopupBg = true;
      displayItemAttPopup = true;
    }
  }
  // END popups
}
