public with sharing class SubGrantDetailsController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private GrantClass gc = new GrantClass();
  private BudgetItemClass bic = new BudgetItemClass();
  private getIdFromString gifs = new getIdFromString();
  private ContactClass cc = new ContactClass();
  private AccountClass ac = new AccountClass();

  public Account acct { get; set; }
  public Grant__c grant { get; set; }
  public ID grantId { get; set; }
  public Boolean isNationalSubGrant { get; set; }

  public Map<String, List<Budget_Item__c>> expense_map { get; set; }
  public Map<String, List<Budget_Item__c>> labor_map { get; set; }
  public Boolean hasLabor { get; set; }
  public Boolean hasExpenses { get; set; }

  public String statusColor { get; set; }
  public String errorMessage { get; set; }
  public Boolean editMode { get; set; }
  public Boolean incompleteReport { get; set; }
  public Boolean sendBack { get; set; }
  public Boolean deny { get; set; }
  public Boolean canCloseGrant { get; set; }
  public Boolean canReopenGrant { get; set; }

  public Decimal laborRequestedAmount { get; set; }
  public Decimal expenseRequestedAmount { get; set; }
  public Decimal updatedRequestedAmount { get; set; }

  public List<Contact> contacts { get; set; }
  public String boardMemberEmail { get; set; }
  public Boolean sendLOASuccessful { get; set; }
  public Boolean sendFFATASuccessful { get; set; }
  public Boolean sendGCLSuccessful { get; set; }

  public Boolean displayPopupBg { get; set; }
  public Boolean displayLaborNotesPopup { get; set; }
  public Boolean displayExpenseNotesPopup { get; set; }
  public Boolean displayBudgetNotesPopup { get; set; }
  public Boolean displayCloseGrantPopup { get; set; }
  public Boolean displayLOAPopup { get; set; }

  public String newModification { get; set; }
  public Boolean displayModificationPopup { get; set; }
  public Boolean updatePopupNeeded { get; set; }
  public Boolean displayUpdatePopup { get; set; }
  public Boolean displayAwardPopup { get; set; }

  public List<Attachment> att_list { get; set; }

  // BEGIN Constructor
  public SubGrantDetailsController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;
    if (portalName == 'BBBS')
      portalName = '';

    isNationalSubGrant = false;
    expense_map = new Map<String, List<Budget_Item__c>>();
    labor_map = new Map<String, List<Budget_Item__c>>();
    hasLabor = false;
    hasExpenses = false;

    editMode = false;
    incompleteReport = false;
    sendBack = false;
    deny = false;
    laborRequestedAmount = 0;
    expenseRequestedAmount = 0;
    updatedRequestedAmount = 0;

    displayPopupBg = false;
    displayExpenseNotesPopup = false;
    displayBudgetNotesPopup = false;
    displayModificationPopup = false;
    newModification = '';

    contacts = new List<Contact>();
    att_list = new List<Attachment>();

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);
    getGrant();
  }
  // END Constructor

  public void getGrant() {
    labor_map.clear();
    expense_map.clear();

    if (grantId != null || grant.Id != null) {
      grant = gc.getGrant(grantId);
      String name = grant.Name;
      if (
        name.contains('JJ2') ||
        name.contains('JJ5') ||
        name.contains('JJ6')
      ) {
        updatePopupNeeded = true;
      }
      for (Attachment a : grant.Attachments) {
        att_list.add(a);
      }
      acct = ac.getAccount(grant.Account__r.Id); //[SELECT ID, Name, RecordType.Name FROM Account WHERE ID = :grant.Account__r.Id];
      for (Contact c : cc.getContactPopupList(acct.Id)) {
        //                if(c.Role__c != null && c.Role__c.contains('Board'))
        if (c.RecordType.Name == 'Contact')
          contacts.add(c);
      }

      canCloseGrant = false;
      canReopenGrant = false;
      if (userAcctType == 'National Organization') {
        if (
          grant.Grant_Status__c != 'Closed' &&
          grant.Reimbursements_Pending_Approval__c == 0
        )
          canCloseGrant = true;
        if (
          grant.Grant_Status__c == 'Closed' &&
          grant.National_Grant_Status__c != 'Closed'
        )
          canReopenGrant = true;
      }

      if (
        grant.Grant_Status__c == null ||
        grant.Grant_Status__c == 'Pending Review' ||
        grant.Grant_Status__c == 'Budget Submitted' ||
        grant.Grant_Status__c == 'Revisions Needed'
      ) {
        editMode = true;
        statusColor = 'text-warning';
      }
      if (grant.Grant_Status__c == 'Denied') {
        statusColor = 'text-danger';
      }
      if (
        grant.Grant_Status__c == 'Approved' ||
        grant.Grant_Status__c == 'Awarded'
      ) {
        statusColor = 'text-success';
      }

      if (
        userAcctType == 'National Organization' &&
        grant.Account__r.Id == userAcct.Id
      ) {
        isNationalSubGrant = true;
      }

      for (Grantee_Report__c gr : [
        SELECT Id, Report_Status__c
        FROM Grantee_Report__c
        WHERE Grant__r.Id = :GrantId
      ]) {
        system.debug('>>> gr = ' + gr);
        if (gr.Report_Status__c == 'In Progress') {
          incompleteReport = true;
        }
      }

      for (Budget_Item__c bi : bic.getBudgetItems(GrantId)) {
        if (bi.RecordType.Name == 'Expense') {
          if (bi.New_Rate__c > 0) {
            if (bi.Total_Expense__c > 0) {
              if (bi.Total_Expense__c == bi.New_Rate__c) {
                bi.New_Rate__c = null;
              }
            }
          }
          if (bi.New_Item_Budget__c > 0) {
            if (bi.Item_Budget__c > 0) {
              if (bi.Item_Budget__c == bi.New_Item_Budget__c) {
                bi.New_Item_Budget__c = null;
              }
            }
          }
          if (
            (grant.Grant_Status__c == 'Approved' ||
            grant.Grant_Status__c == 'Awarded' ||
            grant.Grant_Status__c == 'Denied' ||
            grant.Grant_Status__c == 'Closed') && bi.Item_Budget__c != null
          ) {
            expenseRequestedAmount += bi.Item_Budget__c;
          } else {
            if (bi.New_Item_Budget__c != null) {
              expenseRequestedAmount += bi.New_Item_Budget__c;
            } else if (bi.Item_Budget__c != null) {
              expenseRequestedAmount += bi.Item_Budget__c;
            }
          }
          if (expense_map.containsKey(bi.Category__c)) {
            List<Budget_Item__c> bi_list = expense_map.get(bi.Category__c);
            bi_list.add(bi);
            expense_map.put(bi.Category__c, bi_list);
          } else {
            expense_map.put(bi.Category__c, new List<Budget_Item__c>{ bi });
          }
          if (expense_map.keySet() != null) {
            hasExpenses = true;
          }
        } else {
          if (labor_map.containsKey(bi.Category__c)) {
            List<Budget_Item__c> bi_list = labor_map.get(bi.Category__c);
            bi_list.add(bi);
            labor_map.put(bi.Category__c, bi_list);
          } else {
            labor_map.put(bi.Category__c, new List<Budget_Item__c>{ bi });
          }
          if (labor_map.keySet() != null) {
            hasLabor = true;
          }
          if (
            grant.Grant_Status__c == 'Approved' ||
            grant.Grant_Status__c == 'Awarded' ||
            grant.Grant_Status__c == 'Denied' ||
            grant.Grant_Status__c == 'Closed'
          ) {
            if (bi.Wages__c != null && portalName != '') {
              laborRequestedAmount += bi.Wages__c;
            } else if (bi.Item_Budget__c != null) {
              laborRequestedAmount += bi.Item_Budget__c;
            }
            if (bi.Fringe_Benefits__c != null) {
              laborRequestedAmount += bi.Fringe_Benefits__c;
            }
          } else {
            if (bi.New_Wages__c != null && portalName != '') {
              laborRequestedAmount += bi.New_Wages__c;
            } else if (bi.Wages__c != null && portalName != '') {
              laborRequestedAmount += bi.Wages__c;
            } else if (bi.New_Item_Budget__c != null) {
              laborRequestedAmount += bi.New_Item_Budget__c;
            } else if (bi.Item_Budget__c != null) {
              laborRequestedAmount += bi.Item_Budget__c;
            }
            if (bi.New_Fringe_Benefits__c != null) {
              laborRequestedAmount += bi.New_Fringe_Benefits__c;
            } else if (bi.Fringe_Benefits__c != null) {
              laborRequestedAmount += bi.Fringe_Benefits__c;
            }
          }
        }
      }
      updatedRequestedAmount = laborRequestedAmount + expenseRequestedAmount;
      if (grant.Use_Indirect_Rate__c == 'Yes') {
        if (grant.New_Indirect_Rate_Amount__c != null) {
          updatedRequestedAmount += grant.New_Indirect_Rate_Amount__c;
        } else if (grant.Indirect_Rate_Amount__c != null) {
          updatedRequestedAmount += grant.Indirect_Rate_Amount__c;
        }
      }
      updatedRequestedAmount.setScale(2);
    }
  }

  public void saveNotes() {
    gc.upsertGrant(grant);
    displayBudgetNotesPopup = false;
  }

  public void updateAward() {
    Date dt = date.today();
    String fdt = dt.format();
    String mh =
      fdt +
      ': Award Amount changed from ' +
      grant.Previously_Awarded_Amount__c +
      ' to ' +
      grant.Amount__c +
      ' by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (grant.Modification_History__c == null)
      grant.Modification_History__c = '';
    grant.Modification_History__c += ' \r\n' + mh;
    gc.upsertGrant(grant);
    displayAwardPopup = false;
  }

  public PageReference saveAndClose() {
    gc.upsertGrant(grant);

    List<Budget_Item__c> bi_update_list = new List<Budget_Item__c>();
    List<List<Budget_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Budget_Item__c bi : expense_list.get(i)) {
        bi_update_list.add(bi);
      }
    }
    List<List<Budget_Item__c>> labor_list = labor_map.values();
    for (Integer i = 0; i < labor_list.size(); i++) {
      for (Budget_Item__c bi : labor_list.get(i)) {
        bi_update_list.add(bi);
      }
    }
    try {
      bic.upsertItems(bi_update_list);
      System.Debug(
        '>>>> Budget list update successful. bi_update_list = ' + bi_update_list
      );

      PageReference pr = new PageReference('/SubGrants');
      pr.setRedirect(true);
      return pr;
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
    }
    return null;
  }

  public PageReference sendBack() {
    Date dt = date.today();
    String fdt = dt.format();
    String mh =
      fdt +
      ': Returned for corrections by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (grant.Modification_History__c == null) {
      grant.Modification_History__c = '';
    }
    grant.Modification_History__c += ' \r\n' + mh;

    grant.Grant_Status__c = 'Revisions Needed';
    gc.upsertGrant(grant);

    PageReference pr = new PageReference('/SubGrants');
    pr.setRedirect(true);
    return pr;
  }

  public PageReference approveBudget() {
    Date dt = date.today();
    String fdt = dt.format();
    String mh =
      fdt +
      ': Approved by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (grant.Modification_History__c == null) {
      grant.Modification_History__c = '';
    }
    grant.Modification_History__c += ' \r\n' + mh;

    grant.Grant_Status__c = 'Approved';
    if (grant.New_Indirect_Rate_Amount__c != null) {
      grant.Indirect_Rate_Amount__c = grant.New_Indirect_Rate_Amount__c;
      grant.New_Indirect_Rate_Amount__c = null;
    }
    gc.upsertGrant(grant);

    List<Budget_Item__c> bi_approve_list = new List<Budget_Item__c>();
    List<List<Budget_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Budget_Item__c bi : expense_list.get(i)) {
        if (bi.New_Item_Budget__c != null) {
          bi.Item_Budget__c = bi.New_Item_Budget__c;
          bi.New_Item_Budget__c = null;
        }
        if (bi.New_Rate__c != null) {
          bi.Total_Expense__c = bi.New_Rate__c;
          bi.New_Rate__c = null;
        }
        bi_approve_list.add(bi);
      }
    }
    List<List<Budget_Item__c>> labor_list = labor_map.values();
    for (Integer i = 0; i < labor_list.size(); i++) {
      for (Budget_Item__c bi : labor_list.get(i)) {
        if (bi.New_Item_Budget__c != null) {
          bi.Item_Budget__c = bi.New_Item_Budget__c;
          bi.New_Item_Budget__c = null;
        }
        if (bi.New_Wages__c != null) {
          bi.Wages__c = bi.New_Wages__c;
          bi.New_Wages__c = null;
        }
        if (bi.New_Fringe_Benefits__c != null) {
          bi.Fringe_Benefits__c = bi.New_Fringe_Benefits__c;
          bi.New_Fringe_Benefits__c = null;
        }
        /*
                if(bi.New_Rate__c != null) {
                    if(bi.Is_Hourly__c) {
                        bi.Hourly_Rate__c = bi.New_Rate__c;
                    } else {
                        bi.Salary__c = bi.New_Rate__c;
                        bi.Hourly_Rate__c = bi.New_Rate__c / 2080;
                    }
                    bi.New_Rate__c = null;
                }
                */
        bi_approve_list.add(bi);
      }
    }
    try {
      bic.upsertItems(bi_approve_list);
      System.Debug(
        '>>>> Budget list update successful. bi_approve_list = ' +
        bi_approve_list
      );
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
    }
    editMode = false;

    PageReference pr = new PageReference(
      '/' +
      portalName +
      'SubGrantDetails?GrantID=' +
      GrantID
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference denyBudget() {
    if (
      grant.Previous_Status__c != null &&
      grant.Previous_Status__c != 'Pending Review' &&
      grant.Previous_Status__c != 'Budget Submitted'
    ) {
      grant.Grant_Status__c = grant.Previous_Status__c;
    } else {
      grant.Grant_Status__c = 'Denied';
    }
    gc.upsertGrant(grant);

    List<Budget_Item__c> bi_deny_list = new List<Budget_Item__c>();
    List<List<Budget_Item__c>> expense_list = expense_map.values();
    for (Integer i = 0; i < expense_list.size(); i++) {
      for (Budget_Item__c bi : expense_list.get(i)) {
        bi.New_Item_Budget__c = null;
        bi.New_Rate__c = null;
        bi_deny_list.add(bi);
      }
    }
    List<List<Budget_Item__c>> labor_list = labor_map.values();
    for (Integer i = 0; i < labor_list.size(); i++) {
      for (Budget_Item__c bi : labor_list.get(i)) {
        bi.New_Item_Budget__c = null;
        bi.New_Rate__c = null;
        bi.New_Fringe_Benefits__c = null;
        bi_deny_list.add(bi);
      }
    }
    try {
      bic.upsertItems(bi_deny_list);
      System.Debug(
        '>>>> Budget list update successful. bi_deny_list = ' + bi_deny_list
      );
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
    }
    editMode = false;

    PageReference pr = new PageReference(
      '/' +
      portalName +
      'SubGrantDetails?GrantID=' +
      GrantID
    );
    pr.setRedirect(true);
    return pr;
  }

  public void saveModification() {
    if (newModification != '') {
      Date dt = date.today();
      String fdt = dt.format();
      String mh =
        fdt +
        ': ' +
        newModification +
        ' (' +
        currentUser.Contact.Name +
        ', ' +
        currentUser.Id +
        ')';
      if (grant.Modification_History__c == null) {
        grant.Modification_History__c = '';
      }
      grant.Modification_History__c += ' \r\n' + mh;
      gc.upsertGrant(grant);
    }
    displayModificationPopup = false;
  }

  // BEGIN closeGrant
  public void closeGrant() {
    gc.closeGrant(grant.Id);
    hideCloseGrantPopup();
    getGrant();
  }

  public void reopenGrant() {
    gc.reopenGrant(grant.Id);
    getGrant();
  }
  // END closeGrant

  // BEGIN sendDocs
  public void sendLOA() {
    errorMessage = '';
    SendSertifiDoc ssd = new SendSertifiDoc();
    ssd.SendSertifiDoc(
      'LOA',
      UserInfo.getUserEmail(),
      grant.CEO_Email_text__c,
      boardMemberEmail,
      grant.Id,
      'NPAL_LOA.pdf',
      null
    );
    if (!ApexPages.hasMessages()) {
      sendLOASuccessful = true;
      grant.LOA_Sent__c = true;
      gc.upsertGrant(grant);
    } else
      errorMessage = String.valueOf(ApexPages.getMessages());
    displayLOAPopup = false;
  }
  public void sendFFATA() {
    errorMessage = '';
    SendSertifiDoc ssd = new SendSertifiDoc();
    ssd.SendSertifiDoc(
      'FFATA',
      UserInfo.getUserEmail(),
      grant.CEO_Email_text__c,
      null,
      grant.Id,
      'NPAL_FFATA.pdf',
      null
    );
    if (!ApexPages.hasMessages())
      sendFFATASuccessful = true;
    else
      errorMessage = String.valueOf(ApexPages.getMessages());
  }
  public void sendGCL() {
    errorMessage = '';
    SendSertifiDoc ssd = new SendSertifiDoc();
    ssd.SendSertifiDoc(
      'Grant Closeout Letter',
      UserInfo.getUserEmail(),
      grant.CEO_Email_text__c,
      null,
      grant.Id,
      'NPAL_GCL.pdf',
      null
    );
    if (!ApexPages.hasMessages())
      sendGCLSuccessful = true;
    else
      errorMessage = String.valueOf(ApexPages.getMessages());
  }
  // END sendDocs

  // BEGIN popups
  public void showLaborNotesPopup() {
    displayLaborNotesPopup = true;
  }

  public void closeLaborNotesPopup() {
    displayLaborNotesPopup = false;
  }

  public void showExpenseNotesPopup() {
    displayExpenseNotesPopup = true;
  }

  public void closeExpenseNotesPopup() {
    displayExpenseNotesPopup = false;
  }

  public void cancelBudgetNotesPopup() {
    displayBudgetNotesPopup = false;
  }

  public void updateNotesPopup() {
    sendBack = false;
    deny = false;
    displayBudgetNotesPopup = true;
  }

  public void sendBackPopup() {
    sendBack = true;
    deny = false;
    displayBudgetNotesPopup = true;
  }

  public void denyPopup() {
    sendBack = false;
    deny = true;
    displayBudgetNotesPopup = true;
  }

  public void modificationPopup() {
    displayModificationPopup = true;
  }

  public void cancelModificationPopup() {
    displayModificationPopup = false;
  }

  public void updatePopup() {
    displayUpdatePopup = true;
  }

  public void cancelUpdatePopup() {
    displayUpdatePopup = false;
  }

  public void showAwardPopup() {
    grant.Previously_Awarded_Amount__c = grant.Amount__c;
    displayAwardPopup = true;
  }
  public void hideAwardPopup() {
    displayAwardPopup = false;
  }

  public void showCloseGrantPopup() {
    displayCloseGrantPopup = true;
  }
  public void hideCloseGrantPopup() {
    displayCloseGrantPopup = false;
  }

  public void showLOAPopup() {
    displayLOAPopup = true;
  }
  public void hideLOAPopup() {
    displayLOAPopup = false;
  }
}
