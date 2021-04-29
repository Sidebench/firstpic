public without sharing class DocumentClass {
  public String soql { get; set; }
  public Set<Id> docIds { get; set; }

  public String getSOQL(
    Id orgId,
    Id grantId,
    Id assessId,
    Id reportId,
    Id requestId,
    String groupId,
    String soqlAND,
    Boolean includeAtts
  ) {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Document__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    soql = 'SELECT ' + expr;
    if (includeAtts)
      soql += ', (SELECT Id, Name, Description, ParentId FROM Attachments)';
    soql += ' FROM Document__c ';
    String soqlWhere = ' WHERE Name != null ';
    if (assessId != null)
      soqlWhere += ' AND Assessment__c = \'' + assessId + '\'';
    else if (reportId != null)
      soqlWhere += ' AND Session_Report__c = \'' + reportId + '\'';
    else if (requestId != null)
      soqlWhere += ' AND Reimbursement__c = \'' + requestId + '\'';
    else if (grantId != null)
      soqlWhere += ' AND Grant__c = \'' + grantId + '\'';
    else if (orgId != null)
      soqlWhere +=
        ' AND (Local_Organization_Id__c = \'' +
        orgId +
        '\' OR Organization__c = \'' +
        orgId +
        '\')';

    if (groupId != null && groupId != '')
      soqlWhere += ' AND Group_Id__c = \'' + groupId + '\'';
    if (soqlAND != null && soqlAND != '')
      soqlWhere += soqlAND;
    system.debug('DocumentClass soqlWhere = ' + soqlWhere);
    soql += soqlWhere + ' ORDER BY Name';
    soql += ' LIMIT 1000';
    return soql;
  }

  public List<Document__c> getDocList(
    Id orgId,
    Id grantId,
    Id assessId,
    Id reportId,
    Id requestId,
    String groupId,
    String soqlAND
  ) {
    getSOQL(
      orgId,
      grantId,
      assessId,
      reportId,
      requestId,
      groupId,
      soqlAND,
      false
    );
    docIds = new Set<Id>();
    List<Document__c> doc_list = new List<Document__c>();
    for (Document__c d : database.query(soql)) {
      doc_list.add(d);
      docIds.add(d.Id);
    }
    system.debug('DocumentClass getDocList doc_list = ' + doc_list);
    return doc_list;
  }

  public List<Document__c> getDocWithAttList(
    Id orgId,
    Id grantId,
    Id assessId,
    Id reportId,
    Id requestId,
    String groupId,
    String soqlAND
  ) {
    getSOQL(
      orgId,
      grantId,
      assessId,
      reportId,
      requestId,
      groupId,
      soqlAND,
      true
    );
    List<Document__c> doc_list = database.query(soql);
    system.debug('DocumentClass getDocWithAttList doc_list = ' + doc_list);
    return doc_list;
  }

  public List<Attachment> getAttList() {
    List<Attachment> att_list = new List<Attachment>();
    for (Attachment a : [
      SELECT Id, Name, ParentId, Description, CreatedDate
      FROM Attachment
      WHERE ParentId IN :docIds
    ]) {
      att_list.add(a);
    }
    system.debug('DocumentClass getAttList att_list = ' + att_list);
    return att_list;
  }

  public void upsertDoc(Document__c doc) {
    try {
      upsert doc;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void upsertDocs(List<Document__c> docs) {
    try {
      upsert docs;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void deleteDoc(Document__c doc) {
    try {
      delete doc;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void getHasAtts(
    Map<Id, Id> parent_contact_ids,
    Map<Id, String> modHist
  ) {
    List<Document__c> docs = new List<Document__c>();
    for (Document__c d : [
      SELECT
        Id,
        Has_Attachments__c,
        Submitted_By__c,
        Submitted_Date__c,
        Modification_History__c,
        (SELECT Id FROM Attachments)
      FROM Document__c
      WHERE Id IN :parent_contact_ids.keySet()
    ]) {
      d.Submitted_By__c = parent_contact_ids.get(d.Id);
      d.Submitted_Date__c = date.today();
      if (d.Modification_History__c == null)
        d.Modification_History__c = modHist.get(d.Id);
      else
        d.Modification_History__c += ' \r\n' + modHist.get(d.Id);
      d.Has_Attachments__c = false;
      for (Attachment a : d.Attachments)
        d.Has_Attachments__c = true;
      docs.add(d);
    }
    try {
      upsert docs;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }
}
