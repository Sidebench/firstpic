trigger UserTrigger on User(after insert) {
  Set<Id> contactIds = new Set<Id>();

  for (User u : Trigger.new) {
    contactIds.add(u.ContactId);
  }

  if (contactIds.size() > 0) {
    List<Contact> contacts = [
      SELECT Is_Community_User__c
      FROM Contact
      WHERE Id IN :contactIds
    ];
    for (Contact c : contacts) {
      c.Is_Community_User__c = true;
    }
    update contacts;
  }
}
