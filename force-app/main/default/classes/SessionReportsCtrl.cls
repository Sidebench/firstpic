public without sharing class SessionReportsCtrl {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  private SessionReportClass src = new SessionReportClass();
  private PaginationClass pc = new PaginationClass();
  private GetIdFromString gifs = new GetIdFromString();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public Id siteId { get; set; }
  public List<innerClass> allReports { get; set; }
  public List<innerClass> reports { get; set; }

  public String orgName { get; set; }
  public String reportName { get; set; }
  public String year { get; set; }
  public List<SelectOption> yearOptions { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public SessionReportsCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    siteId = null;
    if (userAcctType == 'Site')
      siteId = userAcct.Id;

    yearOptions = spf.getPicklistOptions('Session_Report__c', 'Year__c', null);
    if (year == null)
      year = String.valueOf(date.today().year());

    statusOptions = new List<SelectOption>();
    statusOptions.add(new SelectOption('All Reports', 'View All'));
    Schema.DescribeFieldResult fieldResult = Session_Report__c.Status__c.getDescribe();
    for (Schema.PicklistEntry f : fieldResult.getPicklistValues())
      statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
    status = 'All Reports';

    allReports = new List<innerClass>();
    reports = new List<innerClass>();
  }

  public void getLists() {
    allReports.clear();

    Map<Id, Session_Report__c> report_map = new Map<Id, Session_Report__c>();
    Map<Id, Id> q1 = new Map<Id, Id>();
    Map<Id, String> q1s = new Map<Id, String>();
    Map<Id, Id> q2 = new Map<Id, Id>();
    Map<Id, String> q2s = new Map<Id, String>();
    Map<Id, Id> q3 = new Map<Id, Id>();
    Map<Id, String> q3s = new Map<Id, String>();
    Map<Id, Id> q4 = new Map<Id, Id>();
    Map<Id, String> q4s = new Map<Id, String>();

    String sortBy = '';
    if (userAcctType == 'National Organization')
      sortBy = 'Local_Organization_Name__c';
    else if (userAcctType == 'Local Organization')
      sortBy = 'Site_Name__c';
    else
      sortBy = 'Site_Name__c';

    String soqlAND = '';
    soqlAND += ' AND Year__c = \'' + year + '\'';

    for (
      Session_Report__c i : src.getRelatedReportList(
        userAcct.Id,
        siteId,
        userAcctType,
        orgName,
        reportName,
        status,
        sortBy,
        soqlAND
      )
    ) {
      report_map.put(i.Site_Id__c, i);
      if (i.Reporting_Period__c != null) {
        if (i.Reporting_Period__c.contains('Q1')) {
          q1.put(i.Site_Id__c, i.Id);
          q1s.put(i.Site_Id__c, i.Status__c);
        } else if (i.Reporting_Period__c.contains('Q2')) {
          q2.put(i.Site_Id__c, i.Id);
          q2s.put(i.Site_Id__c, i.Status__c);
        } else if (i.Reporting_Period__c.contains('Q3')) {
          q3.put(i.Site_Id__c, i.Id);
          q3s.put(i.Site_Id__c, i.Status__c);
        } else {
          q4.put(i.Site_Id__c, i.Id);
          q4s.put(i.Site_Id__c, i.Status__c);
        }
      }
    }
    for (Id i : report_map.keyset()) {
      innerClass ic = new innerClass(
        report_map.get(i).Local_Organization_Name__c,
        report_map.get(i).Site_Name__c,
        q1.get(i),
        q1s.get(i),
        q2.get(i),
        q2s.get(i),
        q3.get(i),
        q3s.get(i),
        q4.get(i),
        q4s.get(i)
      );
      allReports.add(ic);
    }
    totalSize = allReports.size();
    first();
  }

  // BEGIN Inner Class
  public class innerClass {
    public String orgName { get; set; }
    public String siteName { get; set; }
    public Id q1Id { get; set; }
    public String q1Status { get; set; }
    public Id q2Id { get; set; }
    public String q2Status { get; set; }
    public Id q3Id { get; set; }
    public String q3Status { get; set; }
    public Id q4Id { get; set; }
    public String q4Status { get; set; }

    public innerClass(
      String oname,
      String sname,
      Id q1,
      String q1s,
      Id q2,
      String q2s,
      Id q3,
      String q3s,
      Id q4,
      String q4s
    ) {
      orgName = oname;
      siteName = sname;
      q1Id = q1;
      q1Status = q1s;
      q2Id = q2;
      q2Status = q2s;
      q3Id = q3;
      q3Status = q3s;
      q4Id = q4;
      q4Status = q4s;
    }
  }
  // END inner Class

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
