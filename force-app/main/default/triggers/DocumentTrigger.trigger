trigger DocumentTrigger on Document__c(after insert, after update) {
  AccountClass ac = new AccountClass();
  Map<Id, String> aId_doc = new Map<Id, String>();
  List<Account> accts = new List<Account>();

  DocumentClass dc = new DocumentClass();
  Set<Id> aIds = new Set<Id>();
  List<Document__c> docs = new List<Document__c>();

  AssessmentClass sac = new AssessmentClass();
  Set<Id> saIds = new Set<Id>();

  GrantClass gc = new GrantClass();
  Map<Id, Document__c> grantDocs = new Map<Id, Document__c>();

  for (Document__c d : Trigger.new) {
    //  AUTO-HOLD
    //if(d.Overdue__c == true && trigger.oldMap.get(d.Id).Overdue__c == false &&
    //(d.Name.contains('Audit') || d.Name.contains('DOJ')))
    //aId_doc.put(d.Organization__c, d.Name);
    if (d.Assessment__c != null)
      saIds.add(d.Assessment__c);
    if (Trigger.isInsert) {
      //if(d.Organization__c != null) aIds.add(d.Organization__c);
      if (d.Grant__c != null)
        grantDocs.put(d.Grant__c, d);
    }
  }

  /*  AUTO-HOLD
     * If we use this again in the future, add logic to prevent repeat hold for same reason.
    if(aId_doc.size() > 0) {
        for(Account a : [SELECT Id, Hold_Status__c, Hold_Reason__c, Hold_Date__c, Hold_History__c, Hold_Notes__c FROM Account WHERE Id IN :aId_doc.keySet()]) {
            a.Hold_Status__c = 'Hold';
            String name = aId_doc.get(a.Id);
            String reason = 'Document Past Due';
            if(name.contains('Audit')) reason = 'Current FYE Audit Past Due';
            else reason = 'DOJ Certification Past Due';
            a.Hold_Reason__c = aId_doc.get(a.Id) + ' Past Due';
            a.Hold_Date__c = date.today();
            a.Hold_Notes__c = 'Agency placed on hold automatically.';
            a.Hold_History__c = ac.getHoldHistory(null, a);
            system.debug(a.Hold_History__c);
            accts.add(a);
        }
    }
    */

  //if(accts.size() > 0) ac.upsertAccounts(accts);  AUTO-HOLD
  if (saIds.size() > 0)
    sac.getAttStatus(saIds);
  if (grantDocs.size() > 0)
    gc.updateGrantDocStatus(grantDocs);
}
