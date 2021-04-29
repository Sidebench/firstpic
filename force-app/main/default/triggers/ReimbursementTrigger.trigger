trigger ReimbursementTrigger on Reimbursement_Request__c(after update) {
  Set<Id> ids = new Set<Id>();
  List<Reimbursement_Item__c> items = new List<Reimbursement_Item__c>();

  for (Reimbursement_Request__c i : Trigger.new) {
    if (i.Status__c != Trigger.oldMap.get(i.Id).Status__c)
      ids.add(i.Id);
  }

  for (Reimbursement_Item__c i : [
    SELECT Reimbursement_Status__c, Reimbursement_Status_for_Formula_Fields__c
    FROM Reimbursement_Item__c
    WHERE Reimbursement_Request__r.Id IN :ids
  ]) {
    i.Reimbursement_Status_for_Formula_Fields__c = i.Reimbursement_Status__c;
    items.add(i);
  }
  update items;
}
