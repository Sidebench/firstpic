public with sharing class ProgramPlansCtrl {
  private UserClass userClass = new UserClass();
  private ProgramPlanClass ppc = new ProgramPlanClass();
  private PaginationClass pc = new PaginationClass();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public List<Program_Plan__c> allItems { get; set; }
  public List<Program_Plan__c> items { get; set; }

  public String orgName { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public ProgramPlansCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    sortByOptions = new List<SelectOption>();
    sortByOptions.add(new SelectOption('Organization_Name__c', 'Organization'));
    sortByOptions.add(new SelectOption('Status__c', 'Status'));
    sortByOptions.add(new SelectOption('Submitted_Date__c', 'Submitted Date'));
    sortBy = 'Submitted_Date__c';

    allItems = new List<Program_Plan__c>();
    items = new List<Program_Plan__c>();
  }

  public void getLists() {
    String soqlAND = '';
    if (sortBy != '' && sortBy != null)
      soqlAND += ' ORDER BY ' + sortBy + ' DESC';
    allItems = ppc.getRelatedPlans(userAcct.Id, userAcctType, orgName, soqlAND);
    system.debug('allItems = ' + allItems);
    totalSize = allItems.size();
    first();
  }

  // BEGIN pagination
  public void first() {
    items.clear();
    counter = 0;
    if (limitSize <= allItems.size()) {
      for (Integer i = 0; i < limitSize; i++)
        items.add(allItems.get(i));
    } else {
      for (Integer i = 0; i < allItems.size(); i++)
        items.add(allItems.get(i));
    }
    getRecordCount();
    disablePrevious = true;
    getDisableNext();
  }

  public void next() {
    items.clear();
    counter = counter + limitSize;
    if ((counter + limitSize) <= allItems.size()) {
      for (Integer i = counter - 1; i < (counter + limitSize); i++)
        items.add(allItems.get(i));
    } else {
      for (Integer i = counter; i < allItems.size(); i++)
        items.add(allItems.get(i));
    }
    getRecordCount();
    disablePrevious = false;
    getDisableNext();
  }

  public void previous() {
    items.clear();
    counter = counter - limitSize;
    Integer totalSize = counter + limitSize;
    if (counter + limitSize > allItems.size())
      totalSize = allItems.size();
    else
      for (Integer i = counter; i < totalSize; i++)
        items.add(allItems.get(i));
    getRecordCount();
    getDisablePrevious();
    disableNext = false;
  }

  public void last() {
    items.clear();
    getLastCounter();
    for (Integer i = counter; i < allItems.size(); i++)
      items.add(allItems.get(i));
    getRecordCount();
    disablePrevious = false;
    disableNext = true;
  }

  public void getLastCounter() {
    if (math.mod(totalSize, limitSize) == 0) {
      counter = limitSize * ((totalSize / limitSize) - 1);
    } else if (math.mod(totalSize, limitSize) != 0) {
      counter = limitSize * ((totalSize / limitSize));
    }
    if (totalSize == 0)
      counter = 0;
  }

  public void getRecordCount() {
    recordCount = '';
    if (totalSize != 0) {
      recordCount += (counter + 1) + ' - ';
      if ((counter + limitSize) <= totalSize)
        recordCount += counter + limitSize;
      else
        recordCount += totalSize;
      recordCount += ' of ' + totalSize;
    }
  }

  public void getDisableNext() {
    if ((counter + limitSize) >= totalSize)
      disableNext = true;
    else
      disableNext = false;
  }

  public void getDisablePrevious() {
    if (counter == 0)
      disablePrevious = true;
    else
      disablePrevious = false;
  }
  // END pagination
}
