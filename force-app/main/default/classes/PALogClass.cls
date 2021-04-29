public without sharing class PALogClass {
  public PALogClass() {
  }
  public String soql { get; set; }

  public void getSoql() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PA_Log__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr += 'Site__r.Name';

    soql = 'SELECT ' + expr + ' FROM PA_Log__c';
  }

  public List<PA_Log__c> getLogs(Id reportId) {
    getSOQL();
    soql += ' WHERE Monthly_PA_Report__c = \'' + reportId + '\'';
    soql += ' ORDER BY Date__c asc';
    List<PA_Log__c> logs = database.query(soql);
    return logs;
  }

  public void upsertLogs(List<PA_Log__c> logs) {
    try {
      upsert logs;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}
