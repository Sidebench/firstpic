public without sharing class ContactClass {
  public String soql { get; set; }

  public ContactClass() {
    getSOQL();
  }

  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Contact.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    //expr = expr.removeEnd(', ');
    expr += 'RecordType.Name, Parent_Guardian__r.AccountId, Parent_Guardian__r.Name, Account.Name, Cohort__r.Name, Cohort__r.Session__r.Season__r.Id';

    soql = 'SELECT ' + expr + ' FROM Contact';
    return soql;
  }

  public List<Contact> getContactList() {
    getSOQL();
    List<Contact> contact_list = new List<Contact>();
    soql += ' ORDER BY LastName';
    contact_list = Database.query(soql);
    return contact_list;
  }

  public List<Contact> getContactPopupList(Id orgId) {
    List<Contact> contact_list = [
      SELECT
        Id,
        Account.Name,
        Name,
        Title,
        Role__c,
        Email,
        Phone,
        RecordType.Name
      FROM Contact
      WHERE AccountId = :orgId
      ORDER BY LastName
    ];
    return contact_list;
  }

  public List<Contact> getRelatedContactList(
    Id acctId,
    String recordType,
    String name,
    String soqlAND
  ) {
    String soql = 'SELECT Name, FirstName, LastName, Email, Phone, Title, Role__c, Extension__c, User_Profile__c, RecordType.Name, Account.Name, Account.RecordType.Name, Highest_Chapter_Completed__c';
    soql +=
      ' FROM Contact WHERE (AccountId = \'' +
      acctId +
      '\' OR Account.Local_Organization__c =  \'' +
      acctId +
      '\')';
    if (recordType != null && recordType != '')
      soql += ' AND RecordType.Name = \'' + recordType + '\'';
    if (name != null && name != '')
      soql += ' AND Name LIKE \'%' + name + '%\'';
    if (soqlAND != null && soqlAND != '')
      soql += soqlAND;
    soql += ' ORDER BY Name';
    system.debug('getRelatedContactList soql = ' + soql);
    List<Contact> contact_list = database.query(soql);
    return contact_list;
  }

  public Contact getContact(Id contactId) {
    getSOQL();
    Contact c = new Contact();
    if (contactId != null) {
      soql += ' WHERE Id = \'' + contactId + '\' LIMIT 1';
      Contact[] contacts = Database.query(soql);
      if (contacts.size() > 0) {
        c = contacts[0];
      }
    }
    return c;
  }

  public List<Contact> getDuplicateContact(Id acctId, Contact contact) {
    Contact[] dups = [
      SELECT Name
      FROM Contact
      WHERE
        (AccountId = :acctId
        OR Account.Local_Organization__c = :acctId)
        AND FirstName = :contact.FirstName
        AND LastName = :contact.LastName
        AND Gender__c = :contact.Gender__c
        AND Birth_Month__c = :contact.Birth_Month__c
        AND Birth_Year__c = :contact.Birth_Year__c
    ];
    return dups;
  }

  public void upsertContact(Contact contact) {
    try {
      upsert contact;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void upsertContactList(List<Contact> contactList) {
    system.debug('ContactClass upsertContactList contactList = ' + contactList);
    try {
      upsert contactList;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void deleteContact(Contact cont) {
    try {
      delete cont;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }
}
