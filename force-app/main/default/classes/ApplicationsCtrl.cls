public with sharing class ApplicationsCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private ApplicationClass ac = new ApplicationClass();
  private PaginationClass pc = new PaginationClass();

  public List<Application__c> allApps { get; set; }
  public List<Application__c> apps { get; set; }

  public Id siteId { get; set; }
  public String siteName { get; set; }
  public String appType { get; set; }
  public List<SelectOption> appTypeOptions { get; set; }
  public String grantType { get; set; }
  public List<SelectOption> grantTypeOptions { get; set; }
  public String year { get; set; }
  public List<SelectOption> yearOptions { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }
  public Boolean viewAll { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public ApplicationsCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    approverLevel = uc.approverLevel;
    portalName = uc.userProfile;

    allApps = new List<Application__c>();
    apps = new List<Application__c>();
    viewAll = false;

    String urlSiteId = ApexPages.currentPage().getParameters().get('siteId');
    if (urlSiteId != '' && urlSiteId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlSiteId)
          .matches()
      ) {
        siteId = Id.valueOf(urlSiteId);
      }
    }
    if (siteId == null)
      siteId = userAcct.Id;

    appTypeOptions = new List<SelectOption>();
    appTypeOptions.add(new SelectOption('', 'View All'));
    appTypeOptions.add(new SelectOption('New', 'New'));
    appTypeOptions.add(new SelectOption('Existing', 'Existing'));

    grantType = ApexPages.currentPage().getParameters().get('grantType');
    grantTypeOptions = new List<SelectOption>();
    grantTypeOptions.add(new SelectOption('', 'View All'));
    if (portalName == 'Ripken') {
      grantTypeOptions.add(new SelectOption('GREAT', 'I\'m GREAT'));
      grantTypeOptions.add(
        new SelectOption('Badges for Baseball', 'Badges for Baseball')
      );
      grantTypeOptions.add(
        new SelectOption('Special Initiative', 'Special Initiative')
      );
    }
    if (portalName == 'NCAI') {
      grantTypeOptions.add(new SelectOption('TRAIL', 'TRAIL'));
      grantTypeOptions.add(new SelectOption('OVC', 'OVC'));
    }

    yearOptions = new List<SelectOption>();
    yearOptions.add(new SelectOption('', 'View All'));
    String[] years;
    if (
      userAcctType == 'National Organization' &&
      userAcct.Grant_Year_Options__c != null
    ) {
      for (String i : userAcct.Grant_Year_Options__c.split(';')) {
        yearOptions.add(new SelectOption(i, i));
      }
    } else if (userAcct.National_Grant_Year_Options__c != null) {
      for (String i : userAcct.National_Grant_Year_Options__c.split(';')) {
        yearOptions.add(new SelectOption(i, i));
      }
    }
    if (userAcct.Current_Grant_Year__c != null)
      year = userAcct.Current_Grant_Year__c;

    statusOptions = new List<SelectOption>();
    statusOptions.add(new SelectOption('', 'View All'));
    //Schema.DescribeFieldResult fieldResult = Application__c.Status__c.getDescribe();
    //for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) { statusOptions.add(new SelectOption(f.getLabel(), f.getValue())); }
    statusOptions.add(
      new SelectOption('Sent to Applicant', 'Sent to Applicant')
    );
    statusOptions.add(new SelectOption('Submitted', 'Submitted'));
    statusOptions.add(new SelectOption('Reviewed', 'Reviewed'));
    statusOptions.add(new SelectOption('Sent Back', 'Sent Back'));
    statusOptions.add(new SelectOption('Awarded', 'Awarded'));

    sortByOptions = new List<SelectOption>();
    if (portalName == 'Ripken')
      sortByOptions.add(new SelectOption('Organization__c', 'Site'));
    else
      sortByOptions.add(new SelectOption('Organization__c', 'Organization'));
    sortByOptions.add(new SelectOption('Status__c', 'Status'));
    sortByOptions.add(new SelectOption('Submitted_Date__c', 'Submitted Date'));
    if (userAcctType == 'National Organization') {
      if (!portalName.contains('NCAI'))
        sortByOptions.add(
          new SelectOption(
            'Organization__r.Program_Coordinator__c',
            'Program Coordinator'
          )
        );
      sortBy = 'Status__c';
    } else {
      sortBy = 'Grant_Year__c';
    }
    system.debug('sortByOptions = ' + sortByOptions);
  }

  public void getSOIs() {
    getLists(true);
  }

  public void getApps() {
    getLists(false);
  }

  public void getLists(Boolean isSOIList) {
    Id paId = currentUser.ContactId;
    if (
      userAcctType == 'Local Organization' ||
      viewAll ||
      approverLevel == 'Finance Admin' ||
      portalName.contains('NCAI')
    ) {
      paId = null;
    }

    String soqlAND = '';
    if (appType != null && appType != '')
      soqlAND = ' AND Type__c = \'' + appType + '\'';
    if (isSOIList)
      soqlAND += ' AND Grant_Type__c = \'SOI\'';
    else {
      if (portalName.contains('TRAIL'))
        grantType = 'TRAIL';
      else if (portalName.contains('OVC'))
        grantType = 'OVC';
      if (grantType != null && grantType != '')
        soqlAND += ' AND Grant_Type__c LIKE \'%' + grantType + '%\'';
      soqlAND += ' AND Grant_Type__c != \'SOI\'';
      if (userAcctType == 'National Organization' && year != null && year != '')
        soqlAND += ' AND Grant_Year__c = \'' + year + '\'';
    }

    allApps = ac.getRelatedApplicationList(
      siteId,
      siteName,
      status,
      soqlAND,
      sortBy,
      paId
    );
    totalSize = allApps.size();
    system.debug('allApps = ' + allApps);
    first();
  }

  // BEGIN pagination
  public void first() {
    counter = 0;
    apps = pc.first(allApps, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = true;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void next() {
    counter = counter + limitSize;
    apps = pc.next(allApps, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void previous() {
    counter = counter - limitSize;
    apps = pc.previous(allApps, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = pc.getDisablePrevious(counter);
    disableNext = false;
  }

  public void last() {
    counter = pc.getLastCounter(counter, limitSize, totalSize);
    apps = pc.last(allApps, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = true;
  }
  // END pagination
}
