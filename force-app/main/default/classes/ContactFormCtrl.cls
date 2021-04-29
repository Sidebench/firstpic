public class ContactFormCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public Account acct { get; set; }
  public String portalName { get; set; }

  public Id SessionId { get; set; }
  public Id ContactId { get; set; }
  public Id ParentId { get; set; }
  public Id CohortId { get; set; }

  public Contact youth { get; set; }
  public Contact parent { get; set; }
  public Date birthdate { get; set; }

  public ContactClass contactClass = new ContactClass();
  public List<Contact> contact_list { get; set; }
  public String lastName { get; set; }
  public String email { get; set; }
  public String errorMessage { get; set; }

  public Map<Id, String> cohort_map { get; set; }
  public String cohortName { get; set; }

  public Boolean searchMode { get; set; }
  public Boolean displayContactPopup { get; set; }
  public Boolean displayCohortPopup { get; set; }

  public ContactFormCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    portalName = userClass.userProfile;

    youth = new Contact();
    parent = new Contact();

    SessionId = ApexPages.currentPage().getParameters().get('SessionId');
    ContactId = ApexPages.currentPage().getParameters().get('ContactId');
    cohort_map = new Map<Id, String>();
    contact_list = new List<Contact>();

    lastName = '';
    email = '';
    errorMessage = '';

    searchMode = false;
    displayContactPopup = false;
    displayCohortPopup = false;

    if (userAcct != null) {
      AccountClass accountClass = new AccountClass();
      acct = accountClass.getAccount(userAcct.Id);

      if (ContactId != null) {
        youth = contactClass.getContact(ContactId);
        birthdate = youth.Birthdate;
        cohortName = youth.Cohort__r.Name;
        if (youth.Parent_Guardian__c != null) {
          ContactClass p = new ContactClass();
          parent = p.getContact(youth.Parent_Guardian__c);
        }
        if (SessionId == null)
          SessionId = youth.Cohort__r.Session__r.Id;
      }

      if (SessionId != null) {
        Session__c[] sessions = [
          SELECT Id, Name
          FROM Session__c
          WHERE Id = :SessionId
        ];
        if (sessions.size() > 0) {
          if (youth.Current_Session__c == null) {
            youth.Current_Session__c = sessions[0].Id;
          }
          if (youth.Session_One_2017__c == null) {
            youth.Session_One_2017__c = sessions[0].Id;
          }

          for (Session__c s : [
            SELECT Id, Name
            FROM Session__c
            WHERE RecordType.Name = 'Cohort' AND Session__c = :sessions[0].Id
          ]) {
            cohort_map.put(s.Id, s.Name);
          }
        }
      }
    }
  }

  public void contactSearch() {
    String qry =
      'SELECT AccountId, Name, FirstName, LastName, Email FROM Contact WHERE AccountId = \'' +
      acct.Id +
      '\' AND RecordType.Name = \'Parent/Guardian\'';
    system.debug('>>> lastName = ' + lastName);
    if (lastName != '') {
      qry += ' AND lastName = \'' + lastName + '\'';
    }
    system.debug('>>> email = ' + email);
    if (email != '') {
      qry += ' AND email = \'' + email + '\'';
    }
    system.debug('>>> qry = ' + qry);
    contact_list = Database.query(qry);
    system.debug('>>> contact_list = ' + contact_list);
  }

  public void upsertParent() {
    errorMessage = '';
    if (parent.Id == null) {
      parent.AccountId = acct.Id;
    }
    parent.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Parent/Guardian')
      .getRecordTypeId();
    if (parent.LastName != null) {
      try {
        contactClass.upsertContact(parent);
        youth.Parent_Guardian__c = parent.Id;
        system.debug('>>> parent upsert successful. parent = ' + parent);
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    } else {
      errorMessage = 'Parent last name is required';
    }
    displayContactPopup = false;
  }

  public void upsertYouth() {
    if (youth.Active_Status__c == null) {
      youth.Active_Status__c = 'Active';
    }
    errorMessage = '';
    if (youth.Id == null && youth.AccountId == null) {
      youth.AccountId = acct.Id;
    }
    youth.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Youth')
      .getRecordTypeId();
    youth.Birthdate = birthdate;
    if (youth.LastName == null) {
      errorMessage = 'Last name is required';
    }
    if (portalName == 'LEGO') {
      if (youth.Cohort__c == null)
        errorMessage = 'Cohort is required';
      if (youth.Gender__c == null)
        errorMessage = 'Gender is required';
    }
    if (errorMessage == '') {
      try {
        contactClass.upsertContact(youth);
        system.debug('>>> youth upsert successful. youth = ' + youth);
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    }
  }

  public void selectContact() {
    ContactClass p = new ContactClass();
    parent = p.getContact(ParentId);
    youth.Parent_Guardian__c = parent.Id;
    displayContactPopup = false;
  }

  public void selectCohort() {
    youth.Cohort__c = CohortId;
    displayCohortPopup = false;
  }

  public PageReference save() {
    upsertYouth();
    if (errorMessage == '') {
      string url = '';
      if (portalName == 'LEGO')
        url = '?SessionId=' + SessionId;
      PageReference pr = new PageReference('/' + portalName + 'About' + url);
      pr.setRedirect(true);
      return pr;
    }
    system.debug('>>> errorMessage = ' + errorMessage);
    return null;
  }

  public void saveAndAdd() {
    upsertYouth();
    youth = new Contact();
    parent = new Contact();
    contact_list.clear();
    cohortName = '';
    lastName = '';
    email = '';
    birthdate = null;
    errorMessage = '';
  }

  public PageReference returnToAbout() {
    string url = '';
    if (portalName == 'LEGO')
      url = '?SessionId=' + SessionId;
    PageReference pr = new PageReference('/' + portalName + 'About' + url);
    pr.setRedirect(true);
    return pr;
  }

  public void contactPopup() {
    if (displayContactPopup == true) {
      displayContactPopup = false;
    } else {
      displayContactPopup = true;
    }
  }

  public void cohortPopup() {
    if (displayCohortPopup == true) {
      displayCohortPopup = false;
    } else {
      displayCohortPopup = true;
    }
  }
}
