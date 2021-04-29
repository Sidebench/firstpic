public without sharing class DCTATReportClass {
  public String soql { get; set; }
  public String getSOQL() {
    String fields = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Grantee_Report__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      fields += fieldName + ', ';
    }
    fields = fields.removeEnd(', ');

    soql = 'SELECT ' + fields + ' FROM Grantee_Report__c';
    return soql;
  }

  public List<Grantee_Report__c> getReportList() {
    soql = getSOQL();
    soql += ' ORDER BY Report_Status__c, Submitted_Date__c';
    List<Grantee_Report__c> reports = database.query(soql);
    return reports;
  }

  public List<Grantee_Report__c> getRelatedReportList(
    Id acctId,
    String orgName,
    String status,
    String sortBy,
    String soqlAND
  ) {
    String soql = 'SELECT Name, Local_Organization_Name__c, Organization_Name__c, Grant__r.Id, Grant_Name__c, Grant_Type__c, Primary_Approver_Name__c, Primary_Approver_Id__c, Report_Status__c, Submitted_Date__c, Quarter__c, Year__c FROM Grantee_Report__c';
    soql +=
      ' WHERE (National_Organization_Id__c = \'' +
      acctId +
      '\' OR Local_Organization_Id__c = \'' +
      acctId +
      '\' OR Organization_Id__c = \'' +
      acctId +
      '\')';
    if (orgName != '' && orgName != null)
      soql +=
        ' AND (Organization_Name__c LIKE \'%' +
        orgName +
        '%\' or Local_Organization_Name__c LIKE \'%' +
        orgName +
        '%\')';
    if (status != '' && status != null)
      soql += ' AND Report_Status__c = \'' + status + '\'';
    if (soqlAND != '' && soqlAND != null)
      soql += soqlAND;
    if (sortBy != '' && sortBy != null)
      soql += ' ORDER BY ' + sortBy;
    system.debug('DCTATReportClass getRelatedReportList soql = ' + soql);
    List<Grantee_Report__c> reports = database.query(soql);
    return reports;
  }

  public Grantee_Report__c getReport(Id reportId) {
    soql = getSOQL();
    if (reportId != null)
      soql += ' WHERE Id = \'' + reportId + '\'';

    Grantee_Report__c report = new Grantee_Report__c();
    Grantee_Report__c[] reports = database.query(soql);
    if (reports.size() > 0)
      report = reports[0];
    return report;
  }

  public void upsertReport(Grantee_Report__c report) {
    try {
      upsert report;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void createReports(String fpNatCode, String quarter) {
    if (fpNatCode == null)
      fpNatCode = 'Ripken';
    Date dt = date.today();
    List<Grantee_Report__c> r_list = new List<Grantee_Report__c>();
    Integer count = 0;
    for (Grant__c g : [
      SELECT Id, Account__r.Id, Account__r.Primary_Approver_Email_text__c
      FROM Grant__c
      WHERE
        RecordType.Name = 'Sub-Grant'
        AND FirstPic_National_Org_Code__c = :fpNatCode
        AND Year__c = :string.valueOf(dt.year())
    ]) {
      count++;
      Grantee_Report__c r = new Grantee_Report__c(
        Year__c = string.valueOf(dt.year()),
        Grant__c = g.Id,
        Organization__c = g.Account__c,
        Report_Status__c = 'Not Started',
        Quarter__c = quarter,
        Primary_Approver_Email__c = g.Account__r.Primary_Approver_Email_text__c
      );
      r_list.add(r);
    }
    system.debug('count = ' + count);
    system.debug('r_list = ' + r_list);
    insert r_list;
  }

  public void createReportsForSites(
    String orgCode,
    String year,
    String quarter
  ) {
    Date dt = date.today();
    if (orgCode == null)
      orgCode = 'STEM';
    if (year == null)
      year = string.valueOf(dt.year());
    if (quarter == null)
      quarter = 'Q2';

    List<Grantee_Report__c> items = new List<Grantee_Report__c>();
    List<Grant__c> grants = [
      SELECT Id, Account__c
      FROM Grant__c
      WHERE
        FirstPic_National_Org_Code__c = :orgCode
        AND Grant_Status__c != 'Closed'
        AND National_Grant__r.Reporting_Period_Start_Date__c <= :dt
        AND National_Grant__r.Reporting_Period_End_Date__c >= :dt
    ];
    List<Account> accts = [
      SELECT Id, Local_Organization_Id__c, Primary_Approver_Email_text__c
      FROM Account
      WHERE
        FirstPic_National_Org_Code__c = :orgCode
        AND RecordType.Name = 'Site'
        AND Is_Active__c = TRUE
    ];
    Integer count = 0;
    for (Account a : accts) {
      for (Grant__c g : grants) {
        if (a.Local_Organization_Id__c == g.Account__c) {
          count++;
          Grantee_Report__c r = new Grantee_Report__c(
            Grant__c = g.Id,
            Organization__c = a.Id,
            Report_Status__c = 'Not Started',
            Year__c = year,
            Quarter__c = quarter,
            Primary_Approver_Email__c = a.Primary_Approver_Email_text__c
          );
          items.add(r);
        }
      }
    }
    system.debug(count);
    system.debug(items);
    insert items;
  }
}
