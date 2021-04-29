public without sharing class VictimsServedReportClass {
  public String getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Victims_Served_Report__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    String soql = 'SELECT ' + expr + ' FROM Victims_Served_Report__c';
    return soql;
  }

  public Victims_Served_Report__c getReport(Id reportId) {
    String soql = getSoql();
    Victims_Served_Report__c report = new Victims_Served_Report__c();

    if (reportId != null)
      soql += ' WHERE Id = \'' + reportId + '\'';

    Victims_Served_Report__c[] reports = Database.query(soql);
    if (reports.size() == 1) {
      report = reports[0];
    }
    return report;
  }

  public List<Victims_Served_Report__c> getRelatedReportList(
    Id acctId,
    String userAcctType,
    String orgName,
    String soqlAND
  ) {
    String soql = 'SELECT Id, Name, Organization__c, Organization_Name__c, Year__c, Month__c, Status__c, Submitted_Date__c FROM Victims_Served_Report__c';
    if (orgName != null && orgName != '') {
      soql +=
        ' WHERE Organization_Name__c LIKE \'%' +
        String.escapeSingleQuotes(orgName) +
        '%\'';
    } else if (userAcctType == 'National Organization') {
      soql +=
        ' WHERE Organization__r.National_Organization__c = \'' +
        acctId +
        '\'';
    } else if (acctId != null) {
      soql += ' WHERE Organization__c = \'' + acctId + '\'';
    }
    if (soqlAND != null && soqlAND != '')
      soql += soqlAND;
    system.debug('Victims Served Report soql = ' + soql);

    List<Victims_Served_Report__c> reports = Database.query(soql);
    return reports;
  }

  public void upsertReport(Victims_Served_Report__c report) {
    try {
      upsert report;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}
