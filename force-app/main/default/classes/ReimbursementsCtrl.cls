public with sharing class ReimbursementsCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  public List<Reimbursement_Request__c> allItems { get; set; }
  public List<Reimbursement_Request__c> items { get; set; }

  private GrantClass gc = new GrantClass();
  private ReimbursementClass rc = new ReimbursementClass();
  private SelectOptionsClass soc = new SelectOptionsClass();
  private PaginationClass pc = new PaginationClass();

  public String orgName { get; set; }
  public String keyword { get; set; }
  public Id grantId { get; set; }
  public String grantStatus { get; set; }
  public List<SelectOption> grantOptions { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }
  public Boolean canEdit { get; set; }
  public Boolean showStatus { get; set; }
  public Boolean showPrimaryApprover { get; set; }
  public Boolean showApprovedAmount { get; set; }
  public Boolean viewAllLevelOne { get; set; }
  public Id primaryApproverId { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public String errorMessage { get; set; }

  public ReimbursementsCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    if (approverLevel == 'Level One')
      primaryApproverId = currentUser.ContactId;
    viewAllLevelOne = false;
    String urlViewAll = ApexPages.currentPage().getParameters().get('viewall');
    if (urlViewAll == 'true')
      viewAllLevelOne = true;
    //viewAllLevelOne = true;
    //if(approverLevel == 'Level One') viewAllLevelOne = false;

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    if (
      userAcctType == 'National Organization' &&
      urlGrantId != '' &&
      urlGrantId != null
    ) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlGrantId)
          .matches()
      ) {
        grantId = Id.valueOf(urlGrantId);
      }
    }
    String soqlAND = ' AND Grant_Status__c != \'Closed\'';
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
      '',
      soqlAND
    );
    if (grantId == null && portalName != 'BBBS')
      grantId = gc.selectedGrantId;

    grantStatus = ApexPages.currentPage().getParameters().get('grantStatus');

    status = ApexPages.currentPage().getParameters().get('status');
    if (status != null)
      status = status.capitalize();
    if (status == 'completed')
      status = 'Approved';
    if (grantStatus == 'Closed')
      status = 'View All';
    getStatusOptions();

    keyword = '';
    keyword = ApexPages.currentPage().getParameters().get('keyword');
    orgName = ApexPages.currentPage().getParameters().get('name');

    sortBy = ApexPages.currentPage().getParameters().get('sortBy');
    if (sortBy == null)
      sortBy = 'Request_Date__c';
    sortByOptions = new List<SelectOption>();
    if (userAcctType == 'National Organization')
      sortByOptions.add(new SelectOption('Organization__c', 'Organization'));
    sortByOptions.add(new SelectOption('Name', 'Request Id'));
    sortByOptions.add(new SelectOption('Request_Date__c', 'Request Date'));
    sortByOptions.add(new SelectOption('Grant__r.Name', 'Sub-Grant Name'));
    if (userAcctType == 'National Organization')
      sortByOptions.add(new SelectOption('Status__c', 'Status'));

    allItems = new List<Reimbursement_Request__c>();
    items = new List<Reimbursement_Request__c>();
    getLists();
  }

  public void getLists() {
    errorMessage = '';
    Id paId = primaryApproverId;
    if (viewAllLevelOne)
      paId = null;

    if (portalName == 'Ripken')
      showApprovedAmount = true;
    else if (
      portalName.contains('NCAI') ||
      portalName == 'STEM' ||
      portalName == 'NPAL'
    ) {
      if (
        status == 'Approved' ||
        status == 'Paid' ||
        userAcctType == 'National Organization'
      )
        showApprovedAmount = true;
    } else
      showApprovedAmount = false;

    String soqlAND = '';
    if (grantStatus != 'Closed' && userAcctType == 'Local Organization')
      soqlAND = ' AND Grant_Status__c != \'Closed\'';
    if (portalName.contains('TRAIL'))
      soqlAND += ' AND (Grant__r.Grant_Type__c = \'TRAIL\' OR Grant__r.National_Grant_Type__c = \'TRAIL\')';
    if (portalName.contains('OVC'))
      soqlAND += ' AND (Grant__r.Grant_Type__c = \'OVC\' OR Grant__r.National_Grant_Type__c = \'OVC\')';
    allItems = rc.getRelatedRequests(
      userAcct.Id,
      grantId,
      status,
      sortBy,
      orgName,
      keyword,
      paId,
      soqlAND
    );

    for (Reimbursement_Request__c r : allItems) {
      if (
        userAcctType == 'Local Organization' &&
        portalName != 'NPAL' &&
        r.Status__c.contains('Approval')
      )
        r.Status__c = 'Pending Approval';
    }
    system.debug(allItems);

    canEdit = false;
    if (
      userAcctType == 'Local Organization' &&
      (status == 'Incomplete' ||
      status == 'Revisions Needed' ||
      status == 'Revision in Progress')
    )
      canEdit = true;
    showStatus = false;
    if (
      status == '' ||
      status == null ||
      status == 'View All' ||
      status == 'All In Progress' ||
      status == 'Pending Approval' ||
      (keyword != null &&
      keyword != '')
    )
      showStatus = true;
    showPrimaryApprover = false;
    if (
      userAcctType == 'National Organization' &&
      status == 'Pending First Approval' &&
      portalName != 'NPAL'
    )
      showPrimaryApprover = true;

    totalSize = allItems.size();
    if (totalSize > 999)
      errorMessage = 'List is too large to display. Please narrow search criteria and refresh results';
    else
      first();
  }

  public void getStatusOptions() {
    statusOptions = soc.getStatusOptions(
      userAcctType,
      portalName,
      grantId,
      'reimbursement'
    );
    status = soc.getDefaultStatus(
      portalName,
      userAcctType,
      grantId,
      'reimbursement',
      approverLevel,
      status
    );
  }

  // BEGIN Pagination
  public void first() {
    counter = 0;
    items = pc.first(allItems, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = true;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void next() {
    counter = counter + limitSize;
    items = pc.next(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void previous() {
    counter = counter - limitSize;
    items = pc.previous(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = pc.getDisablePrevious(counter);
    disableNext = false;
  }

  public void last() {
    counter = pc.getLastCounter(counter, limitSize, totalSize);
    items = pc.last(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = true;
  }
  // END Pagination
}
