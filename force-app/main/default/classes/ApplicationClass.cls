public without sharing class ApplicationClass {
  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Application__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    //expr = expr.removeEnd(', ');
    expr += 'RecordType.Name, National_Organization__r.Name, Organization__r.Primary_Approver__c, Organization__r.Primary_Approver_Name__c, Organization__r.Secondary_Approver__c, Organization__r.Program_Coordinator__c';

    String soql = 'SELECT ' + expr + ' FROM Application__c';
    system.debug('>>> soql = ' + soql);
    return soql;
  }

  public List<Application__c> getApplicationList() {
    List<Application__c> app_list = new List<Application__c>();
    app_list = Database.query(getSOQL());
    return app_list;
  }

  public List<Application__c> getRelatedApplicationList(
    Id acctId,
    String keyword,
    String status,
    String soqlAND,
    String sortBy,
    Id paId
  ) {
    String soql = 'SELECT Id, Name, RecordType.Name, Organization__r.Id, Organization__r.Name, Organization_Name__c, Status__c, Submitted_Date__c, Primary_Approver__c, Organization__r.Primary_Approver__c, Organization__r.Primary_Approver_Name__c, Primary_Approver_Name__c, Type__c, Grant_Type__c, Eligibility_Notice_Received__c, DUNS_Number__c';
    soql += ', Grant_Year__c, Federal_Debt__c, Audit_Fund__c, Audit_Finding__c, Audit_Notes__c, Review_Notes__c';
    soql += ' FROM Application__c WHERE Name != null';
    if (acctId != null)
      soql +=
        ' AND (Organization__r.Id = \'' +
        acctId +
        '\' OR National_Organization__r.Id = \'' +
        acctId +
        '\')';
    if (keyword != '' && keyword != null)
      soql +=
        ' AND (Name LIKE \'%' +
        String.escapeSingleQuotes(keyword) +
        '%\' OR Organization__r.Name LIKE \'%' +
        String.escapeSingleQuotes(keyword) +
        '%\')';
    if (status != '' && status != null)
      soql += ' AND Status__c = \'' + status + '\'';
    if (paId != null) {
      soql += ' AND (Organization__r.Primary_Approver__c = \'' + paId + '\'';
      soql += ' OR Primary_Approver__c = \'' + paId + '\'';
      soql += ' OR (Organization__r.Secondary_Approver__c = \'' + paId + '\'';
      soql += ' AND (Organization__r.Primary_Approver_On_Leave__c = true OR FirstPic_National_Org_Code__c = \'Ripken\')))';
    }
    if (soqlAND != '' && soqlAND != null)
      soql += soqlAND;
    if (sortBy != '' && sortBy != null)
      soql += ' ORDER BY ' + sortBy + ' desc';
    else
      soql += ' ORDER BY Name';
    system.debug('Application soql = ' + soql);
    List<Application__c> apps = Database.query(soql);
    return apps;
  }

  public Application__c getApplication(Id appId) {
    Application__c app = new Application__c();
    if (appId != null) {
      String soql = getSOQL();
      soql += ' WHERE Id = \'' + appId + '\'';
      Application__c[] apps = Database.query(soql);
      if (apps.size() > 0) {
        app = apps[0];
      }
    }
    return app;
  }

  public List<Application_Site__c> getAppSites(Id appId) {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Application_Site__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');
    String soql =
      'SELECT ' +
      expr +
      ' FROM Application_Site__c WHERE Application__c = \'' +
      appId +
      '\'';
    system.debug('Application Sites soql = ' + soql);
    List<Application_Site__c> appSites = Database.query(soql);
    return appSites;
  }

  public List<Application_Review__c> getAppReviews(Id appId, Id reviewerId) {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Application_Review__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr += 'Reviewer__r.Name';
    String soql = 'SELECT ' + expr + ' FROM Application_Review__c';
    soql += ' WHERE Name != null';
    if (appId != null)
      soql += ' AND Application__c = \'' + appId + '\'';
    if (reviewerId != null)
      soql += ' AND Reviewer__c = \'' + reviewerId + '\'';
    system.debug('Application Reviews soql = ' + soql);
    List<Application_Review__c> items = Database.query(soql);
    return items;
  }

  public void upsertApplication(Application__c app) {
    try {
      upsert app;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }

  public void upsertApplications(List<Application__c> apps) {
    try {
      upsert apps;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }

  public void upsertAppSites(List<Application_Site__c> sites) {
    try {
      upsert sites;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }

  public void upsertAppReview(Application_Review__c review) {
    try {
      upsert review;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }

  public void updateNationalOrgField(List<Application__c> appList) {
    Account[] accts = [
      SELECT Id, FirstPic_National_Org_Code__c
      FROM Account
      WHERE RecordType.Name = 'National Organization'
    ];
    for (Application__c app : appList) {
      for (Account a : accts) {
        if (app.National_Organization_Id__c != null) {
          if (a.Id == app.National_Organization_Id__c) {
            app.National_Organization__c = a.Id;
          }
        } else if (
          app.RecordType.Name == 'Under Armour' &&
          a.FirstPic_National_Org_Code__c == 'UA'
        ) {
          app.National_Organization__c = a.Id;
        } else if (
          app.RecordType.Name.contains('Ripken') &&
          a.FirstPic_National_Org_Code__c == 'Ripken'
        ) {
          app.National_Organization__c = a.Id;
        } else if (
          app.RecordType.Name.contains('NCAI') &&
          a.FirstPic_National_Org_Code__c == 'NCAI'
        ) {
          app.National_Organization__c = a.Id;
        }
      }
    }
    try {
      update appList;
    } catch (Exception e) {
      system.debug(e);
    }
  }

  public void deleteApplicationSites(List<Application_Site__c> sites) {
    try {
      delete sites;
    } catch (Exception e) {
      system.debug(e);
    }
  }
}
