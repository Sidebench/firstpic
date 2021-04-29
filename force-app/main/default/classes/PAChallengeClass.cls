public without sharing class PAChallengeClass {
  public String soql { get; set; }

  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PA_Challenge__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    soql = 'SELECT ' + expr + ' FROM PA_Challenge__c';
    return soql;
  }

  public List<PA_Challenge__c> getPACList(Id yprId) {
    getSOQL();
    soql += ' WHERE Youth_in_Program_Report__c = \'' + yprId + '\'';
    List<PA_Challenge__c> pacs = new List<PA_Challenge__c>();
    pacs = Database.query(soql);
    return pacs;
  }

  public void upsertPAC(PA_Challenge__c pac) {
    try {
      upsert pac;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  public void upsertPACs(List<PA_Challenge__c> pacs) {
    for (PA_Challenge__c p : pacs) {
      if (p.Limit_to_Whole_Numbers__c) {
        if (p.Challenge_1__c != null)
          p.Challenge_1__c = p.Challenge_1__c.setScale(0);
        if (p.Challenge_2__c != null)
          p.Challenge_2__c = p.Challenge_2__c.setScale(0);
        if (p.Challenge_3__c != null)
          p.Challenge_3__c = p.Challenge_3__c.setScale(0);
        if (p.Challenge_4__c != null)
          p.Challenge_4__c = p.Challenge_4__c.setScale(0);
        if (p.Challenge_5__c != null)
          p.Challenge_5__c = p.Challenge_5__c.setScale(0);
        if (p.Challenge_6__c != null)
          p.Challenge_6__c = p.Challenge_6__c.setScale(0);
      }
    }
    try {
      upsert pacs;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}
