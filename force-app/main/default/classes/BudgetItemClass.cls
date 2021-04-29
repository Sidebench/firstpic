public without sharing class BudgetItemClass {
  public String soql { get; set; }

  public BudgetItemClass() {
  }

  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Budget_Item__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    //expr = expr.removeEnd(', ');
    expr += 'RecordType.Name';

    soql = 'SELECT ' + expr + ' FROM Budget_Item__c';
    return soql;
  }

  public List<Budget_Item__c> getBudgetItems(Id grantId) {
    List<Budget_Item__c> budgetItems = new List<Budget_Item__c>();
    getSOQL();
    if (grantId != null) {
      soql += ' WHERE Grant__c = \'' + grantId + '\' ORDER BY Name';
      budgetItems = Database.query(soql);
    }
    return budgetItems;
  }

  public Budget_Item__c getBudgetItem(Id itemId) {
    Budget_Item__c item = new Budget_Item__c();
    getSOQL();
    soql += ' WHERE Id = \'' + itemId + '\'';
    system.debug('BudgetItemClass getBudgetItem soql = ' + soql);
    Budget_Item__c[] budgetItems = Database.query(soql);
    if (budgetItems.size() > 0)
      item = budgetItems[0];
    return item;
  }

  public void upsertItem(Budget_Item__c item) {
    try {
      upsert item;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void upsertItems(List<Budget_Item__c> items) {
    try {
      upsert items;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void deleteItems(List<Budget_Item__c> items) {
    try {
      delete items;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }
}
