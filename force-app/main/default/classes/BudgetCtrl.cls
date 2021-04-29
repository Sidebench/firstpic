public with sharing class BudgetCtrl {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private GrantClass gc = new GrantClass();
  private ReimbursementClass rc = new ReimbursementClass();
  private BudgetItemClass bic = new BudgetItemClass();
  private getIdFromString gifs = new getIdFromString();

  public Grant__c grant { get; set; }
  public ID grantId { get; set; }
  public String statusColor { get; set; }
  public Boolean isReviewMode { get; set; }
  public Decimal durationWks { get; set; }
  public Decimal laborBudgetAmount { get; set; }
  public Decimal expenseBudgetAmount { get; set; }
  public Decimal totalBudgetAmount { get; set; }
  public Decimal previousRate { get; set; }
  public Decimal laborIndirectCostsBudgetAmount { get; set; }
  public Decimal expenseIndirectCostsBudgetAmount { get; set; }
  public Decimal totalIndirectCostsBudgetAmount { get; set; }
  public Boolean hasReimbursements { get; set; }

  public List<String> categories { get; set; }
  public List<Budget_Item__c> laborItem_list { get; set; }
  public List<Budget_Item__c> newLaborItem_list { get; set; }
  public List<Budget_Item__c> expenseItem_list { get; set; }
  public List<Budget_Item__c> newExpenseItem_list { get; set; }

  public Id selectedItemId { get; set; }
  public String selectedItemType { get; set; }
  public Budget_Item__c selectedItem { get; set; }

  //private SertifiClass sc = new SertifiClass();
  //public List<Sertifi2_0__EDocument__c> docs { get; set; }
  public List<Attachment> atts { get; set; }
  public String LOALink { get; set; }
  public Boolean sendLOASuccessful { get; set; }
  public Boolean sendFFATASuccessful { get; set; }

  public String sendBackTo { get; set; }
  public Boolean canCloseGrant { get; set; }
  public Boolean canReopenGrant { get; set; }

  public Boolean displayNotesPopup { get; set; }
  public Boolean displayLaborNotesPopup { get; set; }
  public Boolean displayNewLaborNotesPopup { get; set; }
  public Boolean displayNewExpenseNotesPopup { get; set; }
  public Boolean displaySendBackPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public Boolean displayUpdatePopup { get; set; }
  public Boolean displayCloseGrantPopup { get; set; }

  public String errorMessage { get; set; }
  private Date dt = date.today();
  private String fdt = dt.format();
  private String modHist = '';
  public Boolean runInit { get; set; }
  public Boolean updateIndirectRate { get; set; }

  public BudgetCtrl getBudgetCtrl() {
    return this;
  }

  public BudgetCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);
    grant = new Grant__c();

    durationWks = 0;
    laborBudgetAmount = 0;
    expenseBudgetAmount = 0;
    totalBudgetAmount = 0;
    laborIndirectCostsBudgetAmount = 0;
    expenseIndirectCostsBudgetAmount = 0;
    totalIndirectCostsBudgetAmount = 0;

    categories = new List<String>();
    laborItem_list = new List<Budget_Item__c>();
    newLaborItem_list = new List<Budget_Item__c>();
    expenseItem_list = new List<Budget_Item__c>();
    newExpenseItem_list = new List<Budget_Item__c>();
    selectedItem = new Budget_Item__c();
    //docs = new List<Sertifi2_0__EDocument__c>();
    atts = new List<Attachment>();

    errorMessage = '';
    runInit = true;
    updateIndirectRate = false;
  }

  public void init() {
    if (runInit) {
      getGrant();
      getBudgetItems();
      getTotals();

      String updateLaborIndirectRate = ApexPages.currentPage()
        .getParameters()
        .get('updateLaborIndirectRate');
      if (updateLaborIndirectRate == 'true') {
        updateIndirectRate = true;
        updateLaborIndirectRate();
      }

      if (grant.Apply_Indirect_Rate_to_Expenses__c) {
        String updateExpenseIndirectRate = ApexPages.currentPage()
          .getParameters()
          .get('updateExpenseIndirectRate');
        if (updateExpenseIndirectRate == 'true') {
          updateIndirectRate = true;
          updateExpenseIndirectRate();
        }
      }

      runInit = false;
    }
  }

  public void getGrant() {
    canCloseGrant = false;
    canReopenGrant = false;
    if (grantId != null) {
      grant = gc.getGrant(grantId);
      if (grant.Duration__c != null)
        durationWks = grant.Duration__c / 7;
      else if (grant.Grant_Duration__c != null)
        durationWks = grant.Grant_Duration__c / 7;
      if (grant.Amount__c == null)
        grant.Amount__c = 0;
      totalBudgetAmount = grant.Total_New_Item_Budget__c;
      laborBudgetAmount = grant.Total_Labor_Item_Budget__c;
      expenseBudgetAmount = grant.Total_Expense_Item_Budget__c;

      String status = '';
      if (grant.Grant_Status__c != null)
        status = grant.Grant_Status__c;
      if (status.contains('Pending')) {
        statusColor = 'text-warning';
      }
      if (
        (status == 'Pending First Approval' &&
        (approverLevel == 'Level One' ||
        approverLevel == 'Level Two')) ||
        (status == 'Pending Second Approval' &&
        approverLevel == 'Level Two') ||
        (status == 'Pending Third Approval' &&
        (approverLevel == 'Level Three' ||
        approverLevel == 'Level Four')) ||
        (status == 'Pending Fourth Approval' &&
        approverLevel == 'Level Four') ||
        (status.contains('Pending') && approverLevel == 'Finance Admin')
      ) {
        isReviewMode = true;
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

      if (grant.Number_of_Reimbursements__c > 0)
        hasReimbursements = true;

      for (Attachment i : grant.Attachments) {
        if (
          i.Name.contains('Letter of Agreement') ||
          i.Name.contains('LOA') ||
          i.Name.contains('FFATA')
        ) {
          atts.add(i);
        }
      }
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
    }
  }

  // BEGIN getBudgetItems
  public void getBudgetItems() {
    laborItem_list.clear();
    newLaborItem_list.clear();
    expenseItem_list.clear();
    newExpenseItem_list.clear();
    categories.clear();

    Set<String> temp = new Set<String>();
    if (GrantId != null) {
      for (Budget_Item__c bi : bic.getBudgetItems(GrantId)) {
        if (bi.Is_Active__c)
          bi.Selected__c = false;
        if (bi.Item_Note__c != null || bi.Response__c != null)
          bi.Has_Notes__c = true;
        if (bi.RecordType.Name == 'Labor') {
          laborItem_list.add(bi);
          if (portalName == 'Ripken' && bi.FICA_Percent__c > 7.65)
            errorMessage += 'FICA cannot be greater than 7.65%. <br />';
        } else if (bi.RecordType.Name == 'Expense') {
          expenseItem_list.add(bi);
          if (bi.Category__c == null)
            bi.Category__c = 'Other Costs';
          if (
            bi.Apply_Indirect_Rate_Cap__c &&
            bi.Amount_Allocated_for_Indirect_Cost__c == null
          )
            bi.Amount_Allocated_for_Indirect_Cost__c = grant.National_Grant_Indirect_Rate_Cap__c;
          if (!temp.contains(bi.Category__c)) {
            temp.add(bi.Category__c);
            categories.add(bi.Category__c);
          }
        }
      }
    }
    categories.sort();
  }
  // END getBudgetItems

  // BEGIN updateIndirectRate
  public void updateLaborIndirectRate() {
    previousRate = grant.Indirect_Rate__c;
    List<Budget_Item__c> laborClone = new List<Budget_Item__c>();
    for (Budget_Item__c i : laborItem_list) {
      if (i.Is_Active__c && i.Total_Approved_Salary__c > 0) {
        Budget_Item__c bi = i.clone(false, true);
        if (i.Original_Budget_Item__c != null)
          bi.Original_Budget_Item__c = i.Original_Budget_Item__c;
        else
          bi.Original_Budget_Item__c = i.Id;
        laborClone.add(bi);

        i.Selected__c = true;
      }
    }
    markPersonnelInactive();
    laborItem_list.addAll(laborClone);
  }

  public void updateExpenseIndirectRate() {
    List<Budget_Item__c> expenseClone = new List<Budget_Item__c>();
    for (Budget_Item__c i : expenseItem_list) {
      if (i.Is_Active__c && i.Total_Approved_Amount__c > 0) {
        Budget_Item__c bi = i.clone(false, true);
        if (i.Original_Budget_Item__c != null)
          bi.Original_Budget_Item__c = i.Original_Budget_Item__c;
        else
          bi.Original_Budget_Item__c = i.Id;
        if (
          i.Apply_Indirect_Rate_Cap__c &&
          i.Item_Budget__c > grant.National_Grant_Indirect_Rate_Cap__c
        )
          bi.Amount_Allocated_for_Indirect_Cost__c = grant.National_Grant_Indirect_Rate_Cap__c;
        expenseClone.add(bi);

        i.Selected__c = true;
      }
    }
    markExpensesInactive();
    expenseItem_list.addAll(expenseClone);
  }
  // END updateIndirectRate

  // BEGIN addItem
  public void addLaborItem() {
    Budget_Item__c bi = new Budget_Item__c(
      Grant__c = grant.Id,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Labor')
        .getRecordTypeId(),
      Is_Active__c = true,
      Category__c = 'Personnel',
      Number_of_Weeks_on_Grant__c = durationWks.setScale(2)
    );
    newLaborItem_list.add(bi);
  }

  public void addExpenseItem() {
    Budget_Item__c bi = new Budget_Item__c(
      Grant__c = grant.Id,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId(),
      Is_Active__c = true,
      Category__c = 'Other Costs',
      Quantity__c = 1,
      Amount_Allocated_for_Indirect_Cost__c = grant.National_Grant_Indirect_Rate_Cap__c
    );
    newExpenseItem_list.add(bi);
  }

  public void addMileageItem() {
    Budget_Item__c bi = new Budget_Item__c(
      Grant__c = grant.Id,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId(),
      Is_Active__c = true,
      Name = 'Mileage',
      Type__c = 'Mileage'
    );
    if (portalName == 'Ripken') {
      bi.Category__c = 'Program Related Travel';
      bi.Mileage_Rate__c = .545;
    } else
      bi.Category__c = 'Travel';
    newExpenseItem_list.add(bi);
  }
  // END addItem

  // BEGIN deactivateItems
  public void markPersonnelInactive() {
    for (Budget_Item__c bi : laborItem_list) {
      if (bi.Selected__c) {
        bi.Is_Active__c = false;
        if (bi.Total_Approved_Salary__c != null) {
          bi.New_Wages__c = bi.Total_Approved_Salary__c;
        } else {
          bi.New_Wages__c = 0;
        }
        if (bi.Total_Approved_Benefits__c != null) {
          bi.New_Fringe_Benefits__c = bi.Total_Approved_Benefits__c;
        } else {
          bi.New_Fringe_Benefits__c = 0;
        }
        bi.New_Item_Budget__c = bi.New_Wages__c + bi.New_Fringe_Benefits__c;
        bi.Selected__c = false;
      }
    }
  }

  public void markExpensesInactive() {
    for (Budget_Item__c bi : expenseItem_list) {
      if (bi.Selected__c) {
        bi.Is_Active__c = false;
        if (bi.Total_Approved_Amount__c != null) {
          bi.New_Item_Budget__c = bi.Total_Approved_Amount__c;
        } else {
          bi.New_Item_Budget__c = 0;
        }
        bi.Selected__c = false;
      }
    }
  }
  // END deactivateItems

  // BEGIN deleteItems
  public void deleteLaborItems() {
    deleteItem('labor');
  }
  public void deleteNewLaborItems() {
    deleteItem('newLabor');
  }

  public void deleteExpenseItems() {
    deleteItem('expense');
  }
  public void deleteNewExpenseItems() {
    deleteItem('newExpense');
  }

  public void deleteItem(String listType) {
    List<Budget_Item__c> bi_list = new List<Budget_Item__c>();
    if (listType == 'labor')
      bi_list = laborItem_list;
    if (listType == 'newLabor')
      bi_list = newLaborItem_list;
    if (listType == 'expense')
      bi_list = expenseItem_list;
    if (listType == 'newExpense')
      bi_list = newExpenseItem_list;

    List<Budget_Item__c> delete_list = new List<Budget_Item__c>();
    Integer i = 0;
    while (i < bi_list.size()) {
      if (bi_list.get(i).Selected__c) {
        if (listType == 'labor' || listType == 'expense')
          delete_list.add(bi_list.get(i));
        bi_list.remove(i);
      } else {
        i++;
      }
    }
    bic.deleteItems(delete_list);
  }
  // END deleteItems

  // BEGIN updateAmounts
  public void updateExistingLaborAmounts() {
    errorMessage = '';
    updateLaborAmounts('existing');
  }
  public void updateNewLaborAmounts() {
    errorMessage = '';
    updateLaborAmounts('new');
  }
  public void updateAllLaborAmounts() {
    errorMessage = '';
    updateLaborAmounts('existing');
    updateLaborAmounts('new');
  }

  public void updateLaborAmounts(String listType) {
    List<Budget_Item__c> bi_list = new List<Budget_Item__c>();
    if (listType == 'existing')
      bi_list = laborItem_list;
    if (listType == 'new')
      bi_list = newLaborItem_list;

    for (Budget_Item__c bi : bi_list) {
      if (bi.Is_Active__c) {
        if (
          bi.Projected_Grant_Hours_Per_Week__c > bi.Projected_Hours_Per_Week__c
        )
          errorMessage +=
            '<b>Correction Required:</b> Grant Hrs/Wk cannont exceed Total Hrs/Wk for ' +
            bi.Name +
            '.  <br />';
        if (bi.Number_of_Weeks_on_Grant__c == null)
          bi.Number_of_Weeks_on_Grant__c = 52.14;
        if (bi.Projected_Grant_Hours_Per_Week__c == 0) {
          bi.Projected_Percent_Time_on_Grant__c = 0;
        }
        if (
          bi.Projected_Hours_Per_Week__c != null &&
          bi.Projected_Grant_Hours_Per_Week__c != null &&
          bi.Projected_Hours_Per_Week__c != 0
        ) {
          bi.Projected_Hours_Per_Week__c = bi.Projected_Hours_Per_Week__c.setScale(
            2
          );
          bi.Projected_Grant_Hours_Per_Week__c = bi.Projected_Grant_Hours_Per_Week__c.setScale(
            2
          );
          bi.Projected_Percent_Time_on_Grant__c =
            (bi.Projected_Grant_Hours_Per_Week__c /
            bi.Projected_Hours_Per_Week__c) * 100;

          if (bi.New_Rate__c != null) {
            bi.New_Rate__c = bi.New_Rate__c.setScale(2);
            if (bi.Is_Hourly__c) {
              bi.New_Wages__c = (bi.New_Rate__c *
                bi.Projected_Grant_Hours_Per_Week__c *
                bi.Number_of_Weeks_on_Grant__c)
                .setScale(2);
            } else {
              bi.New_Wages__c = ((bi.New_Rate__c / 52.14) *
                (bi.Projected_Percent_Time_on_Grant__c / 100) *
                bi.Number_of_Weeks_on_Grant__c)
                .setScale(2);
            }
          }

          Decimal fb = 0;
          bi.New_Fringe_Benefits__c = 0;
          if (bi.FICA_Percent__c != null && bi.FICA_Percent__c != 0) {
            bi.FICA__c = ((bi.FICA_Percent__c / 100) * bi.New_Wages__c)
              .setScale(2);
            fb += bi.FICA__c;
            if (portalName == 'Ripken' && bi.FICA_Percent__c > 7.65)
              errorMessage += 'FICA cannot be greater than 7.65%. <br />';
          } else {
            bi.FICA_Percent__c = 0;
            bi.FICA__c = 0;
          }
          if (bi.SUTA_Percent__c != null && bi.SUTA_Percent__c != 0) {
            bi.SUTA__c = ((bi.SUTA_Percent__c / 100) * bi.New_Wages__c)
              .setScale(2);
            fb += bi.SUTA__c;
          } else {
            bi.SUTA_Percent__c = 0;
            bi.SUTA__c = 0;
          }
          if (
            bi.Workers_Comp_Percent__c != null &&
            bi.Workers_Comp_Percent__c != 0
          ) {
            bi.Workers_Comp__c = ((bi.Workers_Comp_Percent__c / 100) *
              bi.New_Wages__c)
              .setScale(2);
            fb += bi.Workers_Comp__c;
          } else {
            bi.Workers_Comp_Percent__c = 0;
            bi.Workers_Comp__c = 0;
          }
          if (
            bi.Retirement_Percent__c != null &&
            bi.Retirement_Percent__c != 0
          ) {
            bi.Retirement__c = ((bi.Retirement_Percent__c / 100) *
              bi.New_Wages__c)
              .setScale(2);
            fb += bi.Retirement__c;
          } else {
            bi.Retirement_Percent__c = 0;
            bi.Retirement__c = 0;
          }
          if (bi.Other_Percent__c != null && bi.Other_Percent__c != 0) {
            bi.Other_Percent_Based__c = ((bi.Other_Percent__c / 100) *
              bi.New_Wages__c)
              .setScale(2);
            fb += bi.Other_Percent_Based__c;
            if (bi.Item_Note__c == null)
              errorMessage +=
                '<b>Correction Required:</b> Please add a note for ' +
                bi.Name +
                '\'s Other Percent Based Benefit.  <br />';
          } else {
            bi.Other_Percent__c = 0;
            bi.Other_Percent_Based__c = 0;
          }
          if (bi.Medical_Premium__c != null && bi.Medical_Premium__c != 0) {
            bi.Medical__c = ((bi.Medical_Premium__c / (52.14)) *
              bi.Number_of_Weeks_on_Grant__c *
              (bi.Projected_Percent_Time_on_Grant__c / 100))
              .setScale(2);
            fb += bi.Medical__c;
          } else {
            bi.Medical_Premium__c = 0;
            bi.Medical__c = 0;
          }
          if (bi.Dental_Premium__c != null && bi.Dental_Premium__c != 0) {
            bi.Dental__c = ((bi.Dental_Premium__c / (52.14)) *
              bi.Number_of_Weeks_on_Grant__c *
              (bi.Projected_Percent_Time_on_Grant__c / 100))
              .setScale(2);
            fb += bi.Dental__c;
          } else {
            bi.Dental_Premium__c = 0;
            bi.Dental__c = 0;
          }
          if (bi.Vision_Premium__c != null && bi.Vision_Premium__c != 0) {
            bi.Vision__c = ((bi.Vision_Premium__c / (52.14)) *
              bi.Number_of_Weeks_on_Grant__c *
              (bi.Projected_Percent_Time_on_Grant__c / 100))
              .setScale(2);
            fb += bi.Vision__c;
          } else {
            bi.Vision_Premium__c = 0;
            bi.Vision__c = 0;
          }
          if (
            bi.Short_Term_Premium__c != null &&
            bi.Short_Term_Premium__c != 0
          ) {
            bi.Short_Term_Disability__c = ((bi.Short_Term_Premium__c /
              (52.14)) *
              bi.Number_of_Weeks_on_Grant__c *
              (bi.Projected_Percent_Time_on_Grant__c / 100))
              .setScale(2);
            fb += bi.Short_Term_Disability__c;
          } else {
            bi.Short_Term_Premium__c = 0;
            bi.Short_Term_Disability__c = 0;
          }
          if (bi.Long_Term_Premium__c != null && bi.Long_Term_Premium__c != 0) {
            bi.Long_Term_Disability__c = ((bi.Long_Term_Premium__c / (52.14)) *
              bi.Number_of_Weeks_on_Grant__c *
              (bi.Projected_Percent_Time_on_Grant__c / 100))
              .setScale(2);
            fb += bi.Long_Term_Disability__c;
          } else {
            bi.Long_Term_Premium__c = 0;
            bi.Long_Term_Disability__c = 0;
          }
          if (bi.Life_Premium__c != null && bi.Life_Premium__c != 0) {
            bi.Life__c = ((bi.Life_Premium__c / (52.14)) *
              bi.Number_of_Weeks_on_Grant__c *
              (bi.Projected_Percent_Time_on_Grant__c / 100))
              .setScale(2);
            fb += bi.Life__c;
          } else {
            bi.Life_Premium__c = 0;
            bi.Life__c = 0;
          }
          if (bi.Other_Premium__c != null && bi.Other_Premium__c != 0) {
            bi.Other_Benefits__c = ((bi.Other_Premium__c / (52.14)) *
              bi.Number_of_Weeks_on_Grant__c *
              (bi.Projected_Percent_Time_on_Grant__c / 100))
              .setScale(2);
            fb += bi.Other_Benefits__c;
            if (bi.Item_Note__c == null)
              errorMessage +=
                '<b>Correction Required:</b> Please add a note for ' +
                bi.Name +
                '\'s Other Premium Based Benefit.  <br />';
          } else {
            bi.Other_Premium__c = 0;
            bi.Other_Benefits__c = 0;
          }
          bi.New_Fringe_Benefits__c = fb;

          bi.New_Item_Budget__c = 0;
          if (bi.New_Wages__c != null)
            bi.New_Item_Budget__c += bi.New_Wages__c;
          if (bi.New_Fringe_Benefits__c != null)
            bi.New_Item_Budget__c += bi.New_Fringe_Benefits__c;

          if (grant.Indirect_Rate__c != null)
            bi.Indirect_Rate__c = grant.Indirect_Rate__c;
        }
      }
    }
    List<FormulaRecalcResult> results = Formula.recalculateFormulas(bi_list);
    getLaborTotals();
  }

  public void updateExistingExpenseAmounts() {
    errorMessage = '';
    updateExpenseAmounts('existing');
  }
  public void updateNewExpenseAmounts() {
    errorMessage = '';
    updateExpenseAmounts('new');
  }
  public void updateAllExpenseAmounts() {
    errorMessage = '';
    updateExpenseAmounts('existing');
    updateExpenseAmounts('new');
  }

  public void updateExpenseAmounts(String listType) {
    List<Budget_Item__c> bi_list = new List<Budget_Item__c>();
    if (listType == 'existing')
      bi_list = expenseItem_list;
    if (listType == 'new')
      bi_list = newExpenseItem_list;

    for (Budget_Item__c bi : bi_list) {
      if (bi.Is_Active__c && bi.Quantity__c != null) {
        if (bi.Type__c != 'Mileage' && bi.New_Rate__c != null)
          bi.New_Item_Budget__c = bi.New_Rate__c * bi.Quantity__c;
        if (bi.Type__c == 'Mileage' && bi.Mileage_Rate__c != null)
          bi.New_Item_Budget__c = (bi.Mileage_Rate__c * bi.Quantity__c)
            .setScale(2);
        if (
          grant.Indirect_Rate__c != null &&
          grant.Apply_Indirect_Rate_to_Expenses__c
        )
          bi.Indirect_Rate__c = grant.Indirect_Rate__c;
        if (!grant.Apply_Indirect_Rate_to_Expenses__c)
          bi.Amount_Allocated_for_Indirect_Cost__c = 0;
        if (
          bi.Apply_Indirect_Rate_Cap__c &&
          bi.Amount_Allocated_for_Indirect_Cost__c >
          grant.National_Grant_Indirect_Rate_Cap__c
        )
          errorMessage +=
            'Amount allocated for  ' +
            bi.Name +
            ' indirect cost must be less than the indirect rate cap.<br/>';
        if (
          bi.Apply_Indirect_Rate_Cap__c &&
          bi.Amount_Allocated_for_Indirect_Cost__c > bi.New_Item_Budget__c
        )
          errorMessage +=
            'Indirect Cost for ' +
            bi.Name +
            ' cannot exceed Rate. Please adjust.<br/>';
      }
    }
    List<FormulaRecalcResult> results = Formula.recalculateFormulas(bi_list);
    getExpenseTotals();
  }
  // END updateAmounts

  // BEGIN getTotals
  public void getTotals() {
    totalBudgetAmount = 0;
    totalIndirectCostsBudgetAmount = 0;
    getLaborTotals();
    getExpenseTotals();
    getTotal();
  }

  public void getTotal() {
    totalBudgetAmount = laborBudgetAmount + expenseBudgetAmount;
    totalIndirectCostsBudgetAmount =
      laborIndirectCostsBudgetAmount + expenseIndirectCostsBudgetAmount;
    if (totalIndirectCostsBudgetAmount > 0)
      totalBudgetAmount += totalIndirectCostsBudgetAmount;
    totalBudgetAmount = totalBudgetAmount.setScale(2);
    if (
      !grant.National_Grant__r.Allow_Budget_to_Exceed_Award__c &&
      totalBudgetAmount > grant.Amount__c.setScale(2)
    )
      errorMessage = 'Requested Amount Exceeds Grant Awarded Amount';
  }

  public void getLaborTotals() {
    laborBudgetAmount = 0;
    laborIndirectCostsBudgetAmount = 0;
    for (Budget_Item__c bi : laborItem_list) {
      if (bi.New_Item_Budget__c != null) {
        laborBudgetAmount += bi.New_Item_Budget__c;
        if (bi.Indirect_Rate__c != null)
          laborIndirectCostsBudgetAmount +=
            bi.Indirect_Rate__c *
            bi.New_Item_Budget__c /
            100;
      } else if (bi.Item_Budget__c != null) {
        laborBudgetAmount += bi.Item_Budget__c;
        if (bi.Indirect_Rate__c != null)
          laborIndirectCostsBudgetAmount +=
            bi.Indirect_Rate__c *
            bi.Item_Budget__c /
            100;
      }
      //if(bi.Indirect_Costs_Budget__c != null) laborIndirectCostsBudgetAmount += bi.Indirect_Costs_Budget__c;
    }
    for (Budget_Item__c bi : newlaborItem_list) {
      if (bi.New_Item_Budget__c != null) {
        laborBudgetAmount += bi.New_Item_Budget__c;
        if (bi.Indirect_Rate__c != null)
          laborIndirectCostsBudgetAmount +=
            bi.Indirect_Rate__c *
            bi.New_Item_Budget__c /
            100;
      }
      //if(bi.Indirect_Costs_Budget__c != null) laborIndirectCostsBudgetAmount += bi.Indirect_Costs_Budget__c;
    }
    getTotal();
  }

  public void getExpenseTotals() {
    expenseBudgetAmount = 0;
    expenseIndirectCostsBudgetAmount = 0;
    for (Budget_Item__c bi : expenseItem_list) {
      if (bi.New_Item_Budget__c != null) {
        expenseBudgetAmount += bi.New_Item_Budget__c;
        if (
          bi.Indirect_Rate__c != null &&
          grant.Apply_Indirect_Rate_to_Expenses__c
        ) {
          if (bi.Apply_Indirect_Rate_Cap__c)
            expenseIndirectCostsBudgetAmount +=
              bi.Indirect_Rate__c *
              bi.Amount_Allocated_for_Indirect_Cost__c /
              100;
          else
            expenseIndirectCostsBudgetAmount +=
              bi.Indirect_Rate__c *
              bi.New_Item_Budget__c /
              100;
        }
      } else if (bi.Item_Budget__c != null) {
        expenseBudgetAmount += bi.Item_Budget__c;
        if (
          bi.Indirect_Rate__c != null &&
          grant.Apply_Indirect_Rate_to_Expenses__c
        ) {
          if (bi.Apply_Indirect_Rate_Cap__c)
            expenseIndirectCostsBudgetAmount +=
              bi.Indirect_Rate__c *
              bi.Amount_Allocated_for_Indirect_Cost__c /
              100;
          else
            expenseIndirectCostsBudgetAmount +=
              bi.Indirect_Rate__c *
              bi.Item_Budget__c /
              100;
        }
      }
      //if(bi.Indirect_Costs_Budget__c != null) expenseIndirectCostsBudgetAmount += bi.Indirect_Costs_Budget__c;
    }
    for (Budget_Item__c bi : newExpenseItem_list) {
      if (bi.New_Item_Budget__c != null) {
        expenseBudgetAmount += bi.New_Item_Budget__c;
        if (
          bi.Indirect_Rate__c != null &&
          grant.Apply_Indirect_Rate_to_Expenses__c
        ) {
          if (bi.Apply_Indirect_Rate_Cap__c)
            expenseIndirectCostsBudgetAmount +=
              bi.Indirect_Rate__c *
              bi.Amount_Allocated_for_Indirect_Cost__c /
              100;
          else
            expenseIndirectCostsBudgetAmount +=
              bi.Indirect_Rate__c *
              bi.New_Item_Budget__c /
              100;
        }
      }
      //if(bi.Indirect_Costs_Budget__c != null) expenseIndirectCostsBudgetAmount += bi.Indirect_Costs_Budget__c;
    }
    getTotal();
  }
  // END getTotals

  // BEGIN save
  public void savePersonnel() {
    upsertLaborItems();
    gc.upsertGrant(grant);
    getBudgetItems();
  }

  public void saveExpenses() {
    upsertExpenseItems();
    gc.upsertGrant(grant);
    getBudgetItems();
  }

  public void upsertLaborItems() {
    updateAllLaborAmounts();
    bic.upsertItems(laborItem_list);
    bic.upsertItems(newLaborItem_list);
  }

  public void upsertExpenseItems() {
    updateAllExpenseAmounts();
    bic.upsertItems(expenseItem_list);
    bic.upsertItems(newExpenseItem_list);
  }

  public void upsertItem() {
    if (selectedItem != null) {
      List<Budget_Item__c> bi_list = new List<Budget_Item__c>();
      if (selectedItemType == 'labor')
        bi_list = laborItem_list;
      if (selectedItemType == 'newLabor')
        bi_list = newLaborItem_list;
      if (selectedItemType == 'expense')
        bi_list = expenseItem_list;
      if (selectedItemType == 'newExpense')
        bi_list = newExpenseItem_list;
      for (Budget_Item__c bi : bi_list) {
        if (selectedItemId == bi.Id) {
          bi.Item_Note__c = selectedItem.Item_Note__c;
          bi.Response__c = selectedItem.Response__c;
          if (
            (selectedItem.Item_Note__c != null &&
            selectedItem.Item_Note__c != '') ||
            (selectedItem.Response__c != null &&
            selectedItem.Response__c != '')
          ) {
            bi.Has_Notes__c = true;
          } else {
            bi.Has_Notes__c = false;
          }
        }
      }
      bic.upsertItem(selectedItem);
      system.debug('selectedItem = ' + selectedItem);
    }
    displayNotesPopup = false;
    displayLaborNotesPopup = false;
  }

  public void upsertGrant() {
    system.debug('>>> modHist = ' + modHist);
    if (modHist != '') {
      if (grant.Modification_History__c == null)
        grant.Modification_History__c = modHist;
      else
        grant.Modification_History__c += ' \r\n' + modHist;
    }
    gc.upsertGrant(grant);
    modHist = '';
  }
  // END save

  // BEGIN page actions
  public PageReference next() {
    errorMessage = '';
    upsertLaborItems();
    if (updateIndirectRate && previousRate != grant.Indirect_Rate__c)
      modHist =
        fdt +
        ': Indirect rate updated. Previous rate was ' +
        previousRate.setScale(0) +
        '%. Approved indirect costs incurred to date $' +
        grant.Reimbursement_Approved_Indirect_Costs__c +
        '.';
    upsertGrant();

    if (ApexPages.hasMessages() || errorMessage != '')
      return null;
    String url = '/BudgetExpenses?grantId=' + grantId;
    if (updateIndirectRate)
      url =
        '/BudgetExpenses?grantId=' +
        grantId +
        '&updateExpenseIndirectRate=true';
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference previous() {
    errorMessage = '';
    upsertExpenseItems();
    gc.upsertGrant(grant);
    if (ApexPages.hasMessages() || errorMessage != '')
      return null;
    PageReference pr = new PageReference('/BudgetPersonnel?grantId=' + grantId);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference review() {
    if (errorMessage == '') {
      upsertExpenseItems();
      grant.Grant_Status__c = 'Incomplete';
      upsertGrant();

      if (ApexPages.hasMessages())
        return null;
      PageReference pr = new PageReference('/BudgetDetails?grantId=' + grantId);
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference submit() {
    if (errorMessage == '') {
      modHist =
        fdt +
        ': Modification Submitted by ' +
        currentUser.Contact.Name +
        ' (' +
        currentUser.Id +
        ')';
      grant.Previous_Status__c = grant.Grant_Status__c;
      grant.Grant_Status__c = 'Pending First Approval';
      grant.Primary_Contact__c = currentUser.ContactId;
      upsertGrant();

      if (ApexPages.hasMessages())
        return null;
      PageReference pr = new PageReference('/BudgetDetails?grantId=' + grantId);
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public PageReference sendBack() {
    modHist =
      fdt +
      ': Returned for corrections by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (sendBackTo == 'affiliate') {
      grant.Grant_Status__c = 'Revisions Needed';
    } else if (
      sendBackTo == 'levelone' ||
      grant.Grant_Status__c == 'Pending Second Approval'
    ) {
      grant.Grant_Status__c = 'Pending First Approval';
    } else if (
      sendBackTo == 'leveltwo' ||
      grant.Grant_Status__c == 'Pending Third Approval'
    ) {
      grant.Grant_Status__c = 'Pending Second Approval';
      grant.Approved_Email_Sent__c = false;
    } else if (
      sendBackTo == 'levelthree' ||
      grant.Grant_Status__c == 'Pending Fourth Approval'
    ) {
      grant.Grant_Status__c = 'Pending Third Approval';
    } else {
      grant.Grant_Status__c = 'Revisions Needed';
    }
    upsertGrant();

    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference('/SubGrants');
    pr.setRedirect(true);
    return pr;
  }

  public PageReference approve() {
    modHist =
      fdt +
      ': Approved by ' +
      currentUser.Contact.Name +
      ' (' +
      currentUser.Id +
      ')';
    if (
      approverLevel == 'Level One' ||
      (approverLevel == 'Finance Admin' &&
      grant.Grant_Status__c == 'Pending First Approval')
    ) {
      if (grant.National_Grant__r.Number_of_Approvals_Required__c > 1) {
        grant.Grant_Status__c = 'Pending Second Approval';
      } else {
        grant.Grant_Status__c = 'Approved';
      }
    } else if (
      approverLevel == 'Level Two' ||
      (approverLevel == 'Finance Admin' &&
      grant.Grant_Status__c == 'Pending Second Approval')
    ) {
      if (grant.National_Grant__r.Number_of_Approvals_Required__c > 2) {
        grant.Grant_Status__c = 'Pending Third Approval';
      } else {
        grant.Grant_Status__c = 'Approved';
      }
    } else if (
      approverLevel == 'Level Three' ||
      (approverLevel == 'Finance Admin' &&
      grant.Grant_Status__c == 'Pending Third Approval')
    ) {
      if (grant.National_Grant__r.Number_of_Approvals_Required__c > 3) {
        grant.Grant_Status__c = 'Pending Fourth Approval';
      } else {
        grant.Grant_Status__c = 'Approved';
      }
    } else if (
      approverLevel == 'Finance Admin' ||
      approverLevel == 'Level Four'
    ) {
      grant.Grant_Status__c = 'Approved';
    }

    if (grant.Grant_Status__c == 'Approved') {
      grant.Approved_Email_Sent__c = false;

      for (Budget_Item__c bi : laborItem_list) {
        bi.Item_Budget__c = bi.New_Item_Budget__c;
        bi.Rate__c = bi.New_Rate__c;
        bi.Wages__c = bi.New_Wages__c;
        bi.Fringe_Benefits__c = bi.New_Fringe_Benefits__c;
      }
      bic.upsertItems(laborItem_list);

      for (Budget_Item__c bi : expenseItem_list) {
        bi.Item_Budget__c = bi.New_Item_Budget__c;
        bi.Rate__c = bi.New_Rate__c;
      }
      bic.upsertItems(expenseItem_list);
    }

    upsertGrant();
    isReviewMode = false;
    displayApprovePopup = false;

    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference('/SubGrants');
    pr.setRedirect(true);
    return pr;
  }
  // END page actions

  // BEGIN createMOU
  public void createMOU() {
    errorMessage = '';
    CreateMOUCtrl mou = new CreateMOUCtrl();
    if (grant.National_Grant_Type__c == 'OVC') {
      mou.CreateMOU(
        UserInfo.getUserEmail(),
        grant.Account__r.Signatory_Email__c,
        grant.Id,
        grant.LOA__c
      );
    } else {
      mou.CreateMOU(
        UserInfo.getUserEmail(),
        grant.CEO_Email_text__c,
        grant.Id,
        grant.LOA__c
      );
    }
    if (!ApexPages.hasMessages()) {
      sendLOASuccessful = true;
      if (portalName == 'Ripken') {
        grant.LOA_Sent__c = true;
        gc.upsertGrant(grant);
      }
    } else
      errorMessage = String.valueOf(ApexPages.getMessages());
  }
  // END createMOU

  // BEGIN sendFFATA
  public void sendFFATA() {
    errorMessage = '';
    SendSertifiDoc ssd = new SendSertifiDoc();
    ssd.SendSertifiDoc(
      'FFATA',
      UserInfo.getUserEmail(),
      grant.CEO_Email_text__c,
      null,
      grant.Id,
      'TRAIL_FFATA.pdf',
      null
    );
    if (!ApexPages.hasMessages())
      sendFFATASuccessful = true;
    else
      errorMessage = String.valueOf(ApexPages.getMessages());
  }
  // END sendFFATA

  // BEGIN updateLOASubmittedDate
  public void updateLOASubmittedDate() {
    grant.LOA_Submitted_Date__c = dt;
    gc.upsertGrant(grant);
  }
  // END updateLOASubmittedDate

  // BEGIN updateBudget
  public PageReference updateBudget() {
    grant.Grant_Status__c = 'Incomplete';
    gc.upsertGrant(grant);
    PageReference pr = new PageReference('/BudgetPersonnel?grantId=' + grantId);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference updateBudgetIndirectRate() {
    grant.Grant_Status__c = 'Incomplete';
    gc.upsertGrant(grant);
    PageReference pr = new PageReference(
      '/BudgetPersonnel?grantId=' +
      grantId +
      '&updateLaborIndirectRate=true'
    );
    pr.setRedirect(true);
    return pr;
  }
  // END updateBudget

  // BEGIN closeGrant
  public void closeGrant() {
    gc.closeGrant(grant.Id);
    displayCloseGrantPopup = false;
    getGrant();
  }

  public void reopenGrant() {
    gc.reopenGrant(grant.Id);
    getGrant();
  }
  // END closeGrant

  // BEGIN popups
  public void showNotesPopup() {
    if (selectedItemId != null) {
      selectedItem = bic.getBudgetItem(selectedItemId);
      displayNotesPopup = true;
    }
  }
  public void hideNotesPopup() {
    displayNotesPopup = false;
  }

  public void showLaborNotesPopup() {
    displayLaborNotesPopup = true;
  }
  public void hideLaborNotesPopup() {
    displayLaborNotesPopup = false;
  }

  public void showNewLaborNotesPopup() {
    displayNewLaborNotesPopup = true;
  }
  public void hideNewLaborNotesPopup() {
    displayNewLaborNotesPopup = false;
  }

  public void showNewExpenseNotesPopup() {
    displayNewExpenseNotesPopup = true;
  }
  public void hideNewExpenseNotesPopup() {
    displayNewExpenseNotesPopup = false;
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

  public void showUpdatePopup() {
    displayUpdatePopup = true;
  }
  public void hideUpdatePopup() {
    displayUpdatePopup = false;
  }

  public void showCloseGrantPopup() {
    displayCloseGrantPopup = true;
  }
  public void hideCloseGrantPopup() {
    displayCloseGrantPopup = false;
  }
  // END popups
}
