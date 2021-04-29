public without sharing class FieldLabelClass {
  public Map<String, String> getFieldLabelMap(
    String objectType,
    String grantType,
    String appType,
    String soqlAND
  ) {
    Map<String, String> labels = new Map<String, String>();
    String soql =
      'SELECT Field_API__c, Label__c FROM Field_Label__c WHERE Object__c includes (\'' +
      objectType +
      '\')';
    if (grantType != null) {
      if (grantType.contains('GREAT'))
        grantType = 'GREAT';
      soql += ' AND Grant_Type__c INCLUDES (\'' + grantType + '\', \'All\')';
    }
    if (appType != null)
      soql +=
        ' AND (Application_Type__c  = \'' +
        appType +
        '\' OR Application_Type__c  = \'All\')';
    if (soqlAND != null)
      soql += soqlAND;
    soql += ' ORDER BY Order__c';

    system.debug('FieldLabelClass getFieldLabelMap soql = ' + soql);
    for (Field_Label__c i : database.query(soql)) {
      labels.put(i.Field_API__c, i.Label__c);
    }
    return labels;
  }

  public List<Field_Label__c> getFields(
    String objectType,
    String grantType,
    String appType,
    String soqlAND
  ) {
    String soql =
      'SELECT Field_API__c, Label__c, Required__c, Order__c FROM Field_Label__c WHERE Object__c includes (\'' +
      objectType +
      '\')';
    if (grantType != null) {
      if (grantType.contains('GREAT'))
        grantType = 'GREAT';
      soql += ' AND Grant_Type__c INCLUDES (\'' + grantType + '\', \'All\')';
    }
    if (appType != null)
      soql +=
        ' AND (Application_Type__c  = \'' +
        appType +
        '\' OR Application_Type__c  = \'All\')';
    if (soqlAND != null)
      soql += soqlAND;
    soql += ' ORDER BY Order__c';
    system.debug('FieldLabelClass getFieldMap soql = ' + soql);

    Set<String> names = new Set<String>();
    List<Field_Label__c> fields = new List<Field_Label__c>();
    for (Field_Label__c i : database.query(soql)) {
      if (!names.contains(i.Field_API__c))
        fields.add(i);
      names.add(i.Field_API__c);
    }
    system.debug('FieldLabelClass getFieldMap fields = ' + fields);
    return fields;
  }

  public Map<String, String> getFieldNameMap(
    String objectType,
    String grantType,
    String appType,
    String soqlAND
  ) {
    Map<String, String> labels = new Map<String, String>();
    String soql =
      'SELECT Field_API__c, Field_Name__c FROM Field_Label__c WHERE Object__c includes (\'' +
      objectType +
      '\')';
    if (grantType != null) {
      if (grantType.contains('GREAT'))
        grantType = 'GREAT';
      soql += ' AND Grant_Type__c INCLUDES (\'' + grantType + '\', \'All\')';
    }
    if (appType != null)
      soql +=
        ' AND (Application_Type__c  = \'' +
        appType +
        '\' OR Application_Type__c  = \'All\')';
    if (soqlAND != null)
      soql += soqlAND;
    soql += ' ORDER BY Order__c';

    system.debug('FieldLabelClass getFieldNameMap soql = ' + soql);
    for (Field_Label__c i : database.query(soql)) {
      labels.put(i.Field_API__c.toLowerCase(), i.Field_Name__c);
    }
    return labels;
  }
}
