public without sharing class ReimbursementCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private ReimbursementClass rc = new ReimbursementClass();
  private BudgetItemClass bic = new BudgetItemClass();
  private ReimbursementItemClass ric = new ReimbursementItemClass();
  private DocumentClass dc = new DocumentClass();
  private AttachmentClass ac = new AttachmentClass();
  private getIdFromString gifs = new getIdFromString();

  public ID grantId { get; set; }
  public List<SelectOption> grant_list { get; set; }
  public Grant__c grant { get; set; }

  public ID requestId { get; set; }
  public Reimbursement_Request__c request { get; set; }
  public String status { get; set; }

  public Decimal personnelRequested { get; set; }
  public Decimal personnelApproved { get; set; }
  public Decimal personnelSubmittedBalance { get; set; }
  public Decimal personnelBalance { get; set; }
  public Decimal fringeRequested { get; set; }
  public Decimal fringeApproved { get; set; }
  public Decimal fringeSubmittedBalance { get; set; }
  public Decimal fringeBalance { get; set; }
  public Decimal expensesRequested { get; set; }
  public Decimal expensesApproved { get; set; }
  public Decimal expenseSubmittedBalance { get; set; }
  public Decimal expenseBalance { get; set; }
  public Decimal indirectCostsRequested { get; set; }
  public Decimal totalRequested { get; set; }
  public Decimal totalApproved { get; set; }
  public Decimal awarded { get; set; }
  public Decimal balance { get; set; }

  public List<Reimbursement_Item__c> personnel_list { get; set; }
  public List<Reimbursement_Item__c> fringe_list { get; set; }
  public List<Reimbursement_Item__c> expense_list { get; set; }
  public List<Document__c> docs { get; set; }
  public List<Attachment> atts { get; set; }
  public List<Attachment> itemAtts { get; set; }
  public Id selectedAttId { get; set; }

  public List<String> categories { get; set; }
  public Map<String, Decimal> catBudgeted { get; set; }
  public Map<String, Decimal> catRequested { get; set; }
  public Map<String, Decimal> catApproved { get; set; }
  public Map<String, Decimal> catBalance { get; set; }
  public Boolean runGetItems { get; set; }

  public Decimal payPeriod { get; set; }
  public List<Decimal> payPeriods { get; set; }
  public Id selectedItemId { get; set; }
  public String selectedItemType { get; set; }
  public Reimbursement_Item__c selectedItem { get; set; }

  public String sendBackTo { get; set; }
  public Boolean displayNotesPopup { get; set; }
  public Boolean displayAttPopup { get; set; }
  public Boolean displaySendBackPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public Boolean displayDeletePopup { get; set; }
  public Boolean displayDenyPopup { get; set; }
  public Boolean displayReviewPopup { get; set; }

  public String warningMessage { get; set; }
  public String errorMessage { get; set; }

  private Date dt = date.today();
  private String fdt = dt.format();
  private String modHist = '';
  public Boolean isReviewMode { get; set; }

  public ReimbursementCtrl getReimbursementCtrl() {
    return this;
  }

  public ReimbursementCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    approverLevel = uc.approverLevel;
    portalName = uc.userProfile;

    grant = new Grant__c();
    grant_list = new List<SelectOption>();
    request = new Reimbursement_Request__c();
    personnel_list = new List<Reimbursement_Item__c>();
    fringe_list = new List<Reimbursement_Item__c>();
    expense_list = new List<Reimbursement_Item__c>();

    docs = new List<Document__c>();
    atts = new List<Attachment>();
    itemAtts = new List<Attachment>();

    payPeriods = new List<Decimal>();
    categories = new List<String>();
    catBudgeted = new Map<String, Decimal>();
    catRequested = new Map<String, Decimal>();
    catApproved = new Map<String, Decimal>();
    catBalance = new Map<String, Decimal>();
    runGetItems = true;

    personnelRequested = 0;
    personnelApproved = 0;
    personnelSubmittedBalance = 0;
    personnelBalance = 0;
    fringeRequested = 0;
    fringeApproved = 0;
    fringeSubmittedBalance = 0;
    fringeBalance = 0;
    expensesRequested = 0;
    expensesApproved = 0;
    expenseSubmittedBalance = 0;
    expenseBalance = 0;
    indirectCostsRequested = 0;
    totalRequested = 0;
    totalApproved = 0;
    awarded = 0;
    balance = 0;

    status = '';
    warningMessage = '';
    errorMessage = '';

    String urlRequestId = ApexPages.currentPage()
      .getParameters()
      .get('requestId');
    if (urlRequestId != '' && urlRequestId != null) {
      requestId = gifs.getId(urlRequestId);
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlRequestId)
          .matches()
      ) {
        requestId = Id.valueOf(urlRequestId);
      }
      getRequest();
    } else {
      String urlGrantId = ApexPages.currentPage()
        .getParameters()
        .get('grantId');
      grantId = gifs.getId(urlGrantId);

      if (grantId == null) {
        grant_list.add(new SelectOption('', '-- Select a Sub-Grant --'));
        for (Grant__c g : [
          SELECT Id, Name, LOA_Submitted_Date__c
          FROM Grant__c
          WHERE Account__c = :userAcct.Id AND Grant_Status__c = 'Approved'
        ]) {
          if (
            portalName == 'Ripken' ||
            (portalName != 'Ripken' ||
            g.LOA_Submitted_Date__c != null)
          ) {
            grant_list.add(new SelectOption(g.Id, g.Name));
          }
        }
      } else {
        getGrant();
      }
    }

    String urlPayPeriod = ApexPages.currentPage()
      .getParameters()
      .get('payPeriod');
    if (urlPayPeriod != null && urlPayPeriod != '')
      payPeriod = Decimal.valueOf(urlPayPeriod);
  }

  // BEGIN getGrant
  public void getGrant() {
    if (grantId != null && runGetItems) {
      grantId = Id.valueOf(grantId);
      Grant__c[] grants = [
        SELECT
          Account__r.Id,
          Account__r.Primary_Approver_Email_text__c,
          Name,
          Amount__c,
          Balance__c,
          Total_Labor_Item_Budget__c,
          Salary_Balance__c,
          Benefits_Balance__c,
          Total_Fringe_Benefits__c,
          Reimbursement_Approved_Amount__c,
          Prevent_Skip_Reimbursement_Approvals__c,
          Indirect_Rate__c,
          Grant_Type__c,
          National_Grant_Type__c,
          Procurement_Threshold__c,
          National_Grant_Indirect_Rate_Cap__c
        FROM Grant__c
        WHERE Id = :grantId
      ];
      if (grants.size() > 0) {
        grant = grants[0];
        if (grants[0].Balance__c > 0)
          balance = grants[0].Balance__c;
        if (grants[0].Amount__c > 0)
          awarded = grants[0].Amount__c;
      }
    }
  }
  // END getGrant

  // BEGIN getRequest
  public void getRequest() {
    if (requestId != null) {
      request = rc.getRequest(requestId);
      if (payPeriod == null) {
        Integer i = 1;
        while (i <= request.Number_of_Pay_Periods__c) {
          payPeriods.add(i);
          i++;
        }
      } else {
        payPeriods.add(payPeriod);
      }
      grantId = request.Grant__c;
      if (grant.Id == null)
        getGrant();
      getReviewMode();
    }
  }
  // END getRequest

  // BEGIN getReviewMode
  public void getReviewMode() {
    status = '';
    isReviewMode = false;
    if (request.Status__c != null)
      status = request.Status__c;
    if (
      (status.contains('Pending') && approverLevel == 'Finance Admin') ||
      (status == 'Pending First Approval' &&
      (approverLevel == 'Level One' ||
      (approverLevel == 'Level Two' &&
      request.Prevent_Skip_Reimbursement_Approvals__c == false))) ||
      (status == 'Pending Second Approval' &&
      approverLevel == 'Level Two') ||
      (status == 'Pending Third Approval' &&
      (approverLevel == 'Level Three' ||
      (approverLevel == 'Level Four' &&
      request.Prevent_Skip_Reimbursement_Approvals__c == false))) ||
      (status == 'Pending Fourth Approval' &&
      approverLevel == 'Level Four')
    ) {
      isReviewMode = true;
    }
  }
  // END getReviewMode

  // BEGIN createRequestItems
  public void createRequestItems() {
    if (grant.Id != null) {
      Decimal i = 1;
      if (request.Number_of_Pay_Periods__c == null) {
        errorMessage = 'Please enter the number of pay periods in the request period.';
      } else {
        for (Budget_Item__c bi : bic.getBudgetItems(grant.Id)) {
          if (bi.Is_Active__c) {
            if (
              bi.RecordType.Name == 'Labor' &&
              request.Number_of_Pay_Periods__c > 0
            ) {
              Reimbursement_Item__c ri = new Reimbursement_Item__c(
                Reimbursement_Request__c = request.Id,
                Budget_Item__c = bi.Id,
                Indirect_Rate__c = bi.Indirect_Rate__c,
                RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
                  .get('Labor')
                  .getRecordTypeId(),
                Type__c = 'Fringe'
              );
              if (bi.Is_Hourly__c == true) {
                ri.Is_Hourly__c = true;
                if (bi.Rate__c != null)
                  ri.Rate__c = (bi.Rate__c).setScale(2);
              }
              fringe_list.add(ri);
            } else if (bi.RecordType.Name == 'Expense') {
              Reimbursement_Item__c ri = new Reimbursement_Item__c(
                Reimbursement_Request__c = request.Id,
                Budget_Item__c = bi.Id,
                RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
                  .get('Expense')
                  .getRecordTypeId(),
                Quantity__c = 1,
                Apply_Cap__c = bi.Apply_Indirect_Rate_Cap__c,
                Indirect_Rate__c = bi.Indirect_Rate__c,
                Indirect_Costs_Budget__c = bi.Indirect_Costs_Budget__c,
                Total_Related_Item_Requested_Amount__c = bi.Total_Requested_Amount__c
              );
              if (bi.Type__c == 'Mileage')
                ri.Type__c = 'Mileage';
              expense_list.add(ri);
            }
          }
        }
        if (fringe_list.size() > 0)
          ric.upsertItems(fringe_list);
        if (expense_list.size() > 0)
          ric.upsertItems(expense_list);

        while (i <= request.Number_of_Pay_Periods__c) {
          for (Reimbursement_Item__c fringe : fringe_list) {
            Reimbursement_Item__c ri = new Reimbursement_Item__c(
              Reimbursement_Request__c = request.Id,
              Budget_Item__c = fringe.Budget_Item__c,
              Indirect_Rate__c = fringe.Indirect_Rate__c,
              RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
                .get('Labor')
                .getRecordTypeId(),
              Pay_Period__c = i,
              Type__c = 'Personnel',
              Reimbursement_Item__c = fringe.Id,
              Rate__c = fringe.Rate__c,
              Is_Hourly__c = fringe.Is_Hourly__c
            );
            personnel_list.add(ri);
          }
          i++;
        }
        if (personnel_list.size() > 0)
          ric.upsertItems(personnel_list);
      }
    }
  }
  // END createRequestItems

  // BEGIN getRequestItems
  public void getRequestItems() {
    if (runGetItems) {
      getPersonnelItems();
      getFringeItems();
      getExpenseItems();
      docs = dc.getDocList(null, null, null, null, requestId, null, null);
      atts = dc.getAttList();
      getTotals();
      runGetItems = false;
    }
  }

  public void getPersonnelItems() {
    personnel_list.clear();

    if (requestId != null) {
      for (
        Reimbursement_Item__c ri : ric.getRequestItems(requestId, 'personnel')
      ) {
        if (ri.Item_Note__c != null || ri.Response__c != null)
          ri.Has_Notes__c = true;
        if (
          status.contains('Pending') &&
          ri.Requested_Salary__c != null &&
          ri.Approved_Salary__c == null
        )
          ri.Approved_Salary__c = ri.Requested_Salary__c;
        personnel_list.add(ri);
      }
    }
  }

  public void getFringe() {
    getRequestItems();
    updateFringeAmounts();
  }
  public void getFringeItems() {
    fringe_list.clear();

    if (requestId != null) {
      for (
        Reimbursement_Item__c ri : ric.getRequestItems(requestId, 'fringe')
      ) {
        if (ri.Item_Note__c != null || ri.Response__c != null)
          ri.Has_Notes__c = true;
        if (
          status.contains('Pending') &&
          ri.Requested_Benefits__c != null &&
          ri.Approved_Benefits__c == null
        )
          ri.Approved_Benefits__c = ri.Requested_Benefits__c;
        fringe_list.add(ri);
      }
    }

    for (Reimbursement_Item__c ri : fringe_list) {
      if (portalName == 'Ripken' && ri.FICA_Percent__c > 7.65)
        errorMessage += 'FICA cannot be greater than 7.65%. <br />';
      ri.Personnel_Quantity_Towards_Grant__c = 0;
      ri.Personnel_Percent_Towards_Grant__c = 0;
      ri.Personnel_Requested_Salary__c = 0;
      for (Reimbursement_Item__c p : personnel_list) {
        if (p.Reimbursement_Item__c == ri.Id) {
          if (p.Quantity_Towards_Grant__c != null)
            ri.Personnel_Quantity_Towards_Grant__c += p.Quantity_Towards_Grant__c;
          if (p.Percent_Towards_Grant__c != null)
            ri.Personnel_Percent_Towards_Grant__c += p.Percent_Towards_Grant__c;
          if (p.Requested_Salary__c != null)
            ri.Personnel_Requested_Salary__c += p.Requested_Salary__c;
        }
      }
      if (
        ri.Personnel_Percent_Towards_Grant__c > 0 &&
        request.Number_of_Pay_Periods__c > 0
      ) {
        ri.Personnel_Percent_Towards_Grant__c =
          ri.Personnel_Percent_Towards_Grant__c /
          request.Number_of_Pay_Periods__c;
      }
      ri.Personnel_Requested_Salary__c = ri.Personnel_Requested_Salary__c.setScale(
        2
      );
      ri.Personnel_Percent_Towards_Grant__c = ri.Personnel_Percent_Towards_Grant__c.setScale(
        3
      );
    }
  }

  public void getExpenseItems() {
    expense_list.clear();
    if (requestId != null) {
      for (
        Reimbursement_Item__c ri : ric.getRequestItems(requestId, 'expense')
      ) {
        if (ri.Item_Note__c != null || ri.Response__c != null)
          ri.Has_Notes__c = true;
        if (
          status.contains('Pending') &&
          ri.Requested_Amount__c != null &&
          ri.Approved_Amount__c == null
        )
          ri.Approved_Amount__c = ri.Requested_Amount__c;
        expense_list.add(ri);
      }
    }
    getItemAtts();
    getCategoryAmounts();
  }
  // END getRequestItems

  // BEGIN update amounts
  public void updatePersonnelAmounts() {
    errorMessage = '';
    for (Reimbursement_Item__c ri : personnel_list) {
      if (
        ri.Quantity_Towards_Grant__c == null ||
        ri.Quantity_Towards_Grant__c == 0 ||
        ri.Quantity__c == null ||
        ri.Quantity__c == 0 ||
        ri.Rate__c == null ||
        ri.Rate__c == 0
      ) {
        ri.Percent_Towards_Grant__c = 0;
        ri.Requested_Salary__c = 0;
      } else {
        ri.Percent_Towards_Grant__c =
          ri.Quantity_Towards_Grant__c /
          ri.Quantity__c *
          100;
        if (ri.Is_Hourly__c) {
          ri.Requested_Salary__c = (ri.Rate__c * ri.Quantity_Towards_Grant__c)
            .setScale(2);
        } else {
          ri.Requested_Salary__c = ((ri.Rate__c * ri.Percent_Towards_Grant__c) /
            100)
            .setScale(2);
        }
        if (ri.Indirect_Rate__c > 0)
          ri.Indirect_Rate_Amount__c =
            (ri.Requested_Salary__c * ri.Indirect_Rate__c) / 100;
      }
    }
    getTotals();
  }

  public void updateFringeAmounts() {
    errorMessage = '';
    for (Reimbursement_Item__c ri : fringe_list) {
      Decimal fb = 0;
      ri.New_Fringe_Benefits__c = 0;
      ri.Requested_Benefits__c = 0;
      if (ri.Personnel_Requested_Salary__c != null) {
        if (ri.FICA_Percent__c != null && ri.FICA_Percent__c != 0) {
          ri.FICA__c = ((ri.FICA_Percent__c / 100) *
            ri.Personnel_Requested_Salary__c)
            .setScale(2);
          fb += ri.FICA__c;
          if (portalName == 'Ripken' && ri.FICA_Percent__c > 7.65)
            errorMessage += 'FICA cannot be greater than 7.65%. <br />';
        } else {
          ri.FICA_Percent__c = 0;
          ri.FICA__c = 0;
        }
        if (ri.SUTA_Percent__c != null && ri.SUTA_Percent__c != 0) {
          ri.SUTA__c = ((ri.SUTA_Percent__c / 100) *
            ri.Personnel_Requested_Salary__c)
            .setScale(2);
          fb += ri.SUTA__c;
        } else {
          ri.SUTA_Percent__c = 0;
          ri.SUTA__c = 0;
        }
        if (
          ri.Workers_Comp_Percent__c != null &&
          ri.Workers_Comp_Percent__c != 0
        ) {
          ri.Workers_Comp__c = ((ri.Workers_Comp_Percent__c / 100) *
            ri.Personnel_Requested_Salary__c)
            .setScale(2);
          fb += ri.Workers_Comp__c;
        } else {
          ri.Workers_Comp_Percent__c = 0;
          ri.Workers_Comp__c = 0;
        }
        if (ri.Retirement_Percent__c != null && ri.Retirement_Percent__c != 0) {
          ri.Retirement__c = ((ri.Retirement_Percent__c / 100) *
            ri.Personnel_Requested_Salary__c)
            .setScale(2);
          fb += ri.Retirement__c;
        } else {
          ri.Retirement_Percent__c = 0;
          ri.Retirement__c = 0;
        }
        if (ri.Other_Percent__c != null && ri.Other_Percent__c != 0) {
          ri.Other_Percent_Based__c = ((ri.Other_Percent__c / 100) *
            ri.Personnel_Requested_Salary__c)
            .setScale(2);
          fb += ri.Other_Percent_Based__c;
          if (errorMessage == null)
            errorMessage = '';
          if (ri.Item_Note__c == null)
            errorMessage +=
              '<b>Correction Required:</b> Please add a note for ' +
              ri.Budget_Item__r.Name +
              '\'s Other Percent Based Benefit.  <br />';
        } else {
          ri.Other_Percent__c = 0;
          ri.Other_Percent_Based__c = 0;
        }
      }

      if (ri.Personnel_Percent_Towards_Grant__c != null) {
        if (ri.Medical_Premium__c != null && ri.Medical_Premium__c != 0) {
          ri.Medical__c =
            ri.Medical_Premium__c *
            (ri.Personnel_Percent_Towards_Grant__c / 100);
          fb += ri.Medical__c;
        } else {
          ri.Medical_Premium__c = 0;
          ri.Medical__c = 0;
        }
        if (ri.Dental_Premium__c != null && ri.Dental_Premium__c != 0) {
          ri.Dental__c =
            ri.Dental_Premium__c *
            (ri.Personnel_Percent_Towards_Grant__c / 100);
          fb += ri.Dental__c;
        } else {
          ri.Dental_Premium__c = 0;
          ri.Dental__c = 0;
        }
        if (ri.Vision_Premium__c != null && ri.Vision_Premium__c != 0) {
          ri.Vision__c =
            ri.Vision_Premium__c *
            (ri.Personnel_Percent_Towards_Grant__c / 100);
          fb += ri.Vision__c;
        } else {
          ri.Vision_Premium__c = 0;
          ri.Vision__c = 0;
        }
        if (ri.Short_Term_Premium__c != null && ri.Short_Term_Premium__c != 0) {
          ri.Short_Term_Disability__c =
            ri.Short_Term_Premium__c *
            (ri.Personnel_Percent_Towards_Grant__c / 100);
          fb += ri.Short_Term_Disability__c;
        } else {
          ri.Short_Term_Premium__c = 0;
          ri.Short_Term_Disability__c = 0;
        }
        if (ri.Long_Term_Premium__c != null && ri.Long_Term_Premium__c != 0) {
          ri.Long_Term_Disability__c =
            ri.Long_Term_Premium__c *
            (ri.Personnel_Percent_Towards_Grant__c / 100);
          fb += ri.Long_Term_Disability__c;
        } else {
          ri.Long_Term_Premium__c = 0;
          ri.Long_Term_Disability__c = 0;
        }
        if (ri.Life_Premium__c != null && ri.Life_Premium__c != 0) {
          ri.Life__c =
            ri.Life_Premium__c * (ri.Personnel_Percent_Towards_Grant__c / 100);
          fb += ri.Life__c;
        } else {
          ri.Life_Premium__c = 0;
          ri.Life__c = 0;
        }
        if (ri.Other_Premium__c != null && ri.Other_Premium__c != 0) {
          ri.Other_Benefits__c =
            ri.Other_Premium__c *
            ri.Personnel_Percent_Towards_Grant__c /
            100;
          fb += ri.Other_Benefits__c;
          if (errorMessage == null)
            errorMessage = '';
          if (ri.Item_Note__c == null)
            errorMessage +=
              '<b>Correction Required:</b> Please add a note for ' +
              ri.Title__c +
              '\'s Other Premium Benefit.  <br />';
        } else {
          ri.Other_Premium__c = 0;
          ri.Other_Benefits__c = 0;
        }
      }
      ri.Requested_Benefits__c = fb.setScale(2);
      ri.New_Fringe_Benefits__c = fb.setScale(2);
      if (ri.Indirect_Rate__c > 0)
        ri.Indirect_Rate_Amount__c =
          ri.Requested_Benefits__c *
          ri.Indirect_Rate__c /
          100;
    }
    getTotals();
  }

  public void updateExpenseAmounts() {
    Decimal total = 0;
    for (Reimbursement_Item__c ri : expense_list) {
      if (ri.Quantity__c != null && ri.Quantity__c > 0) {
        if (ri.Type__c != 'Mileage' && ri.Rate__c != null) {
          ri.Requested_Amount__c = (ri.Quantity__c * ri.Rate__c).setScale(2);
        } else if (ri.Type__c == 'Mileage' && ri.Mileage_Rate__c != null) {
          ri.Requested_Amount__c = (ri.Quantity__c * ri.Mileage_Rate__c)
            .setScale(2);
        } else {
          ri.Requested_Amount__c = 0;
        }
        if (ri.Indirect_Rate__c > 0 && ri.Indirect_Costs_Budget__c > 0) {
          Decimal amount = ri.Requested_Amount__c;
          if (ri.Approved_Amount__c != null)
            amount = ri.Approved_Amount__c;
          if (ri.Apply_Cap__c) {
            Decimal budgetedIndirectCost = ri.Indirect_Costs_Budget__c;
            Decimal indirectRequested = amount * ri.Indirect_Rate__c / 100;
            Decimal previousIndirectRequested = ri.Budget_Item__r.Requested_Indirect_Rate_Amount__c;
            Decimal totalIndirectRequested =
              previousIndirectRequested + indirectRequested;
            Decimal availableIndirectCost =
              budgetedIndirectCost - previousIndirectRequested;

            if (previousIndirectRequested >= budgetedIndirectCost)
              ri.Indirect_Rate_Amount__c = 0;
            else if (totalIndirectRequested <= budgetedIndirectCost)
              ri.Indirect_Rate_Amount__c = indirectRequested;
            else
              ri.Indirect_Rate_Amount__c = availableIndirectCost;
          } else {
            ri.Indirect_Rate_Amount__c = amount * ri.Indirect_Rate__c / 100;
          }
        }
      } else {
        ri.Requested_Amount__c = 0;
      }
    }
    getTotals();
  }

  // BEGIN getTotals
  public void getTotals() {
    personnelRequested = 0;
    personnelApproved = 0;
    personnelSubmittedBalance = 0;
    personnelBalance = 0;
    fringeRequested = 0;
    fringeApproved = 0;
    fringeSubmittedBalance = 0;
    fringeBalance = 0;
    expensesRequested = 0;
    expensesApproved = 0;
    expenseSubmittedBalance = 0;
    expenseBalance = 0;
    indirectCostsRequested = 0;
    totalRequested = 0;
    totalApproved = 0;
    warningMessage = '';

    for (Reimbursement_Item__c ri : personnel_list) {
      if (ri.Requested_Salary__c != null)
        personnelRequested += ri.Requested_Salary__c;
      if (ri.Approved_Salary__c != null) {
        personnelApproved += ri.Approved_Salary__c;
        totalApproved += ri.Approved_Salary__c;
      }
      if (ri.Indirect_Rate_Amount__c > 0)
        indirectCostsRequested += ri.Indirect_Rate_Amount__c;
    }
    for (Reimbursement_Item__c ri : fringe_list) {
      if (ri.Requested_Benefits__c != null)
        fringeRequested += ri.Requested_Benefits__c;
      if (ri.Approved_Benefits__c != null) {
        fringeApproved += ri.Approved_Benefits__c;
        totalApproved += ri.Approved_Benefits__c;
      }
      if (ri.Indirect_Rate_Amount__c > 0)
        indirectCostsRequested += ri.Indirect_Rate_Amount__c;
    }
    for (Reimbursement_Item__c ri : expense_list) {
      if (ri.Requested_Amount__c != null)
        expensesRequested += ri.Requested_Amount__c;
      if (ri.Approved_Amount__c != null) {
        expensesApproved += ri.Approved_Amount__c;
        totalApproved += ri.Approved_Amount__c;
      }
      if (ri.Indirect_Rate_Amount__c > 0)
        indirectCostsRequested += ri.Indirect_Rate_Amount__c;
    }
    if (request.Grant_Total_Requested_Salary__c != null)
      personnelSubmittedBalance =
        request.Budgeted_Personnel__c - request.Grant_Total_Requested_Salary__c;
    if (request.Grant_Total_Requested_Benefits__c != null)
      fringeSubmittedBalance =
        request.Budgeted_Fringe__c - request.Grant_Total_Requested_Benefits__c;
    if (request.Grant_Total_Requested_Expenses__c != null)
      expenseSubmittedBalance =
        request.Budgeted_Expenses__c -
        request.Grant_Total_Requested_Expenses__c;

    if (request.Salary_Balance__c != null)
      personnelBalance = request.Salary_Balance__c - personnelApproved;
    else
      personnelBalance = 0;
    if (request.Benefits_Balance__c != null)
      fringeBalance = request.Benefits_Balance__c - fringeApproved;
    else
      fringeBalance = 0;
    if (request.Expense_Balance__c != null)
      expenseBalance = request.Expense_Balance__c - expensesApproved;
    else
      expenseBalance = 0;

    totalRequested = personnelRequested + fringeRequested + expensesRequested;
    // Commenting this out because formula field Requested_Indirect_Costs__c can't be used in Total_Approved_Amount
    // if(request.Requested_Indirect_Costs__c != null) totalRequested += request.Requested_Indirect_Costs__c;
    request.Indirect_Rate_Amount__c = indirectCostsRequested;
    totalRequested += indirectCostsRequested;
    totalApproved += indirectCostsRequested;

    if (warningMessage == null)
      warningMessage = '';
    if (
      grant.Salary_Balance__c != null &&
      (personnelRequested > (grant.Salary_Balance__c * 1.1))
    )
      warningMessage = 'Requested Personnel exceeds Balance by more than 10%. <br />';
    if (
      grant.Benefits_Balance__c != null &&
      (fringeRequested > (grant.Benefits_Balance__c * 1.1))
    )
      warningMessage += 'Requested Benefits exceeds Balance by more than 10%. <br />';
    if (grant.Balance__c != null && (totalRequested > grant.Balance__c))
      warningMessage += 'Total Requested Amount exceeds Sub-Grant Balance. <br />';

    getCategoryAmounts();
  }
  // END getTotals

  public void getCategoryAmounts() {
    categories.clear();
    catBudgeted.clear();
    catRequested.clear();
    catApproved.clear();
    catBalance.clear();
    Set<String> cats = new Set<String>();

    for (Reimbursement_Item__c ri : expense_list) {
      String cat = ri.Budget_Item__r.Category__c;
      if (cat == null) {
        cat = 'Other Costs';
      }
      if (!cats.contains(cat)) {
        cats.add(cat);
        categories.add(cat);
      }

      Decimal bud = 0;
      if (ri.Budget_Item__r.Item_Budget__c != null)
        bud += ri.Budget_Item__r.Item_Budget__c;
      if (catBudgeted.get(cat) != null)
        bud += catBudgeted.get(cat);
      catBudgeted.put(cat, bud.setScale(2));

      Decimal req = 0;
      if (ri.Requested_Amount__c != null)
        req += ri.Requested_Amount__c;
      if (catRequested.get(cat) != null)
        req += catRequested.get(cat);
      catRequested.put(cat, req.setScale(2));

      Decimal app = 0;
      if (ri.Approved_Amount__c != null)
        app += ri.Approved_Amount__c;
      if (catApproved.get(cat) != null)
        app += catApproved.get(cat);
      catApproved.put(cat, app.setScale(2));

      Decimal bal = 0;
      if (ri.Budget_Item__r.Balance__c != null)
        bal += ri.Budget_Item__r.Balance__c;
      //if(bal != null && ri.Approved_Amount__c != null && (ri.Reimbursement_Status__c == 'Approved' || ri.Reimbursement_Status__c == 'Paid')) bal -= ri.Approved_Amount__c;
      if (catBalance.get(cat) != null)
        bal += catBalance.get(cat);
      catBalance.put(cat, bal.setScale(2));
    }
  }
  // END update

  // BEGIN save items
  public void upsertItem() {
    if (selectedItem != null) {
      ric.upsertItem(selectedItem);
      List<Reimbursement_Item__c> ri_list = new List<Reimbursement_Item__c>();
      if (selectedItemType == 'personnel')
        ri_list = personnel_list;
      if (selectedItemType == 'fringe')
        ri_list = fringe_list;
      if (selectedItemType == 'expense')
        ri_list = expense_list;
      for (Reimbursement_Item__c ri : ri_list) {
        if (selectedItemId == ri.Id) {
          ri.Item_Note__c = selectedItem.Item_Note__c;
          ri.Response__c = selectedItem.Response__c;
          if (
            (selectedItem.Item_Note__c != null &&
            selectedItem.Item_Note__c != '') ||
            (selectedItem.Response__c != null &&
            selectedItem.Response__c != '')
          ) {
            ri.Has_Notes__c = true;
          } else {
            ri.Has_Notes__c = false;
          }
        }
      }
    }
    displayNotesPopup = false;
    warningMessage = '';
    errorMessage = '';
  }

  public void upsertPersonnelItems() {
    updatePersonnelAmounts();
    ric.upsertItems(personnel_list);
  }

  public void upsertFringeItems() {
    updateFringeAmounts();
    ric.upsertItems(fringe_list);
  }

  public void upsertExpenseItems() {
    updateExpenseAmounts();
    ric.upsertItems(expense_list);
  }
  // END save items

  // BEGIN save request
  public void upsertRequest() {
    system.debug('modHist = ' + modHist);
    if (request.Grant__c == null)
      request.Grant__c = grant.Id;
    Boolean isNewRequest = false;
    if (request.Id == null) {
      isNewRequest = true;
      request.Primary_Approver_Email__c = grant.Account__r.Primary_Approver_Email_text__c;
    }
    if (request.Indirect_Rate__c == null)
      request.Indirect_Rate__c = grant.Indirect_Rate__c;
    if (isNewRequest && request.Number_of_Pay_Periods__c > 10)
      errorMessage = 'No more than 10 pay periods are allowed per Reimbursement Request.';
    else {
      if (modHist != '') {
        if (request.Modification_History__c == null) {
          request.Modification_History__c = modHist;
        } else {
          request.Modification_History__c += ' \r\n' + modHist;
        }
      }
      rc.upsertRequest(request);
      requestId = request.Id;
      if (isNewRequest)
        createRequestItems();
      modHist = '';
    }
  }

  public void saveAll() {
    errorMessage = '';
    getTotals();
    if (errorMessage == '') {
      ric.upsertItems(personnel_list);
      ric.upsertItems(fringe_list);
      ric.upsertItems(expense_list);
      upsertRequest();
    }
  }

  public void docValidation() {
    errorMessage = '';
    Boolean hasPayroll = false;
    Boolean hasTimesheet = false;
    String groupId = '';

    if (payPeriod != null)
      groupId = 'pay period: ' + String.valueOf(payPeriod);
    for (Document__c d : [
      SELECT Name, Group_Id__c, Has_Attachments__c
      FROM Document__c
      WHERE Reimbursement__c = :request.Id AND Group_Id__c = :groupId
    ]) {
      if (d.Name == 'Payroll' && d.Has_Attachments__c)
        hasPayroll = true;
      if (d.Name == 'Timesheet' && d.Has_Attachments__c)
        hasTimesheet = true;
    }
    if (hasPayroll == false)
      errorMessage = '<b>Correction Required:</b> Please upload a payroll document. <br />';
    if (hasTimesheet == false)
      errorMessage += '<b>Correction Required:</b> Please upload a timesheet. <br />';
  }
  // END save request

  // BEGIN page actions
  public PageReference saveAndExit() {
    errorMessage = '';
    upsertRequest();
    if (ApexPages.hasMessages() || errorMessage != '')
      return null;
    return new PageReference('/Reimbursements');
  }

  public void savePersonnel() {
    upsertPersonnelItems();
    getFringeItems();
    upsertFringeItems();
  }

  public PageReference savePersonnelAndExit() {
    savePersonnel();
    if (ApexPages.hasMessages())
      return null;
    return new PageReference('/Reimbursements');
  }

  public PageReference saveFringeAndExit() {
    upsertFringeItems();
    if (ApexPages.hasMessages())
      return null;
    return new PageReference('/Reimbursements');
  }

  public PageReference saveExpensesAndExit() {
    upsertExpenseItems();
    if (ApexPages.hasMessages())
      return null;
    return new PageReference('/Reimbursements');
  }

  public PageReference goToPersonnelForm() {
    errorMessage = '';
    request.Previous_Status__c = request.Status__c;
    if (request.Previous_Status__c == 'Revisions Needed') {
      request.Status__c = 'Revision in Progress';
    } else if (request.Previous_Status__c == null) {
      request.Status__c = 'Incomplete';
    }

    upsertRequest();

    if (ApexPages.hasMessages() || errorMessage != '')
      return null;
    String url = '';
    if (request.Number_of_Pay_Periods__c > 0) {
      url = '/ReimbursementPersonnel?requestId=' + request.Id + '&payPeriod=1';
    } else {
      url = '/ReimbursementExpenses?requestId=' + request.Id;
    }
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference previousFromPersonnel() {
    savePersonnel();
    docValidation();
    String url;
    Decimal previous = payPeriod - 1;
    if (previous > 0) {
      url =
        '/ReimbursementPersonnel?requestId=' +
        request.Id +
        '&payPeriod=' +
        previous;
    } else {
      url = '/ReimbursementForm?requestId=' + request.Id;
    }
    if (payPeriod != null && errorMessage == '') {
      PageReference pr = new PageReference(url);
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference nextFromPersonnel() {
    savePersonnel();
    docValidation();
    String url;
    Decimal next = payPeriod + 1;
    if (next > request.Number_of_Pay_Periods__c) {
      url = '/ReimbursementFringe?requestId=' + request.Id;
    } else {
      url =
        '/ReimbursementPersonnel?requestId=' +
        request.Id +
        '&payPeriod=' +
        next;
    }
    if (payPeriod != null && errorMessage == '') {
      PageReference pr = new PageReference(url);
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference previousFromFringe() {
    upsertFringeItems();
    if (errorMessage == '') {
      PageReference pr = new PageReference(
        '/ReimbursementPersonnel?requestId=' +
        request.Id +
        '&payPeriod=' +
        request.Number_of_Pay_Periods__c
      );
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference goToExpensesForm() {
    upsertFringeItems();
    if (errorMessage == '') {
      PageReference pr = new PageReference(
        '/ReimbursementExpenses?requestId=' + requestId
      );
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference previousFromExpenses() {
    upsertExpenseItems();
    rc.upsertRequest(request);
    PageReference pr = new PageReference(
      '/ReimbursementFringe?requestId=' + requestId
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference review() {
    system.debug('review ');
    upsertExpenseItems();
    rc.upsertRequest(request);
    Boolean over = false;
    system.debug(
      'grant.Procurement_Threshold__c ' + grant.Procurement_Threshold__c
    );
    for (Reimbursement_Item__c ri : expense_list) {
      system.debug('review ri Requested_Amount__c ' + ri.Requested_Amount__c);
      if (
        grant.Grant_Type__c == 'OVC' &&
        grant.Procurement_Threshold__c != null &&
        ri.Requested_Amount__c > grant.Procurement_Threshold__c
      )
        over = true;
    }
    system.debug('review over ' + over);
    if (over == true) {
      showReviewPopup();
    } else {
      PageReference pr = new PageReference(
        '/Reimbursement?requestId=' + requestId
      );
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference goToReview() {
    PageReference pr = new PageReference(
      '/Reimbursement?requestId=' + requestId
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference submit() {
    if (errorMessage == '') {
      modHist =
        fdt +
        ': Request Submitted by ' +
        currentUser.Contact.Name +
        ' (' +
        currentUser.Id +
        ')';
      request.Request_Date__c = dt;
      request.Previous_Status__c = request.Status__c;
      request.Status__c = 'Pending First Approval';
      request.Primary_Contact__c = currentUser.ContactId;
      request.Modification_Last_Submitted_Date__c = dt;
      upsertRequest();

      PageReference pr = new PageReference(
        '/Reimbursement?requestId=' + requestId
      );
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference cancel() {
    return new PageReference('/Reimbursements');
  }

  public PageReference sendBack() {
    for (Reimbursement_Item__c ri : personnel_list) {
      ri.Approved_Salary__c = null;
    }
    for (Reimbursement_Item__c ri : fringe_list) {
      ri.Approved_Benefits__c = null;
    }
    for (Reimbursement_Item__c ri : expense_list) {
      ri.Approved_Amount__c = null;
    }

    modHist =
      fdt +
      ': Returned for corrections by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';

    request.Previous_Status__c = request.Status__c;
    if (sendBackTo == 'affiliate') {
      request.Status__c = 'Revisions Needed';
      if (request.Level_One_Sent_Back_Count__c == null)
        request.Level_One_Sent_Back_Count__c = 1;
      else
        request.Level_One_Sent_Back_Count__c += 1;
      request.Level_One_Sent_Back_Date__c = date.today();
    } else if (
      sendBackTo == 'levelone' ||
      request.Status__c == 'Pending Second Approval'
    ) {
      request.Status__c = 'Pending First Approval';
      if (request.Level_Two_Sent_Back_Count__c == null)
        request.Level_Two_Sent_Back_Count__c = 1;
      else
        request.Level_Two_Sent_Back_Count__c += 1;
      request.Level_Two_Sent_Back_Date__c = date.today();
    } else if (
      sendBackTo == 'leveltwo' ||
      request.Status__c == 'Pending Third Approval'
    ) {
      request.Status__c = 'Pending Second Approval';
      request.Approved_Email_Sent__c = false;
      if (request.Level_Three_Sent_Back_Count__c == null)
        request.Level_Three_Sent_Back_Count__c = 1;
      else
        request.Level_Three_Sent_Back_Count__c += 1;
      request.Level_Three_Sent_Back_Date__c = date.today();
    } else if (
      sendBackTo == 'levelthree' ||
      request.Status__c == 'Pending Fourth Approval'
    ) {
      request.Status__c = 'Pending Third Approval';
      if (request.Level_Four_Sent_Back_Count__c == null)
        request.Level_Four_Sent_Back_Count__c = 1;
      else
        request.Level_Four_Sent_Back_Count__c += 1;
      request.Level_Four_Sent_Back_Date__c = date.today();
    } else {
      request.Status__c = 'Revisions Needed';
    }
    saveAll();

    if (errorMessage != '' || ApexPages.hasMessages())
      return null;
    return new PageReference('/Reimbursements');
  }

  public PageReference deny() {
    modHist =
      fdt +
      ': Denied by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    request.Status__c = 'Denied';
    request.Approved_Amount__c = 0;
    upsertRequest();
    if (ApexPages.hasMessages())
      return null;
    else
      return new PageReference('/Reimbursements');
  }

  public PageReference approve() {
    displayApprovePopup = false;
    errorMessage = '';
    for (Reimbursement_Item__c ri : personnel_list) {
      if (
        userAcctType == 'National Organization' &&
        ri.Approved_Salary__c < ri.Requested_Salary__c &&
        (ri.Response__c == null ||
        ri.Response__c == '')
      )
        errorMessage +=
          'A reviewer note is required to explain why Personnel item ' +
          ri.Title__c +
          ' was approved for a lower amount. <br />';
      if (ri.Approved_Salary__c > ri.Requested_Salary__c)
        errorMessage +=
          'Approved Salary for ' +
          ri.Title__c +
          ' must be less than or equal to Requested Salary. <br />';
    }
    for (Reimbursement_Item__c ri : fringe_list) {
      if (
        portalName != 'Ripken' &&
        userAcctType == 'National Organization' &&
        ri.Approved_Benefits__c < ri.New_Fringe_Benefits__c &&
        (ri.Response__c == null ||
        ri.Response__c == '')
      )
        errorMessage +=
          'A reviewer note is required to explain why Fringe item ' +
          ri.Title__c +
          ' was approved for a lower amount. <br />';
      if (ri.Approved_Benefits__c > ri.New_Fringe_Benefits__c)
        errorMessage +=
          'Approved Benefits for ' +
          ri.Title__c +
          ' must be less than or equal to Requested Benefits. <br />';
    }
    for (Reimbursement_Item__c ri : expense_list) {
      if (
        userAcctType == 'National Organization' &&
        ri.Approved_Amount__c < ri.Requested_Amount__c &&
        (ri.Response__c == null ||
        ri.Response__c == '')
      )
        errorMessage +=
          'A reviewer note is required to explain why Expense item ' +
          ri.Title__c +
          ' was approved for a lower amount. <br />';
      if (ri.Approved_Amount__c > ri.Requested_Amount__c)
        errorMessage +=
          'Approved Amount for ' +
          ri.Title__c +
          ' must be less than or equal to Requested Amount. <br />';
    }
    if (
      totalApproved >
      (grant.Amount__c - grant.Reimbursement_Approved_Amount__c) ||
      totalApproved > balance
    )
      errorMessage += 'Approved Amount must be less than or equal to the Awarded Amount. <br />';
    if (errorMessage != '' || ApexPages.hasMessages()) {
      system.debug(
        '>>> approve reimbursement error = ' +
        errorMessage +
        '; ' +
        String.valueOf(ApexPages.getMessages())
      );
      return null;
    }

    modHist =
      fdt +
      ': Approved by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';

    request.Previous_Status__c = request.Status__c;
    if (
      approverLevel == 'Level One' ||
      (approverLevel == 'Finance Admin' &&
      request.Status__c == 'Pending First Approval')
    ) {
      request.Level_One_Approver__c = uc.currentUser.ContactId;
      request.Level_One_Approved_Date__c = Date.today();
      if (request.Number_of_Approvals_Required__c > 1)
        request.Status__c = 'Pending Second Approval';
      else
        request.Status__c = 'Approved';
    } else if (
      approverLevel == 'Level Two' ||
      (approverLevel == 'Finance Admin' &&
      request.Status__c == 'Pending Second Approval')
    ) {
      request.Level_Two_Approver__c = uc.currentUser.ContactId;
      request.Level_Two_Approved_Date__c = Date.today();
      if (request.Number_of_Approvals_Required__c > 2)
        request.Status__c = 'Pending Third Approval';
      else
        request.Status__c = 'Approved';
    } else if (
      approverLevel == 'Level Three' ||
      (approverLevel == 'Finance Admin' &&
      request.Status__c == 'Pending Third Approval')
    ) {
      request.Level_Three_Approver__c = uc.currentUser.ContactId;
      request.Level_Three_Approved_Date__c = Date.today();
      if (request.Number_of_Approvals_Required__c > 3)
        request.Status__c = 'Pending Fourth Approval';
      else
        request.Status__c = 'Approved';
    } else if (
      approverLevel == 'Finance Admin' ||
      approverLevel == 'Level Four'
    ) {
      request.Level_Four_Approver__c = uc.currentUser.ContactId;
      request.Level_Four_Approved_Date__c = Date.today();
      request.Status__c = 'Approved';
    }
    saveAll();

    if (errorMessage != '' || ApexPages.hasMessages())
      return null;
    return new PageReference('/Reimbursements');
  }

  public PageReference deleteReimbursement() {
    rc.deleteRequest(request);
    if (ApexPages.hasMessages())
      return null;
    return new PageReference('/Reimbursements');
  }

  public void getItemAtts() {
    Set<Id> eIds = new Set<Id>();
    for (Reimbursement_Item__c ri : expense_list) {
      eIds.add(ri.Id);
    }
    if (eIds.size() > 0)
      itemAtts = ac.getAttachments(null, eIds);
  }
  public void deleteAtt() {
    system.debug('selectedAttId = ' + selectedAttId);
    if (selectedAttId != null) {
      Attachment[] a = [SELECT Id FROM Attachment WHERE Id = :selectedAttId];
      if (a.size() > 0)
        ac.deleteAttachment(a[0]);
      getItemAtts();
    }
  }
  // END page actions

  // BEGIN popups
  public void showNotesPopup() {
    if (selectedItemId != null) {
      selectedItem = ric.getRequestItem(selectedItemId);
      displayNotesPopup = true;
    }
  }
  public void hideNotesPopup() {
    displayNotesPopup = false;
    getItemAtts();
  }

  public void showAttPopup() {
    displayAttPopup = true;
  }
  public void hideAttPopup() {
    displayAttPopup = false;
    getItemAtts();
  }

  public void showSendBackPopup() {
    displaySendBackPopup = true;
  }
  public void hideSendBackPopup() {
    displaySendBackPopup = false;
  }

  public void showApprovePopup() {
    displayApprovePopup = true;
  }
  public void hideApprovePopup() {
    displayApprovePopup = false;
  }

  public void showDenyPopup() {
    displayDenyPopup = true;
  }
  public void hideDenyPopup() {
    displayDenyPopup = false;
  }

  public void showDeletePopup() {
    displayDeletePopup = true;
  }
  public void hideDeletePopup() {
    displayDeletePopup = false;
  }

  public void showReviewPopup() {
    system.debug('showReviewPopup ');
    displayReviewPopup = true;
  }
  public void hideReviewPopup() {
    displayReviewPopup = false;
  }
  // END popups
}
