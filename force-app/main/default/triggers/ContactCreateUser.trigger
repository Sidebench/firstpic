trigger ContactCreateUser on Contact(after insert, after update) {
  Map<String, Contact> contact_map = new Map<String, Contact>();
  List<Contact> contact_list = new List<Contact>();
  List<Contact> update_list = new List<Contact>();
  Set<Id> uId_set = new Set<Id>();
  List<User> user_list = new List<User>();
  List<User> newUser_list = new List<User>();

  Profile bbbs = [SELECT Id FROM Profile WHERE Name = 'BBBS Community Login'];
  Profile npal = [SELECT Id FROM Profile WHERE Name = 'NPAL Community Login'];
  //Profile lego = [SELECT Id FROM Profile WHERE Name = 'LEGO Community Login'];

  for (Contact c : [
    SELECT
      Id,
      Is_Community_User__c,
      Account.Name,
      Account.National_Organization__r.Name,
      FirstName,
      LastName,
      Email
    FROM Contact
    WHERE Id IN :Trigger.new
  ]) {
    if (
      c.Is_Community_User__c &&
      (Trigger.isInsert ||
      c.Is_Community_User__c != Trigger.oldMap.get(c.Id).Is_Community_User__c)
    ) {
      contact_list.add(c);
    }
    if (
      !c.Is_Community_User__c &&
      Trigger.isUpdate &&
      (c.Is_Community_User__c != Trigger.oldMap.get(c.Id).Is_Community_User__c)
    ) {
      update_list.add(c);
    }
  }

  for (User u : [
    SELECT Id, Contact.Id
    FROM User
    WHERE ContactId IN :contact_list
  ]) {
    uId_set.add(u.Contact.Id);
  }

  for (Contact c : contact_list) {
    if (!uId_set.contains(c.Id)) {
      string alias = c.FirstName.substring(0, 1) + c.LastName;
      if (alias.length() > 7) {
        alias = alias.substring(0, 6);
      }
      User u = new User(
        Email = c.Email,
        FirstName = c.FirstName,
        LastName = c.LastName,
        UserName = c.Email,
        Contact = c,
        ContactId = c.Id,
        Alias = alias,
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'GMT',
        IsActive = true
      );
      if (
        c.Account.Name.containsIgnoreCase('Big Brothers') ||
        (c.Account.National_Organization__c != null &&
        c.Account.National_Organization__r.Name.containsIgnoreCase(
          'Big Brothers'
        ))
      ) {
        u.ProfileId = bbbs.Id;
      }
      if (
        c.Account.Name.containsIgnoreCase('NPAL') ||
        (c.Account.National_Organization__c != null &&
        c.Account.National_Organization__r.Name.containsIgnoreCase('NPAL'))
      ) {
        u.ProfileId = npal.Id;
      }
      //if(c.Account.National_Organization__r.Name.containsIgnoreCase('Lego')) {
      //    u.ProfileId = lego.Id;
      //}
      newUser_list.add(u);
    }
  }
  if (newUser_list.size() > 0) {
    try {
      insert newUser_list;
      System.Debug(
        '>>>> User(s) created successfully. newUser_list = ' + newUser_list
      );
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  if (update_list.size() > 0) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    // Set list of people who should get the email
    List<String> sendTo = new List<String>();
    sendTo.add('melaina@s4g.us');
    email.setToAddresses(sendTo);

    // Set email contents
    email.setSubject('User isActive Update Needed');
    String body =
      'The following contacts have been removed from ' +
      System.URL.getSalesforceBaseURL().toExternalForm() +
      ': ';
    for (Contact c : update_list) {
      body += c.Id + ', ';
    }
    body.removeEnd(', ');
    body += '.';
    email.setHtmlBody(body);

    // Send all
    emails.add(email);
    Messaging.sendEmail(emails);
  }
}
