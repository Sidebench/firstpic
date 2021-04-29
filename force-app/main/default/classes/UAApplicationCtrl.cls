public without sharing class UAApplicationCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private UserClassWithoutSharing ucws = new UserClassWithoutSharing();
  private AccountClass acctClass = new AccountClass();
  private ContactClass cc = new ContactClass();
  private ApplicationClass appClass = new ApplicationClass();
  private GrantClass gc = new GrantClass();
  private DCTATReportClass drc = new DCTATReportClass();
  private CreateMOUCtrl mou = new CreateMOUCtrl();
  private getIdFromString gifs = new getIdFromString();

  public Id appId { get; set; }
  public String appType { get; set; }
  public Application__c app { get; set; }
  public Application_Review__c review { get; set; }
  public List<Application_Review__c> reviews { get; set; }
  public String title { get; set; }
  public Decimal awardAmount { get; set; }
  public Date startDate { get; set; }
  public Date endDate { get; set; }
  public Decimal score { get; set; }

  private SchemaPicklistFields spf = new SchemaPicklistFields();
  public List<SelectOption> impactedOptions { get; set; }
  public List<SelectOption> incomeOptions { get; set; }
  public List<SelectOption> genderOptions { get; set; }

  public Account acct { get; set; }
  public List<Contact> contacts { get; set; }
  public Contact ceo { get; set; }
  public Contact pc { get; set; }

  public Id grantId { get; set; }
  public Grant__c sg { get; set; }

  public String grant { get; set; }
  public List<SelectOption> grantOptions { get; set; }

  public String notesPopupType { get; set; }
  public Boolean displayScorePopup { get; set; }
  public Boolean displayAwardPopup { get; set; }
  public Boolean displayNotesPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }

  String url = '/UAApplicationList';
  public Boolean readOnly { get; set; }
  public Boolean reviewed { get; set; }
  public Boolean showSuccess { get; set; }
  public String errorMessage { get; set; }

  public Attachment att501 { get; set; }
  public Attachment attBB { get; set; }
  public Attachment attW9 { get; set; }
  public Attachment att990 { get; set; }
  public Attachment attFunding { get; set; }
  public Attachment attLogo { get; set; }

  public UAApplicationCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    approverLevel = uc.approverLevel;

    app = new Application__c();
    review = new Application_Review__c();
    reviews = new List<Application_Review__c>();
    acct = new Account();
    contacts = new List<Contact>();
    ceo = new Contact();
    pc = new Contact();
    sg = new Grant__c();

    portalName = 'UA';
    app.National_Organization_Id__c = '00136000015aFIy';
    readOnly = true;
    reviewed = false;

    att501 = new Attachment();
    attBB = new Attachment();
    attW9 = new Attachment();
    att990 = new Attachment();
    attFunding = new Attachment();
    attLogo = new Attachment();

    String grantUrlId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(grantUrlId);

    String url = (ApexPages.currentPage().getUrl()).toLowerCase();
    if (url.contains('freedom')) {
      appType = 'freedom';
      app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('UA Freedom')
        .getRecordTypeId();
    } else if (url.contains('catalyst')) {
      appType = 'catalyst';
      app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('UA Catalyst')
        .getRecordTypeId();
    } else {
      appType = 'pride';
      app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('UA Pride')
        .getRecordTypeId();
    }

    if (grantId == null) {
      String appUrlId = ApexPages.currentPage().getParameters().get('appId');
      appId = gifs.getId(appUrlId);
      if (appId != null) {
        app = appClass.getApplication(appId);

        if (userAcctType == 'National Organization') {
          readOnly = true;
        } else if (
          app.Status__c == 'Sent to Applicant' ||
          app.Status__c == 'In Progress' ||
          app.Status__c == 'Sent Back'
        ) {
          readOnly = false;
        }

        reviews = appClass.getAppReviews(appId, null);
        for (Application_Review__c r : reviews) {
          if (r.Reviewer__c == currentUser.ContactId) {
            review = r;
            reviewed = true;
            score = r.Score__c;
          }
        }
        if (currentUser.Profile.Name == 'UA Admin') {
          if (app.Number_of_Reviews__c > 0)
            score = (app.Total_Score__c / app.Number_of_Reviews__c).setScale(2);
        }

        if (app.Organization__c != null) {
          acct = acctClass.getAccount(app.Organization__c);
        }
      }
    }

    if (userAcctType == 'National Organization') {
      getGrantOptions();
    }

    if (app.Organization_Name__c != null) {
      String filename = app.Organization_Name__c + '.pdf';
      Apexpages.currentPage()
        .getHeaders()
        .put('content-disposition', 'inline; filename=' + filename);
    }

    impactedOptions = spf.getPicklistOptions(
      'Application__c',
      'Individuals_Directly_Impacted_by_Grant__c',
      null
    );
    incomeOptions = spf.getPicklistOptions('Application__c', 'Income__c', null);
    genderOptions = spf.getPicklistOptions('Application__c', 'Gender__c', null);
  }

  // BEGIN getGrantOptions
  public void getGrantOptions() {
    if (grantId != null) {
      sg = gc.getGrant(grantId);
    } else if (app.Id != null) {
      if (app.Awarded_Amount__c != null) {
        awardAmount = app.Awarded_Amount__c;
        sg.Amount__c = app.Awarded_Amount__c;
      }
      if (app.Grant_Start_Date__c != null)
        startDate = app.Grant_Start_Date__c;
      if (app.Grant_End_Date__c != null)
        endDate = app.Grant_End_Date__c;

      Date dt = date.today();
      sg.Year__c = String.valueOf(dt.year());
      sg.State__c = app.State__c;

      grantOptions = new List<SelectOption>();
      for (Grant__c g : [
        SELECT Id, Name
        FROM Grant__c
        WHERE Account__c = :userAcct.Id
      ]) {
        grantOptions.add(new SelectOption(g.Id, g.Name));
      }
      if (grantOptions.size() == 1)
        grant = grantOptions.get(0).getValue();
    }
  }
  // END getGrantOptions

  // BEGIN save
  public void save() {
    errorMessage = '';
    app.Status__c = 'In Progress';
    appClass.upsertApplication(app);
  }
  // END save

  // BEGIN submit
  public PageReference submit() {
    errorMessage = '';
    createContacts();

    fieldValidation();
    if (ApexPages.hasMessages() || errorMessage != '') {
      system.debug(
        'Apex Pages has Messages Or ErrorMessgae is not blank: ' +
        errorMessage +
        '\n' +
        apexpages.getMessages()
      );
      resetAtts();
      return null;
    } else {
      app.Status__c = 'Submitted';
      app.Submitted_Date__c = date.today();
      appClass.upsertApplication(app);
      System.debug('after Application Upsertion: ' + app);

      if (app.Id != null) {
        List<Attachment> attchList = new List<Attachment>();
        if (appType == 'pride') {
          attW9.ParentId = app.Id;
          attW9.Description = attW9.Name;
          attW9.Name = 'W9';
          attchList.add(attW9);

          att990.ParentId = app.Id;
          att990.Description = att990.Name;
          att990.Name = '990';
          attchList.add(att990);

          attFunding.ParentId = app.Id;
          attFunding.Description = attFunding.Name;
          attFunding.Name = 'Grant Funding Allocation Breakdown';
          attchList.add(attFunding);

          attLogo.ParentId = app.Id;
          attLogo.Description = attLogo.Name;
          attLogo.Name = 'Hi-Res Logo';
          attchList.add(attLogo);
        } else {
          att501.ParentId = app.Id;
          att501.Description = att501.Name;
          att501.Name = '501 c (3)';
          attchList.add(att501);

          attBB.ParentId = app.Id;
          attBB.Description = attBB.Name;
          attBB.Name = 'Budget Breakdown';
          attchList.add(attBB);
        }
        try {
          upsert attchList;
          System.debug(
            'Attachments available in: ' +
            [SELECT id, name FROM attachment WHERE parentId = :app.id]
          );
          attchList.clear();
        } catch (Exception e) {
          errorMessage = 'Error uploading attachment. <br />' + e.getMessage();
        } finally {
          resetAtts();
          System.debug('');
        }
      }

      if (ApexPages.hasMessages())
        errorMessage += string.valueOf(ApexPages.getMessages());
      if (errorMessage == '')
        showSuccess = true;
    }

    return null;
  }
  // END submit

  public void resetAtts() {
    att501.Body = null;
    att501 = new Attachment();
    attBB.Body = null;
    attBB = new Attachment();
    attW9.Body = null;
    attW9 = new Attachment();
    att990.Body = null;
    att990 = new Attachment();
    attFunding.Body = null;
    attFunding = new Attachment();
    attLogo.Body = null;
    attLogo = new Attachment();
  }

  // BEGIN fieldValidation
  public void fieldValidation() {
    // Catalyst Only Required Fields
    if (appType == 'catalyst') {
      if (app.Project_Title__c == null || app.Project_Title__c == '')
        errorMessage += 'Project Title is Missing <br />';

      if (app.Age__c == null)
        errorMessage += 'Please select the Age of youth impacted <br />';

      if (app.Cities_Served__c == null)
        errorMessage += 'Please select the Area Of Impact <br />';

      if (
        app.Unmet_Needs_will_be_Met__c == null ||
        app.Unmet_Needs_will_be_Met__c == ''
      )
        errorMessage += 'Please explain how your program/project will meet need through innovation, entrepreneurship or education <br />';

      if (
        app.How_Program_will_be_delivered__c == null ||
        app.How_Program_will_be_delivered__c == ''
      )
        errorMessage += 'Please explain your organization or staff leadership experience in delivering proven or promising opportunities to the target population <br />';

      if (app.References__c == null || app.References__c == '')
        errorMessage += 'Please list 3 references and contact information <br />';
    }

    // Freedom Only Required Fields
    if (appType == 'freedom') {
      if (app.Overview_501c3__c == null)
        errorMessage += 'Please provide a brief overview of your 501 (c)(3) <br />';

      if (app.Impact__c == null)
        errorMessage += 'Please explain program/project impact <br />';

      if (app.Sustainability__c == null)
        errorMessage += 'Please explain how your program is sustainable <br />';

      if (
        app.R1_First_Name__c == null ||
        app.R1_First_Name__c == '' ||
        app.R1_Last_Name__c == null ||
        app.R1_Last_Name__c == '' ||
        app.R1_Email__c == null ||
        app.R1_Email__c == '' ||
        app.R1_Phone__c == null ||
        app.R1_Phone__c == '' ||
        app.R1_Relationship__c == null ||
        app.R1_Relationship__c == '' ||
        app.R2_First_Name__c == null ||
        app.R2_First_Name__c == '' ||
        app.R2_Last_Name__c == null ||
        app.R2_Last_Name__c == '' ||
        app.R2_Email__c == null ||
        app.R2_Email__c == '' ||
        app.R2_Phone__c == null ||
        app.R2_Phone__c == '' ||
        app.R2_Relationship__c == null ||
        app.R2_Relationship__c == '' ||
        app.R3_First_Name__c == null ||
        app.R3_First_Name__c == '' ||
        app.R3_Last_Name__c == null ||
        app.R3_Last_Name__c == '' ||
        app.R3_Email__c == null ||
        app.R3_Email__c == '' ||
        app.R3_Phone__c == null ||
        app.R3_Phone__c == '' ||
        app.R3_Relationship__c == null ||
        app.R3_Relationship__c == ''
      )
        errorMessage += 'Please list 3 references and contact information <br />';
    }

    // Freedom & Catalyst Shared Required Fields
    if (appType != 'pride') {
      if (app.CEO_First_Name__c == null || app.CEO_First_Name__c == '')
        errorMessage += 'CEO First Name is Missing <br />';

      if (app.CEO_Last_Name__c == null || app.CEO_Last_Name__c == '')
        errorMessage += 'CEO Last Name is Missing <br />';

      if (app.CEO_Email__c == null || app.CEO_Email__c == '')
        errorMessage += 'CEO Email is Missing <br />';

      if (app.CEO_Phone__c == null || app.CEO_Phone__c == '')
        errorMessage += 'CEO Phone is Missing <br />';

      if (app.Year_Founded__c == null || app.Year_Founded__c == '')
        errorMessage += 'Please specify the number of years the organization has operated <br />';

      if (app.Gender__c == null)
        errorMessage += 'Please select the Gender <br />';

      if (app.Total_Budget__c == null)
        errorMessage += 'Please specify the Total Annual Organization Budget <br />';

      if (app.Total_Project_Program_Budget__c == null)
        errorMessage += 'Please specify the Total Program Budget <br />';

      if (app.Amount_of_Funding_Matched__c == null)
        errorMessage += 'Please specify how much of the requested funding will be matched <br />';

      if (app.Amount_of_Funding_Matched__c != 0)
        if (
          app.Amount_of_Funding_Matched__c > 0 &&
          app.Type_of_Funds_Used_for_Match__c == null
        )
          errorMessage += 'Please specify what type of Funds will be used for the Match <br />';

      if (app.Philanthropic_Pillar__c == null)
        errorMessage += 'Please select which UA philanthropic pillar your program/request are appealing to (select all that apply <br />';

      if (app.Individuals_Directly_Impacted_by_Grant__c == null)
        errorMessage += 'Please select the number of individuals directly impacted by the project <br />';

      if (app.Program_Objectives__c == null || app.Program_Objectives__c == '')
        errorMessage += 'Please describe your Program Objectives and how will you measure impact <br />';

      if (
        app.How_Story_will_be_Amplified__c == null ||
        app.How_Story_will_be_Amplified__c == ''
      )
        errorMessage += 'Please explain what story will be amplified if this grant is awarded <br />';

      if (
        app.Example_of_Unsuccessful_Program__c == null ||
        app.Example_of_Unsuccessful_Program__c == ''
      )
        errorMessage += 'Please provide an example of a time when the Project/Program did not succeed <br />';

      if (att501.Name == null)
        errorMessage += 'Please upload a 501 c(3) <br />';
      else if (att501.BodyLength > 4000000)
        errorMessage += 'File size of 501 c(3) should be less than 4Mb <br />';

      if (attBB.Name == null)
        errorMessage += 'Please upload a Budget Breakdown <br />';
      else if (attBB.BodyLength > 4000000)
        errorMessage += 'File size of Budget Breakdown should be less than 4Mb <br />';
    }

    // Pride Only Required Fields
    if (appType == 'pride') {
      //if(app.Is_Organization_501_c3__c == null || app.Is_Organization_501_c3__c == '')
      //    errorMessage += 'Please provide an answer to the question "Is your organization a 501 c3?" <br />';

      //if(app.LGBTQ_Youth_Served__c == null || app.LGBTQ_Youth_Served__c == '')
      //    errorMessage += 'Please provide an answer to the question "Does your organization serve LGBTQ+ youth?" <br />';

      //if(app.Sponsorship_Request_Reason__c == null || app.Sponsorship_Request_Reason__c == '')
      //    errorMessage += 'Please answer why you\'re requesting sponsorship" <br />';

      //if(app.Cities_Served__c == null)
      //    errorMessage += 'Please select cities currently served <br />';

      if (attW9.Name == null)
        errorMessage += 'Please upload a W9 <br />';
      else if (attW9.BodyLength > 4000000)
        errorMessage += 'File size of the W9 should be less than 4Mb <br />';

      if (att990.Name == null)
        errorMessage += 'Please upload a 990 <br />';
      else if (att990.BodyLength > 4000000)
        errorMessage += 'File size of the 990 should be less than 4Mb <br />';

      if (attFunding.Name == null)
        errorMessage += 'Please upload a Grant Funding Allocation Breakdown <br />';
      else if (attFunding.BodyLength > 4000000)
        errorMessage += 'File size of the Grant Funding Allocation Breakdown should be less than 4Mb <br />';

      if (attLogo.Name == null)
        errorMessage += 'Please upload a Hi-Res Logo <br />';
      else if (attLogo.BodyLength > 4000000)
        errorMessage += 'File size of the Hi-Res Logo should be less than 4Mb <br />';
    }

    // Shared Required Fields
    if (app.Organization_Name__c == null || app.Organization_Name__c == '')
      errorMessage += 'Organization Name is Missing <br />';

    if (app.EIN__c == null || app.EIN__c == '')
      errorMessage += 'EIN is Missing <br />';

    if (app.Address__c == null || app.Address__c == '')
      errorMessage += 'Address is Missing <br />';

    if (app.City__c == null || app.City__c == '')
      errorMessage += 'City is Missing <br />';

    if (app.State__c == null || app.State__c == '')
      errorMessage += 'State is Missing <br />';

    if (app.Postal_Zip_Code__c == null || app.Postal_Zip_Code__c == '')
      errorMessage += 'Zip Code is Missing <br />';

    if (
      app.Program_Contact_First_Name__c == null ||
      app.Program_Contact_First_Name__c == ''
    )
      errorMessage += 'Program Contact First Name is Missing <br />';

    if (
      app.Program_Contact_Last_Name__c == null ||
      app.Program_Contact_Last_Name__c == ''
    )
      errorMessage += 'Program Contact Last Name is Missing <br />';

    if (
      app.Program_Contact_Email__c == null ||
      app.Program_Contact_Email__c == ''
    )
      errorMessage += 'Program Contact Email is Missing <br />';

    if (
      app.Program_Contact_Phone__c == null ||
      app.Program_Contact_Phone__c == ''
    )
      errorMessage += 'Program Contact Phone is Missing <br />';

    if (app.Total_Amount_Requested__c == null)
      errorMessage += 'Pleaes specify the Total Amount Requested From Under Armour <br />';
    else if (app.Total_Amount_Requested__c > 25000)
      errorMessage += 'Your request exceeds the maximum amount of $25,000. <br />';

    if (
      app.Previous_Support_Received__c == null ||
      app.Previous_Support_Received__c == ''
    )
      errorMessage += 'Please specify if in the past have you received any support from the Under Armour <br />';
    else if (
      app.Previous_Support_Received__c == 'Yes' &&
      (app.Support_Years_and_Contribution__c == null ||
      app.Support_Years_and_Contribution__c == '')
    )
      errorMessage += 'Please describe regarding the previous contribution that has been received from Under Armour <br />';

    if (app.Has_Participation_Fee__c == null)
      errorMessage += 'Please specify if there is any Participation Fee <br />';
    else if (
      app.Has_Participation_Fee__c == 'Yes' &&
      app.Participation_Fee__c == null
    )
      errorMessage += 'Please specify the Participation Fee <br />';

    if (app.How_Funds_Utilized__c == null || app.How_Funds_Utilized__c == '')
      errorMessage += 'Please explain how UA grant funds will be utilized <br />';

    if (
      app.Employees_Donating_Volunteering_Sitting__c == null ||
      app.Employees_Donating_Volunteering_Sitting__c == ''
    )
      errorMessage += 'Please specify if you have UA employees sitting on the Board for your Organization. If none specify as N/A <br />';

    if (
      app.Other_Organizations_Supporting_Program__c == null ||
      app.Other_Organizations_Supporting_Program__c == ''
    )
      errorMessage += 'Please mention if there are any other Organizations that currently support your Program/Organization. If none specify as N/A <br />';

    if (app.Instagram__c != null && !app.Instagram__c.contains('@'))
      errorMessage += 'Instagram requires an "@" symbol before the handle <br />';

    if (app.Twitter__c != null && !app.Twitter__c.contains('@'))
      errorMessage += 'Twitter requires an "@" symbol before the handle <br />';
  }
  // END fieldValidation

  // BEGIN notEligible
  public PageReference notEligible() {
    app.Status__c = 'Closed';
    app.Closed_Date__c = date.today();
    appClass.upsertApplication(app);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }
  // END notEligible

  // BEGIN createReview
  public void createReview() {
    review = new Application_Review__c(
      Application__c = app.Id,
      Reviewer__c = currentUser.ContactId
    );
    readOnly = false;
  }
  // END createReview

  // BEGIN score
  public PageReference score() {
    app.Status__c = 'Reviewed';
    String r = app.Reviewers__c;
    if (r != null)
      r += ';' + currentUser.Contact.Name;
    else
      r = currentUser.Contact.Name;
    app.Reviewers__c = r;
    appClass.upsertApplication(app);
    appClass.upsertAppReview(review);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }
  // END score

  // BEGIN award
  public PageReference award() {
    errorMessage = '';
    if (awardAmount != null)
      app.Awarded_Amount__c = awardAmount;
    if (startDate != null)
      app.Grant_Start_Date__c = startDate;
    if (endDate != null)
      app.Grant_End_Date__c = endDate;

    if (app.Organization__c == null && app.National_Organization__c != null) {
      Account[] accts = [
        SELECT Id, EIN__c
        FROM Account
        WHERE
          EIN__c = :app.EIN__c
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
    acct.Type = app.Type__c;
    acct.EIN__c = app.EIN__c;
    acct.Name = app.Organization_Name__c;
    acct.BillingStreet = app.Address__c;
    acct.BillingCity = app.City__c;
    acct.BillingState = app.State__c;
    acct.BillingPostalCode = app.Postal_Zip_Code__c;
    if (app.Mailing_Address_Same_as_Physical_Address__c) {
      acct.ShippingStreet = app.Address__c;
      acct.ShippingCity = app.City__c;
      acct.ShippingState = app.State__c;
      acct.ShippingPostalCode = app.Postal_Zip_Code__c;
    } else {
      acct.ShippingStreet = app.Mailing_Address__c;
      acct.ShippingCity = app.Mailing_City__c;
      acct.ShippingState = app.Mailing_State__c;
      acct.ShippingPostalCode = app.Mailing_Postal_Code__c;
    }
    acct.Total_Budget__c = app.Total_Budget__c;
    acct.Number_of_Sites__c = app.Number_of_Sites__c;
    acct.Urban__c = app.Urban__c;
    acct.Suburban__c = app.Suburban__c;
    acct.Rural__c = app.Rural__c;
    acct.Type = app.Type__c;
    acct.Additional_Org_Classification__c = app.Additional_Org_Classification__c;
    acct.Mission_Statement__c = app.Mission_Statement__c;
    acct.Number_of_Youth_Served_per_Year__c = app.Number_of_Youth_Served_per_Year__c;
    acct.Min_Age_of_Youth__c = app.Min_Age_of_Youth__c;
    acct.Max_Age_of_Youth__c = app.Max_Age_of_Youth__c;
    acct.Percent_Male__c = app.Percent_Male__c;
    acct.Percent_Female__c = app.Percent_Female__c;
    acct.Percent_American_Indian_Alaska_Native__c = app.Percent_American_Indian_Alaska_Native__c;
    acct.Percent_Asian__c = app.Percent_Asian__c;
    acct.Percent_Black_or_African_American__c = app.Percent_Black_or_African_American__c;
    acct.Percent_Hispanic_or_Latino__c = app.Percent_Hispanic_or_Latino__c;
    acct.Percent_Native_Hawaiian_Pacific_Islander__c = app.Percent_Native_Hawaiian_Pacific_Islander__c;
    acct.Percent_White__c = app.Percent_White__c;
    acct.Percent_More_than_One_Race__c = app.Percent_More_than_One_Race__c;
    acct.Percent_Race_Not_Indicated__c = app.Percent_Race_Not_Indicated__c;
    acct.Percent_Eligible_Free_Reduced_Lunch__c = app.Percent_Eligible_Free_Reduced_Lunch__c;
    acct.Percent_Youth_in_Single_Parent_Homes__c = app.Percent_Youth_in_Single_Parent_Homes__c;
    acct.Youth_Living_at_or_below_Poverty_Level__c = app.Youth_Living_at_or_below_Poverty_Level__c;

    User u = new User();
    u = ucws.getUser(' WHERE Alias = \'fpadmin\'');
    if (u == null)
      u = ucws.getUser(' WHERE Profile.Name = \'System Administrator\'');
    system.debug('ApplicationCtrl user for acct owner = ' + u.Name);
    if (u != null)
      acct.OwnerId = u.Id;
    acctClass.upsertAccount(acct);
    system.debug('ApplicationCtrl acct after upsert = ' + acct.Name);
    if (ApexPages.hasMessages() && !system.Test.isRunningTest())
      return null;

    createContacts();
    cc.upsertContactList(contacts);
    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;

    acct.CEO__c = ceo.Id;
    acctClass.upsertAccount(acct);

    app.Organization__c = acct.Id;
    app.Status__c = 'Awarded';
    app.Awarded_Date__c = date.today();
    appClass.upsertApplication(app);
    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;

    Date dt = date.today();
    sg.Account__c = acct.Id;
    if (sg.Name == null || sg.Name == '')
      sg.Name = app.Name + ' Grant';
    if (sg.Amount__c == null)
      sg.Amount__c = app.Awarded_Amount__c;
    sg.Application__c = app.Id;
    sg.CEO_Email__c = ceo.Email;
    sg.Grant_Status__c = 'Awarded';
    sg.Project_Name__c = app.Project_Title__c;
    if (sg.Start_Date__c == null)
      sg.Start_Date__c = app.Grant_Start_Date__c;
    if (sg.End_Date__c == null)
      sg.End_Date__c = app.Grant_End_Date__c;
    sg.Report_Due_Date__c = dt.addMonths(6);
    sg.RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
      .get('Sub-Grant')
      .getRecordTypeId();
    if (grant != null)
      sg.National_Grant__c = Id.valueOf(grant);
    else {
      for (Grant__c g : gc.getRelatedGrants(userAcct.Id, null)) {
        if (
          (app.RecordType.Name.contains('Freedom') &&
          g.Name.contains('Freedom')) ||
          (app.RecordType.Name.contains('Catalyst') &&
          g.Name.contains('Catalyst')) ||
          (app.RecordType.Name.contains('Pride') && g.Name.contains('Pride'))
        ) {
          sg.National_Grant__c = g.Id;
        }
      }
    }
    gc.upsertGrant(sg);

    Grantee_Report__c gr = new Grantee_Report__c(
      Grant__c = sg.Id,
      Report_Status__c = 'Requested',
      Scheduled_Date__c = dt.addMonths(6)
    );
    drc.upsertReport(gr);
    mou.CreateMOU(ceo.Email, null, sg.Id, 'UA_Letter_of_Agreement.pdf');

    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }
  // END award

  // BEGIN upsertGrant
  public PageReference upsertGrant() {
    gc.upsertGrant(sg);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference('/BudgetDetails?grantId=' + sg.Id);
    pr.setRedirect(true);
    return pr;
  }
  // END upsertGrant

  // BEGIN createContacts
  public void createContacts() {
    contacts.clear();
    Id rId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Contact')
      .getRecordTypeId();
    Map<String, Id> emails = new Map<String, Id>();
    for (Contact c : [SELECT Email FROM Contact WHERE AccountId = :acct.Id])
      emails.put(c.Email, c.Id);

    if (app.CEO_Email__c != null) {
      if (!emails.containsKey(app.CEO_Email__c)) {
        if (emails.containsKey(app.CEO_Email__c))
          ceo.Id = emails.get(app.CEO_Email__c);
        ceo.AccountId = app.Organization__c;
        ceo.Salutation = app.CEO_Prefix__c;
        ceo.FirstName = app.CEO_First_Name__c;
        ceo.LastName = app.CEO_Last_Name__c;
        ceo.Suffix = app.CEO_Suffix__c;
        ceo.Title = app.CEO_Title__c;
        ceo.Role__c = 'CEO';
        ceo.Email = app.CEO_Email__c;
        ceo.Phone = app.CEO_Phone__c;
        ceo.Extension__c = app.CEO_Ext__c;
        ceo.MobilePhone = app.CEO_Mobile__c;
        ceo.RecordTypeId = rId;
        contacts.add(ceo);
      }
    }

    if (app.Program_Contact_Email__c != null) {
      if (!emails.containsKey(app.Program_Contact_Email__c)) {
        if (emails.containsKey(app.Program_Contact_Email__c))
          pc.Id = emails.get(app.Program_Contact_Email__c);
        pc.AccountId = app.Organization__c;
        pc.Salutation = app.Program_Contact_Prefix__c;
        pc.FirstName = app.Program_Contact_First_Name__c;
        pc.LastName = app.Program_Contact_Last_Name__c;
        pc.Suffix = app.Program_Contact_Suffix__c;
        pc.Title = app.Program_Contact_Title__c;
        pc.Role__c = 'Program Coordinator';
        pc.Email = app.Program_Contact_Email__c;
        pc.Phone = app.Program_Contact_Phone__c;
        pc.Extension__c = app.Program_Contact_Ext__c;
        pc.MobilePhone = app.Program_Contact_Mobile__c;
        pc.RecordTypeId = rId;
        contacts.add(pc);
      }
    }
  }
  // END createContacts

  // BEGIN popups
  public void scorePopup() {
    if (displayScorePopup == true) {
      displayScorePopup = false;
    } else {
      Decimal total = 0;
      if (app.Unmet_Needs_will_be_Met_Score__c != null) {
        total += Decimal.valueOf(app.Unmet_Needs_will_be_Met_Score__c);
      }
      if (app.How_Story_will_be_Amplified_Score__c != null) {
        total += Decimal.valueOf(app.How_Story_will_be_Amplified_Score__c);
      }
      if (app.How_Program_will_be_Delivered_Score__c != null) {
        total += Decimal.valueOf(app.How_Program_will_be_Delivered_Score__c);
      }
      if (app.Example_of_Unsuccessful_Program_Score__c != null) {
        total += Decimal.valueOf(app.Example_of_Unsuccessful_Program_Score__c);
      }
      if (total > 0) {
        app.Score__c = total.divide(4, 2);
      }
      displayScorePopup = true;
    }
  }

  public void awardPopup() {
    if (displayAwardPopup == true) {
      displayAwardPopup = false;
    } else {
      displayAwardPopup = true;
    }
  }
  public void showNotEligiblePopup() {
    notesPopupType = 'notEligible';
    displayNotesPopup = true;
  }
  public void hideNotesPopup() {
    displayNotesPopup = false;
  }
  // END popups
}
