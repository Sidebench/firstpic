public with sharing class SiteDetailsCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }
  public String approverLevel { get; set; }

  private AccountClass accountClass = new AccountClass();
  private ContactClass contactClass = new ContactClass();
  private ApplicationClass appClass = new ApplicationClass();
  private PaginationClass pc = new PaginationClass();
  private getIdFromString gifs = new getIdFromString();

  public Contact newContact { get; set; }
  public List<Contact> contacts { get; set; }
  public Id selectedContactId { get; set; }
  public Contact selectedContact { get; set; }
  public String contactSiteId { get; set; }
  public List<SelectOption> siteOptions { get; set; }
  public List<SelectOption> profileOptions { get; set; }

  public Id siteId { get; set; }
  public Account acct { get; set; }
  public List<Account> allSites { get; set; }
  public List<Account> sites { get; set; }
  public String siteName { get; set; }
  public Id selectedSiteId { get; set; }
  public Application__c soi { get; set; }
  public Application__c app { get; set; }
  public String appType { get; set; }
  public List<SelectOption> appTypeOptions { get; set; }

  public List<Contact> allYouth { get; set; }
  public List<Contact> youth { get; set; }
  public String youthName { get; set; }
  public String youthSiteId { get; set; }

  public Boolean displayEditOrgPopup { get; set; }
  public Boolean displayAddContactPopup { get; set; }
  public Boolean displayEditContactPopup { get; set; }
  public Boolean displayDeleteContactPopup { get; set; }
  public Boolean displaySendApplicationPopup { get; set; }

  public string errorMessage { get; set; }

  Integer siteCounter = 0;
  Integer siteLimitSize = 20;
  Integer siteTotalSize = 0;
  public String siteRecordCount { get; set; }
  public Boolean siteDisablePrevious { get; set; }
  public Boolean siteDisableNext { get; set; }

  Integer youthCounter = 0;
  Integer youthLimitSize = 20;
  Integer youthTotalSize = 0;
  public String youthRecordCount { get; set; }
  public Boolean youthDisablePrevious { get; set; }
  public Boolean youthDisableNext { get; set; }

  public TALogCtrl logCtrl = new TALogCtrl();
  public TALogCtrl getTALogCtrl() {
    return logCtrl;
  }

  public SiteDetailsCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;
    approverLevel = userClass.approverLevel;

    newContact = new Contact();
    selectedContact = new Contact();
    contacts = new List<Contact>();
    allSites = new List<Account>();
    sites = new List<Account>();
    allYouth = new List<Contact>();
    youth = new List<Contact>();
    soi = new Application__c();
    app = new Application__c();
    errorMessage = '';

    String urlSiteID = ApexPages.currentPage().getParameters().get('siteId');
    siteId = gifs.getId(urlSiteID);
    String urlOrgID = ApexPages.currentPage().getParameters().get('orgId');
    Id orgId = gifs.getId(urlOrgID);

    acct = new Account();
    if (siteId != null)
      acct = accountClass.getAccount(siteId);
    else if (orgId != null)
      acct = accountClass.getAccount(orgId);
    else if (userAcct != null)
      acct = accountClass.getAccount(userAcct.Id);

    siteOptions = new List<SelectOption>();
    siteOptions.add(new SelectOption('', '-- Select a Site --'));
    for (
      Account a : accountClass.getRelatedAccountList(
        acct.Id,
        userAcctType,
        '',
        '',
        null
      )
    ) {
      siteOptions.add(new SelectOption(a.Id, a.Name));
    }

    profileOptions = new List<SelectOption>();
    profileOptions.add(new SelectOption('', '-- Select a Profile --'));
    profileOptions.add(new SelectOption('Program Admin', 'Program Admin'));
    profileOptions.add(new SelectOption('All Access', 'All Access'));
    profileOptions.add(new SelectOption('Inactive User', 'Inactive User'));

    appTypeOptions = new List<SelectOption>();
    if (portalName == 'Ripken') {
      appTypeOptions.add(
        new SelectOption('Ripken Special Initiative', 'Special Initiative')
      );
      appTypeOptions.add(
        new SelectOption('Ripken Baseball', 'Badges for Baseball')
      );
      appTypeOptions.add(new SelectOption('Ripken I\'m GREAT', 'I\'m GREAT'));
      appTypeOptions.add(
        new SelectOption('Ripken Healthy Lifestyles', 'Healthy Lifestyles')
      );
      appType = 'Ripken Baseball';
    } else if (portalName.contains('TRAIL')) {
      appType = 'NCAI - TRAIL';
    }
  }

  public void getLists() {
    getRelatedContactList();
    getRelatedAccountList();
    if (portalName.contains('NCAI')) {
      getRelatedYouthList();
      Application__c[] items = appClass.getRelatedApplicationList(
        acct.Id,
        null,
        null,
        ' AND RecordType.Name = \'NCAI - SOI\'',
        null,
        null
      );
      if (items.size() > 0) {
        soi = items[0];
      }
    }
  }

  public void getRelatedAccountList() {
    sites.clear();
    allSites = accountClass.getRelatedAccountList(
      acct.Id,
      userAcctType,
      'Local Organization',
      siteName,
      null
    );
    siteTotalSize = allSites.size();
    siteFirst();
  }

  public void getRelatedContactList() {
    contacts.clear();
    contacts = contactClass.getRelatedContactList(
      acct.Id,
      'Contact',
      null,
      null
    );
  }

  public void getRelatedYouthList() {
    youth.clear();
    Id aId = acct.Id;
    if (youthSiteId != null && youthSiteId != '')
      aId = Id.valueOf(youthSiteId);
    allYouth = contactClass.getRelatedContactList(
      aId,
      'Youth',
      youthName,
      null
    );
    youthTotalSize = allYouth.size();
    youthFirst();
  }

  public void upsertOrg() {
    accountClass.upsertAccount(acct);
    displayEditOrgPopup = false;
  }

  public void upsertContact() {
    if (selectedContact.LastName != null & selectedContact.Email != null) {
      if (selectedContact.RecordTypeId == null)
        selectedContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
          .get('Contact')
          .getRecordTypeId();
      if (contactSiteId != null && contactSiteId != '')
        selectedContact.AccountId = Id.valueOf(contactSiteId);
      if (selectedContact.AccountID == null)
        selectedContact.AccountID = acct.Id;
      try {
        contactClass.upsertContact(selectedContact);
        displayEditContactPopup = false;
        errorMessage = '';
        getRelatedContactList();
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    } else if (selectedContact.LastName == null) {
      errorMessage = 'Last name is required';
    } else if (selectedContact.Email == null) {
      errorMessage = 'Email is required';
    }
  }

  public void deleteContact() {
    if (selectedContact.Id != null) {
      contactClass.deleteContact(selectedContact);
      displayDeleteContactPopup = false;
    }
  }

  public void sendApplication() {
    if (app.National_Organization__c == null)
      app.National_Organization__c = userAcct.Id;
    if (appType != null)
      app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get(appType)
        .getRecordTypeId();
    if (app.Organization__c == null || app.Primary_Approver__c == null) {
      app.Primary_Approver__c = currentUser.ContactId;
      app.Primary_Approver_Email__c = currentUser.Contact.Email;
    }
    app.Status__c = 'Sent to Applicant';
    appClass.upsertApplication(app);
    if (!ApexPages.hasMessages())
      displaySendApplicationPopup = false;
    else
      errorMessage = String.valueOf(ApexPages.getMessages());
  }

  // BEGIN Popups
  public void showEditOrgPopup() {
    displayEditOrgPopup = true;
  }
  public void hideEditOrgPopup() {
    displayEditOrgPopup = false;
  }

  public void showEditRelatedContactPopup() {
    if (selectedContactId != null) {
      selectedContact = contactClass.getContact(selectedContactId);
      contactSiteId = selectedContact.AccountId;
    } else {
      selectedContact = new Contact();
      contactSiteId = '';
    }
    displayEditContactPopup = true;
  }
  public void hideEditRelatedContactPopup() {
    displayEditContactPopup = false;
  }

  public void showDeleteContactPopup() {
    if (selectedContactId != null) {
      Contact[] c = [
        SELECT Id, Name
        FROM Contact
        WHERE Id = :selectedContactId
      ];
      if (c.size() > 0) {
        selectedContact = c[0];
        displayDeleteContactPopup = true;
      }
    }
  }
  public void hideDeleteContactPopup() {
    displayDeleteContactPopup = false;
  }

  public void showSendApplicationPopup() {
    app = new Application__c();
    system.debug('selectedSiteId = ' + selectedSiteId);
    if (selectedSiteId != null) {
      Account a = accountClass.getAccount(selectedSiteId);
      if (a.Id != null) {
        if (portalName.contains('NCAI')) {
          Grant__c[] grants = [
            SELECT Amount__c
            FROM Grant__c
            WHERE Account__c = :a.Id
          ];
          if (grants.size() > 0) {
            app.Previous_Award_Amount__c = grants[0].Amount__c;
            app.Type__c = 'Existing';
          } else {
            app.Type__c = 'New';
          }
        }
        app.Organization__c = a.Id;
        app.Organization_Name__c = a.Name;
        app.National_Organization__c = a.National_Organization_Id__c;
        app.Primary_Approver__c = a.Primary_Approver__c;
        app.Primary_Approver_Email__c = a.Primary_Approver_Email__c;
        app.Applicant_Name__c = a.CEO_Name__c;
        app.Applicant_Email__c = a.CEO_Email__c;
        app.Address__c = a.BillingStreet;
        app.City__c = a.BillingCity;
        app.State__c = a.Billing_State_Long__c;
        app.Postal_Zip_Code__c = a.BillingPostalCode;
        app.Mailing_Address__c = a.ShippingStreet;
        app.Mailing_City__c = a.ShippingCity;
        app.Mailing_State__c = a.Shipping_State_Long__c;
        app.Mailing_Postal_Code__c = a.ShippingPostalCode;
        app.EIN__c = a.EIN__c;
        app.Website__c = a.Website;
        app.Phone__c = a.Phone;
        app.Fax__c = a.Fax;
        app.DUNS_Number__c = a.DUNS_Number__c;
      }
    }
    displaySendApplicationPopup = true;
  }
  public void hideSendApplicationPopup() {
    displaySendApplicationPopup = false;
  }
  // END popups

  // BEGIN Site Pagination
  public void siteFirst() {
    siteCounter = 0;
    if (allSites.size() > 0) {
      sites = pc.first(allSites, siteLimitSize);
      siteRecordCount = pc.getRecordCount(
        siteCounter,
        siteLimitSize,
        siteTotalSize
      );
      siteDisablePrevious = true;
      siteDisableNext = pc.getDisableNext(
        siteCounter,
        siteLimitSize,
        siteTotalSize
      );
    }
  }

  public void siteNext() {
    siteCounter = siteCounter + siteLimitSize;
    sites = pc.next(allSites, siteCounter, siteLimitSize);
    siteRecordCount = pc.getRecordCount(
      siteCounter,
      siteLimitSize,
      siteTotalSize
    );
    siteDisablePrevious = false;
    siteDisableNext = pc.getDisableNext(
      siteCounter,
      siteLimitSize,
      siteTotalSize
    );
  }

  public void sitePrevious() {
    siteCounter = siteCounter - siteLimitSize;
    sites = pc.previous(allSites, siteCounter, siteLimitSize);
    siteRecordCount = pc.getRecordCount(
      siteCounter,
      siteLimitSize,
      siteTotalSize
    );
    siteDisablePrevious = pc.getDisablePrevious(siteCounter);
    siteDisableNext = false;
  }

  public void siteLast() {
    siteCounter = pc.getLastCounter(siteCounter, siteLimitSize, siteTotalSize);
    sites = pc.last(allSites, siteCounter, siteLimitSize);
    siteRecordCount = pc.getRecordCount(
      siteCounter,
      siteLimitSize,
      siteTotalSize
    );
    siteDisablePrevious = false;
    siteDisableNext = true;
  }
  // END Site Pagination

  // BEGIN Youth Pagination
  public void youthFirst() {
    youthCounter = 0;
    if (allYouth.size() > 0) {
      youth = pc.first(allYouth, youthLimitSize);
      youthRecordCount = pc.getRecordCount(
        youthCounter,
        youthLimitSize,
        youthTotalSize
      );
      youthDisablePrevious = true;
      youthDisableNext = pc.getDisableNext(
        youthCounter,
        youthLimitSize,
        youthTotalSize
      );
    }
  }

  public void youthNext() {
    youthCounter = youthCounter + youthLimitSize;
    youth = pc.next(allYouth, youthCounter, youthLimitSize);
    youthRecordCount = pc.getRecordCount(
      youthCounter,
      youthLimitSize,
      youthTotalSize
    );
    youthDisablePrevious = false;
    youthDisableNext = pc.getDisableNext(
      youthCounter,
      youthLimitSize,
      youthTotalSize
    );
  }

  public void youthPrevious() {
    youthCounter = youthCounter - youthLimitSize;
    youth = pc.previous(allYouth, youthCounter, youthLimitSize);
    youthRecordCount = pc.getRecordCount(
      youthCounter,
      youthLimitSize,
      youthTotalSize
    );
    youthDisablePrevious = pc.getDisablePrevious(youthCounter);
    youthDisableNext = false;
  }

  public void youthLast() {
    youthCounter = pc.getLastCounter(
      youthCounter,
      youthLimitSize,
      youthTotalSize
    );
    youth = pc.last(allYouth, youthCounter, youthLimitSize);
    youthRecordCount = pc.getRecordCount(
      youthCounter,
      youthLimitSize,
      youthTotalSize
    );
    youthDisablePrevious = false;
    youthDisableNext = true;
  }
  // END Youth Pagination
}
