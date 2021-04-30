public without sharing class ProgressReportClass {
  public String soql { get; set; }

  public void getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Progress_Report__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr += 'RecordType.Name';

    soql = 'SELECT ' + expr + ' FROM Progress_Report__c';
  }

  public Progress_Report__c getReport(Id reportId, Id orgId, Id grantId) {
    getSoql();
    Progress_Report__c report = new Progress_Report__c();

    if (reportId != null)
      soql += ' WHERE Id = \'' + reportId + '\'';
    if (grantId != null && orgId != null)
      soql +=
        ' WHERE Grant__c = \'' +
        grantId +
        '\' AND Organization__c = \'' +
        orgId +
        '\'';
    system.debug('>>> report soql = ' + soql);

    Progress_Report__c[] reports = Database.query(soql);
    if (reports.size() == 1) {
      report = reports[0];
    }
    return report;
  }

  public List<Progress_Report__c> getRelatedReportList(
    Id acctId,
    Id orgId,
    String userAcctType,
    String orgName,
    String reportId,
    String month,
    Integer year,
    String status,
    String sortBy,
    String soqlAND
  ) {
    String soql = 'SELECT Local_Organization_Name__c, Organization_Name__c, Name, Grant_Name__c, Month__c, Quarter__c, Year__c, Status__c, Submitted_Date__c, Needs_Attention__c, Needs_Additional_Review__c, Is_Overdue__c FROM Progress_Report__c';
    soql += ' WHERE Name != null';
    if (orgId == null) {
      if (userAcctType == 'National Organization')
        soql +=
          ' AND Organization__r.National_Organization__c = \'' +
          acctId +
          '\'';
      else
        soql +=
          ' AND (Local_Organization_Id__c = \'' +
          acctId +
          '\' OR Organization__c = \'' +
          acctId +
          '\')';
    } else {
      soql +=
        ' AND (Organization__r.National_Organization__c = \'' +
        orgId +
        '\' OR Local_Organization_Id__c = \'' +
        orgId +
        '\' OR Organization__c = \'' +
        orgId +
        '\')';
    }
    if (orgName != '' && orgName != null)
      soql +=
        ' AND (Organization_Name__c LIKE \'%' +
        orgName +
        '%\' OR Local_Organization_Name__c LIKE \'%' +
        orgName +
        '%\')';
    if (reportId != '' && reportId != null)
      soql += ' AND Name LIKE \'%' + reportId + '%\'';
    if (month != null && month != '' && month != 'View All')
      soql += ' AND Month__c = \'' + month + '\'';
    if (year != null)
      soql += ' AND Year__c = \'' + String.valueOf(year) + '\'';
    if (
      status != '' &&
      status != null &&
      status != 'All Reports' &&
      status != 'View All'
    )
      soql += ' AND Status__c = \'' + status + '\'';
    if (soqlAND != null && soqlAND != '')
      soql += soqlAND;
    if (sortBy != '' && sortBy != null)
      soql += ' ORDER BY ' + sortBy;
    soql += ' LIMIT 1000';
    system.debug('Progress Report Class soql = ' + soql);

    List<Progress_Report__c> report_list = Database.query(soql);
    return report_list;
  }

  public void upsertReport(Progress_Report__c report) {
    try {
      upsert report;
      system.debug('>>> report = ' + report);
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void createQuarterlyReports(
    String naOrgName,
    String quarter,
    String year
  ) {
    Integer count = 0;
    Date dt = date.today();
    if (naOrgName == null)
      naOrgName = 'STEM';
    if (year == null)
      year = string.valueOf(dt.year());
    if (quarter == null)
      quarter = 'Q1';

    List<Progress_Report__c> prs = new List<Progress_Report__c>();
    List<Grant__c> grants = [
      SELECT Id, Account__c
      FROM Grant__c
      WHERE
        FirstPic_National_Org_Code__c = :naOrgName
        AND Grant_Status__c != 'Closed'
        AND National_Grant__r.Reporting_Period_Start_Date__c <= :dt
        AND National_Grant__r.Reporting_Period_End_Date__c >= :dt
    ];
    List<Account> accts = [
      SELECT Id, Name, Is_Active__c, Local_Organization_Id__c
      FROM Account
      WHERE
        FirstPic_National_Org_Code__c = :naOrgName
        AND RecordType.Name = 'Site'
        AND Is_Active__c = TRUE
    ];

    for (Account a : accts) {
      for (Grant__c g : grants) {
        if (a.Local_Organization_Id__c == g.Account__c) {
          Progress_Report__c pr = new Progress_Report__c(
            Status__c = 'Not Started',
            Organization__c = a.Id,
            Grant__c = g.Id,
            Quarter__c = quarter,
            Year__c = year,
            RecordTypeID = Schema.SObjectType.Progress_Report__c.getRecordTypeInfosByName()
              .get('Quarterly')
              .getRecordTypeId()
          );
          prs.add(pr);
          count++;
        }
      }
    }
    system.debug(count);
    system.debug(prs);
    insert prs;
  }
}
