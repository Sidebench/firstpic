trigger AccountTrigger on Account(after update) {
  ContactUtilitiesClass util = new ContactUtilitiesClass();
  Set<Id> aIds = new Set<Id>();
  Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName()
    .get('Local Organization')
    .getRecordTypeId();

  for (Account a : Trigger.new) {
    if (a.RecordTypeId == rtId) {
      if (
        a.CEO__c != Trigger.oldMap.get(a.Id).CEO__c ||
        Trigger.oldMap.get(a.Id).CEO__c == null ||
        a.CEO_Email__c != a.CEO_Email_text__c ||
        a.DOD__c != Trigger.oldMap.get(a.Id).DOD__c ||
        a.DOD_Email__c != a.DOD_Email_text__c
      ) {
        aIds.add(a.Id);
      }
    }
  }
  if (aIds.size() > 0)
    util.updateSiteEmailFeilds(aIds);

}
