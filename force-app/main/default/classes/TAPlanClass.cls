public without sharing class TAPlanClass {
  public String getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.TA_Plan__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    String soql = 'SELECT ' + expr + ' FROM TA_Plan__c';
    return soql;
  }

  public TA_Plan__c getPlan(Id orgId, Id planId) {
    String soql = getSoql();
    TA_Plan__c plan = new TA_Plan__c();

    if (planId != null)
      soql += ' WHERE Id = \'' + planId + '\'';
    else if (orgId != null)
      soql += ' WHERE Organization__c = \'' + orgId + '\'';

    TA_Plan__c[] plans = Database.query(soql);
    if (plans.size() == 1) {
      plan = plans[0];
    }
    return plan;
  }

  public List<TA_Plan__c> getRelatedPlans(
    Id acctId,
    String userAcctType,
    String orgName,
    String soqlAND
  ) {
    String soql = 'SELECT Id, Name, Organization__c, Organization_Name__c, LastModifiedDate, Compliance_Score__c, Finance_Score__c, Program_Score__c FROM TA_Plan__c';
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
    system.debug('TA Plan soql = ' + soql);

    List<TA_Plan__c> plans = Database.query(soql);
    return plans;
  }

  public void upsertPlan(TA_Plan__c plan) {
    try {
      upsert plan;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}
