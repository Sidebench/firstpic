public without sharing class VictimsServedReportsCtrl {
  private UserClass userClass = new UserClass();
  private VictimsServedReportClass vsrc = new VictimsServedReportClass();
  private PaginationClass pc = new PaginationClass();
  private GetIdFromString gifs = new GetIdFromString();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public List<Victims_Served_Report__c> allReports { get; set; }
  public List<Victims_Served_Report__c> reports { get; set; }

  public String orgName { get; set; }
  public String year { get; set; }
  public String month { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public VictimsServedReportsCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    statusOptions = new List<SelectOption>();
    statusOptions.add(new SelectOption('All Reports', 'View All'));
    Schema.DescribeFieldResult fieldResult = Victims_Served_Report__c.Status__c.getDescribe();
    for (Schema.PicklistEntry f : fieldResult.getPicklistValues())
      statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
    status = 'All Reports';

    allReports = new List<Victims_Served_Report__c>();
    reports = new List<Victims_Served_Report__c>();
  }

  public void getLists() {
    String soqlAND = '';
    if (month == 'All')
      month = null;
    if (month != null)
      soqlAND += ' AND Month__c = \'' + month + '\'';
    if (year == 'All')
      year = null;
    if (year != null)
      soqlAND += ' AND Year__c = ' + Double.valueOf(year);
    if (status != null && status != 'View All' && status != 'All Reports')
      soqlAND += ' AND Status__c = \'' + status + '\'';
    allReports = vsrc.getRelatedReportList(
      userAcct.Id,
      userAcctType,
      orgName,
      soqlAND
    );
    system.debug('allReports = ' + allReports);
    totalSize = allReports.size();
    first();
  }

  // BEGIN pagination
  public void first() {
    reports.clear();
    counter = 0;
    if (limitSize <= allReports.size()) {
      for (Integer i = 0; i < limitSize; i++)
        reports.add(allReports.get(i));
    } else {
      for (Integer i = 0; i < allReports.size(); i++)
        reports.add(allReports.get(i));
    }
    getRecordCount();
    disablePrevious = true;
    getDisableNext();
  }

  public void next() {
    reports.clear();
    counter = counter + limitSize;
    if ((counter + limitSize) <= allReports.size()) {
      for (Integer i = counter - 1; i < (counter + limitSize); i++)
        reports.add(allReports.get(i));
    } else {
      for (Integer i = counter; i < allReports.size(); i++)
        reports.add(allReports.get(i));
    }
    getRecordCount();
    disablePrevious = false;
    getDisableNext();
  }

  public void previous() {
    reports.clear();
    counter = counter - limitSize;
    Integer totalSize = counter + limitSize;
    if (counter + limitSize > allReports.size())
      totalSize = allReports.size();
    else
      for (Integer i = counter; i < totalSize; i++)
        reports.add(allReports.get(i));
    getRecordCount();
    getDisablePrevious();
    disableNext = false;
  }

  public void last() {
    reports.clear();
    getLastCounter();
    for (Integer i = counter; i < allReports.size(); i++)
      reports.add(allReports.get(i));
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
