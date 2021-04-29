public without sharing class YouthInProgramReportClass {
  public YouthInProgramReportClass() {
  }
  public String soql { get; set; }

  public void getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Youth_in_Program_Report__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    soql = 'SELECT ' + expr + ' FROM Youth_in_Program_Report__c';
  }

  public Youth_in_Program_Report__c getYPR(
    Id yprId,
    Id contactId,
    Id reportId,
    Id grantId
  ) {
    getSOQL();
    Youth_in_Program_Report__c ypr = new Youth_in_Program_Report__c();
    soql += ' WHERE Name != null';
    if (yprId != null)
      soql += ' AND Id = \'' + yprId + '\'';
    else {
      if (contactId != null)
        soql += ' AND Contact__c = \'' + contactId + '\'';
      if (reportId != null)
        soql += ' AND Program_Report__c = \'' + reportId + '\'';
      if (grantId != null)
        soql += ' AND Grant__c = \'' + grantId + '\'';
    }
    system.debug('Youth_in_Program_Report__c soql = ' + soql);
    Youth_in_Program_Report__c[] yprs = Database.query(soql);
    if (yprs.size() > 0)
      ypr = yprs[0];
    return ypr;
  }

  public List<Youth_in_Program_Report__c> getRelatedYPRList(
    Set<Id> prIds,
    String sortBy
  ) {
    getSOQL();
    soql += ' WHERE Program_Report__c IN :prIds AND Is_Deleted__c = false';
    if (sortBy != null && sortBy != '')
      soql += ' ORDER BY ' + sortBy;
    else
      soql += ' ORDER BY Site_Name__c, Contact_Name__c';
    soql += ' LIMIT 1000';
    system.debug('Youth_in_Program_Report__c soql = ' + soql);
    List<Youth_in_Program_Report__c> yprs = Database.query(soql);
    return yprs;
  }

  public List<Youth_in_Program_Report__c> getRelatedGrantYPRList(
    Set<Id> gIds,
    String sortBy
  ) {
    getSOQL();
    soql += ' WHERE Grant__c IN :gIds AND Is_Deleted__c = false';
    if (sortBy != null && sortBy != '')
      soql += ' ORDER BY ' + sortBy;
    else
      soql += ' ORDER BY Org_Name__c, Contact_Name__c';
    soql += ' LIMIT 1000';
    system.debug('Youth_in_Program_Report__c soql = ' + soql);
    List<Youth_in_Program_Report__c> yprs = Database.query(soql);
    return yprs;
  }

  public List<Youth_in_Program_Report__c> getYouthYPRList(Id youthId) {
    getSOQL();
    soql +=
      ' WHERE Contact__c = \'' +
      youthId +
      '\' AND Is_Deleted__c = false ORDER BY Grant_Year__c';
    system.debug('Youth_in_Program_Report__c soql = ' + soql);
    List<Youth_in_Program_Report__c> yprs = Database.query(soql);
    return yprs;
  }

  public void upsertYPR(Youth_in_Program_Report__c ypr) {
    try {
      upsert ypr;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  public void upsertYPRs(List<Youth_in_Program_Report__c> yprs) {
    try {
      upsert yprs;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  public void deleteYPR(Youth_in_Program_Report__c ypr) {
    ypr.Is_Deleted__c = true;
    try {
      upsert ypr;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}
