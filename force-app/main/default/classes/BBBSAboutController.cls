public with sharing class BBBSAboutController {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }

  private AccountClass accountClass = new AccountClass();
  private ContactClass contactClass = new ContactClass();
  private UserClassWithoutSharing ucws = new UserClassWithoutSharing();
  private getIdFromString gifs = new getIdFromString();

  public Id orgId { get; set; }
  public Account acct { get; set; }
  public List<Contact> contact_list { get; set; }
  public Contact newContact { get; set; }
  public Contact selectedContact { get; set; }
  public Id selectedContactId { get; set; }
  public Boolean selectedContactIsUser { get; set; }
  public List<SelectOption> profiles { get; set; }

  public List<User> user_list { get; set; }
  public User selectedUser { get; set; }
  public Id selectedUserId { get; set; }
  public Boolean showInactiveUsers { get; set; }

  public List<Assessment__c> assess_list { get; set; }
  public Assessment__c sa { get; set; }
  public Id selectedSAId { get; set; }
  public String selectedSAStart { get; set; }
  public Id AssessmentId { get; set; }
  public Boolean hasContacts { get; set; }

  //public Boolean shouldDeactivateAndDelete { get; set; }
  public Date dunsExpDate { get; set; }
  public Boolean displayEditDunsPopup { get; set; }
  public Boolean displayAddContactPopup { get; set; }
  public Boolean displayEditContactPopup { get; set; }
  public Boolean displayDeleteContactPopup { get; set; }
  public Boolean displayUserPopup { get; set; }
  public Boolean displayAssessmentPopup { get; set; }

  public string errorMessage { get; set; }

  public BBBSAboutController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;

    acct = new Account();
    contact_list = new List<Contact>();
    user_list = new List<User>();
    newContact = new Contact();
    selectedContact = new Contact();
    assess_list = new List<Assessment__c>();
    sa = new Assessment__c();
    selectedSAStart = 'AssessmentP01';

    String urlOrgId = ApexPages.currentPage().getParameters().get('orgId');
    orgId = gifs.getId(urlOrgId);

    if (orgId != null)
      acct = accountClass.getAccount(orgId);
    else if (userAcct != null)
      acct = accountClass.getAccount(userAcct.Id);

    if (acct != null) {
      newContact = new Contact();
      newContact.AccountId = acct.Id;
      //shouldDeactivateAndDelete = false;
      showInactiveUsers = false;

      getUsers();

      profiles = new List<SelectOption>();
      profiles.add(new SelectOption('', '-- Select a Profile --'));
      if (userAcctType == 'Local Organization') {
        profiles.add(
          new SelectOption('Self Assessment Only', 'Self Assessment Only')
        );
        profiles.add(new SelectOption('All Access', 'All Access'));
      }
      if (userAcctType == 'National Organization') {
        profiles.add(new SelectOption('Level One', 'Level One'));
        profiles.add(new SelectOption('Level Two', 'Level Two'));
        profiles.add(new SelectOption('Level Two Admin', 'Level Two Admin'));
        profiles.add(new SelectOption('Level Three', 'Level Three'));
      }
      profiles.add(new SelectOption('Inactive User', 'Inactive User'));
    }
  }

  public void getLists() {
    contact_list.clear();
    assess_list.clear();
    hasContacts = true;
    Boolean CEO = false;
    Boolean BoardChair = false;
    Boolean ProgramLead = false;
    Boolean FundDevelopmentLead = false;
    Boolean FinanceLead = false;
    Boolean MarketingRecruitmentLead = false;

    for (
      Contact c : contactClass.getRelatedContactList(
        acct.Id,
        'Contact',
        null,
        ' AND Is_Deleted__c = false'
      )
    ) {
      if (c.AccountId == acct.Id) {
        contact_list.add(c);
        if (c.Role__c == 'CEO') {
          CEO = true;
        }
        if (c.Role__c == 'Board Chair') {
          BoardChair = true;
        }
        if (c.Role__c == 'Program Lead') {
          ProgramLead = true;
        }
        if (c.Role__c == 'Fund Development Lead') {
          FundDevelopmentLead = true;
        }
        if (c.Role__c == 'Finance Lead') {
          FinanceLead = true;
        }
        if (c.Role__c == 'Marketing/Recruitment Lead') {
          MarketingRecruitmentLead = true;
        }
      }
    }
    if (CEO == false) {
      hasContacts = false;
    }
    if (BoardChair == false) {
      hasContacts = false;
    }
    if (ProgramLead == false) {
      hasContacts = false;
    }
    if (FundDevelopmentLead == false) {
      hasContacts = false;
    }
    if (FinanceLead == false) {
      hasContacts = false;
    }
    if (MarketingRecruitmentLead == false) {
      hasContacts = false;
    }

    for (Assessment__c a : [
      SELECT
        Id,
        Year__c,
        Organization__c,
        CreatedDate,
        LastModifiedDate,
        Submitted_Date__c,
        Assessment_Status__c,
        Attachment_Status__c,
        Compliance_Status__c
      FROM Assessment__c
      WHERE Organization__c = :acct.Id
      ORDER BY Year__c DESC
    ]) {
      if (a.Year__c == 2020) {
        sa = a;
      } else {
        assess_list.add(a);
      }
    }
  }

  public void getUsers() {
    String soqlWHERE = ' WHERE AccountId = \'' + userAcct.Id + '\'';
    if (!showInactiveUsers)
      soqlWHERE += ' AND IsActive = true';
    user_list = ucws.getUserList(soqlWHERE);
  }

  public void updateOrg() {
    if (dunsExpDate != null) {
      acct.New_DUNS_Exp_Date__c = dunsExpDate;
      acct.DUNS_Review_Status__c = 'Submitted';
    }
    try {
      accountClass.upsertAccount(acct);
    } catch (Exception e) {
      system.debug(e.getMessage());
      errorMessage = e.getMessage();
    }
    displayEditDUNSPopup = false;
  }

  public void addContact() {
    if (newContact.LastName != null & newContact.Email != null) {
      try {
        contactClass.upsertContact(newContact);
        newContact = new Contact();
        newContact.AccountId = acct.Id;
        getLists();
        displayAddContactPopup = false;
        errorMessage = '';
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
    if (selectedContact.LastName == null) {
      errorMessage = 'Last name is required';
    } else if (selectedContact.Email == null) {
      errorMessage = 'Email is required';
    }
    if (errorMessage == '') {
      try {
        contactClass.upsertContact(selectedContact);
        displayEditContactPopup = false;
        getLists();
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    }
  }
  /* MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa)
    public void deactivateAndDelete() {
        selectedContact.Is_Deleted__c = true;
        contactClass.upsertContact(selectedContact);
        selectedUser.IsActive = false;
        ucws.updateUser(selectedUser);
        getLists();
        getUsers();
        displayUserPopup = false;
    }
    */
  public void deleteContact() {
    selectedContact.Is_Deleted__c = true;
    contactClass.upsertContact(selectedContact);
    getLists();
    displayDeleteContactPopup = false;
  }

  public void deactivateUser() {
    selectedUser.IsActive = false;
    ucws.updateUser(selectedUser);
    getUsers();
    displayUserPopup = false;
  }

  public void addContactPopup() {
    displayAddContactPopup = true;
  }
  public void cancelAddContactPopup() {
    displayAddContactPopup = false;
  }

  public void editContactPopup() {
    errorMessage = '';
    if (selectedContactId != null) {
      selectedContact = contactClass.getContact(selectedContactId);
    }
    displayEditContactPopup = true;
  }
  public void cancelEditContactPopup() {
    displayEditContactPopup = false;
  }

  public void deleteContactPopup() {
    errorMessage = '';
    selectedContactIsUser = false;
    selectedUser = null;
    if (selectedContactId != null) {
      selectedContact = contactClass.getContact(selectedContactId);
      selectedUser = ucws.getUser(
        ' WHERE IsActive = true AND ContactId = \'' +
        selectedContactId +
        '\''
      );
      if (selectedUser != null)
        selectedContactIsUser = true;
      displayDeleteContactPopup = true;
      /*
            if(selectedUser.Id != null) {
                shouldDeactivateAndDelete = true;
                deactivateUserPopup();
            } else {
                displayDeleteContactPopup = true; 
            }
            */
    }
  }
  public void cancelDeleteContactPopup() {
    displayDeleteContactPopup = false;
  }

  public void deactivateUserPopup() {
    errorMessage = '';
    if (selectedUserId != null) {
      selectedUser = ucws.getUser(' WHERE Id = \'' + selectedUserId + '\'');
    }
    displayUserPopup = true;
  }
  public void cancelDeactivateUserPopup() {
    displayUserPopup = false;
  }

  public void showAssessmentPopup() {
    if (selectedSAId != null) {
      for (Assessment__c sa : [
        SELECT Hide_Standards__c, Year__c
        FROM Assessment__c
        WHERE Id = :selectedSAId
      ]) {
        if (sa.Year__c < 2019)
          selectedSAStart = 'AssessmentPage1';
        if (sa.Hide_Standards__c)
          selectedSAStart = 'AssessmentPage9';
      }
      displayAssessmentPopup = true;
    }
  }
  public void hideAssessmentPopup() {
    displayAssessmentPopup = false;
  }

  public void showEditDUNSPopup() {
    displayEditDUNSPopup = true;
  }
  public void hideEditDUNSPopup() {
    displayEditDUNSPopup = false;
  }
}
