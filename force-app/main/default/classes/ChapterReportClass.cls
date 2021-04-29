public without sharing class ChapterReportClass {
  public String soql { get; set; }

  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Chapter_Report__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet())
      expr += fieldName + ', ';
    expr = expr.removeEnd(', ');

    soql = 'SELECT ' + expr + ' FROM Chapter_Report__c';
    return soql;
  }

  public List<Chapter_Report__c> getReportList(Set<Id> yprIds) {
    getSOQL();
    soql += ' WHERE Youth_in_Program_Report__c IN :yprIds AND Youth_in_Program_Report__r.Is_Deleted__c = false';
    List<Chapter_Report__c> crs = Database.query(soql);
    return crs;
  }

  public void upsertCR(Chapter_Report__c cr) {
    try {
      upsert cr;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  public void upsertCRs(List<Chapter_Report__c> crs) {
    try {
      upsert crs;
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}
