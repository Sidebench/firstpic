public without sharing class ProgramPlanClass {
  public String getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Program_Plan__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    String soql = 'SELECT ' + expr + ' FROM Program_Plan__c';
    return soql;
  }

  public Program_Plan__c getPlan(Id planId) {
    String soql = getSoql();
    Program_Plan__c plan = new Program_Plan__c();

    if (planId != null)
      soql += ' WHERE Id = \'' + planId + '\'';
    //else if(orgId != null) soql += ' WHERE Organization__c = \'' + orgId + '\'';

    Program_Plan__c[] plans = Database.query(soql);
    if (plans.size() == 1) {
      plan = plans[0];
    }
    return plan;
  }

  public List<Program_Plan__c> getRelatedPlans(
    Id acctId,
    String userAcctType,
    String orgName,
    String soqlAND
  ) {
    String soql = 'SELECT Id, Name, Organization__c, Organization_Name__c, Submitted_Date__c, Status__c FROM Program_Plan__c';
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
    system.debug('Program Plan soql = ' + soql);

    List<Program_Plan__c> plans = Database.query(soql);
    return plans;
  }

  public void upsertPlan(Program_Plan__c plan, Boolean setAsCurrentPlan) {
    if (setAsCurrentPlan) {
      plan.Is_Current_Plan__c = true;
      List<Program_Plan__c> plans = getRelatedPlans(
        plan.Organization__c,
        null,
        null,
        null
      );
      for (Program_Plan__c p : plans) {
        p.Is_Current_Plan__c = false;
      }
      try {
        upsert plans;
      } catch (Exception e) {
        ApexPages.addMessages(e);
      }
    }
    try {
      upsert plan;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}
