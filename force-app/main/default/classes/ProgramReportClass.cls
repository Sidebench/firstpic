public without sharing class ProgramReportClass {
  public ProgramReportClass() {
  }
  public String soql { get; set; }

  public void getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Program_Report__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr += 'RecordType.Name, Site__r.Name, Grant__r.Name';

    soql = 'SELECT ' + expr + ' FROM Program_Report__c';
  }

  public Program_Report__c getCurrentReport(Id acctId) {
    Date dt = date.today();
    Program_Report__c[] reports = [
      SELECT Id
      FROM Program_Report__c
      WHERE Site__c = :acctId AND Month_Int__c = :dt.month()
    ];
    if (reports.size() > 0) {
      return reports[0];
    }
    return null;
  }

  public Program_Report__c getReport(Id reportId) {
    getSoql();
    Program_Report__c report = new Program_Report__c();

    if (reportId != null)
      soql += ' WHERE Id = \'' + reportId + '\'';

    Program_Report__c[] reports = Database.query(soql);
    if (reports.size() == 1) {
      report = reports[0];
    }
    return report;
  }

  public Program_Report__c getYouthDataReport(
    Id reportId,
    Id siteId,
    Id grantId,
    String year
  ) {
    getSoql();
    //soql = 'SELECT Name, Status__c, Site__c, Site_Id__c, Site_Name__c, Grant__c, Grant__r.Name, Start_Date__c, End_Date__c, Grant_Year__c';
    //soql += ' FROM Program_Report__c WHERE RecordType.Name = \'Youth Data\'';
    soql += ' WHERE RecordType.Name = \'Youth Data\'';
    if (reportId != null) {
      soql += ' AND Id = \'' + reportId + '\'';
    } else if (siteId != null && grantId != null && year != null) {
      soql +=
        ' AND Site__c = \'' +
        siteId +
        '\' AND Grant__c = \'' +
        grantId +
        '\' AND Grant_Year__c = \'' +
        year +
        '\'';
    }
    system.debug('Program Report soql = ' + soql);

    Program_Report__c report = new Program_Report__c();
    Program_Report__c[] reports = Database.query(soql);
    if (reports.size() == 1) {
      report = reports[0];
    }
    return report;
  }

  public List<Program_Report__c> getRelatedReportList(
    Id acctId,
    String userAcctType,
    Id localOrgId,
    Id siteId,
    Id grantId,
    String soqlAND
  ) {
    getSOQL();
    if (siteId != null) {
      soql += ' WHERE Site__c = \'' + siteId + '\'';
    } else if (localOrgId != null) {
      soql += ' WHERE Site__r.Local_Organization__c = \'' + localOrgId + '\'';
    } else if (userAcctType == 'National Organization') {
      soql += ' WHERE Site__r.National_Organization__c = \'' + acctId + '\'';
    } else if (userAcctType == 'Local Organization') {
      soql +=
        ' WHERE (Site__c = \'' +
        acctId +
        '\' OR Site__r.Local_Organization__c = \'' +
        acctId +
        '\')';
    } else {
      soql += ' WHERE Site__c = \'' + acctId + '\'';
    }
    if (grantId != null)
      soql +=
        ' AND (Grant__r.Id = \'' +
        grantId +
        '\' OR Grant__r.National_Grant__r.Id = \'' +
        grantId +
        '\')';
    if (soqlAND != null && soqlAND != '')
      soql += soqlAND;
    system.debug('Program Report soql = ' + soql);

    List<Program_Report__c> reports = Database.query(soql);
    return reports;
  }

  public void upsertReport(Program_Report__c report) {
    try {
      upsert report;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  public void createYouthDataReport(Id siteId, Id grantId, String year) {
    Program_Report__c pr = new Program_Report__c(
      Name = year + ' Youth Data Report',
      Status__c = 'Not Started',
      Site__c = siteId,
      Grant__c = grantId,
      RecordTypeID = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
        .get('Youth Data')
        .getRecordTypeId(),
      Grant_Year__c = year
    );
    system.debug(pr);
    insert pr;
  }

  public void createYouthDataReports(String naOrgName) {
    List<Program_Report__c> prs = new List<Program_Report__c>();
    List<Grant__c> grants = [
      SELECT Id, Account__c
      FROM Grant__c
      WHERE
        FirstPic_National_Org_Code__c = :naOrgName
        AND Grant_Status__c != 'Closed'
    ];
    List<Account> accts = [
      SELECT Id, Local_Organization_Id__c
      FROM Account
      WHERE FirstPic_National_Org_Code__c = :naOrgName
    ];
    Date sd = Date.newInstance(2018, 1, 1);
    Date ed = Date.newInstance(2018, 12, 31);
    Id rid = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
      .get('Youth Data')
      .getRecordTypeId();
    for (Account a : accts) {
      for (Grant__c g : grants) {
        if (a.Local_Organization_Id__c == g.Account__c) {
          Program_Report__c pr = new Program_Report__c(
            Name = 'Youth Data Report Y1',
            Status__c = 'Not Started',
            Site__c = a.Id,
            Grant__c = g.Id,
            Start_Date__c = sd,
            End_Date__c = ed,
            RecordTypeID = rid,
            Grant_Year__c = '2017 - 2018'
          );
          prs.add(pr);
        }
      }
    }
    system.debug(prs);
    insert prs;
  }
}
