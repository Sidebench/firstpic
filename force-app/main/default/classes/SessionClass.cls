public without sharing class SessionClass {
  public String expr { get; set; }
  public String soql { get; set; }

  public SessionClass(Id sessionId, String sType) {
  }

  public void getSOQL() {
    expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Session__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    //expr = expr.removeEnd(', ');
    expr += 'RecordType.Name, Site__r.Id, Site__r.Name, Season__r.Program_Report_Status__c, Session__r.Site__r.Id, Session__r.Season__r.Id, Session__r.Season__r.Name, Session__r.Name, Site__r.National_Organization__r.Id, Lesson__r.Name';

    soql = 'SELECT ' + expr + ' FROM Session__c';
  }

  public Session__c getSession(Id sessionId, Boolean includeAttachments) {
    if (sessionId != null) {
      getSOQL();
      String thisExpr = expr;
      if (includeAttachments) {
        expr += ' ,(SELECT Id, Name, Description FROM Attachments ORDER BY LastModifiedDate desc)';
      }
      String thisSOQL = 'SELECT ' + expr + ' FROM Session__c';
      thisSOQL += ' WHERE Id = \'' + sessionId + '\'';
      Session__c i = database.query(thisSOQL);
      return i;
    }
    return null;
  }

  public List<Session__c> getSessionList(Id sessionId, String sType) {
    if (sessionId != null) {
      getSOQL();
      if (sType == 'season') {
        soql += ' WHERE RecordType.Name = \'Season\'';
      } else if (sType == 'cohort') {
        soql += ' WHERE RecordType.Name = \'Cohort\'';
        if (sessionId != null)
          soql += ' AND Session__c = \'' + sessionId + '\'';
      } else if (sType == 'lesson') {
        soql += ' WHERE RecordType.Name = \'Lesson\'';
        if (sessionId != null)
          soql += ' AND Session__c = \'' + sessionId + '\'';
      } else if (sType == 'meeting') {
        soql += ' WHERE RecordType.Name = \'Meeting\'';
        if (sessionId != null)
          soql += ' AND Cohort__c = \'' + sessionId + '\'';
      } else {
        soql += ' WHERE RecordType.Name = \'Session\'';
        if (sessionId != null)
          soql += ' AND Season__c = \'' + sessionId + '\'';
      }
      system.debug('SessionClass getSessionList soql = ' + soql);
      List<Session__c> i = database.query(soql);
      return i;
    }
    return null;
  }

  public void upsertSession(Session__c i) {
    try {
      upsert i;
      system.debug('Session updated successfully: ' + i);
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void deleteSession(Session__c i) {
    try {
      delete i;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }
}
