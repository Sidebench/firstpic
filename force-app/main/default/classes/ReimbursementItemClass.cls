public without sharing class ReimbursementItemClass {
  public String soql { get; set; }

  public ReimbursementItemClass() {
  }

  public String getSOQL() {
    String fields = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Reimbursement_Item__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      fields += fieldName + ', ';
    }
    //fields = fields.removeEnd(', ');
    fields += 'RecordType.Name, Reimbursement_Request__r.Name,Reimbursement_Request__r.FTE__c, Reimbursement_Request__r.Youth_Served_Percent__c';
    fields += ',Budget_Item__r.Name,Budget_Item__r.Category__c,Budget_Item__r.Factor_Type__c, Budget_Item__r.Title__c, Budget_Item__r.Requested_Indirect_Rate_Amount__c';
    fields += ',Budget_Item__r.Item_Budget__c,Budget_Item__r.Total_Approved_Salary__c,Budget_Item__r.Total_Approved_Benefits__c,Budget_Item__r.Total_Approved_Amount__c, Budget_Item__r.Other_Factor_Percent__c, Budget_Item__r.Labor_Balance__c, Budget_Item__r.Fringe_Balance__c, Budget_Item__r.Balance__c, Budget_Item__r.Item_Balance__c, Budget_Item__r.Rate__c ';
    fields += ',(SELECT ID, ParentID, Name FROM Attachments ORDER BY LastModifiedDate desc LIMIT 1)';

    soql = 'SELECT ' + fields + ' FROM Reimbursement_Item__c';
    return soql;
  }

  public List<Reimbursement_Item__c> getRequestItems(
    Id requestId,
    String listType
  ) {
    getSOQL();
    soql += ' WHERE Reimbursement_Request__c = \'' + requestId + '\'';
    if (listType == 'labor')
      soql += ' AND RecordType.Name = \'Labor\'';
    if (listType == 'personnel')
      soql += ' AND Type__c = \'Personnel\'';
    if (listType == 'fringe')
      soql += ' AND Type__c = \'Fringe\'';
    if (listType == 'expense')
      soql += ' AND RecordType.Name = \'Expense\'';
    soql += ' ORDER BY Title__c LIMIT 200';
    system.debug('soql = ' + soql);
    List<Reimbursement_Item__c> requestItemList = Database.query(soql);
    system.debug('Reimbursement Items: ' + requestItemList);
    return requestItemList;
  }

  public Reimbursement_Item__c getRequestItem(Id itemId) {
    Reimbursement_Item__c item = new Reimbursement_Item__c();
    getSOQL();
    soql += ' WHERE Id = \'' + itemId + '\'';
    Reimbursement_Item__c[] requestItems = Database.query(soql);
    if (requestItems.size() > 0)
      item = requestItems[0];
    system.debug('Reimbursement Items: ' + item);
    return item;
  }

  public void upsertItem(Reimbursement_Item__c item) {
    try {
      upsert item;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void upsertItems(List<Reimbursement_Item__c> items) {
    try {
      upsert items;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }
}
