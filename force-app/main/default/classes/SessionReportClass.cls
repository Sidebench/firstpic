public without sharing class SessionReportClass {
  public String soql { get; set; }

  public void getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Session_Report__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    soql = 'SELECT ' + expr + ' FROM Session_Report__c';
  }

  public SessionReportClass() {
    getSoql();
  }

  public Id getLatestReportId(Id siteId) {
    Session_Report__c[] reports = [
      SELECT Id
      FROM Session_Report__c
      WHERE Site__c = :siteId
      ORDER BY LastModifiedDate DESC
    ];
    if (reports.size() > 0) {
      Id reportId = reports[0].Id;
      return reportId;
    }
    return null;
  }

  public Session_Report__c getReport(Id reportId, Id sessionId, Id siteId) {
    getSoql();
    Session_Report__c report = new Session_Report__c();

    if (reportId != null) {
      soql += ' WHERE Id = \'' + reportId + '\'';
    }
    if (sessionId != null) {
      soql += ' WHERE Session__c = \'' + sessionId + '\'';
      if (siteId != null) {
        soql += ' AND Site__c = \'' + siteId + '\'';
      }
    }
    system.debug('>>> report soql = ' + soql);

    Session_Report__c[] reports = Database.query(soql);
    if (reports.size() == 1) {
      report = reports[0];
    }
    return report;
  }

  public List<Session_Report__c> getReportList() {
    getSoql();
    List<Session_Report__c> report_list = new List<Session_Report__c>();
    report_list = Database.query(soql);
    return report_list;
  }

  public List<Session_Report__c> getRelatedReportList(
    Id acctId,
    Id siteId,
    String userAcctType,
    String siteName,
    String reportName,
    String status,
    String sortBy,
    String soqlAND
  ) {
    String soql = 'SELECT Name, Local_Organization_Name__c, Site__r.Id, Site__r.Name, Site_Id__c, Site_Name__c, Status__c, Submitted_Date__c, Reporting_Period__c, Year__c, LastModifiedDate FROM Session_Report__c';
    soql += ' WHERE Name != null';
    if (siteId == null) {
      if (userAcctType == 'National Organization') {
        soql += ' AND Site__r.National_Organization__c = \'' + acctId + '\'';
      }
      if (userAcctType == 'Local Organization') {
        soql +=
          ' AND (Site__c = \'' +
          acctId +
          '\' OR Site__r.Local_Organization__c = \'' +
          acctId +
          '\')';
      }
    } else {
      soql += ' AND Site__c = \'' + siteId + '\'';
    }
    if (siteName != '' && siteName != null)
      soql +=
        ' AND (Site__r.Name LIKE \'%' +
        siteName +
        '%\' OR Local_Organization_Name__c LIKE \'%' +
        siteName +
        '%\')';
    if (reportName != '' && reportName != null)
      soql += ' AND Name LIKE \'%' + reportName + '%\'';
    if (status != '' && status != null && status != 'All Reports')
      soql += ' AND Status__c = \'' + status + '\'';
    if (soqlAND != '' && soqlAND != null)
      soql += soqlAND;
    if (sortBy != '' && sortBy != null)
      soql += ' ORDER BY ' + sortBy;
    system.debug('SessionReportClass getRelatedReportList soql = ' + soql);

    List<Session_Report__c> report_list = new List<Session_Report__c>();
    report_list = Database.query(soql);
    return report_list;
  }

  public void upsertReport(Session_Report__c report) {
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

  public void createProgressReports(String natOrg, String reportingPeriod) {
    if (natOrg == null)
      natOrg = 'TRAIL';
    List<Session_Report__c> reports = new List<Session_Report__c>();
    for (Account a : [
      SELECT Id, Name, Local_Organization_Id__c
      FROM Account
      WHERE FirstPic_National_Org_Code__c = :natOrg AND RecordType.Name = 'Site'
    ]) {
      String name = a.Name;
      List<String> elems = name.split(' ');
      name = '';
      for (String x : elems) {
        name += x.substring(0, 1).toUpperCase();
      }
      name = name.replace('&', '');
      name = name.replace('(', '');
      name = name.replace('-', '');

      Session_Report__c report = new Session_Report__c(
        Name = name + ' ' + reportingPeriod + ' Progress Report',
        Status__c = 'Not Started',
        Site__c = a.Id,
        Reporting_Period__c = reportingPeriod,
        RecordTypeID = Schema.SObjectType.Session_Report__c.getRecordTypeInfosByName()
          .get('Progress Report')
          .getRecordTypeId()
      );
      reports.add(report);
    }
    system.debug(reports);
    insert reports;
  }

  public void createSessionReports(String natOrg, String sessionId) {
    List<Session_Report__c> items = new List<Session_Report__c>();
    Session__c[] sessions = [
      SELECT Name, Site__r.Name
      FROM Session__c
      WHERE Id = :sessionId
    ];
    for (Account a : [
      SELECT Id, Name
      FROM Account
      WHERE
        FirstPic_National_Org_Code__c = :natOrg
        AND RecordType.Name = 'Site'
        AND Is_Active__c = TRUE
    ]) {
      Session_Report__c i = new Session_Report__c(
        Name = a.Name.left(30) +
          ' - ' +
          sessions[0].Name.left(30) +
          ' Program Report',
        Session__c = sessionId,
        Site__c = a.Id,
        Status__c = 'Not Started',
        RecordTypeID = Schema.SObjectType.Session_Report__c.getRecordTypeInfosByName()
          .get('Session Report')
          .getRecordTypeId()
      );
      items.add(i);
    }
    system.debug(items);
    insert items;
  }
}
