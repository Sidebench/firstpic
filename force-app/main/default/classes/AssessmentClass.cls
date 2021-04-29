public without sharing class AssessmentClass {
  public String soql { get; set; }

  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Assessment__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');

    soql = 'SELECT ' + expr + ' FROM Assessment__c';
    return soql;
  }

  public Assessment__c getAssessment(Id aId) {
    getSOQL();
    Assessment__c assessment = new Assessment__c();
    if (aId != null) {
      soql += ' WHERE Id = \'' + aId + '\'';
      Assessment__c[] assessments = Database.query(soql);
      if (assessments.size() > 0) {
        assessment = assessments[0];
      }
    }
    return assessment;
  }

  public void upsertAssessment(Assessment__c assess) {
    try {
      upsert assess;
      System.Debug('>>>> Assessment upsert successful. assess = ' + assess);
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  // BEGIN getAttStatus
  public void getAttStatus(Set<Id> saIds) {
    List<Assessment__c> sa_list = new List<Assessment__c>();
    Map<Id, String> sa_map = new Map<Id, String>();
    Set<String> doc_list = new Set<String>();
    doc_list.add('Strategic and Annual Plan');
    //doc_list.add('Fund Development Plan');
    //doc_list.add('Separation of Duties for Fiscal Control');
    doc_list.add('Board Development Plan');
    //doc_list.add('Written Succession Plan');
    //doc_list.add('Previous Audit');
    //doc_list.add('AIM Fee Form');
    doc_list.add('Audit');
    doc_list.add('Affiliation Fee Form');
    doc_list.add('Income Statement');
    doc_list.add('Network Growth Goals');
    doc_list.add('Network Growth Goals & Innovative Programs');
    doc_list.add('Organizational Chart');
    doc_list.add('Program Manual');
    doc_list.add('Proof of Insurance');
    doc_list.add('Supporting Documentation for Affiliation Fee Form');
    doc_list.add('Technology Licenses Form');
    doc_list.add('Verification Letter');

    for (Document__c d : [
      SELECT Name, Status__c, Assessment__c
      FROM Document__c
      WHERE
        Assessment__c IN :saIds
        AND Status__c = 'Approved'
        AND Required__c = TRUE
    ]) {
      if (doc_list.contains(d.Name))
        sa_map.put(d.Assessment__c, 'Approved');
    }
    for (Document__c d : [
      SELECT Name, Status__c, Assessment__c
      FROM Document__c
      WHERE
        Assessment__c IN :saIds
        AND Status__c = 'Submitted'
        AND Required__c = TRUE
    ]) {
      if (doc_list.contains(d.Name))
        sa_map.put(d.Assessment__c, 'Submitted');
    }
    for (Document__c d : [
      SELECT Name, Status__c, Assessment__c
      FROM Document__c
      WHERE
        Assessment__c IN :saIds
        AND Status__c = 'Incomplete'
        AND Required__c = TRUE
    ]) {
      if (doc_list.contains(d.Name))
        sa_map.put(d.Assessment__c, 'Incomplete');
    }
    for (Document__c d : [
      SELECT Name, Status__c, Assessment__c
      FROM Document__c
      WHERE Assessment__c IN :saIds AND Status__c = 'Sent Back'
    ]) {
      if (doc_list.contains(d.Name))
        sa_map.put(d.Assessment__c, 'Sent Back');
    }

    for (Assessment__c sa : [
      SELECT Id, Attachment_Status__c
      FROM Assessment__c
      WHERE Id IN :sa_map.keyset()
    ]) {
      sa.Attachment_Status__c = sa_map.get(sa.Id);
      if (sa_map.get(sa.Id) == 'Sent Back')
        sa.Reviewed__c = 'No';
      sa_list.add(sa);
    }
    try {
      upsert sa_list;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }
  // END getAttStatus

  // BEGIN createAssessments
  public void createAssessments(Integer year, Boolean hideStandards) {
    List<Assessment__c> sas = new List<Assessment__c>();
    for (Account a : [
      SELECT Id, Name
      FROM Account
      WHERE FirstPic_National_Org_Code__c = 'BBBSA'
    ]) {
      Assessment__c sa = new Assessment__c(
        Organization__c = a.Id,
        Year__c = year,
        Hide_Standards__c = hideStandards
      );
      sas.add(sa);
    }
    insert sas;

    List<Document__c> doc_list = new List<Document__c>();
    Set<String> names = new Set<String>();
    Set<String> addNames = new Set<String>();
    names.add('Audit');
    addNames.add('Affiliation Fee Form');
    addNames.add('Income Statement');
    addNames.add('Network Growth Goals');
    addNames.add('Organizational Chart');
    addNames.add('Program Manual');
    names.add('Proof of Insurance');
    addNames.add('Supporting Documentation for Affiliation Fee Form');
    addNames.add('Technology Licenses Form');
    addNames.add('Verification Letter');

    for (Assessment__c sa : [
      SELECT Id, Organization__c
      FROM Assessment__c
      WHERE Year__c = :year
    ]) {
      for (String n : addNames) {
        Document__c d = new Document__c(
          Assessment__c = sa.Id,
          Organization__c = sa.Organization__c,
          Status__c = 'Requested',
          Name = n,
          Group_Id__c = 'Additional Documents',
          Required__c = true
        );
        doc_list.add(d);
      }
      for (String n : names) {
        Document__c d = new Document__c(
          Assessment__c = sa.Id,
          Organization__c = sa.Organization__c,
          Status__c = 'Requested',
          Name = n,
          Required__c = true
        );
        doc_list.add(d);
      }
    }
    system.debug(doc_list);
    insert doc_list;
  }
  // END createAssessments
}
