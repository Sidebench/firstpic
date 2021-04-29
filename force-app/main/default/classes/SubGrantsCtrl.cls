public with sharing class SubGrantsCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }
  public String approverLevel { get; set; }

  private GrantClass gc = new GrantClass();
  private SelectOptionsClass soc = new SelectOptionsClass();
  private PaginationClass pc = new PaginationClass();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public List<Grant__c> allsubgrants { get; set; }
  public List<Grant__c> subgrants { get; set; }

  public String orgName { get; set; }
  public String grantName { get; set; }
  public Id grantId { get; set; }
  public List<SelectOption> grantOptions { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }
  public String sourceType { get; set; }
  public List<SelectOption> sourceTypeOptions { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }
  public Boolean displayStatus { get; set; }
  public Boolean viewAll { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public String errorMessage { get; set; }

  public SubGrantsCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    allsubgrants = new List<Grant__c>();
    subgrants = new List<Grant__c>();
    sourceType = '';

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

    status = ApexPages.currentPage().getParameters().get('status');
    if (status != null)
      status = status.capitalize();
    if (status == 'completed')
      status = 'Approved';

    grantName = ApexPages.currentPage().getParameters().get('grantName');
    sortBy = ApexPages.currentPage().getParameters().get('sortBy');
    if (sortBy != null)
      sortBy = 'Name';

    viewAll = true;
    if (approverLevel == 'Level One')
      viewAll = false;
  }

  public void getOptions() {
    String gt = 'grant';
    String soqlAND = '';
    if (userAcctType == 'Local Organization') {
      gt = 'subgrant';
      soqlAND = ' AND Grant_Status__c != \'Closed\'';
    }
    if (portalName.contains('TRAIL'))
      soqlAND += ' AND (Grant_Type__c = \'TRAIL\' OR National_Grant_Type__c = \'TRAIL\')';
    if (portalName.contains('OVC'))
      soqlAND += ' AND (Grant_Type__c = \'OVC\' OR National_Grant_Type__c = \'OVC\')';

    grantOptions = gc.getGrantOptions(
      userAcctType,
      userAcct.Id,
      null,
      'Name',
      '',
      gt,
      soqlAND
    );
    if (grantId == null)
      grantId = gc.selectedGrantId;

    sourceType = '';
    sourceTypeOptions = new List<SelectOption>();
    sourceTypeOptions = spf.getPicklistOptions(
      'Grant__c',
      'Source_Type_Options__c',
      'View All'
    );

    sortByOptions = new List<SelectOption>();
    if (userAcctType == 'National Organization')
      sortByOptions.add(new SelectOption('Account__r.Name', 'Organization'));
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
    if (userAcctType == 'National Organization')
      sortByOptions.add(new SelectOption('Grant_Status__c', 'Status'));
    if (sortBy == null)
      sortBy = 'Name';

    getStatusOptions();
    getLists();
  }

  public void getStatusOptions() {
    statusOptions = soc.getStatusOptions(
      userAcctType,
      portalName,
      grantId,
      'grant'
    );
    status = soc.getDefaultStatus(
      portalName,
      userAcctType,
      grantId,
      'grant',
      approverLevel,
      status
    );
  }

  public void getLists() {
    errorMessage = '';
    String soqlAND = '';
    if (userAcctType == 'Local Organization') {
      soqlAND += '';
      if (status != 'Closed') {
        soqlAND += ' AND Grant_Status__c != \'Closed\'';
      }
    }
    if (sourceType != '' && sourceType != 'View All')
      soqlAND += ' AND Source_Type__c LIKE \'%' + sourceType + '%\'';
    if (userAcctType == 'National Organization' && viewAll == false) {
      soqlAND +=
        ' AND (Primary_Approver_Id__c = \'' +
        currentUser.ContactId +
        '\'';
      soqlAND +=
        ' OR (Secondary_Approver_Id__c = \'' +
        currentUser.ContactId +
        '\'';
      soqlAND += ' AND (Primary_Approver_On_Leave__c = true OR FirstPic_National_Org_Code__c = \'Ripken\')))';
    }
    if (portalName.contains('TRAIL'))
      soqlAND += ' AND (Grant_Type__c = \'TRAIL\' OR National_Grant_Type__c = \'TRAIL\')';
    if (portalName.contains('OVC'))
      soqlAND += ' AND (Grant_Type__c = \'OVC\' OR National_Grant_Type__c = \'OVC\')';
    allSubGrants = gc.getRelatedSubGrants(
      userAcct.Id,
      grantId,
      status,
      sortBy,
      orgName,
      grantName,
      soqlAND
    );

    displayStatus = false;
    if (
      status == null ||
      status == '' ||
      status == 'View All' ||
      status == 'All In Progress' ||
      status == 'Pending Approval' ||
      (grantName != '' &&
      grantName != null)
    )
      displayStatus = true;

    totalSize = allsubgrants.size();
    if (totalSize > 999)
      errorMessage =
        'List of ' +
        totalSize +
        ' results is too large to display. Please narrow search criteria and refresh results';
    else
      first();
  }

  // BEGIN Pagination
  public void first() {
    counter = 0;
    subgrants = pc.first(allsubgrants, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = true;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void next() {
    counter = counter + limitSize;
    subgrants = pc.next(allsubgrants, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void previous() {
    counter = counter - limitSize;
    subgrants = pc.previous(allsubgrants, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = pc.getDisablePrevious(counter);
    disableNext = false;
  }

  public void last() {
    counter = pc.getLastCounter(counter, limitSize, totalSize);
    subgrants = pc.last(allsubgrants, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = true;
  }
  // END Pagination
}
