public with sharing class ApplicationCtrl {
  private UserClass uc = new UserClass();
  private FieldLabelClass flc = new FieldLabelClass();
  private UserClassWithoutSharing ucws = new UserClassWithoutSharing();
  private AccountClass acctClass = new AccountClass();
  private ContactClass cc = new ContactClass();
  private ApplicationClass appClass = new ApplicationClass();
  private GrantClass gc = new GrantClass();
  private DCTATReportClass drc = new DCTATReportClass();
  private CreateMOUCtrl mou = new CreateMOUCtrl();
  private getIdFromString gifs = new getIdFromString();
  private AttachmentClass attClass = new AttachmentClass();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  public Map<String, String> fields { get; set; }
  public Map<String, String> siteFields { get; set; }
  public List<Application_Site__c> activeSites { get; set; }
  public List<Application_Site__c> inactiveSites { get; set; }
  public List<Application_Site__c> newSites { get; set; }

  public Id appId { get; set; }
  public String appType { get; set; }
  public Application__c app { get; set; }
  public String title { get; set; }
  public Decimal awardAmount { get; set; }
  public Date startDate { get; set; }
  public Date endDate { get; set; }

  public Application_Review__c review { get; set; }
  public List<Application_Review__c> reviews { get; set; }
  public Boolean editingReview { get; set; }
  public Boolean canReview { get; set; }
  public Boolean canAward { get; set; }
  public Boolean canSeeReviews { get; set; }
  public String note { get; set; }

  public Account acct { get; set; }
  public List<Contact> contacts { get; set; }
  public Contact ceo { get; set; }
  public Contact ga { get; set; }
  public Contact fa { get; set; }
  public Contact pc { get; set; }
  public String gaEmail { get; set; }

  public Id grantId { get; set; }
  public Grant__c sg { get; set; }

  public String grant { get; set; }
  public List<SelectOption> grantOptions { get; set; }
  public List<SelectOption> serviceOptions {
    get {
      return spf.getPicklistOptions(
        'Application__c',
        'Areas_of_Service__c',
        null
      );
    }
    set;
  }
  public String[] services {
    get {
      String[] selected = new List<String>();
      List<SelectOption> sos = this.serviceOptions;
      for (SelectOption s : sos) {
        if (
          this.app.Areas_of_Service__c != null &&
          this.app.Areas_of_Service__c.contains(s.getValue())
        )
          selected.add(s.getValue());
      }
      return selected;
    }
    public set {
      String selectedConcat = '';
      for (String s : value) {
        if (selectedConcat == '')
          selectedConcat += s;
        else
          selectedConcat += ';' + s;
      }
      app.Areas_of_Service__c = selectedConcat;
    }
  }

  public Boolean hasAtts { get; set; }
  public Attachment att { get; set; }

  public String notesPopupType { get; set; }
  public Boolean displayScorePopup { get; set; }
  public Boolean displayAwardPopup { get; set; }
  public Boolean displayNotesPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public Boolean displayAttPopup { get; set; }
  public Boolean displayReviewNotesPopup { get; set; }

  Date dt = date.today();
  String url = '/Applications';
  public Boolean showInactiveSites { get; set; }
  public Boolean showDeleteSitesBtn { get; set; }
  public Boolean readOnly { get; set; }
  public Boolean score1ReadOnly { get; set; }
  public Boolean score2ReadOnly { get; set; }
  public Decimal score1Total { get; set; }
  public Decimal score2Total { get; set; }
  public Boolean showSuccess { get; set; }
  public Boolean showSaveSuccess { get; set; }
  public String errorMessage { get; set; }

  public ApplicationCtrl getApplicationCtrl() {
    return this;
  }

  public ApplicationCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    portalName = uc.userProfile;

    approverLevel = uc.approverLevel;
    if (approverLevel == 'Level One' || approverLevel == 'Level Two') {
      score1ReadOnly = false;
      score2ReadOnly = true;
      canReview = true;
    } else if (
      approverLevel == 'Level Four' ||
      approverLevel == 'Level Three'
    ) {
      score1ReadOnly = true;
      score2ReadOnly = false;
      canAward = true;
      canSeeReviews = true;
    }

    app = new Application__c();
    acct = new Account();
    contacts = new List<Contact>();
    ceo = new Contact();
    ga = new Contact();
    fa = new Contact();
    pc = new Contact();
    sg = new Grant__c();

    fields = new Map<String, String>();
    siteFields = new Map<String, String>();
    activeSites = new List<Application_Site__c>();
    inactiveSites = new List<Application_Site__c>();
    newSites = new List<Application_Site__c>();
    review = new Application_Review__c();
    reviews = new List<Application_Review__c>();
    editingReview = false;
    showInactiveSites = true;
    showDeleteSitesBtn = false;
    readOnly = true;
    notesPopupType = 'sendBack';

    //serviceOptions = spf.getPicklistOptions('Application__c', 'Areas_of_Service__c', null);

    String grantUrlId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(grantUrlId);

    if (grantId == null) {
      String appUrlId = ApexPages.currentPage().getParameters().get('appId');
      appId = gifs.getId(appUrlId);
      if (appId != null) {
        app = appClass.getApplication(appId);
        gaEmail = app.Grant_Admin_Email__c;
        if (app.RecordType.Name == 'Ripken Special Initiative') {
          title = 'Special Initiative';
          appType = 'special';
        } else if (app.RecordType.Name == 'Ripken Baseball') {
          title = 'Badges for Baseball';
          appType = 'baseball';
        } else if (app.RecordType.Name.contains('GREAT')) {
          title = 'I\'m GREAT';
          appType = 'great';
        } else if (app.RecordType.Name == 'Ripken Healthy Lifestyles') {
          title = 'Healthy Lifestyles';
          appType = 'healthy';
        }
        if (userAcctType == 'National Organization') {
          readOnly = true;
          if (app.Status__c != 'Submitted' && app.Status__c != 'Reviewed') {
            canReview = false;
            canAward = false;
          }
          reviews = appClass.getAppReviews(appId, null);
          for (Application_Review__c r : reviews) {
            if (r.Reviewer__c == currentUser.ContactId) {
              review = r;
              canReview = false;
              if (app.Status__c == 'Submitted' || app.Status__c == 'Reviewed')
                editingReview = true;
            }
          }
        } else if (
          app.Status__c == 'Sent to Applicant' ||
          app.Status__c == 'In Progress' ||
          app.Status__c == 'Sent Back'
        ) {
          readOnly = false;
        }
        if (app.Organization__c != null) {
          getAcct();
        }
      }
    }

    if (userAcctType == 'National Organization') {
      getGrantOptions();
      getScoreTotals();
    }
  }

  // BEGIN get Acct and Sites
  public void getAcct() {
    acct = acctClass.getAccount(app.Organization__c);
    getSites();
  }
  public void getSites() {
    activeSites.clear();
    inactiveSites.clear();
    showDeleteSitesBtn = false;

    Set<Id> sIds = new Set<Id>();
    Set<String> sNames = new Set<String>();
    for (Application_Site__c s : appClass.getAppSites(app.Id)) {
      s.Delete__c = false;
      if (
        s.Active_Status__c == 'Not Currently Implementing Site' ||
        s.Active_Status__c == 'Currently Implementing Site Not Continuing'
      ) {
        inactiveSites.add(s);
        sIds.add(s.Site_Id__c);
      } else {
        activeSites.add(s);
        sIds.add(s.Site_Id__c);
      }
    }
    if (app.Organization__c != null) {
      for (Account a : acctClass.getSiteList(app.Organization__c, null)) {
        if (!sIds.contains(a.Id) && !sNames.contains(a.Name)) {
          Application_Site__c s = new Application_Site__c(
            Application__c = app.Id,
            Site_Id__c = a.Id,
            Name = a.Name,
            Is_Active__c = a.Is_Active__c,
            Active_Status__c = a.Active_Status__c,
            Delete__c = false
          );
          if (a.Active_Status__c == null)
            s.Active_Status__c = 'Currently Implementing Site Proposing To Continue';
          if (
            a.Active_Status__c == 'Not Currently Implementing Site' ||
            a.Active_Status__c == 'Currently Implementing Site Not Continuing'
          ) {
            inactiveSites.add(s);
          } else {
            activeSites.add(s);
          }
        } else {
          for (Application_Site__c s : activeSites) {
            if (s.Site_Id__c == null && s.Name == a.Name)
              s.Site_Id__c = a.Id;
          }
          for (Application_Site__c s : inactiveSites) {
            if (s.Site_Id__c == null && s.Name == a.Name)
              s.Site_Id__c = a.Id;
          }
        }
      }
    }
    for (Application_Site__c s : activeSites) {
      if (s.Site_Id__c == null)
        showDeleteSitesBtn = true;
    }
    for (Application_Site__c s : inactiveSites) {
      if (s.Site_Id__c == null)
        showDeleteSitesBtn = true;
    }
    if (newSites.size() > 0)
      showDeleteSitesBtn = true;
  }
  // END getAcct

  // BEGIN getFields
  public void getFields() {
    if (
      app.RecordTypeId ==
      Schema.SObjectType.Application__c.getRecordTypeInfosByName()
        .get('NCAI - OVC')
        .getRecordTypeId()
    ) {
      fields = flc.getFieldLabelMap(
        'Application__c',
        app.Grant_Type__c,
        app.Type__c,
        ' AND Year__c includes (\'' +
        app.Grant_Year__c +
        '\')'
      );
    } else
      fields = flc.getFieldLabelMap(
        'Application__c',
        app.Grant_Type__c,
        app.Type__c,
        null
      );
    siteFields = flc.getFieldLabelMap('Application_Site__c', null, null, null);
  }
  // END getFields

  // BEGIN getAtt
  public void getAtt(String name) {
    for (Attachment a : attClass.getAttachments(app.Id, null)) {
      if (a.Name == name)
        att = a;
      system.debug('attachment = ' + a.Name);
    }
  }
  // END getAtt

  // BEGIN getFieldsAndAtt
  public void getFieldsAndAtt() {
    getFields();
    getAtt(ApexPages.CurrentPage().getParameters().get('AttName'));
  }
  // END getFieldsAndAtt

  // BEGIN add & remove sites
  public void addSite() {
    newSites.add(
      new Application_Site__c(
        Application__c = app.Id,
        Active_Status__c = 'New Site',
        Is_Active__c = true
      )
    );
    showDeleteSitesBtn = true;
  }
  public void deleteSites() {
    List<Application_Site__c> sitesToDelete = new List<Application_Site__c>();
    for (Application_Site__c s : activeSites) {
      if (s.Delete__c == true)
        sitesToDelete.add(s);
    }
    for (Application_Site__c s : inactiveSites) {
      if (s.Delete__c == true)
        sitesToDelete.add(s);
    }
    appClass.deleteApplicationSites(sitesToDelete);

    Integer i = 0;
    while (i < newSites.size()) {
      if (newSites.get(i).Delete__c == true) {
        newSites.remove(i);
      } else {
        i++;
      }
    }

    getSites();
  }
  // END add & remove sites

  // BEGIN deleteAtt
  public void deleteAtt() {
    if (att.Id != null) {
      attClass.deleteAttachment(att);
      att = new Attachment();
    }
  }
  // END deleteAtt

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

      sg.Year__c = String.valueOf(dt.year());
      sg.State__c = app.State__c;
      if (app.RecordType.Name == 'Ripken Baseball')
        sg.Grant_Type__c = 'Badges for Baseball';
      else if (app.RecordType.Name == 'Ripken Special Initiative')
        sg.Grant_Type__c = 'Special Initiative';
      else if (app.RecordType.Name.contains('GREAT'))
        sg.Grant_Type__c = 'I\'m GREAT';
      else if (app.RecordType.Name.contains('TRAIL'))
        sg.Grant_Type__c = 'TRAIL';
      else if (app.RecordType.Name.contains('OVC'))
        sg.Grant_Type__c = 'OVC';

      grantOptions = new List<SelectOption>();
      for (Grant__c g : [
        SELECT Id, Name
        FROM Grant__c
        WHERE Account__c = :userAcct.Id AND RecordType.Name = 'Grant'
        LIMIT 100
      ]) {
        grantOptions.add(new SelectOption(g.Id, g.Name));
      }
      if (grantOptions.size() == 1)
        grant = grantOptions.get(0).getValue();
    }
  }
  // END getGrantOptions

  // BEGIN getTotal
  public void getTotal() {
    app.Total_Amount_Requested__c = 0;
    if (app.Personnel_Budget__c != null)
      app.Total_Amount_Requested__c += app.Personnel_Budget__c;
    if (app.Fringe_Benefits_Budget__c != null)
      app.Total_Amount_Requested__c += app.Fringe_Benefits_Budget__c;
    if (app.Travel_Budget__c != null)
      app.Total_Amount_Requested__c += app.Travel_Budget__c;
    if (app.Supplies_Budget__c != null)
      app.Total_Amount_Requested__c += app.Supplies_Budget__c;
    if (app.Contracts_Budget__c != null)
      app.Total_Amount_Requested__c += app.Contracts_Budget__c;
    if (app.Contractor_Travel_Budget__c != null)
      app.Total_Amount_Requested__c += app.Contractor_Travel_Budget__c;
    if (app.Other_Costs_Budget__c != null)
      app.Total_Amount_Requested__c += app.Other_Costs_Budget__c;
    if (app.Indirect_Costs_Budget__c != null)
      app.Total_Amount_Requested__c += app.Indirect_Costs_Budget__c;
  }
  // END getTotal

  // BEGIN getScoreTotals
  public void getScoreTotals() {
    score1Total = 0;
    score2Total = 0;

    if (app.Retention_Efforts_for_Youth_Score__c != null)
      score1Total += Decimal.valueOf(app.Retention_Efforts_for_Youth_Score__c);
    if (app.Retention_Efforts_for_Youth_Score_2__c != null)
      score2Total += Decimal.valueOf(
        app.Retention_Efforts_for_Youth_Score_2__c
      );
    if (app.Caretaker_Involvement_Score__c != null)
      score1Total += Decimal.valueOf(app.Caretaker_Involvement_Score__c);
    if (app.Caretaker_Involvement_Score_2__c != null)
      score2Total += Decimal.valueOf(app.Caretaker_Involvement_Score_2__c);
    if (app.Community_Health_Partnership_Score__c != null)
      score1Total += Decimal.valueOf(app.Community_Health_Partnership_Score__c);
    if (app.Community_Health_Partnership_Score_2__c != null)
      score2Total += Decimal.valueOf(
        app.Community_Health_Partnership_Score_2__c
      );

    if (app.Type__c == 'New') {
      if (app.How_Youth_in_Community_Informed_Score__c != null)
        score1Total += Decimal.valueOf(
          app.How_Youth_in_Community_Informed_Score__c
        );
      if (app.How_Youth_in_Community_Informed_Score_2__c != null)
        score2Total += Decimal.valueOf(
          app.How_Youth_in_Community_Informed_Score_2__c
        );
      if (app.How_Existing_Members_Recruited_Score__c != null)
        score1Total += Decimal.valueOf(
          app.How_Existing_Members_Recruited_Score__c
        );
      if (app.How_Existing_Members_Recruited_Score_2__c != null)
        score2Total += Decimal.valueOf(
          app.How_Existing_Members_Recruited_Score_2__c
        );
    }

    if (app.Type__c == 'Existing') {
      if (app.Previous_Challenges_Recruitment_Score__c != null)
        score1Total += Decimal.valueOf(
          app.Previous_Challenges_Recruitment_Score__c
        );
      if (app.Previous_Challenges_Recruitment_Score_2__c != null)
        score2Total += Decimal.valueOf(
          app.Previous_Challenges_Recruitment_Score_2__c
        );
      if (app.Other_Challenges_Score__c != null)
        score1Total += Decimal.valueOf(app.Other_Challenges_Score__c);
      if (app.Other_Challenges_Score_2__c != null)
        score2Total += Decimal.valueOf(app.Other_Challenges_Score_2__c);
      if (app.Other_Successes_Score__c != null)
        score1Total += Decimal.valueOf(app.Other_Successes_Score__c);
      if (app.Other_Successes_Score_2__c != null)
        score2Total += Decimal.valueOf(app.Other_Successes_Score_2__c);
      if (app.Opportunity_for_Expansion_Score__c != null)
        score1Total += Decimal.valueOf(app.Opportunity_for_Expansion_Score__c);
      if (app.Opportunity_for_Expansion_Score_2__c != null)
        score2Total += Decimal.valueOf(
          app.Opportunity_for_Expansion_Score_2__c
        );
    }
  }
  // END getScoreTotals

  // BEGIN save
  public void save() {
    errorMessage = '';
    app.Status__c = 'In Progress';
    appClass.upsertApplication(app);
    appClass.upsertAppSites(activeSites);
    appClass.upsertAppSites(inactiveSites);
    appClass.upsertAppSites(newSites);
    if (errorMessage == '')
      showSaveSuccess = true;

    //PageReference tempPage = ApexPages.currentPage();
    //tempPage.setRedirect(true);
    //return tempPage;
  }
  // END save

  // BEGIN submit
  public void submit() {
    errorMessage = '';
    createContacts();
    system.debug('contacts = ' + contacts);

    if (portalName == 'Ripken' || app.FirstPic_National_Org_Code__c == 'Ripken')
      ripkenFieldValidation();
    else if (app.Grant_Type__c == 'TRAIL')
      trailFieldValidation();
    else if (app.Grant_Type__c == 'OVC')
      ovcFieldValidation();

    if (errorMessage == '') {
      app.Status__c = 'Submitted';
      app.Submitted_Date__c = date.today();
    }

    appClass.upsertApplication(app);
    appClass.upsertAppSites(activeSites);
    appClass.upsertAppSites(inactiveSites);
    appClass.upsertAppSites(newSites);

    if (errorMessage == '') {
      if (ApexPages.hasMessages())
        errorMessage += string.valueOf(ApexPages.getMessages());
      if (errorMessage == '')
        showSuccess = true;
    }
  }
  // END submit

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

  // BEGIN approve
  public PageReference approve() {
    errorMessage = '';
    app.Status__c = 'Approved';
    appClass.upsertApplication(app);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }
  // END approve

  // BEGIN sendBack
  public PageReference sendBack() {
    app.Status__c = 'Sent Back';
    appClass.upsertApplication(app);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }
  // END sendBack

  // BEGIN createReview
  public void createReview() {
    review = new Application_Review__c(
      RecordTypeId = Schema.SObjectType.Application_Review__c.getRecordTypeInfosByName()
        .get('NCAI')
        .getRecordTypeId(),
      Application__c = app.Id,
      Reviewer__c = currentUser.ContactId
    );
    editingReview = true;
  }
  // END createReview

  // BEGIN score
  public PageReference score() {
    app.Status__c = 'Reviewed';
    appClass.upsertApplication(app);
    if (editingReview)
      appClass.upsertAppReview(review);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    if (app.Grant_Type__c == 'OVC') {
      ovcReviewValidation();
      if (errorMessage == '')
        return pr;
      else
        return null;
    } else {
      return pr;
    }
  }
  // END score

  // BEGIN save score
  public PageReference saveScore() {
    appClass.upsertApplication(app);
    if (editingReview)
      appClass.upsertAppReview(review);
    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    if (app.Grant_Type__c == 'OVC') {
      ovcReviewValidation();
      if (errorMessage == '')
        return pr;
      else
        return null;
    } else {
      return pr;
    }
  }
  // END save score

  // BEGIN Review Validation
  public void ovcReviewValidation() {
    errorMessage = '';
    if (review.Biggest_Issue_Org_is_Facing_Score__c == null) {
      errorMessage += 'Issue Addressed Review Score is Required. <br />';
    }
    if (
      review.Biggest_Issue_Org_is_Facing_Notes__c == null ||
      review.Biggest_Issue_Org_is_Facing_Notes__c == ''
    ) {
      errorMessage += 'Issue Addressed Review Comments are Required.<br />';
    }
    if (review.How_Funds_Utilized_Score__c == null) {
      errorMessage += 'Funds Utilized Review Score is Required. <br />';
    }
    if (
      review.How_Funds_Utilized_Notes__c == null ||
      review.How_Funds_Utilized_Notes__c == ''
    ) {
      errorMessage += 'Funds Utilized Review Comments are Required. <br/>';
    }
    if (
      app.Has_Needs_Assessment__c && review.Needs_Assessment_Score__c == null
    ) {
      errorMessage += 'Needs Assessment Review Score is Required. <br/>';
    }
    if (
      app.Has_Needs_Assessment__c &&
      (review.Needs_Assessment_Notes__c == null ||
      review.Needs_Assessment_Notes__c == '')
    ) {
      errorMessage += 'Needs Assessment Review Comments are Required. <br/>';
    }
    if (app.Has_Strategic_Plan__c && review.Strategic_Plan_Score__c == null) {
      errorMessage += 'Strategic Plan Review Score is Required. <br/>';
    }
    if (
      app.Has_Strategic_Plan__c &&
      (review.Strategic_Plan_Notes__c == null ||
      review.Strategic_Plan_Notes__c == '')
    ) {
      errorMessage += 'Strategic Plan Review Comments are Required. <br/>';
    }
    if (
      review.Current_Program_Score__c == null &&
      app.Grant_Year__c == '2020 - 2021'
    ) {
      errorMessage += 'Current Program Review Score is Required. <br/>';
    }
    if (
      (review.Current_Program_Notes__c == null ||
      review.Current_Program_Notes__c == '') &&
      app.Grant_Year__c == '2020 - 2021'
    ) {
      errorMessage += 'Current Program Review Comments are Required. <br/>';
    }
    if (
      app.Has_Equipment_and_Supplies__c &&
      review.Equipment_and_Supplies_Score__c == null
    ) {
      errorMessage += 'Equipment and Supplies Review Score is Required. <br/>';
    }
    if (
      app.Has_Equipment_and_Supplies__c &&
      (review.Equipment_and_Supplies_Notes__c == null ||
      review.Equipment_and_Supplies_Notes__c == '')
    ) {
      errorMessage += 'Equipment and Supplies Review Comments are Required. <br/>';
    }
    if (review.Responsibilities_Score__c == null) {
      errorMessage += 'Capabilities and Competencies (Responsibility) Review Score is Required. <br/>';
    }
    if (
      review.Responsibilities_Notes__c == null ||
      review.Responsibilities_Notes__c == ''
    ) {
      errorMessage += 'Capabilities and Competencies (Responsibility) Review Comments are Required. <br/>';
    }
    if (review.Able_to_Recruit_Score__c == null) {
      errorMessage += 'Capabilities and Competencies (Able to Recruit) Review Score is Required. <br/>';
    }
    if (
      review.Able_to_Recruit_Notes__c == null ||
      review.Able_to_Recruit_Notes__c == ''
    ) {
      errorMessage += 'Capabilities and Competencies (Able to Recruit) Review Comments are Required. <br/>';
    }
    if (review.Other_Challenges_Score__c == null) {
      errorMessage += 'Plan for Collecting Data Review Score is Required. <br/>';
    }
    if (
      review.Other_Challenges_Notes__c == null ||
      review.Other_Challenges_Notes__c == ''
    ) {
      errorMessage += 'Plan for Collecting Data Review Comments are Required. <br/>';
    }
    if (review.Budget_Details_Score__c == null) {
      errorMessage += 'Budget Review Score is Required. <br/>';
    }
    if (
      review.Budget_Details_Notes__c == null ||
      review.Budget_Details_Notes__c == ''
    ) {
      errorMessage += 'Budget Review Comments are Required. <br/>';
    }
    if (review.Should_Award__c == null) {
      errorMessage += 'Award Recommendation is Required. <br/>';
    }
    if (review.Notes__c == null || review.Notes__c == '') {
      errorMessage += 'General Review Comments are Required. <br/>';
    }
  }
  // END Review Validation

  // BEGIN award
  public PageReference award() {
    appClass.upsertApplication(app);
    errorMessage = '';
    if (awardAmount != null)
      app.Awarded_Amount__c = awardAmount;
    if (startDate != null)
      app.Grant_Start_Date__c = startDate;
    if (endDate != null)
      app.Grant_End_Date__c = endDate;

    createAcct();
    acct.Type = app.Type__c;
    acct.EIN__c = app.EIN__c;
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

    String grants = acct.National_Grants__c;
    if (grants == null && grants != '')
      grants = app.Grant_Type__c;
    else if (!grants.contains(app.Grant_Type__c))
      grants += '; ' + app.Grant_Type__c;
    system.debug(grants);
    acct.National_Grants__c = grants;

    upsertAcct();
    if (ApexPages.hasMessages() && !system.Test.isRunningTest())
      return null;

    List<Account> accts = new List<Account>();
    List<Application_Site__c> allSites = activeSites;
    for (Application_Site__c s : inactiveSites)
      allSites.add(s);
    for (Application_Site__c s : newSites)
      allSites.add(s);
    for (Application_Site__c s : allSites) {
      Account a = new Account(
        Local_Organization__c = app.Organization__c,
        National_Organization__c = app.National_Organization__c,
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Site')
          .getRecordTypeId(),
        Active_Status__c = s.Active_Status__c,
        Name = s.Name
      );
      if (s.Site_Id__c != null)
        a.Id = s.Site_Id__c;
      if (
        s.Active_Status__c == 'Not Currently Implementing Site' ||
        s.Active_Status__c == 'Currently Implementing Site Not Continuing'
      ) {
        a.Is_Active__c = false;
      } else {
        a.Is_Active__c = true;
      }
      accts.add(a);
    }
    acctClass.upsertAccounts(accts);

    createContacts();
    system.debug('contacts = ' + contacts);
    cc.upsertContactList(contacts);
    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;

    if (portalName == 'Ripken') {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Ripken Local Admin'];
      if (ceo.Id != null) {
        acct.CEO__c = ceo.Id;
        User uceo = ucws.getUser(' WHERE ContactID = \'' + ceo.Id + '\'');
        if (uceo == null) {
          String un = ceo.Email + '.ripken';
          User[] dup = [SELECT Id FROM User WHERE UserName = :un];
          if (dup.size() == 0) {
            CreateCommunityUser ccu = new CreateCommunityUser();
            ccu.createUser(
              ceo.Id,
              ceo.Email,
              un,
              ceo.FirstName,
              ceo.LastName,
              p.Id
            );
          }
        }
      }
      if (pc.Id != null) {
        acct.Program_Coordinator__c = pc.Id;
        User upc = ucws.getUser(' WHERE ContactID = \'' + pc.Id + '\'');
        if (upc == null) {
          String un = pc.Email + '.ripken';
          User[] dup = [SELECT Id FROM User WHERE UserName = :un];
          if (dup.size() == 0) {
            CreateCommunityUser ccu = new CreateCommunityUser();
            ccu.createUser(
              pc.Id,
              pc.Email,
              un,
              pc.FirstName,
              pc.LastName,
              p.Id
            );
          }
        }
      }
    }
    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;

    acctClass.upsertAccount(acct);
    upsertAwardedApp();

    sg.Project_Name__c = app.Project_Title__c;
    if (sg.Start_Date__c == null && app.Grant_Start_Date__c != null)
      sg.Start_Date__c = app.Grant_Start_Date__c;
    if (sg.End_Date__c == null && app.Grant_End_Date__c != null)
      sg.End_Date__c = app.Grant_End_Date__c;
    sg.Report_Due_Date__c = dt.addMonths(6);
    sg.RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
      .get('Sub-Grant')
      .getRecordTypeId();
    if (grant != null)
      sg.National_Grant__c = Id.valueOf(grant);
    createAndUpsertGrant();

    if (ApexPages.hasMessages())
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference awardOVC() {
    errorMessage = '';
    createAcct();
    upsertAcct();

    createContacts();
    system.debug('contacts = ' + contacts);
    cc.upsertContactList(contacts);

    upsertAwardedApp();

    Grant__c[] grants = gc.getRelatedGrants(
      userAcct.Id,
      ' AND Name LIKE \'%OVC-2020%\''
    );
    if (grants.size() > 0) {
      sg.National_Grant__c = grants[0].Id;
    }
    createAndUpsertGrant();

    if (
      (errorMessage != '' || ApexPages.hasMessages()) &&
      !system.Test.isRunningTest()
    )
      return null;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  public void createAcct() {
    Decimal duns;
    if (app.DUNS_Number__c != null)
      duns = Integer.valueOf(app.DUNS_Number__c);
    if (app.Organization__c == null && app.National_Organization__c != null) {
      Account[] accts = [
        SELECT Id, EIN__c, DUNS__c
        FROM Account
        WHERE
          (EIN__c = :app.EIN__c
          OR DUNS__c = :duns)
          AND National_Organization__c = :app.National_Organization__c
      ];
      if (accts.size() > 0) {
        app.Organization__c = accts[0].Id;
        acct.Id = accts[0].Id;
      }
    }
    if (acct.Primary_Approver__c == null) {
      acct.Primary_Approver__c = currentUser.ContactId;
    }
    acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Local Organization')
      .getRecordTypeId();
    acct.National_Organization__c = app.National_Organization__c;
    acct.National_Organization_Name__c = app.National_Organization__r.Name;
    acct.DUNS__c = duns;
    String name = '';
    if (app.Organization_Name__c != null)
      name = app.Organization_Name__c;
    else if (app.Organization__c != null)
      name = app.Organization__c;
    acct.Name = name;
    acct.BillingStreet = app.Address__c;
    acct.BillingCity = app.City__c;
    acct.BillingState = app.State__c;
    acct.BillingPostalCode = app.Postal_Zip_Code__c;
  }

  public void upsertAcct() {
    User u = new User();
    u = ucws.getUser(' WHERE Alias = \'fpadmin\'');
    if (u == null)
      u = ucws.getUser(' WHERE Profile.Name = \'System Administrator\'');
    system.debug('ApplicationCtrl user for acct owner = ' + u.Name);
    if (u != null)
      acct.OwnerId = u.Id;
    acctClass.upsertAccount(acct);
    system.debug('ApplicationCtrl acct after upsert = ' + acct.Name);
  }

  public void upsertAwardedApp() {
    if (awardAmount != null)
      app.Awarded_Amount__c = awardAmount;
    app.Organization__c = acct.Id;
    app.Status__c = 'Awarded';
    app.Awarded_Date__c = date.today();
    appClass.upsertApplication(app);
  }

  public void createAndUpsertGrant() {
    sg.Account__c = acct.Id;
    if (sg.Name == null || sg.Name == '')
      sg.Name = app.Name + ' Grant';

    if (sg.Amount__c == null || sg.Amount__c == 0) {
      if (awardAmount != null && awardAmount > 0)
        sg.Amount__c = awardAmount;
      else if (app.Awarded_Amount__c != null && app.Awarded_Amount__c > 0)
        sg.Amount__c = app.Awarded_Amount__c;
    }

    sg.Application__c = app.Id;
    sg.CEO_Email__c = ceo.Email;
    sg.Program_Coordinator_Email__c = pc.Email;
    sg.Program_Coordinator__c = pc.Id;
    sg.RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
      .get('Sub-Grant')
      .getRecordTypeId();
    sg.LOA_Sent__c = false;
    gc.upsertGrant(sg);
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

  // BEGIN fieldValidation
  public void ripkenFieldValidation() {
    if (
      app.CEO_First_Name__c == null ||
      app.CEO_Last_Name__c == null ||
      app.CEO_Title__c == null ||
      app.CEO_Email__c == null ||
      app.CEO_Phone__c == null
    )
      errorMessage = 'Please fill out all fields for Chief Professional Officer, Executive Director, President. <br />';
    if (
      !app.GA_Same_as_CEO__c &&
      (app.Grant_Admin_First_Name__c == null ||
      app.Grant_Admin_Last_Name__c == null ||
      app.Grant_Admin_Title__c == null ||
      app.Grant_Admin_Email__c == null ||
      app.Grant_Admin_Phone__c == null)
    )
      errorMessage += 'Please fill out all fields for Application Contact, Grant Administration Primary Contact. <br />';
    if (
      !app.FA_Same_as_CEO__c &&
      !app.FA_Same_as_GA__c &&
      (app.Finance_Admin_First_Name__c == null ||
      app.Finance_Admin_Last_Name__c == null ||
      app.Finance_Admin_Title__c == null ||
      app.Finance_Admin_Email__c == null ||
      app.Finance_Admin_Phone__c == null)
    )
      errorMessage += 'Please fill out all fields for Direct Service Contact, Primary Program Coordinator. <br />';
    if (
      !app.PC_Same_as_CEO__c &&
      !app.PC_Same_as_GA__c &&
      (app.Program_Contact_First_Name__c == null ||
      app.Program_Contact_Last_Name__c == null ||
      app.Program_Contact_Title__c == null ||
      app.Program_Contact_Email__c == null ||
      app.Program_Contact_Phone__c == null)
    )
      errorMessage += 'Please fill out all fields for Financial Contact. <br />';

    if (app.Organization_Name__c == null)
      errorMessage += 'Organization Name is required <br />';
    if (app.EIN__c == null)
      errorMessage += 'EIN is required <br />';
    if (app.Website__c == null)
      errorMessage += 'Website is required <br />';
    if (app.Phone__c == null)
      errorMessage += 'Phone is required <br />';
    if (app.Address__c == null)
      errorMessage += 'Address is required <br />';
    if (app.City__c == null)
      errorMessage += 'City is required <br />';
    if (app.State__c == null)
      errorMessage += 'State is required <br />';
    if (app.Postal_Zip_Code__c == null)
      errorMessage += 'ZipCode is required <br />';
    if (app.Total_Budget__c == null)
      errorMessage += 'Annual Budget is required <br />';
    if (app.Number_of_Sites__c == null)
      errorMessage += 'No. of Sites is required <br />';
    if (app.Urban__c == null && app.Suburban__c == null && app.Rural__c == null)
      errorMessage += 'Community Setting is required <br />';
    if (app.Type__c == null)
      errorMessage += 'Organization Type is required <br />';
    if (app.Additional_Org_Classification__c == null)
      errorMessage += 'Additional Org Classification is required <br />';
    if (app.Mission_Statement__c == null)
      errorMessage += 'Mission Statement is required <br />';
    if (app.Number_of_Youth_Served_per_Year__c == null)
      errorMessage += 'Number of Youth Served is required <br />';
    if (app.Min_Age_of_Youth__c == null)
      errorMessage += 'Min Age is required <br />';
    if (app.Max_Age_of_Youth__c == null)
      errorMessage += 'Max Age is required <br />';
    if (app.Percent_Male__c == null)
      errorMessage += '% Male is required <br />';
    if (app.Percent_Female__c == null)
      errorMessage += '% Female is required <br />';
    if (app.Percent_Eligible_Free_Reduced_Lunch__c == null)
      errorMessage += '% Youth eligible for free/reduced-price lunch is required <br />';
    if (app.Percent_Youth_in_Single_Parent_Homes__c == null)
      errorMessage += '% Youth in Single-Parent Homes is required <br />';
    if (app.Youth_Living_at_or_below_Poverty_Level__c == null)
      errorMessage += '% Youth living at/below poverty level is required <br />';
    if (app.Program_Number_of_Youth_Served__c == null)
      errorMessage += 'Estimated number of youth is required <br />';
    if (app.Program_Min_Age_of_Youth__c == null)
      errorMessage += 'Min Age of Youth this award will serve is required <br />';
    if (app.Program_Max_Age_of_Youth__c == null)
      errorMessage += 'Max Age of Youth this award will serve is required <br />';
    if (app.Program_Percent_Male__c == null)
      errorMessage += '% Male this award will serve is required <br />';
    if (app.Program_Percent_Female__c == null)
      errorMessage += '% Female this award will serve is required <br />';
    if (app.Program_Number_of_Sites__c == null)
      errorMessage += 'Number of Sites/Units is required <br />';
    if (app.Program_Number_of_Parent_in_Military__c == null)
      errorMessage += 'Number of youth with a parent in the military is required <br />';
    if (app.Program_Percent_Eligible_Reduced_Lunch__c == null)
      errorMessage += '% Youth eligible for free/reduced-price lunch is required <br />';
    if (app.Program_Percent_Youth_Single_Parent_Home__c == null)
      errorMessage += '% Youth in Single-Parent Homes is required <br />';
    if (app.Program_Percent_at_below_Poverty_Level__c == null)
      errorMessage += '% Youth living at/below poverty level is required <br />';
    if (app.Grant_Start_Date__c == null)
      errorMessage += 'Program Start Date is required <br />';
    if (app.Grant_End_Date__c == null)
      errorMessage += 'Program End Date is required <br />';
    if (app.Plan_to_Connect_Youth_with_Adult_Mentors__c == null)
      errorMessage += 'Capacity to recruit and engage community partners is required <br />';
    if (app.Timeline_for_Plans__c == null)
      errorMessage += 'Timeline is required <br />';
    if (app.Social_Media_Usernames__c == null)
      errorMessage += 'Social Media Usernames are required <br />';
    if (appType == 'special' && app.Previous_Experiences__c == null)
      errorMessage += 'Previous experience is required <br />';
    if (
      (appType == 'baseball' || appType == 'healthy') &&
      app.Team_Sports_Implementation_Plan__c == null
    )
      errorMessage += 'Implementation plan is required <br />';
    if (appType == 'baseball' || appType == 'great' || appType == 'healthy') {
      if (app.Orgs_Knowledge_of_Military__c == null)
        errorMessage += 'Knowledge of military is required <br />';
      if (app.Additional_Information__c == null)
        errorMessage += 'Additional information is required <br />';
      if (app.Number_Participating_in_HCHC_Sessions__c == null)
        errorMessage += 'No. to participate in sessions is required <br />';
      if (app.Number_of_Staff_Instructors__c == null)
        errorMessage += 'No. of staff instructors is required <br />';
      if (app.Healthy_Choices_Implementation_Plan__c == null)
        errorMessage += 'Implementation plan is required <br />';
      if (app.School_Opening_and_Closing_Dates__c == null)
        errorMessage += 'School opening and closing dates is required <br />';
    }
    if (app.RecordType.Name.contains('NCAI - OVC')) {
    }

    Boolean hasAtt = false;
    for (Attachment a : attClass.getAttachments(app.Id, null)) {
      if (a.Name == 'Tax Status')
        hasAtt = true;
      system.debug('attachment = ' + a.Name);
    }
    if (hasAtt == false)
      errorMessage += 'A Tax Status document is required. <br />';
  }

  public void trailFieldValidation() {
    if (
      app.Organization_Name__c == null ||
      app.Address__c == null ||
      app.City__c == null ||
      app.State__c == null ||
      app.Postal_Zip_Code__c == null ||
      app.DUNS_Number__c == null ||
      app.Access_to_Computers__c == null ||
      app.Adequate_Space__c == null ||
      app.Previous_Funding_Received__c == null
    ) {
      errorMessage = 'Please fill out all fields for General Applicant Information. <br />';
    }

    if (
      app.CEO_First_Name__c == null ||
      app.CEO_Last_Name__c == null ||
      app.CEO_Email__c == null ||
      app.CEO_Phone__c == null
    )
      errorMessage = 'Please fill out all fields for Chief Executive Officer. <br />';
    if (
      !app.FA_Same_as_CEO__c &&
      (app.Finance_Admin_First_Name__c == null ||
      app.Finance_Admin_Last_Name__c == null ||
      app.Finance_Admin_Email__c == null ||
      app.Finance_Admin_Phone__c == null)
    )
      errorMessage += 'Please fill out all fields for Main Financial Contact. <br />';
    if (
      !app.PC_Same_as_CEO__c &&
      !app.PC_Same_as_FA__c &&
      (app.Program_Contact_First_Name__c == null ||
      app.Program_Contact_Last_Name__c == null ||
      app.Program_Contact_Email__c == null ||
      app.Program_Contact_Phone__c == null)
    )
      errorMessage += 'Please fill out all fields for Main Programmatic Contact. <br />';

    for (Application_Site__c s : activeSites) {
      errorMessage += siteFieldValidation(s);
    }
    for (Application_Site__c s : inactiveSites) {
      errorMessage += siteFieldValidation(s);
    }
    for (Application_Site__c s : newSites) {
      errorMessage += siteFieldValidation(s);
    }

    if (
      app.Retention_Efforts_for_Youth__c == null ||
      app.Caretaker_Involvement__c == null ||
      app.Community_Health_Partnership__c == null ||
      (app.Type__c == 'Existing' &&
      (app.Previous_Challenges_with_Recruitment__c == null ||
      app.Other_Challenges__c == null ||
      app.Other_Successes__c == null ||
      app.Opportunity_for_Expansion__c == null)) ||
      (app.Type__c == 'New' &&
      (app.How_Youth_in_Community_Informed__c == null ||
      app.How_Existing_Members_Recruited__c == null))
    ) {
      errorMessage += 'Please fill out all fields for Application Narrative. <br />';
    }
    if (
      activeSites.size() == 0 &&
      inactiveSites.size() == 0 &&
      newSites.size() == 0
    )
      errorMessage += 'In order to submit an application, you must include information for at least one site at which you plan to run the T.R.A.I.L. program. Please click the red “Add Site” button under Part B. of the application in order to do so.';
    if (errorMessage != '') {
      errorMessage += '<br /><strong>Please enter N/A for any field that does not apply to you. </strong><br />';
    }
  }

  public void ovcFieldValidation() {
    if (app.Organization_Type__c == null)
      errorMessage += 'Organization Type is Missing <br />';
    /*
        else if(app.Organization_Type__c != 'Tribe') {
            hasAtts = false;
            getAtt('Applicant Org Type Documentation');
            if(hasAtts == false) errorMessage += 'Applicant Org Type Documentation is required. <br />';
        }
        */

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

    if (
      app.Has_Needs_Assessment__c == true &&
      (app.Previous_Experiences__c == null ||
      app.Needs_Assessment__c == null)
    )
      errorMessage += 'Needs Assessment questions are required <br />';

    if (
      app.Has_Strategic_Plan__c == true &&
      (app.Strategic_Plan__c == null ||
      app.Additional_Resources_for_Strategic_Plan__c == null)
    )
      errorMessage += 'Strategic Plan questions are required <br />';

    if (
      app.Areas_of_Service__c == null ||
      app.Current_Program_Description__c == null
    )
      errorMessage += 'Support for Victim Services questions are required <br />';

    if (
      app.Has_Equipment_and_Supplies__c == true &&
      app.Equipment_and_Supplies__c == null
    )
      errorMessage += 'Equipment and Supplies questions are required <br />';

    if (app.Responsibilities__c == null || app.Able_to_Recruit__c == null)
      errorMessage += 'Capabilities and Competencies questions are required <br />';

    if (
      app.Biggest_Issue_Organization_is_Facing__c == null ||
      app.How_Funds_Utilized__c == null ||
      app.Biggest_Issue_Organization_is_Facing__c == null ||
      app.Other_Challenges__c == null
    ) {
      errorMessage += 'All fields in the Request Details section with are required <br />';
    }

    if (
      app.Total_Amount_Requested__c > 250000 &&
      (app.Budget_Details__c == null ||
      app.Budget_Details__c == '')
    ) {
      errorMessage += 'Additional justification is required for requests over $250,000. <br />';
    }

    if (app.Personnel_Budget__c == null) {
      errorMessage += 'A Personnel Budget Amount is required. <br />';
    }

    if (app.Fringe_Benefits_Budget__c == null) {
      errorMessage += 'A Fringe Benefits Budget Amount is required. <br />';
    }

    if (app.Travel_Budget__c == null) {
      errorMessage += 'A Travel Budget Amount is required. <br />';
    }

    if (app.Supplies_Budget__c == null) {
      errorMessage += 'An Equipment/Supplies Amount is required. <br />';
    }

    if (app.Contracts_Budget__c == null) {
      errorMessage += 'A Contracts and Consultants Budget Amount is required. <br />';
    }

    if (app.Contractor_Travel_Budget__c == null) {
      errorMessage += 'A Consultant/Contractor Travel Budget Amount is required. <br />';
    }

    if (app.Other_Costs_Budget__c == null) {
      errorMessage += 'An Other Costs Budget Amount is required. <br />';
    }

    if (app.Indirect_Costs_Budget__c == null) {
      errorMessage += 'An Indirect Costs Budget Amount is required. <br />';
    }

    if (
      app.Personnel_Description__c == null ||
      app.Personnel_Description__c == ''
    ) {
      errorMessage += 'A Personnel Budget Description is required. <br />';
    }

    if (
      app.Fringe_Benefits_Description__c == null ||
      app.Fringe_Benefits_Description__c == ''
    ) {
      errorMessage += 'A Fringe Benefits Budget Description is required. <br />';
    }

    if (app.Travel_Description__c == null || app.Travel_Description__c == '') {
      errorMessage += 'A Travel Budget Description is required. <br />';
    }

    if (
      app.Supplies_Description__c == null ||
      app.Supplies_Description__c == ''
    ) {
      errorMessage += 'An Equipment/Supplies Budget Description is required. <br />';
    }

    if (
      app.Contracts_Description__c == null ||
      app.Contracts_Description__c == ''
    ) {
      errorMessage += 'A Contracts and Consultants Budget Description is required. <br />';
    }

    if (
      app.Contractor_Travel_Description__c == null ||
      app.Contractor_Travel_Description__c == ''
    ) {
      errorMessage += 'A Consultant/Contractor Travel Budget Description is required. <br />';
    }

    if (
      app.Other_Costs_Description__c == null ||
      app.Other_Costs_Description__c == ''
    ) {
      errorMessage += 'An Other Costs Budget Description is required. <br />';
    }

    if (
      app.Indirect_Costs_Description__c == null ||
      app.Indirect_Costs_Description__c == ''
    ) {
      errorMessage += 'An Indirect Costs Budget Description is required. <br />';
    }

    if (app.Total_Amount_Requested__c == null) {
      errorMessage += 'Summary Budget Total is required. Please select "Calculate Total" before submitting.<br/>';
    }

    if (app.Signatory_Title__c == null || app.Signatory_Title__c == '') {
      errorMessage += 'A Signatory Title is required. <br />';
    }

    if (app.Signatory_Name__c == null || app.Signatory_Name__c == '') {
      errorMessage += 'A Signatory Title is required. <br />';
    }

    if (app.Signatory_Email__c == null || app.Signatory_Email__c == '') {
      errorMessage += 'A Signatory Title is required. <br />';
    }

    if (app.Terms_Acknowledged__c == false) {
      errorMessage += 'Acknowledging to comply with federal policies and regulations is required.<br/>';
    }

    if (errorMessage != '') {
      errorMessage += '<br /><strong>Please enter N/A for any field that does not apply to you. </strong><br />';
    } else if (gaEmail != app.Grant_Admin_Email__c) {
      User[] dup = [
        SELECT Id
        FROM User
        WHERE UserName = :app.Grant_Admin_Email__c
      ];
      if (dup.size() == 0) {
        updateGA(
          gaEmail,
          app.Grant_Admin_First_Name__c,
          app.Grant_Admin_Last_Name__c,
          app.Grant_Admin_Email__c
        );

        system.debug('contacts = ' + contacts);
        cc.upsertContactList(contacts);
      } else {
        errorMessage +=
          'A user with the email ' +
          app.Grant_Admin_Email__c +
          ' already exists';
      }
    }
  }

  public String siteFieldValidation(Application_Site__c s) {
    String message = '';
    if (
      (app.Type__c == 'Existing' &&
      s.Active_Status__c == null) ||
      s.Name == null ||
      s.Tribes_served__c == null ||
      s.Number_of_Club_Members__c == null ||
      s.Number_of_Applicable_Youth__c == null ||
      s.Average_Daily_Attendance_During_School__c == null ||
      s.Average_Daily_Attendance_During_Summer__c == null ||
      s.School_Implementation_Site__c == null
    ) {
      String name = 'Project Location Details and Communities Served';
      if (s.Name != null)
        name = s.Name;
      message += 'Please fill out all fields for ' + name + '. <br />';
    }
    return message;
  }
  // END fieldValidation

  // BEGIN createContacts
  public void createContacts() {
    contacts.clear();
    Id rId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Contact')
      .getRecordTypeId();
    Map<String, Id> emails = new Map<String, Id>();
    for (Contact c : [SELECT Email FROM Contact WHERE AccountId = :acct.Id])
      emails.put(c.Email, c.Id);

    if (app.CEO_Email__c != null && app.CEO_Last_Name__c != null) {
      if (!emails.containsKey(app.CEO_Email__c) || portalName == 'Ripken') {
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

    if (
      app.Grant_Admin_Email__c != null &&
      app.Grant_Admin_Last_Name__c != null &&
      app.GA_Same_as_CEO__c == false
    ) {
      if (
        !emails.containsKey(app.Grant_Admin_Email__c) || portalName == 'Ripken'
      ) {
        if (emails.containsKey(app.Grant_Admin_Email__c))
          ga.Id = emails.get(app.Grant_Admin_Email__c);
        if (emails.containsKey(gaEmail))
          ga.Id = emails.get(gaEmail);
        ga.AccountId = app.Organization__c;
        ga.Salutation = app.Grant_Admin_Prefix__c;
        ga.FirstName = app.Grant_Admin_First_Name__c;
        ga.LastName = app.Grant_Admin_Last_Name__c;
        ga.Suffix = app.Grant_Admin_Suffix__c;
        ga.Title = app.Grant_Admin_Title__c;
        ga.Role__c = 'Grant Admin';
        ga.Email = app.Grant_Admin_Email__c;
        ga.Phone = app.Grant_Admin_Phone__c;
        ga.Extension__c = app.Grant_Admin_Ext__c;
        ga.MobilePhone = app.Grant_Admin_Mobile__c;
        ga.RecordTypeId = rId;
        contacts.add(ga);
      }
    }

    if (
      app.Finance_Admin_Email__c != null &&
      app.Finance_Admin_Last_Name__c != null &&
      app.FA_Same_as_CEO__c == false &&
      app.FA_Same_as_GA__c == false
    ) {
      if (
        !emails.containsKey(app.Finance_Admin_Email__c) ||
        portalName == 'Ripken'
      ) {
        if (emails.containsKey(app.Finance_Admin_Email__c))
          fa.Id = emails.get(app.Finance_Admin_Email__c);
        fa.AccountId = app.Organization__c;
        fa.Salutation = app.Finance_Admin_Prefix__c;
        fa.FirstName = app.Finance_Admin_First_Name__c;
        fa.LastName = app.Finance_Admin_Last_Name__c;
        fa.Suffix = app.Finance_Admin_Suffix__c;
        fa.Title = app.Finance_Admin_Title__c;
        fa.Role__c = 'Finance Lead';
        fa.Email = app.Finance_Admin_Email__c;
        fa.Phone = app.Finance_Admin_Phone__c;
        fa.Extension__c = app.Finance_Admin_Ext__c;
        fa.MobilePhone = app.Finance_Admin_Mobile__c;
        fa.RecordTypeId = rId;
        contacts.add(fa);
      }
    }

    if (
      app.Program_Contact_Email__c != null &&
      app.Program_Contact_Last_Name__c != null &&
      app.PC_Same_as_CEO__c == false &&
      app.PC_Same_as_FA__c == false &&
      app.PC_Same_as_GA__c == false
    ) {
      if (
        !emails.containsKey(app.Program_Contact_Email__c) ||
        portalName == 'Ripken'
      ) {
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

    /*
        for(Contact c : contacts) {
            if(c.FirstName == null || c.FirstName == '' || c.LastName == null || c.LastName == '' ||
               c.Title == null || c.Title == '' || c.Email == null || c.Email == '' || c.Phone == null || c.Phone == '')
                errorMessage = 'Please fill out all ' + c.Role__c +' fields.';
        }
		*/
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

  // BEGIN popups
  public void showNotEligiblePopup() {
    notesPopupType = 'notEligible';
    displayNotesPopup = true;
  }
  public void showSendBackPopup() {
    notesPopupType = 'sendBack';
    displayNotesPopup = true;
  }
  public void hideNotesPopup() {
    displayNotesPopup = false;
  }
  public void showApprovePopup() {
    displayApprovePopup = true;
  }
  public void hideApprovePopup() {
    displayApprovePopup = false;
  }
  public void showAttPopup() {
    displayAttPopup = true;
  }
  public void hideAttPopup() {
    getAtt('Applicant Org Type Documentation');
    displayAttPopup = false;
  }
  public void showReviewNotesPopup() {
    displayReviewNotesPopup = true;
  }
  public void hideReviewNotesPopup() {
    displayReviewNotesPopup = false;
  }
  // END popups

  @future
  public static void updateGA(
    String gaEmail,
    String first,
    String last,
    String email
  ) {
    UserClassWithoutSharing ucws = new UserClassWithoutSharing();
    User u = ucws.getUser(' WHERE UserName = \'' + gaEmail + '\'');
    u.FirstName = first;
    u.LastName = last;
    u.Email = email;
    u.UserName = email;
    system.debug('grant admin user = ' + u);
    ucws.updateUser(u);
  }
}
