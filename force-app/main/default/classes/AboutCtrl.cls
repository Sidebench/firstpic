public with sharing class AboutCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public String profileName { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public Account acct { get; set; }
  public String portalName { get; set; }

  public AccountClass accountClass = new AccountClass();
  public ContactClass contactClass = new ContactClass();
  public Id SessionId { get; set; }
  public List<SelectOption> options { get; set; }
  public Id SiteId = ApexPages.currentPage().getParameters().get('SiteId');

  public Contact newContact { get; set; }
  public List<Contact> contact_list { get; set; }
  public Id selectedContactId { get; set; }
  public Contact selectedContact { get; set; }
  public List<SelectOption> profiles { get; set; }

  public Id YouthId { get; set; }
  public Contact youth { get; set; }
  public List<Contact> youth_list { get; set; }

  public Id CohortId { get; set; }
  public Session__c session { get; set; }
  public List<Session__c> cohort_list { get; set; }
  public Set<Id> cohortId_set { get; set; }
  public Session__c newCohort { get; set; }

  public Date startDate { get; set; }
  public Date expoDate { get; set; }
  public Date dunsExpDate { get; set; }

  public List<SelectOption> coaches { get; set; }
  public List<SelectOption> models { get; set; }

  public Boolean displayEditOrgPopup { get; set; }
  public Boolean displayEditAddressPopup { get; set; }
  public Boolean displayAddContactPopup { get; set; }
  public Boolean displayEditContactPopup { get; set; }
  public Boolean displayAddCohortPopup { get; set; }
  public Boolean displayDeleteYouthPopup { get; set; }
  public Boolean displayDeleteContactPopup { get; set; }

  public string errorMessage { get; set; }

  public ID coachRt = Schema.SObjectType.Contact.getRecordTypeInfosByName()
    .get('Coach')
    .getRecordTypeId();
  public ID cohortRt = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
    .get('Cohort')
    .getRecordTypeId();

  public AboutCtrl() {
    currentUser = userClass.currentUser;
    profileName = currentUser.Profile.Name;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;

    newContact = new Contact();
    youth = new Contact();
    selectedContact = new Contact();

    session = new Session__c();
    newCohort = new Session__c();
    newCohort.RecordTypeId = cohortRt;

    errorMessage = '';

    models = new List<SelectOption>();
    coaches = new List<SelectOption>();
    contact_list = new List<Contact>();
    youth_list = new List<Contact>();
    cohortId_set = new Set<Id>();
    cohort_list = new List<Session__c>();

    displayEditAddressPopup = false;
    displayAddContactPopup = false;
    displayEditContactPopup = false;
    displayAddCohortPopup = false;

    acct = new Account();
    if (SiteId != null) {
      acct = accountClass.getAccount(SiteId);
    } else if (userAcct != null) {
      acct = accountClass.getAccount(userAcct.Id);
    }
    expoDate = acct.Estimated_Date_of_Expo__c;
    dunsExpDate = acct.Estimated_Date_of_Project__c;

    if (portalName == 'LEGO') {
      Schema.DescribeFieldResult fieldResult = Account.Implementation_Model__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry f : ple) {
        models.add(new SelectOption(f.getLabel(), f.getValue()));
      }

      SessionSelectOptionsCtrl ssoc = new SessionSelectOptionsCtrl();
      options = ssoc.options;

      String sId = ApexPages.currentPage().getParameters().get('SessionId');
      system.debug('sId = ' + sId);
      if ((sId == null || sId == '') && options.size() == 2) {
        String i = options[1].getValue();
        sId = Id.valueOf(i);
      }
      if (sId != null && sId != '')
        SessionId = sId;
      else
        SessionId = ssoc.sessionId;
    } else {
      profiles = new List<SelectOption>();
      profiles.add(new SelectOption('', '-- Select a Profile --'));
      if (userAcctType == 'Local Organization') {
        profiles.add(new SelectOption('Program Admin', 'Program Admin'));
        profiles.add(new SelectOption('All Access', 'All Access'));
      }
      if (userAcctType == 'National Organization') {
        profiles.add(new SelectOption('Level One', 'Level One'));
        profiles.add(new SelectOption('Level Two', 'Level Two'));
        profiles.add(new SelectOption('Level Three', 'Level Three'));
        profiles.add(new SelectOption('Treasurer', 'Treasurer'));
        profiles.add(new SelectOption('Report Builder', 'Report Builder'));
        profiles.add(new SelectOption('Read Only', 'Read Only'));
      }
      profiles.add(new SelectOption('Inactive User', 'Inactive User'));
    }
  }

  public void init() {
    cohort_list.clear();

    if (SessionId != null) {
      Session__c[] sessions = [
        SELECT Id, Name, Start_Date__c
        FROM Session__c
        WHERE Id = :SessionId
      ];
      if (sessions.size() > 0) {
        session = sessions[0];
        startDate = sessions[0].Start_Date__c;
      }

      for (Session__c s : [
        SELECT Id, Name, Coaches__c, Cohort_Size__c, Session__c
        FROM Session__c
        WHERE
          RecordType.Name = 'Cohort'
          AND Site__c = :acct.Id
          AND Session__c = :session.Id
      ]) {
        cohortId_set.add(s.Id);
        cohort_list.add(s);
      }
    }
    if (
      SessionId != null ||
      portalName == 'NPAL' ||
      portalName == 'DMV' ||
      portalName == 'MDGO'
    ) {
      getContactList();
      getYouthList();
    }
  }

  public void getContactList() {
    contact_list.clear();
    coaches.clear();

    for (Contact c : [
      SELECT
        Name,
        AccountId,
        RecordType.Name,
        Active_Status__c,
        FirstName,
        LastName,
        Email,
        Phone,
        Role__c
      FROM Contact
      WHERE AccountId = :acct.Id
    ]) {
      if (portalName == 'LEGO') {
        if (c.RecordType.Name == 'Coach') {
          contact_list.add(c);
          coaches.add(new SelectOption(c.Name, c.Name));
        }
      } else if (c.RecordType.Name != 'Youth') {
        contact_list.add(c);
      }
    }
  }

  public void getYouthList() {
    youth_list.clear();

    for (Contact c : [
      SELECT
        Id,
        AccountId,
        FirstName,
        LastName,
        Youth_ID_Number__c,
        Active_Status__c,
        Cohort__r.Session__c,
        Cohort__r.Name,
        Parent_Guardian__r.Name,
        Parent_Guardian_Name__c,
        Birthdate,
        Grade_Level__c,
        Gender__c,
        Age__c,
        School_Name__c
      FROM Contact
      WHERE AccountId = :acct.Id AND RecordType.Name = 'Youth'
      ORDER BY Name
      LIMIT 100
    ]) {
      if (portalName == 'LEGO') {
        //if(c.Parent_Guardian__r.AccountId == acct.Id || c.AccountId == acct.Id || cohortId_set.contains(c.AccountId)) {
        if (
          c.Cohort__r.Session__c == SessionId ||
          cohortId_set.contains(c.AccountId)
        ) {
          youth_list.add(c);
        }
      } else {
        youth_list.add(c);
      }
    }

    Decimal totalEnrolled = 0;
    Decimal youth = 0;
    Decimal teens = 0;
    for (Contact c : youth_list) {
      if (c.Active_Status__c == 'Active') {
        totalEnrolled += 1;
        if (c.Age__c >= 8 && c.Age__c <= 13) {
          youth += 1;
        }
        if (c.Age__c > 13) {
          teens += 1;
        }
      }
    }
    //acct.Youth_Served__c = totalEnrolled;
    acct.Number_of_8_13_Year_Olds_Enrolled__c = youth;
    acct.Number_of_Teens_Enrolled__c = teens;
  }

  public PageReference updateOrg() {
    if (expoDate != null)
      acct.Estimated_Date_of_Expo__c = expoDate;
    if (dunsExpDate != null)
      acct.New_DUNS_Exp_Date__c = dunsExpDate;
    if (startDate != null)
      session.Start_Date__c = startDate;
    try {
      accountClass.upsertAccount(acct);
      update session;
    } catch (Exception e) {
      system.debug(e.getMessage());
      errorMessage = e.getMessage();
    }

    PageReference pr = new PageReference('/' + portalName + 'About');
    pr.setRedirect(true);
    return pr;
  }

  public void addContact() {
    if (newContact.LastName != null & newContact.Email != null) {
      newContact.AccountId = acct.Id;
      if (portalName == 'LEGO') {
        newContact.RecordTypeId = coachRt;
      }
      try {
        contactClass.upsertContact(newContact);
        contact_list.add(newContact);
        displayAddContactPopup = false;
        newContact = new Contact();
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    } else if (newContact.LastName == null) {
      errorMessage = 'Last name is required';
    } else if (newContact.Email == null) {
      errorMessage = 'Email is required';
    }
  }

  public void updateContacts() {
    errorMessage = '';
    for (Contact c : contact_list) {
      if (c.LastName == null) {
        errorMessage = 'Last name is required';
      } else if (c.Email == null) {
        errorMessage = 'Email is required';
      }
      if (c.Id == null)
        c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
          .get('Contact')
          .getRecordTypeId();
    }
    system.debug('>>> errorMessage = ' + errorMessage);
    if (errorMessage == '') {
      try {
        contactClass.upsertContactList(contact_list);
        displayEditContactPopup = false;
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    }
  }

  public void deleteContact() {
    if (selectedContact.Id != null) {
      contactClass.deleteContact(selectedContact);
      displayDeleteContactPopup = false;
      init();
    }
  }

  public void deleteYouth() {
    if (youth.Id != null) {
      try {
        contactClass.deleteContact(youth);
        displayDeleteYouthPopup = false;
        getYouthList();
      } catch (Exception e) {
        system.debug(e.getMessage());
      }
    }
  }

  public void addCohort() {
    if (newCohort.Name != null) {
      if (newCohort.Coaches__c != null) {
        String c = newCohort.Coaches__c;
        c = c.replace('[', '');
        c = c.replace(']', '');
        newCohort.Coaches__c = c;
      }
      newCohort.Site__c = acct.Id;
      newCohort.Session__c = session.Id;
      try {
        upsert newCohort;
        cohort_list.add(newCohort);
        displayAddCohortPopup = false;

        newCohort = new Session__c();
        newCohort.RecordTypeId = cohortRt;
        newCohort.Site__c = acct.Id;
        newCohort.Session__c = session.Id;
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    }
  }

  // BEGIN Popups
  public void editOrgPopup() {
    if (displayEditOrgPopup == true) {
      displayEditOrgPopup = false;
    } else {
      displayEditOrgPopup = true;
    }
  }

  public void showEditAddressPopup() {
    displayEditAddressPopup = true;
  }
  public void hideEditAddressPopup() {
    displayEditAddressPopup = false;
  }

  public void addContactPopup() {
    displayAddContactPopup = true;
  }

  public void cancelAddContactPopup() {
    newContact = new Contact();
    displayAddContactPopup = false;
  }

  public void editContactPopup() {
    if (displayEditContactPopup == true) {
      displayEditContactPopup = false;
    } else {
      displayEditContactPopup = true;
    }
  }

  public void cancelEditContactPopup() {
    getContactList();
    displayEditContactPopup = false;
  }

  public void deleteContactPopup() {
    if (selectedContactId != null) {
      Contact[] contacts = [
        SELECT Id, Name
        FROM Contact
        WHERE Id = :selectedContactId
      ];
      if (contacts.size() > 0) {
        selectedContact = contacts[0];
        displayDeleteContactPopup = true;
      }
    }
  }
  public void cancelDeleteContactPopup() {
    displayDeleteContactPopup = false;
  }

  public void addCohortPopup() {
    if (displayAddCohortPopup == true) {
      displayAddCohortPopup = false;
    } else {
      displayAddCohortPopup = true;
    }
  }

  public void deleteYouthPopup() {
    if (displayDeleteYouthPopup == true) {
      displayDeleteYouthPopup = false;
    } else {
      if (YouthId != null) {
        Contact[] youths = [SELECT Id, Name FROM Contact WHERE Id = :YouthId];
        if (youths.size() > 0) {
          youth = youths[0];
          //youthName = youths[0].Name;
        }
      }
      displayDeleteYouthPopup = true;
    }
  }
}
