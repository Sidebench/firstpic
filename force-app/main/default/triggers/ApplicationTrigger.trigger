trigger ApplicationTrigger on Application__c(before insert, before update) {
  ApplicationClass ac = new ApplicationClass();
  List<Application__c> items = new List<Application__c>();
  List<Application__c> SOIs = new List<Application__c>();
  Id SOI = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
    .get('NCAI - SOI')
    .getRecordTypeId();

  for (Application__c i : Trigger.new) {
    system.debug('>>>>> i: ' + i);
    if (
      i.National_Organization__c == null &&
      i.National_Organization_Id__c != null
    )
      items.add(i);
    if (i.Is_Statement_of_Interest__c == true && i.RecordTypeId != SOI)
      SOIs.add(i);
  }
  if (items.size() > 0)
    ac.updateNationalOrgField(items);

  for (Application__c app : SOIs) {
    app.RecordTypeId = SOI;
  }
  if (SOIs.size() > 0)
    ac.upsertApplications(SOIs);
}
