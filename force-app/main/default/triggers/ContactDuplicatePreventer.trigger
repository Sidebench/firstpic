trigger ContactDuplicatePreventer on Contact(before insert, before update) {
  Map<String, Contact> contactMap = new Map<String, Contact>();
  for (Contact Contact : Trigger.new) {
    if (
      (Contact.Email != null) &&
      (Trigger.isInsert ||
      (Contact.Email != Trigger.oldMap.get(Contact.Id).Email))
    ) {
      if (contactMap.containsKey(Contact.Email)) {
        Contact.Email.addError(
          'Another new Contact has the same email address.'
        );
      } else {
        contactMap.put(Contact.Email, Contact);
      }
    }
  }

  for (Contact contact : [
    SELECT Email
    FROM Contact
    WHERE Email IN :contactMap.KeySet()
  ]) {
    Contact newContact = contactMap.get(Contact.Email);
    newContact.Email.addError(
      'A Contact with this email address already exists.'
    );
  }
}
