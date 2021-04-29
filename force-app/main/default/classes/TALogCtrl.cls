public with sharing class TALogCtrl {
  public UserClass userClass = new UserClass();
  private AccountClass accountClass = new AccountClass();
  private TALogClass logClass = new TALogClass();
  private getIdFromString gifs = new getIdFromString();
  private PaginationClass pc = new PaginationClass();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public Account acct { get; set; }

  public Id siteId { get; set; }
  public Account site { get; set; }

  public List<TA_Log__c> allLogs { get; set; }
  public List<TA_Log__c> logs { get; set; }
  public TA_Log__c selectedLog { get; set; }
  public Id selectedLogId { get; set; }

  public Id ta { get; set; }
  public List<SelectOption> taOptions { get; set; }
  public List<SelectOption> orgOptions { get; set; }

  public Integer limitSize { get; set; }
  public Boolean displayLimitError { get; set; }
  public Boolean followUpOnly { get; set; }
  public Boolean displayTALogPopup { get; set; }

  Integer counter = 0;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public TALogCtrl getTALogCtrl() {
    return this;
  }

  public TALogCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    acct = userClass.userAcct;
    site = new Account();

    String urlFollowUp = ApexPages.currentPage()
      .getParameters()
      .get('followup');
    if (urlFollowUp != null && urlFollowUp == 'true')
      followUpOnly = true;
    allLogs = new List<TA_Log__c>();
    logs = new List<TA_Log__c>();

    limitSize = 10;
    String pageURL = ApexPages.currentPage().getUrl();
    if (pageURL.toLowerCase().contains('talogs'))
      limitSize = 20;

    String urlTA = ApexPages.currentPage().getParameters().get('ta');
    ta = gifs.getId(urlTA);

    orgOptions = accountClass.getOrgOptions(
      userAcct.Id,
      userClass.userAcctType,
      userClass.userProfile
    );

    getSite();
    getTALogs();

    String urlLogID = ApexPages.currentPage().getParameters().get('logId');
    Id logId = gifs.getId(urlLogID);
    if (logId != null)
      getTALog();
  }

  public void getSite() {
    String urlSiteID = ApexPages.currentPage().getParameters().get('siteId');
    siteId = gifs.getId(urlSiteID);
    if (siteId != null)
      site = accountClass.getAccount(siteId);
  }

  public void getOptions() {
    taOptions = new List<SelectOption>();
    taOptions.add(new SelectOption('', 'View All'));
    Set<Id> ids = new Set<Id>();
    for (TA_Log__c i : allLogs) {
      if (i.TA_By__c != null && !ids.contains(i.TA_By__c)) {
        ids.add(i.TA_By__c);
        taOptions.add(new SelectOption(i.TA_By__c, i.TA_By_Name__c));
      }
    }
  }

  public void getTALogs() {
    logs.clear();
    String soqlAND = '';
    if (ta != null)
      soqlAND = ' AND TA_By__c = \'' + ta + '\'';
    allLogs = logClass.getTALogs(
      siteId,
      followUpOnly,
      null,
      userClass.userProfile,
      soqlAND
    );
    totalSize = allLogs.size();
    if (taOptions == null)
      getOptions();
    if (totalSize > 100)
      displayLimitError = true;
    else
      first();
  }

  public void getTALog() {
    selectedLog = logClass.getTALog(selectedLogId);
  }

  public void getOriginalTALog() {
    if (selectedLog.Original_TA_Log__c != null)
      selectedLog = logClass.getTALog(selectedLog.Original_TA_Log__c);
  }

  public void getFollowUpTALog() {
    if (selectedLog.Follow_Up_TA_Log__c != null)
      selectedLog = logClass.getTALog(selectedLog.Follow_Up_TA_Log__c);
  }

  public void upsertTALog() {
    system.debug('upsertTALog selectedLog = ' + selectedLog);
    logClass.upsertTALog(selectedLog, currentUser.ContactId);
    hideTALogPopup();
  }

  // BEGIN popups
  public void showAddTALogPopup() {
    logClass.newTALog(null, siteId);
    selectedLog = logClass.selectedLog;
    displayTALogPopup = true;
  }

  public void showTALogPopup() {
    logClass.newTALog(selectedLogId, siteId);
    selectedLog = logClass.selectedLog;
    displayTALogPopup = true;
  }

  public void showTAFollowUpPopup() {
    logClass.newTAFollowUp(selectedLogId, siteId);
    selectedLog = logClass.selectedLog;
    displayTALogPopup = true;
  }

  public void hideTALogPopup() {
    displayTALogPopup = false;
    getTALogs();
  }
  //END popups

  // BEGIN pagination
  public void first() {
    counter = 0;
    logs = pc.first(allLogs, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = true;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void next() {
    counter = counter + limitSize;
    logs = pc.next(allLogs, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void previous() {
    counter = counter - limitSize;
    logs = pc.previous(allLogs, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = pc.getDisablePrevious(counter);
    disableNext = false;
  }

  public void last() {
    counter = pc.getLastCounter(counter, limitSize, totalSize);
    logs = pc.last(allLogs, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = true;
  }
  // END pagination
}
