public without sharing class SurveyClass {
  public SurveyClass() {
  }
  public String soql { get; set; }

  public void getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Survey__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    soql = 'SELECT ' + expr + ' FROM Survey__c';
  }

  public Survey__c getSurvey(Id surveyId) {
    getSOQL();
    Survey__c survey = new Survey__c();
    if (surveyId != null) {
      soql += ' WHERE Id = \'' + surveyId + '\'';
      Survey__c[] surveys = Database.query(soql);
      if (surveys.size() > 0) {
        survey = surveys[0];
      }
    }
    return survey;
  }

  public void upsertSurvey(Survey__c survey) {
    try {
      upsert survey;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  /*
    public void updateStatuses(Set<Id> ids) {
        Youth_in_Program_Report__c[] records = [SELECT Pre_Test_Status__c, Post_Test_Status__c FROM Youth_in_Program_Report__c WHERE Id IN :ids];
        for(Survey__c s : [SELECT Youth_in_Program_Report__c, Type__c, Status__c FROM Survey__c WHERE Youth_in_Program_Report__c IN :records]) {
            for(Youth_in_Program_Report__c r : records) {
                if(s.Youth_in_Program_Report__c == r.Id) {
                    if(s.Type__c == 'Pre-Test') r.Pre_Test_Status__c = s.Status__c;
                    if(s.Type__c == 'Post-Test') r.Post_Test_Status__c = s.Status__c;
                }
            }
        }
        try {
            update records;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }
    */
}
