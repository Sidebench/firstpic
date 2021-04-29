public without sharing class ChapterReportCtrl {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  private ContactClass cc = new ContactClass();
  private ProgramReportClass prc = new ProgramReportClass();
  private ChapterReportClass crc = new ChapterReportClass();
  private YouthInProgramReportClass yprc = new YouthInProgramReportClass();
  private PaginationClass pc = new PaginationClass();

  public List<Program_Report__c> allReports { get; set; }
  public List<Program_Report__c> reports { get; set; }
  public Id reportId { get; set; }
  public Program_Report__c report { get; set; }
  public List<Chapter_Report__c> chapterReports { get; set; }
  public Set<Id> yprIds { get; set; }

  public String siteName { get; set; }
  public String year { get; set; }
  public List<SelectOption> yearOptions { get; set; }
  public String successMessage { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public ChapterReportCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    String urlReportId = ApexPages.currentPage()
      .getParameters()
      .get('reportId');
    if (urlReportId != '' && urlReportId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlReportId)
          .matches()
      ) {
        reportId = Id.valueOf(urlReportId);
      }
    }

    allReports = new List<Program_Report__c>();
    reports = new List<Program_Report__c>();
    report = new Program_Report__c();
    chapterReports = new List<Chapter_Report__c>();
    yprIds = new Set<Id>();

    year = ApexPages.currentPage().getParameters().get('year');
    yearOptions = new List<SelectOption>();

    Set<String> yo = new Set<String>();
    for (
      Program_Report__c pr : prc.getRelatedReportList(
        userAcct.Id,
        userAcctType,
        null,
        null,
        null,
        null
      )
    ) {
      if (!yo.contains(pr.Grant_Year__c) && pr.Grant_Year__c != null) {
        yo.add(pr.Grant_Year__c);
        yearOptions.add(new SelectOption(pr.Grant_Year__c, pr.Grant_Year__c));
      }
    }
    yearOptions.sort();
    if (year == null && yearOptions.size() > 0)
      year = String.valueOf(yearOptions.get(yearOptions.size() - 1).getValue());
  }

  public void getLists() {
    string soqlAND = ' AND RecordType.Name = \'Youth Data\'';
    if (siteName != null && siteName != '')
      soqlAND += ' AND Site_Name__c LIKE \'%' + siteName + '%\'';
    if (year != null && year != '')
      soqlAND += ' AND Grant_Year__c LIKE \'%' + year + '%\'';
    allReports = prc.getRelatedReportList(
      userAcct.Id,
      userAcctType,
      null,
      null,
      null,
      soqlAND
    );
    totalSize = allReports.size();

    first();
  }

  public void getReport() {
    report = prc.getYouthDataReport(reportId, null, null, null);
    for (Youth_in_Program_Report__c ypr : [
      SELECT Id
      FROM Youth_in_Program_Report__c
      WHERE Program_Report__c = :report.Id
    ])
      yprIds.add(ypr.Id);
    chapterReports = crc.getReportList(yprIds);
  }

  public void save() {
    successMessage = '';
    crc.upsertCRs(chapterReports);
    Map<Id, Decimal> crs = new Map<Id, Decimal>();
    for (Chapter_Report__c cr : crc.getReportList(yprIds))
      crs.put(cr.Contact_Id__c, cr.Highest_Chapter_Completed__c);

    List<Youth_in_Program_Report__c> yprs = [
      SELECT Contact__c, Highest_Chapter_Completed__c
      FROM Youth_in_Program_Report__c
      WHERE Id IN :yprIds
    ];
    for (Youth_in_Program_Report__c ypr : yprs) {
      if (
        crs.get(ypr.Contact__c) > ypr.Highest_Chapter_Completed__c ||
        ypr.Highest_Chapter_Completed__c == null
      )
        ypr.Highest_Chapter_Completed__c = crs.get(ypr.Contact__c);
    }
    yprc.upsertYPRs(yprs);

    List<Contact> youth = [
      SELECT Highest_Chapter_Completed__c
      FROM Contact
      WHERE Id IN :crs.keySet()
    ];
    for (Contact c : youth) {
      if (
        crs.get(c.Id) > c.Highest_Chapter_Completed__c ||
        c.Highest_Chapter_Completed__c == null
      )
        c.Highest_Chapter_Completed__c = crs.get(c.Id);
    }
    cc.upsertContactList(youth);

    if (!ApexPages.hasMessages())
      successMessage = 'Save Successful';
  }

  // BEGIN Pagination
  public void first() {
    counter = 0;
    reports = pc.first(allReports, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = true;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void next() {
    counter = counter + limitSize;
    reports = pc.next(allReports, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void previous() {
    counter = counter - limitSize;
    reports = pc.previous(allReports, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = pc.getDisablePrevious(counter);
    disableNext = false;
  }

  public void last() {
    counter = pc.getLastCounter(counter, limitSize, totalSize);
    reports = pc.last(allReports, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = true;
  }
  // END Pagination
}
