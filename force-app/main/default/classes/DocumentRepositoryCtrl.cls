public with sharing class DocumentRepositoryCtrl {
  private UserClass uc = new UserClass();
  private AccountClass ac = new AccountClass();
  private ContactClass cc = new ContactClass();
  private UserClassWithoutSharing ucws = new UserClassWithoutSharing();
  private GrantClass gc = new GrantClass();
  private getIdFromString gifs = new getIdFromString();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public User currentUser { get; set; }
  public String profileName { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  public Id orgId { get; set; }
  public List<Account> orgs { get; set; }
  public Account org { get; set; }
  public Date dunsExpDate { get; set; }

  public String keyword { get; set; }
  public String holdStatus { get; set; }
  public List<SelectOption> holdStatusOptions { get; set; }
  public String holdReason { get; set; }
  public List<SelectOption> holdReasonOptions { get; set; }

  public Id grantId { get; set; }
  public List<Grant__c> grants { get; set; }
  public Grant__c grant { get; set; }
  public List<Contact> contacts { get; set; }
  public List<User> users { get; set; }
  public List<Attachment> atts { get; set; }

  public String page2title { get; set; }
  public String year { get; set; }
  public String yearOptions { get; set; }
  public Boolean showYearOptions { get; set; }
  public String allDocsHeader { get; set; }
  public Boolean hasAdmin { get; set; }
  public Boolean statusReadOnly { get; set; }
  public Boolean showRequired { get; set; }
  public Boolean showAccessMode { get; set; }
  public Boolean enableDeleteAtt { get; set; }
  public Boolean displayGrantSpecificDocuments { get; set; }
  public Boolean displayAtts { get; set; }
  public Boolean displayUploadHelpText { get; set; }
  public Boolean displayUpdateBtn { get; set; }
  public Boolean displayOnHoldPopup { get; set; }
  public Boolean displayEditDunsPopup { get; set; }
  public Boolean displayContactPopup { get; set; }

  public DocumentRepositoryCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    profileName = currentUser.Profile.Name;
    approverLevel = uc.approverLevel;
    portalName = uc.userProfile;

    orgs = new List<Account>();
    grants = new List<Grant__c>();
    contacts = new List<Contact>();
    users = new List<User>();
    atts = new List<Attachment>();

    String urlorgId = ApexPages.currentPage().getParameters().get('orgId');
    orgId = gifs.getId(urlorgId);

    String urlgrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlgrantId);

    String urlHoldStatus = ApexPages.currentPage()
      .getParameters()
      .get('holdStatus');
    if (urlHoldStatus != null)
      holdStatus = urlHoldStatus;
    else
      holdStatus = '';
    holdStatusOptions = new List<SelectOption>();
    holdStatusOptions = spf.getPicklistOptions(
      'Account',
      'Hold_Status__c',
      'View All'
    );

    holdReason = '';
    holdReasonOptions = new List<SelectOption>();
    holdReasonOptions.add(new SelectOption('', 'View All'));
    if (portalName.contains('NCAI')) {
      holdReasonOptions.add(
        new SelectOption(
          'Letter of Award not on file',
          'Letter of Award not on file'
        )
      );
      holdReasonOptions.add(
        new SelectOption(
          'FFATA Questionnaire not on file',
          'FFATA Questionnaire not on file'
        )
      );
      holdReasonOptions.add(
        new SelectOption('Federal Debt Reported', 'Federal Debt Reported')
      );
      holdReasonOptions.add(
        new SelectOption(
          'Missing Required Implementation Documents',
          'Missing Required Implementation Documents'
        )
      );
      holdReasonOptions.add(
        new SelectOption(
          'Missing Reports / Youth Data/PA Logs',
          'Missing Reports / Youth Data/PA Logs'
        )
      );
      holdReasonOptions.add(
        new SelectOption(
          'Expired SAM Registration / Federal Debt',
          'Expired SAM Registration / Federal Debt'
        )
      );
      holdReasonOptions.add(new SelectOption('Other', 'Other'));
    } else {
      holdReasonOptions.add(
        new SelectOption('SAM.gov Expired', 'SAM.gov Expired')
      );
      holdReasonOptions.add(
        new SelectOption(
          'Current FYE Audit Past Due',
          'Current FYE Audit Past Due'
        )
      );
      holdReasonOptions.add(
        new SelectOption(
          'DOJ Certification Past Due',
          'DOJ Certification Past Due'
        )
      );
      holdReasonOptions.add(new SelectOption('Other', 'Other'));
    }
    //        holdReasonOptions = spf.getPicklistOptions('Account', 'Hold_Reason__c', 'View All');

    page2title = 'Grant Details';
    allDocsHeader = 'All Federal Grant Compliance Documents';
    statusReadOnly = false;
    hasAdmin = true;
    enableDeleteAtt = false;
    showRequired = true;
    showAccessMode = true;
    showYearOptions = false;
    displayAtts = false;
    displayUpdateBtn = false;
    displayUploadHelpText = false;
    displayGrantSpecificDocuments = true;
    if (approverLevel.contains('Admin'))
      enableDeleteAtt = true;
    if (
      approverLevel == 'Level Three Admin' ||
      (portalName.contains('NCAI') && approverLevel == 'Level Four')
    )
      displayUpdateBtn = true;
    if (portalName.contains('NCAI')) {
      page2title = 'Grant Documentation and Compliance';
      allDocsHeader = 'All Required Documents. <br />The documents below are required for all T.R.A.I.L. grant recipients. <br />Please use the templates above to complete and upload all required documents as soon as possible.';
      hasAdmin = false;
      showRequired = false;
      showAccessMode = false;
      displayAtts = true;
      displayUploadHelpText = true;
      showYearOptions = true;
      displayGrantSpecificDocuments = true;

      if (userAcctType == 'National Organization') {
        enableDeleteAtt = true;
        displayGrantSpecificDocuments = true;
      }
    }
    if (
      (portalName == 'NCAI' && approverLevel == 'Level Four') ||
      portalName.contains('OVC') &&
      (approverLevel == 'Level Two' ||
      approverLevel == 'Level Three')
    ) {
      statusReadOnly = true;
    }
  }

  // BEGIN getLists
  public void getLists() {
    orgs.clear();
    if (grantId != null) {
      grant = gc.getGrant(grantId);
      for (Attachment i : grant.Attachments) {
        if (
          i.Name.contains('Letter of Agreement') ||
          i.Name.contains('LOA') ||
          i.Name.contains('FFATA')
        ) {
          atts.add(i);
        }
      }
    } else if (orgId != null) {
      org = ac.getAccount(orgId);
      if (portalName == 'Ripken')
        page2title = org.Name + ' - Grant Details';
      contacts = cc.getContactPopupList(orgId);
      users = ucws.getUserList(' WHERE AccountId = \'' + orgId + '\'');
      grants = gc.getRelatedSubGrants(
        orgId,
        null,
        null,
        'Name',
        null,
        null,
        null
      );
      if (yearOptions == null)
        yearOptions = org.National_Organization__r.Grant_Year_Options__c;
      if (year == null || year == '')
        year = org.National_Organization__r.Current_Grant_Year__c;
    } else {
      //String soqlAND = ' AND RecordType.Name != \'Site\'';
      String soqlAnd = '';
      if (holdStatus != '' && holdStatus != 'View All')
        soqlAND += ' AND Hold_Status__c = \'' + holdStatus + '\'';
      if (holdReason != null && holdReason != '' && holdReason != 'View All')
        soqlAND += ' AND Hold_Reason__c = \'' + holdReason + '\'';

      if (portalName.contains('OVC'))
        soqlAND += ' AND National_Grants__c INCLUDES (\'OVC\')';
      else if (portalName.contains('TRAIL'))
        soqlAND += ' AND National_Grants__c INCLUDES (\'TRAIL\')';

      for (
        Account a : ac.getRelatedAccountList(
          userAcct.Id,
          userAcctType,
          null,
          null,
          soqlAND
        )
      ) {
        String s1 = '';
        String s2 = '';
        String s3 = '';
        String k = '';
        s1 = String.valueOf(a.Name);
        if (a.BBBS_Id__c != null)
          s2 = String.valueOf(a.BBBS_Id__c);
        if (a.Local_Organization__r.Name != null)
          s3 = String.valueOf(a.Local_Organization__r.Name);
        if (keyword != null && keyword != '')
          k = String.valueOf(keyword).toLowerCase();
        if (
          k == '' ||
          s1.toLowerCase().contains(k) ||
          s2.contains(k) ||
          s3.toLowerCase().contains(k)
        ) {
          orgs.add(a);
        }
      }
    }
  }
  // END getLists

  // BEGIN updateDuns
  public void updateDuns() {
    if (dunsExpDate != null) {
      if (userAcctType == 'National Organization') {
        org.DUNS_Exp_Date__c = dunsExpDate;
        org.New_DUNS_Exp_Date__c = null;
        org.DUNS_Review_Status__c = 'Approved';
      } else {
        org.New_DUNS_Exp_Date__c = dunsExpDate;
        org.DUNS_Review_Status__c = 'Submitted';
      }
      if (dunsExpDate > date.today())
        org.DUNS_Expired__c = false;
      else
        org.DUNS_Expired__c = true;
    }
    ac.upsertAccount(org);
    displayEditDunsPopup = false;
  }

  public void updateHold() {
    org.Hold_History__c = ac.getHoldHistory(currentUser, org);
    org.Hold_Date__c = date.today();
    ac.upsertAccount(org);
    displayOnHoldPopup = false;
  }
  // END updateOrg

  // BEGIN popups
  public void showEditDunsPopup() {
    displayEditDunsPopup = true;
  }
  public void hideEditDunsPopup() {
    displayEditDunsPopup = false;
  }

  public void showOnHoldPopup() {
    displayOnHoldPopup = true;
  }
  public void hideOnHoldPopup() {
    displayOnHoldPopup = false;
  }

  public void showContactPopup() {
    displayContactPopup = true;
  }
  public void hideContactPopup() {
    displayContactPopup = false;
  }
  // END popups
}
