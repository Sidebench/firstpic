public without sharing class TALogClass {
  public TA_Log__c selectedLog { get; set; }

  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.TA_Log__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    String soql = 'SELECT ' + expr + ' FROM TA_Log__c';
    return soql;
  }

  public TA_Log__c getTALog(Id logId) {
    String soql = getSOQL();
    newTALog(null, null);
    TA_Log__c log = selectedLog;
    if (logId != null) {
      soql += ' WHERE Id = \'' + logId + '\'';
      TA_Log__c[] logs = Database.query(soql);
      if (logs.size() > 0) {
        log = logs[0];
      }
    }
    return log;
  }

  public List<TA_Log__c> getTALogs(
    Id orgId,
    Boolean followUpOnly,
    Integer listLimit,
    String userProfile,
    String soqlAND
  ) {
    String soql = getSOQL();
    soql += ' WHERE Date__c != null';
    if (orgId != null)
      soql += ' AND Organization__c = \'' + orgId + '\'';
    if (followUpOnly == true)
      soql += ' AND Flagged_for_Follow_Up__c = true';
    if (userProfile.contains('TRAIL'))
      soql += ' AND Organization__r.National_Grants__c INCLUDES (\'TRAIL\')';
    else if (userProfile.contains('OVC'))
      soql += ' AND Organization__r.National_Grants__c INCLUDES (\'OVC\')';
    if (soqlAND != null)
      soql += soqlAND;
    system.debug('>>>> TALogClass getTALogs soqlAND = ' + soqlAND);
    soql += ' ORDER BY Date__c desc';
    if (listLimit != null)
      soql += ' LIMIT ' + listLimit;
    system.debug('>>>> TALogClass getTALogs soql = ' + soql);

    List<TA_Log__c> logs = new List<TA_Log__c>();
    logs = Database.query(soql);
    return logs;
  }

  public void upsertTALog(TA_Log__c log, Id contactId) {
    if (log.TA_By__c == null && contactId != null)
      log.TA_By__c = contactId;
    try {
      system.debug('upsertTALog log = ' + log);
      upsert log;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
    if (log.Original_TA_Log__c != null) {
      TA_Log__c original = getTALog(log.Original_TA_Log__c);
      original.Flagged_for_Follow_Up__c = false;
      original.Follow_Up_TA_Log__c = log.Id;
      try {
        system.debug('upsertTALog original = ' + original);
        upsert original;
      } catch (Exception e) {
        system.debug('error = ' + e.getMessage());
        ApexPages.addMessage(
          new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
        );
      }
    }
  }

  public void newTALog(Id selectedLogId, Id siteId) {
    if (selectedLogId != null)
      selectedLog = getTALog(selectedLogId);
    else {
      User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
      selectedLog = new TA_Log__c(Date__c = date.today());
      if (siteId != null)
        selectedLog.Organization__c = siteId;
      if (u != null)
        selectedLog.TA_By__c = u.ContactId;
    }
  }

  public void newTAFollowUp(Id selectedLogId, Id siteId) {
    TA_Log__c original = new TA_Log__c();
    if (selectedLogId != null) {
      original = getTALog(selectedLogId);
      if (siteId == null)
        siteId = original.Organization__c;
    }
    selectedLog = new TA_Log__c(
      Organization__c = siteId,
      Date__c = date.today()
    );
    if (original.Id != null)
      selectedLog.Original_TA_Log__c = original.Id;
    selectedLog.Topic__c = original.Topic__c;
    selectedLog.Is_Follow_Up__c = true;
  }
}
