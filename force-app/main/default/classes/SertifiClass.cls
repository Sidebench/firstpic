public without sharing class SertifiClass {
  public List<Sertifi2_0__EDocument__c> getDocs(Id grantId) {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Sertifi2_0__EDocument__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    expr = expr.removeEnd(', ');
    String soql =
      'SELECT ' +
      expr +
      ' FROM Sertifi2_0__EDocument__c WHERE Sertifi2_0__TestContract__r.Grant__c = \'' +
      grantId +
      '\'';
    //AND (Sertifi2_0__PartiallySignedLink__c != null OR Sertifi2_0__SignedLink__c != null)];

    List<Sertifi2_0__EDocument__c> docs = database.query(soql);
    system.debug('docs = ' + docs);
    return docs;
  }
}
