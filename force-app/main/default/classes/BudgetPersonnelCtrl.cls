public with sharing class BudgetPersonnelCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  public GrantClass grantClass = new GrantClass();
  public BudgetItemClass bic = new BudgetItemClass();

  public Account acct { get; set; }
  public ID GrantId { get; set; }
  public Grant__c grant { get; set; }
  public Boolean isNationalSubGrant { get; set; }
  public Id laborId { get; set; }
  public Decimal duration { get; set; }
  public Decimal durationWks { get; set; }
  public Decimal laborRequestedAmount { get; set; }
  public Decimal expenseRequestedAmount { get; set; }
  public Decimal totalRequestedAmount { get; set; }
  public Decimal totalHours = 0;
  public Decimal grantHours = 0;

  public String errorMessage { get; set; }
  public Boolean amountError { get; set; }
  public Boolean displayPopupBg { get; set; }
  public Boolean displayRatePopup { get; set; }
  public Boolean displayLaborNotesPopup { get; set; }
  public Boolean displayNewLaborNotesPopup { get; set; }

  public List<Budget_Item__c> labor_list { get; set; }
  public List<Budget_Item__c> newLabor_list { get; set; }
  public Id selectedItemId { get; set; }
  public Budget_Item__c selectedItem { get; set; }
  public Integer laborCount = 0;
  public Integer newLaborCount = 0;

  public Boolean hasReimbursements { get; set; }
  public List<SelectOption> options { get; set; }
  public String bulkAction { get; set; }
  public List<Budget_Item__c> active_list { get; set; }
  public List<Budget_Item__c> delete_list { get; set; }

  Decimal daysInYear = 365;
  Decimal weeksInYear;

  // BEGIN Constructor
  public BudgetPersonnelCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;

    GrantId = ApexPages.currentPage().getParameters().get('GrantId');
    laborId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
      .get('Labor')
      .getRecordTypeId();

    acct = new Account();
    grant = new Grant__c();

    laborRequestedAmount = 0;
    totalRequestedAmount = 0;
    errorMessage = '';
    amountError = false;
    isNationalSubGrant = false;
    displayPopupBg = false;
    displayRatePopup = false;
    displayLaborNotesPopup = false;
    displayNewLaborNotesPopup = false;

    labor_list = new List<Budget_Item__c>();
    newLabor_list = new List<Budget_Item__c>();
    active_list = new List<Budget_Item__c>();
    delete_list = new List<Budget_Item__c>();
    selectedItem = new Budget_Item__c();

    options = new List<SelectOption>();
    options.add(new SelectOption('', 'Select an Action'));
    options.add(new SelectOption('delete', 'Delete'));
    options.add(new SelectOption('disable', 'Mark Inactive'));

    if (GrantID != null) {
      grant = grantClass.getGrant(GrantId);
      acct = [
        SELECT ID, Name, RecordType.Name
        FROM Account
        WHERE ID = :grant.Account__r.Id
      ];
      duration = grant.Grant_Duration__c;
      if (duration != null) {
        durationWks = (grant.Grant_Duration__c / 7).setScale(2);
      }
      if (
        userAcctType == 'National Organization' &&
        grant.Account__r.Id == userAcct.Id
      ) {
        isNationalSubGrant = true;
      }

      if (grant.Number_of_Reimbursements__c > 0)
        hasReimbursements = true;

      Integer year = date.today().year();
      if (grant.Year__c != null)
        year = Integer.valueOf(grant.Year__c);
      else if (grant.National_Grant__r.Year__c != null)
        year = Integer.valueOf(grant.National_Grant__r.Year__c);
      if (Date.isLeapYear(year))
        daysInYear = 366;
      weeksInYear = (daysInYear / 7).setScale(8);
    }
  }
  // END Constructor

  public void getLists() {
    labor_list.clear();
    totalRequestedAmount = 0;

    for (Budget_Item__c bi : bic.getBudgetItems(GrantId)) {
      if (bi.Item_Note__c != null || bi.Response__c != null)
        bi.Has_Notes__c = true;
      if (bi.RecordType.Name == 'Labor') {
        if (bi.Start_Date__c == null && bi.Effective_Date__c != null)
          bi.Start_Date__c = bi.Effective_Date__c;
        else if (bi.Start_Date__c == null && grant.Grant_Start_Date__c != null)
          bi.Start_Date__c = grant.Grant_Start_Date__c;
        if (bi.End_Date__c == null)
          bi.End_Date__c = grant.Grant_End_Date__c;
        Decimal d = bi.Start_Date__c.daysBetween(bi.End_Date__c) + 1;
        bi.Number_of_Weeks_on_Grant_Long__c = d / 7;
        bi.Selected__c = false;
        if (bi.New_Rate__c == null) {
          if (bi.Is_Hourly__c && bi.Hourly_Rate__c != null)
            bi.New_Rate__c = bi.Hourly_Rate__c.setScale(2);
          if (bi.Is_Hourly__c == false && bi.Salary__c != null)
            bi.New_Rate__c = bi.Salary__c.setScale(2);
        }
        if (bi.New_Item_Budget__c == null && bi.Item_Budget__c != null)
          bi.New_Item_Budget__c = bi.Item_Budget__c;
        if (
          (bi.Previous_Hourly_Rate__c == null ||
          bi.Previous_Hourly_Rate__c == 0) && bi.Hourly_Rate__c != null
        )
          bi.Previous_Hourly_Rate__c = bi.Hourly_Rate__c;
        if (
          bi.Previous_Grant_Hours_Per_Week__c == null &&
          bi.Projected_Grant_Hours_Per_Week__c != null
        )
          bi.Previous_Grant_Hours_Per_Week__c = bi.Projected_Grant_Hours_Per_Week__c;
        if (
          bi.Previous_Percent_Time_on_Grant__c == null &&
          bi.Projected_Percent_Time_on_Grant__c != null
        )
          bi.Previous_Percent_Time_on_Grant__c = bi.Projected_Percent_Time_on_Grant__c;
        if (bi.New_Wages__c == null && bi.Wages__c != null)
          bi.New_Wages__c = bi.Wages__c;
        if (
          bi.Previous_Fringe_Benefits__c == null &&
          bi.Fringe_Benefits__c != null
        )
          bi.Previous_Fringe_Benefits__c = bi.Fringe_Benefits__c;
        if (
          bi.New_Fringe_Benefits__c == null &&
          bi.Fringe_Benefits__c != null &&
          bi.Is_Active__c
        )
          bi.New_Fringe_Benefits__c = bi.Fringe_Benefits__c;

        laborCount += 1;
        labor_list.add(bi);
      }
    }
    if (expenseRequestedAmount == null)
      getExpenses();
    //totalRequestedAmount = expenseRequestedAmount;
    //totalRequestedAmount += laborRequestedAmount;
    //if(grant.Amount__c != null && totalRequestedAmount.setScale(2) > grant.Amount__c) amountError = true;
    updateAmounts();
  }

  public void getExpenses() {
    expenseRequestedAmount = 0;
    for (Budget_Item__c bi : bic.getBudgetItems(GrantId)) {
      if (bi.RecordType.Name == 'Expense') {
        if (bi.New_Item_Budget__c != null)
          expenseRequestedAmount += bi.New_Item_Budget__c;
        else if (bi.Item_Budget__c != null)
          expenseRequestedAmount += bi.Item_Budget__c;
      }
    }
  }

  // BEGIN updateAmounts
  public void updateAmounts() {
    laborRequestedAmount = 0;
    totalRequestedAmount = 0;
    totalHours = 0;
    grantHours = 0;
    errorMessage = '';

    if (
      grant.Youth_Served_with_Grant_Funding__c > 0 &&
      grant.Youth_Served__c > 0
    ) {
      grant.Youth_Served_Percent__c = (grant.Youth_Served_with_Grant_Funding__c /
        grant.Youth_Served__c *
        100)
        .setScale(1);
    }
    if (grant.Youth_Served_Percent__c > 100) {
      errorMessage = 'The projected # of children served with grant funding during the Grant performance period should not exceed the total # of children served.';
    }
    for (Budget_Item__c bi : labor_list) {
      itemCalc(bi);
    }
    for (Budget_Item__c bi : newLabor_list) {
      itemCalc(bi);
    }
    if (
      grantHours != 0 &&
      totalHours != 0 &&
      grant.FTE_at_Affiliate__c != null &&
      grant.FTE_at_Affiliate__c != 0
    ) {
      grant.Estimated_FTE__c = (grantHours /
        (grant.FTE_at_Affiliate__c * 40) *
        100)
        .setScale(1);
    }

    if (expenseRequestedAmount > 0)
      totalRequestedAmount = expenseRequestedAmount;
    totalRequestedAmount += laborRequestedAmount;
    if (
      grant.Amount__c != null &&
      totalRequestedAmount.setScale(2) > grant.Amount__c
    ) {
      amountError = true;
      // errorMessage = 'Requested Amount Exceeds Sub-Grant Amount';
    } else {
      amountError = false;
    }
  }

  public void itemCalc(Budget_Item__c bi) {
    if (bi.Start_Date__c == null)
      bi.Start_Date__c = grant.Grant_Start_Date__c;
    if (bi.End_Date__c == null)
      bi.End_Date__c = grant.Grant_End_Date__c;
    if (bi.Start_Date__c == null || bi.End_Date__c == null) {
      errorMessage = 'Please enter a Start and End Date for ' + bi.Name;
      return;
    }
    Decimal d = bi.Start_Date__c.daysBetween(bi.End_Date__c) + 1;
    bi.Number_of_Weeks_on_Grant_Long__c = (d / 7).setScale(8);
    if (bi.Start_Date__c < grant.Grant_Start_Date__c)
      errorMessage =
        'The Start Date for ' +
        bi.Name +
        ' must not be before the Grant Start Date.';
    if (bi.End_Date__c > grant.Grant_End_Date__c)
      errorMessage =
        'The End Date for ' +
        bi.Name +
        ' must not be after the Grant End Date.';

    if (bi.Is_Active__c == false) {
      if (portalName == 'NPAL') {
        if (bi.Total_Approved_Salary__c != null) {
          bi.New_Wages__c = bi.Total_Approved_Salary__c;
          bi.New_Fringe_Benefits__c = bi.Total_Approved_Benefits__c;
        }
        if (bi.Total_Approved_Amount__c != null) {
          laborRequestedAmount += bi.Total_Approved_Amount__c;
        }
      } else if (portalName == 'DMV') {
        if (bi.Total_Approved_Salary__c != null) {
          bi.Wages__c = bi.Total_Approved_Salary__c;
          bi.Fringe_Benefits__c = bi.Total_Approved_Benefits__c;
        }
        if (bi.Total_Approved_Amount__c != null) {
          laborRequestedAmount += bi.Total_Approved_Amount__c;
        }
      } else {
        if (bi.Total_Approved_Salary__c != null) {
          bi.New_Item_Budget__c = bi.Total_Approved_Salary__c;
          bi.New_Fringe_Benefits__c = bi.Total_Approved_Benefits__c;
          laborRequestedAmount += (bi.New_Item_Budget__c +
          bi.New_Fringe_Benefits__c);
        }
      }
    } else {
      if (bi.New_Wages__c == null) {
        bi.New_Wages__c = 0;
      }
      if (bi.New_Rate__c != null) {
        if (bi.Is_Hourly__c)
          bi.Hourly_Rate__c = bi.New_Rate__c.setScale(2);
        else
          bi.Salary__c = bi.New_Rate__c.setScale(2);
      }
      if (
        bi.Projected_Hours_Per_Week__c == 0 ||
        bi.Projected_Hours_Per_Week__c == null ||
        bi.Projected_Grant_Hours_Per_Week__c == 0 ||
        bi.Projected_Grant_Hours_Per_Week__c == null
      ) {
        bi.Projected_Percent_Time_on_Grant__c = 0;
        bi.New_Wages__c = 0;
        bi.New_Item_Budget__c = 0;
        bi.New_Fringe_Benefits__c = 0;
        if (portalName == 'BBBS')
          bi.FICA__c = 0;
      } else {
        if (bi.Salary__c != null && bi.Is_Hourly__c == false)
          bi.Hourly_Rate__c = (bi.New_Rate__c /
          (bi.Projected_Hours_Per_Week__c * weeksInYear));
        bi.Projected_Percent_Time_on_Grant__c = (bi.Projected_Grant_Hours_Per_Week__c /
          bi.Projected_Hours_Per_Week__c *
          100)
          .setScale(1);
        if (bi.Projected_Percent_Time_on_Grant__c > 100)
          errorMessage = 'The hours worked on grant should not exceed total number of hours worked';

        Decimal fb = 0;
        bi.New_Fringe_Benefits__c = 0;
        if ((portalName == 'NPAL' || portalName == 'DMV') && bi.FICA__c != null)
          fb += bi.FICA__c;
        if (bi.Medical__c != null)
          fb += bi.Medical__c;
        if (bi.Dental__c != null)
          fb += bi.Dental__c;
        if (bi.Short_Term_Disability__c != null)
          fb += bi.Short_Term_Disability__c;
        if (bi.Long_Term_Disability__c != null)
          fb += bi.Long_Term_Disability__c;
        if (bi.Life__c != null)
          fb += bi.Life__c;
        if (bi.Other_Benefits__c != null)
          fb += bi.Other_Benefits__c;

        if (bi.Hourly_Rate__c != null) {
          if (portalName == 'NPAL' || portalName == 'DMV') {
            bi.New_Wages__c = (bi.Hourly_Rate__c *
              bi.Projected_Grant_Hours_Per_Week__c *
              bi.Number_of_Weeks_on_Grant_Long__c)
              .setScale(2);
            bi.New_Item_Budget__c = bi.New_Wages__c;
          } else {
            bi.New_Item_Budget__c = (bi.Hourly_Rate__c *
              bi.Projected_Grant_Hours_Per_Week__c *
              bi.Number_of_Weeks_on_Grant_Long__c)
              .setScale(2);
          }

          if (fb > 0) {
            bi.New_Fringe_Benefits__c =
              (fb / daysInYear) *
              (bi.Number_of_Weeks_on_Grant_Long__c * 7) *
              (bi.Projected_Percent_Time_on_Grant__c / 100);
            system.debug(daysInYear);
            system.debug(bi.New_Fringe_Benefits__c);
            if (portalName == 'NPAL')
              bi.New_Item_Budget__c += bi.New_Fringe_Benefits__c;
          } else {
            bi.New_Fringe_Benefits__c = 0;
          }
          if (portalName != 'NPAL' && bi.New_Item_Budget__c != null) {
            bi.FICA__c = (bi.New_Item_Budget__c * .0765).setScale(2);
            bi.New_Fringe_Benefits__c += bi.FICA__c;
          }
          bi.New_Fringe_Benefits__c = bi.New_Fringe_Benefits__c.setScale(2);

          if (portalName == 'NPAL') {
            laborRequestedAmount += bi.New_Wages__c;
          } else if (portalName == 'DMV') {
            bi.Wages__c = bi.New_Wages__c;
            bi.Item_Budget__c = bi.New_Wages__c;
            bi.Fringe_Benefits__c = bi.New_Fringe_Benefits__c;
            laborRequestedAmount += bi.New_Wages__c;
          } else {
            laborRequestedAmount += bi.New_Item_Budget__c;
          }
          laborRequestedAmount += bi.New_Fringe_Benefits__c;
          totalHours += bi.Projected_Hours_Per_Week__c;
          grantHours += bi.Projected_Grant_Hours_Per_Week__c;
        }
      }
    }
  }
  // END updateAmounts

  // BEGIN updateSelected
  public void updateSelected() {
    system.debug('bulkAction = ' + bulkAction);
    if (bulkAction != '' && bulkAction != null) {
      for (Budget_Item__c bi : labor_list) {
        if (bi.Selected__c) {
          system.debug('bi = ' + bi);
          if (bulkAction.toLowerCase() == 'disable') {
            bi.Is_Active__c = false;
            if (bi.Total_Approved_Salary__c != null) {
              if (portalName == 'NPAL' || portalName == 'DMV')
                bi.New_Wages__c = bi.Total_Approved_Salary__c;
              else
                bi.New_Item_Budget__c = bi.Total_Approved_Salary__c;
            } else {
              bi.New_Item_Budget__c = 0;
            }
            if (bi.Total_Approved_Benefits__c != null)
              bi.New_Fringe_Benefits__c = bi.Total_Approved_Benefits__c;
            else
              bi.New_Fringe_Benefits__c = 0;
            active_list.add(bi);
          }
          if (bulkAction.toLowerCase() == 'enable') {
            bi.Is_Active__c = true;
            active_list.add(bi);
          }
          if (bulkAction.toLowerCase() == 'delete') {
            if (bi.Total_Approved_Amount__c > 0)
              errorMessage = 'Item cannot be deleted';
            else
              delete_list.add(bi);
          }
        }
        bi.Selected__c = false;
      }
    }
    if (delete_list.size() > 0) {
      bic.deleteItems(delete_list);
      getLists();
    }
    bulkAction = '';
    updateAmounts();
  }
  // END updateSelected

  // BEGIN saveLabor
  public void saveLabor() {
    updateAmounts();
    grantClass.upsertGrant(grant);

    if (active_list.size() > 0) {
      bic.upsertItems(active_list);
    }

    for (Budget_Item__c bi : labor_list) {
      if (bi.Item_Budget__c != null && bi.New_Item_Budget__c != null) {
        if (
          bi.Item_Budget__c.round(System.RoundingMode.CEILING) ==
          bi.New_Item_Budget__c.round(System.RoundingMode.CEILING)
        ) {
          bi.New_Item_Budget__c = null;
        }
      }
      if (bi.Wages__c != null && bi.New_Wages__c != null) {
        if (
          bi.Wages__c.round(System.RoundingMode.CEILING) ==
          bi.New_Wages__c.round(System.RoundingMode.CEILING)
        ) {
          bi.New_Wages__c = null;
        }
      }
      if (bi.Fringe_Benefits__c != null && bi.New_Fringe_Benefits__c != null) {
        if (
          bi.Fringe_Benefits__c.round(System.RoundingMode.CEILING) ==
          bi.New_Fringe_Benefits__c.round(System.RoundingMode.CEILING)
        ) {
          bi.New_Fringe_Benefits__c = null;
        }
      }
      if (portalName == 'DMV' && bi.New_Wages__c != null) {
        bi.Wages__c = bi.New_Wages__c;
      }
    }
    bic.upsertItems(labor_list);
    system.debug('>>> labor_list = ' + labor_list);
    bic.upsertItems(newLabor_list);
    system.debug('>>> newLabor_list = ' + newLabor_list);
  }
  // END saveLabor

  // BEGIN saveAndContinue
  public PageReference saveAndContinue() {
    displayPopupBg = false;
    displayRatePopup = false;
    saveLabor();

    if (
      !isNationalSubGrant &&
      (grant.Youth_Served__c == null ||
      grant.Youth_Served__c == 0)
    ) {
      errorMessage = 'Projected # of children served during the Grant performance period must be greater than zero.';
    }
    if (portalName != 'NPAL' && portalName != 'DMV') {
      if (
        !isNationalSubGrant &&
        (grant.Youth_Served_with_Grant_Funding__c == null ||
        grant.Youth_Served_with_Grant_Funding__c == 0)
      ) {
        errorMessage = 'Projected # of children served with grant funding must be greater than zero.';
      }
      if (grant.FTE_at_Affiliate__c == null || grant.FTE_at_Affiliate__c == 0) {
        //errorMessage = 'Number of Full Time Equivalent staff at Affiliate must be greater than zero.';
      }
    }

    if (errorMessage == '') {
      PageReference pr = new PageReference(
        '/' +
        portalName +
        'BudgetExpenses?GrantID=' +
        GrantID
      );
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }
  // END saveAndContinue

  // BEGIN saveAndExit
  public PageReference saveAndExit() {
    saveLabor();

    String pn = portalName;
    if (portalName == 'BBBS')
      pn = '';
    PageReference pr = new PageReference(
      '/' +
      pn +
      'SubGrantDetails?GrantID=' +
      GrantID
    );
    pr.setRedirect(true);
    return pr;
  }
  // END saveAndExit

  // BEGIN addItem
  public void addItem() {
    Budget_Item__c bi = new Budget_Item__c();
    bi.Grant__c = grant.Id;
    bi.RecordTypeId = laborId;
    bi.Category__c = 'Personnel';
    bi.Is_Active__c = true;
    bi.Selected__c = false;
    bi.Number_of_Weeks_on_Grant_Long__c = durationWks;
    bi.Start_Date__c = grant.Grant_Start_Date__c;
    bi.End_Date__c = grant.Grant_End_Date__c;
    newLabor_list.add(bi);
  }
  // END addItem

  // BEGIN delete
  public void deleteItems() {
    List<Budget_Item__c> delete_list = new List<Budget_Item__c>();
    Integer i = 0;
    while (i < newLabor_list.size()) {
      if (newLabor_list.get(i).Selected__c) {
        delete_list.add(newLabor_list.get(i));
        newLabor_list.remove(i);
      } else {
        i++;
      }
    }
    bic.deleteItems(delete_list);

    newLaborCount = 0;
    for (Budget_Item__c bi : newLabor_list) {
      newLaborCount++;
    }
  }
  // END delete

  // BEGIN upsertItem
  public void upsertItem() {
    if (selectedItem != null) {
      for (Budget_Item__c bi : labor_list) {
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
    hideLaborNotesPopup();
  }
  // END upsertItem

  public void ratePopup() {
    if (displayRatePopup == true)
      displayRatePopup = false;
    else
      displayRatePopup = true;
  }

  public void laborNotesPopup() {
    if (displayLaborNotesPopup == true) {
      displayLaborNotesPopup = false;
      //bic.upsertItem(selectedItem);
    } else {
      if (selectedItemId != null) {
        selectedItem = bic.getBudgetItem(selectedItemId);
        displayLaborNotesPopup = true;
      }
    }
  }
  public void showLaborNotesPopup() {
    if (selectedItemId != null) {
      selectedItem = bic.getBudgetItem(selectedItemId);
      displayLaborNotesPopup = true;
    }
  }
  public void hideLaborNotesPopup() {
    displayLaborNotesPopup = false;
  }

  public void newLaborNotesPopup() {
    if (displayNewLaborNotesPopup == true)
      displayNewLaborNotesPopup = false;
    else
      displayNewLaborNotesPopup = true;
  }
}
