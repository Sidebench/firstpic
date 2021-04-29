public without sharing class StatementOfInterestCtrl {
  private UserClass uc = new UserClass();
  private UserClassWithoutSharing ucws = new UserClassWithoutSharing();
  private ApplicationClass appClass = new ApplicationClass();
  private AccountClass acctClass = new AccountClass();
  private ContactClass cc = new ContactClass();
  private getIdFromString gifs = new getIdFromString();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }

  public Application__c app { get; set; }
  public Account acct { get; set; }
  public List<Contact> contacts { get; set; }
  public Contact ga { get; set; }
  public Contact pc { get; set; }

  public String errorMessage { get; set; }
  public Boolean showSuccess { get; set; }

  public StatementOfInterestCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;

    app = new Application__c();
    String appUrlId = ApexPages.currentPage().getParameters().get('appId');
    if (appUrlId != null) {
      Id appId = gifs.getId(appUrlId);
      app = appClass.getApplication(appId);
    }

    acct = new Account();
    contacts = new List<Contact>();
    ga = new Contact();
    pc = new Contact();
  }

  // BEGIN save
  public void save() {
    errorMessage = '';
    appClass.upsertApplication(app);
  }
  // END save

  // BEGIN submit
  public PageReference submit() {
    errorMessage = '';
    fieldValidation();
    if (ApexPages.hasMessages() || errorMessage != '') {
      system.debug(
        'Apex Pages has Messages Or ErrorMessgae is not blank: ' +
        errorMessage +
        '\n' +
        apexpages.getMessages()
      );
      return null;
    } else {
      app.National_Organization_Id__c = '0013600001Pxcii';
      app.Is_Statement_of_Interest__c = true;
      app.Status__c = 'Submitted';
      app.Type__c = app.New_or_Existing__c;
      app.Submitted_Date__c = date.today();
      system.debug('app = ' + app);
      appClass.upsertApplication(app);

      if (ApexPages.hasMessages())
        errorMessage += string.valueOf(ApexPages.getMessages());
      if (errorMessage == '')
        showSuccess = true;
    }

    return null;
  }
  // END submit

  // BEGIN fieldValidation
  public void fieldValidation() {
    if (app.Organization_Type__c == null || app.Organization_Type__c == '') {
      errorMessage += 'Applicant Org Type is required <br />';
    }

    if (app.Organization_Name__c == null || app.Organization_Name__c == '')
      errorMessage += 'Organization Name is Missing <br />';

    if (
      (app.DUNS_Number__c == null || app.DUNS_Number__c == '') &&
      !app.No_DUNS_Number__c
    )
      errorMessage += 'DUNS Number is Missing <br />';

    if (app.Address__c == null || app.Address__c == '')
      errorMessage += 'Address is Missing <br />';

    if (app.City__c == null || app.City__c == '')
      errorMessage += 'City is Missing <br />';

    if (app.State__c == null || app.State__c == '')
      errorMessage += 'State is Missing <br />';

    if (app.Postal_Zip_Code__c == null || app.Postal_Zip_Code__c == '')
      errorMessage += 'Zip Code is Missing <br />';

    if (
      app.Grant_Admin_First_Name__c == null ||
      app.Grant_Admin_First_Name__c == ''
    )
      errorMessage += 'Grant Admin First Name is Missing <br />';

    if (
      app.Grant_Admin_Last_Name__c == null ||
      app.Grant_Admin_Last_Name__c == ''
    )
      errorMessage += 'Grant Admin Last Name is Missing <br />';

    if (app.Grant_Admin_Email__c == null || app.Grant_Admin_Email__c == '')
      errorMessage += 'Grant Admin Email is Missing <br />';

    if (app.Grant_Admin_Phone__c == null || app.Grant_Admin_Phone__c == '')
      errorMessage += 'Grant Admin Phone is Missing <br />';

    if (app.POC_Can_Receive_Communication__c == false) {
      if (
        app.Program_Contact_First_Name__c == null ||
        app.Program_Contact_First_Name__c == ''
      )
        errorMessage += 'Alternate First Name is Missing <br />';

      if (
        app.Program_Contact_Last_Name__c == null ||
        app.Program_Contact_Last_Name__c == ''
      )
        errorMessage += 'Alternate Last Name is Missing <br />';

      if (
        app.Program_Contact_Email__c == null ||
        app.Program_Contact_Email__c == ''
      )
        errorMessage += 'Alternate Email is Missing <br />';

      if (
        app.Program_Contact_Phone__c == null ||
        app.Program_Contact_Phone__c == ''
      )
        errorMessage += 'Alternate Phone is Missing <br />';
    }

    if (app.New_or_Existing__c == 'Existing') {
      if (app.Existing_Services__c == null || app.Existing_Services__c == '') {
        errorMessage += 'Please describe your existing victim services <br />';
      }
    }

    if (app.Strategic_Plan_Victim_Services__c) {
      if (app.Strategic_Plan__c == null || app.Strategic_Plan__c == '') {
        errorMessage += 'Please indicate when you completed a strategic plan <br />';
      }
    }

    if (
      app.Eligibility_Notice_Received__c == null ||
      app.New_or_Existing__c == null ||
      app.Needs_Assessment__c == null ||
      app.Needs_Assessment__c == '' ||
      app.Funding_to_Purchase_Vehicle__c == null ||
      app.Strategic_Plan_Victim_Services__c == null ||
      app.Authority_to_Apply__c == null
    ) {
      errorMessage += 'All fields in the Request Details section with an * are required <br />';
    }

    if (
      (app.Organization_Type__c == 'Consortium' ||
      app.Organization_Type__c == 'Designee') &&
      (app.Tribe_Represented__c == '' ||
      app.Tribe_Represented__c == null)
    ) {
      errorMessage +=
        'As a ' +
        app.Organization_Type__c +
        ' please indicate the Tribe you represent <br />';
    }
  }
  // END fieldValidation

  // BEGIN notEligible
  public PageReference notEligible() {
    app.Status__c = 'Closed';
    app.Closed_Date__c = date.today();
    appClass.upsertApplication(app);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference('/SOIList?grantType=soi');
    pr.setRedirect(true);
    return pr;
  }
  // END notEligible

  // BEGIN approve
  public PageReference approve() {
    errorMessage = '';

    if (
      app.Organization__c == null &&
      app.National_Organization__c != null &&
      app.DUNS_Number__c != null
    ) {
      Account[] accts = [
        SELECT Id, DUNS_Number__c
        FROM Account
        WHERE
          DUNS_Number__c = :app.DUNS_Number__c
          AND National_Organization__c = :app.National_Organization__c
      ];
      if (accts.size() > 0) {
        app.Organization__c = accts[0].Id;
        acct.Id = accts[0].Id;
      }
    }
    acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Local Organization')
      .getRecordTypeId();
    acct.National_Organization__c = app.National_Organization__c;
    acct.National_Organization_Name__c = app.National_Organization__r.Name;
    if (app.DUNS_Number__c != null)
      acct.DUNS__c = Integer.valueOf(app.DUNS_Number__c);
    acct.Name = app.Organization_Name__c;
    acct.BillingStreet = app.Address__c;
    acct.BillingCity = app.City__c;
    acct.BillingState = app.State__c;
    acct.BillingPostalCode = app.Postal_Zip_Code__c;

    String grants = acct.National_Grants__c;
    if (grants == null && grants != '')
      grants = 'OVC';
    else
      grants += ';OVC';
    system.debug(grants);
    acct.National_Grants__c = grants;

    User u = new User();
    u = ucws.getUser(' WHERE Alias = \'fpadmin\'');
    if (u == null)
      u = ucws.getUser(' WHERE Profile.Name = \'System Administrator\'');
    system.debug('ApplicationCtrl user for acct owner = ' + u.Name);
    if (u != null)
      acct.OwnerId = u.Id;
    acctClass.upsertAccount(acct);
    system.debug(
      'ApplicationCtrl acct after upsert = ' +
      acct.Id +
      ' ' +
      acct.Name
    );
    if (ApexPages.hasMessages() && !system.Test.isRunningTest())
      return null;

    createContacts();
    ga.AccountId = acct.Id;
    pc.AccountId = acct.Id;
    system.debug('contacts = ' + contacts);
    cc.upsertContactList(contacts);
    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'NCAI Local All Access'];
    User uga = ucws.getUser(' WHERE ContactID = \'' + ga.Id + '\'');
    if (uga == null || uga.Id == null) {
      String un = ga.Email;
      User[] dup = [SELECT Id FROM User WHERE UserName = :un];
      if (dup.size() == 0) {
        CreateCommunityUser ccu = new CreateCommunityUser();
        ccu.createUser(ga.Id, ga.Email, un, ga.FirstName, ga.LastName, p.Id);
      }
    }
    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;

    app.Organization__c = acct.Id;
    app.Status__c = 'Approved';
    appClass.upsertApplication(app);

    Application__c ovc = new Application__c(
      RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('NCAI - OVC')
        .getRecordTypeId(),
      National_Organization__c = app.National_Organization__c,
      Organization__c = acct.Id,
      Organization_Type__c = app.Organization_Type__c,
      DUNS_Number__c = app.DUNS_Number__c,
      Status__c = 'Sent to Applicant',
      Organization_Name__c = app.Organization_Name__c,
      Address__c = app.Address__c,
      City__c = app.City__c,
      State__c = app.State__c,
      Postal_Zip_Code__c = app.Postal_Zip_Code__c,
      Grant_Admin_First_Name__c = app.Grant_Admin_First_Name__c,
      Grant_Admin_Last_Name__c = app.Grant_Admin_Last_Name__c,
      Grant_Admin_Email__c = app.Grant_Admin_Email__c,
      Grant_Admin_Phone__c = app.Grant_Admin_Phone__c,
      Program_Contact_First_Name__c = app.Program_Contact_First_Name__c,
      Program_Contact_Last_Name__c = app.Program_Contact_Last_Name__c,
      Program_Contact_Email__c = app.Program_Contact_Email__c,
      Program_Contact_Phone__c = app.Program_Contact_Phone__c,
      Applied_For_Victim_Services_Program__c = app.Applied_For_Victim_Services_Program__c,
      Tribe_Represented__c = app.Tribe_Represented__c,
      Authority_to_Apply__c = app.Authority_to_Apply__c,
      Statement_of_Interest__c = app.Id
    );
    system.debug('>>>>> ovc: ' + ovc);
    appClass.upsertApplication(ovc);

    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;

    PageReference pr = new PageReference('/SOIList?grantType=soi');
    pr.setRedirect(true);
    return pr;
  }
  // END approve

  // BEGIN createContacts
  public void createContacts() {
    contacts.clear();
    Id rId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Contact')
      .getRecordTypeId();
    Map<String, Id> emails = new Map<String, Id>();
    for (Contact c : [SELECT Email FROM Contact WHERE AccountId = :acct.Id])
      emails.put(c.Email, c.Id);

    if (app.Grant_Admin_Email__c != null) {
      if (emails.containsKey(app.Grant_Admin_Email__c))
        ga.Id = emails.get(app.Grant_Admin_Email__c);
      ga.Role__c = 'Grant Administrator';
      ga.FirstName = app.Grant_Admin_First_Name__c;
      ga.LastName = app.Grant_Admin_Last_Name__c;
      ga.Email = app.Grant_Admin_Email__c;
      ga.Phone = app.Grant_Admin_Phone__c;
      ga.RecordTypeId = rId;
      contacts.add(ga);
    }

    if (app.Program_Contact_Email__c != null) {
      if (emails.containsKey(app.Program_Contact_Email__c))
        pc.Id = emails.get(app.Program_Contact_Email__c);
      pc.Role__c = 'Program Coordinator';
      pc.FirstName = app.Program_Contact_First_Name__c;
      pc.LastName = app.Program_Contact_Last_Name__c;
      pc.Email = app.Program_Contact_Email__c;
      pc.Phone = app.Program_Contact_Phone__c;
      pc.RecordTypeId = rId;
      contacts.add(pc);
    }
  }
  // END createContacts
}
