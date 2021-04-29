trigger Contact_UpdateAccountLookups on Contact(after insert, after update) {
  Set<Id> aId_set = new Set<Id>();
  Set<Id> aId_clearCEO_set = new Set<Id>();
  Set<Id> aId_clearFL_set = new Set<Id>();
  List<Account> acct_list = new List<Account>();
  List<Account> acct_clear_list = new List<Account>();

  for (Contact c : Trigger.new) {
    if (
      c.Role__c == 'CEO' &&
      (Trigger.isInsert || Trigger.oldMap.get(c.Id).Role__c != 'CEO')
    ) {
      aId_set.add(c.AccountId);
    } else if (
      c.Role__c == 'Finance Lead' &&
      (Trigger.isInsert || Trigger.oldMap.get(c.Id).Role__c != 'Finance Lead')
    ) {
      aId_set.add(c.AccountId);
    }
    if (Trigger.isUpdate) {
      if (c.Role__c != 'CEO' && Trigger.oldMap.get(c.Id).Role__c == 'CEO') {
        aId_clearCEO_set.add(c.AccountId);
      } else if (
        c.Role__c != 'Finance Lead' &&
        Trigger.oldMap.get(c.Id).Role__c == 'Finance Lead'
      ) {
        aId_clearFL_set.add(c.AccountId);
      }
    }
  }

  for (Account a : [
    SELECT CEO__c, Finance_Lead__c
    FROM Account
    WHERE ID IN :aId_set
  ]) {
    for (Contact c : Trigger.new) {
      if (c.AccountId == a.Id) {
        if (c.Role__c == 'CEO') {
          a.CEO__c = c.Id;
          acct_list.add(a);
        }
        if (c.Role__c == 'Finance Lead') {
          a.Finance_Lead__c = c.Id;
          acct_list.add(a);
        }
      }
    }
  }
  system.debug('>>> acct_list = ' + acct_list);

  for (Account a : [SELECT CEO__c FROM Account WHERE ID IN :aId_clearCEO_set]) {
    a.CEO__c = null;
    acct_clear_list.add(a);
  }
  for (Account a : [
    SELECT Finance_Lead__c
    FROM Account
    WHERE ID IN :aId_clearFL_set
  ]) {
    a.Finance_Lead__c = null;
    acct_clear_list.add(a);
  }
  system.debug('>>> acct_clear_list = ' + acct_clear_list);

  try {
    update acct_list;
    update acct_clear_list;
  } catch (Exception e) {
    system.debug('>>> error = ' + e.getMessage());
  }
}
