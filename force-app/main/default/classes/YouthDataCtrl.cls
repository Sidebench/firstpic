public with sharing class YouthDataCtrl {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  private AccountClass ac = new AccountClass();
  private ContactClass cc = new ContactClass();
  private ProgramReportClass prc = new ProgramReportClass();
  private YouthInProgramReportClass yprc = new YouthInProgramReportClass();
  private PAChallengeClass pacc = new PAChallengeClass();
  private SurveyClass sc = new SurveyClass();
  private ChapterReportClass crc = new ChapterReportClass();
  private GrantClass gc = new GrantClass();
  private PaginationClass pc = new PaginationClass();
  private getIdFromString gifs = new getIdFromString();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public Id yprId { get; set; }
  public Youth_in_Program_Report__c ypr { get; set; }
  public Youth_in_Program_Report__c duplicateYPR { get; set; }
  public List<Youth_in_Program_Report__c> allItems { get; set; }
  public List<Youth_in_Program_Report__c> items { get; set; }

  public Id surveyId { get; set; }
  public Survey__c survey { get; set; }
  public Boolean surveyReadOnly { get; set; }
  public List<PA_Challenge__c> pac_list { get; set; }

  public Program_Report__c report { get; set; }
  public Id youthId { get; set; }
  public Contact youth { get; set; }
  public Contact duplicateYouth { get; set; }
  public List<Contact> youth_list { get; set; }

  public Id localOrgId { get; set; }
  public List<SelectOption> localOrgOptions { get; set; }
  public Id siteId { get; set; }
  public List<SelectOption> siteOptions { get; set; }
  public Id grantId { get; set; }
  public List<SelectOption> grantOptions { get; set; }
  public Boolean includeClosedGrants { get; set; }
  public String year { get; set; }
  public List<SelectOption> yearOptions { get; set; }
  public String sortBy { get; set; }
  public List<SelectOption> sortByOptions { get; set; }

  public String reportType { get; set; }
  public Boolean hasSites { get; set; }
  public String siteName { get; set; }
  public String reportName { get; set; }
  public String grantName { get; set; }
  public String grantYear { get; set; }
  public String reportPeriod { get; set; }

  public Date dt = date.today();
  public Decimal activeYouth { get; set; }
  public Decimal leftPast30 { get; set; }
  public Decimal joinedPast30 { get; set; }

  public Boolean displayFindYouthPopup { get; set; }
  public Boolean displayAddYouthToGrantPopup { get; set; }
  public Boolean displayConfirmPopup { get; set; }
  public Boolean displaySendBackPopup { get; set; }
  public Boolean displayApprovePopup { get; set; }
  public Boolean displayEditYPRPopup { get; set; }
  public Boolean displayDeleteYPRPopup { get; set; }

  public String sizeErrorMessage { get; set; }
  public String errorMessage { get; set; }
  public String successMessage { get; set; }
  public String confirmMessage { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public YouthDataCtrl getYouthDataCtrl() {
    return this;
  }

  public YouthDataCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;
    if (userAcctType == 'Site')
      siteId = userAcct.Id;
    if (userAcct.Has_Sites__c || userAcct.National_Has_Sites__c)
      hasSites = true;
    else
      hasSites = false;

    if (portalName == 'NPAL' || portalName == 'DMV')
      reportType = 'grant';
    else
      reportType = 'program';

    report = new Program_Report__c();
    ypr = new Youth_in_Program_Report__c();
    duplicateYPR = new Youth_in_Program_Report__c();
    allItems = new List<Youth_in_Program_Report__c>();
    items = new List<Youth_in_Program_Report__c>();
    youth_list = new List<Contact>();
    pac_list = new List<PA_Challenge__c>();
    youth = new Contact();
    duplicateYouth = new Contact();

    localOrgOptions = new List<SelectOption>();
    siteOptions = new List<SelectOption>();
    grantOptions = new List<SelectOption>();
    includeClosedGrants = true;
    yearOptions = new List<SelectOption>();

    sortByOptions = new List<SelectOption>();
    if (userAcctType != 'Site' && hasSites) {
      sortByOptions.add(new SelectOption('Site_Name__c', 'Site'));
      sortBy = 'Site_Name__c';
    } else {
      sortBy = 'Contact_Name__c';
    }
    sortByOptions.add(new SelectOption('Contact_Name__c', 'Youth Name'));
    sortByOptions.add(new SelectOption('Grant_Name__c', 'Grant Name'));

    getURLParams();
  }

  // BEGIN getURLParams
  public void getURLParams() {
    year = ApexPages.currentPage().getParameters().get('year');

    String urlSiteId = ApexPages.currentPage().getParameters().get('siteId');
    siteId = gifs.getId(urlSiteId);

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);

    String urlYprId = ApexPages.currentPage().getParameters().get('yprId');
    yprId = gifs.getId(urlYprId);

    String urlSurveyId = ApexPages.currentPage()
      .getParameters()
      .get('surveyId');
    surveyId = gifs.getId(urlSurveyId);

    String urlYouthId = ApexPages.currentPage().getParameters().get('youthId');
    youthId = gifs.getId(urlYouthId);
  }
  // END getURLParams

  // BEGIN getLocalOrgs
  public void getLocalOrgs() {
    localOrgOptions.clear();
    Id aId = userAcct.Id;
    if (grantId != null && localOrgOptions == null) {
      Grant__c[] grantOptions = [
        SELECT Account__r.Id
        FROM Grant__c
        WHERE Id = :grantId
      ];
      if (grantOptions.size() > 0)
        aId = grantOptions[0].Account__r.Id;
    }
    if (userAcctType != 'Site')
      localOrgOptions.add(new SelectOption('', ''));
    for (
      Account a : ac.getRelatedAccountList(aId, userAcctType, '', '', null)
    ) {
      if (a.RecordType.Name == 'Local Organization')
        localOrgOptions.add(new SelectOption(a.Id, a.Name));
    }
    if (userAcctType != 'Site' && localOrgOptions.size() == 2) {
      //localOrgId = Id.valueOf(localOrgOptions.get(1).getValue());
    } else if (localOrgOptions.size() == 1) {
      localOrgId = Id.valueOf(localOrgOptions.get(0).getValue());
    }
  }
  // END getLocalOrgs

  // BEGIN getSiteOptions
  public void getSiteOptions() {
    siteOptions.clear();
    Id aId = userAcct.Id;
    if (localOrgId != null)
      aId = localOrgId;
    else if (siteId != null)
      aId = siteId;
    else if (grantId != null) {
      Grant__c[] grantOptions = [
        SELECT Account__r.Id
        FROM Grant__c
        WHERE Id = :grantId
      ];
      if (grantOptions.size() > 0)
        aId = grantOptions[0].Account__r.Id;
    }
    if (userAcctType == 'Site' || hasSites) {
      if (userAcctType != 'Site')
        siteOptions.add(new SelectOption('', 'View All'));
      for (
        Account a : ac.getRelatedAccountList(aId, userAcctType, '', '', null)
      ) {
        if (a.RecordType.Name == 'Site')
          siteOptions.add(new SelectOption(a.Id, a.Name));
      }
      if (siteId == null) {
        if (userAcctType != 'Site' && siteOptions.size() == 2) {
          //siteId = Id.valueOf(siteOptions.get(1).getValue());
        } else if (siteOptions.size() == 1) {
          //siteId = Id.valueOf(siteOptions.get(0).getValue());
        }
      }
    }
  }
  // END getSiteOptions

  // BEGIN getGrantOptions
  public void getGrantOptions() {
    grantOptions.clear();

    Id gcId = userAcct.Id;
    if (userAcctType == 'Site' && userAcct.Local_Organization_Id__c != null)
      gcId = userAcct.Local_Organization_Id__c;
    else if (localOrgId != null)
      gcId = localOrgId;
    if (siteId != null) {
      gcId = siteId;
      List<Account> accts = ac.getRelatedAccountList(
        siteId,
        userAcctType,
        '',
        '',
        null
      );
      if (accts.size() > 0 && accts[0].RecordType.Name == 'Site')
        gcId = accts[0].Local_Organization_Id__c;
    }
    String soqlAND = '';
    if (includeClosedGrants == false)
      soqlAND = ' AND Grant_Status__c != \'Closed\'';
    grantOptions = gc.getGrantOptions(
      userAcctType,
      gcId,
      null,
      'Name',
      '',
      '',
      soqlAND
    );

    if (grantId == null) {
      grantId = gc.selectedGrantId;
      /* 
            if(userAcctType != 'Site' && grantOptions.size() == 2) {
                grantId = Id.valueOf(grantOptions.get(1).getValue());
            } else if(grantOptions.size() > 0) {
                String i = grantOptions.get(0).getValue();
                if(Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(i).matches() ){
                    grantId = Id.valueOf(i);
                    grantName = grantOptions.get(0).getLabel();
                }
            }
            else if(grantOptions.size() == 1) {
                grantId = Id.valueOf(grantOptions.get(0).getValue());
                grantName = grantOptions.get(0).getLabel();
            } else {
                Date dt = date.today();
                Grant__c[] gs = [SELECT Id, Name, Year__c FROM Grant__c WHERE Account__c = :gcId 
                                 AND Grant_Start_Date__c <= :dt AND Grant_End_Date__c >= :dt LIMIT 1];
                if(gs.size() > 0) {
                    grantId = gs[0].Id;
                    grantName = gs[0].Name;
                }
            }
            */
    }
  }
  // END getGrantOptions

  // BEGIN getGrantYearOptions
  public void getGrantYearOptions() {
    yearOptions.clear();
    Set<String> grantYearOptions = new Set<String>();
    for (Grant__c g : gc.getGrantYears(userAcct.Id)) {
      if (!grantYearOptions.contains(g.Year__c) && g.Year__c != null) {
        grantYearOptions.add(g.Year__c);
        yearOptions.add(new SelectOption(g.Year__c, g.Year__c));
      }
    }
    yearOptions.sort();
    if (year == null && yearOptions.size() > 0)
      year = String.valueOf(yearOptions.get(yearOptions.size() - 1).getValue());
  }
  // END getGrantYearOptions

  // BEGIN getYearOptions
  public void getYearOptions() {
    yearOptions = spf.getPicklistOptions(
      'Program_Report__c',
      'Grant_Year__c',
      'View All'
    );
    /*
        yearOptions.clear();
        Set<String> grantYearOptions = new Set<String>();
        for(Program_Report__c pr : prc.getRelatedReportList(userAcct.Id, userAcctType, localOrgId, siteId, null, ' AND RecordType.Name = \'Youth Data\'')) {            
            if(!grantYearOptions.contains(pr.Grant_Year__c) && pr.Grant_Year__c != null) {
                grantYearOptions.add(pr.Grant_Year__c);
                yearOptions.add(new SelectOption(pr.Grant_Year__c, pr.Grant_Year__c));
            }
        }
        yearOptions.sort();
        if(yearOptions.size() == 0) yearOptions.add(new SelectOption(String.valueOf(dt.year()), String.valueOf(dt.year())));
        if(year == null) year = String.valueOf(yearOptions.get(yearOptions.size() - 1).getValue());
		*/
  }

  public void getCurrentYear() {
    Integer y = dt.year();
    for (SelectOption i : yearOptions) {
      if (i.getValue().contains(String.valueOf(y)))
        year = i.getValue();
    }
  }
  // END getYearOptions

  // BEGIN getLists
  public void getLists() {
    getLocalOrgs();
    getSiteOptions();
    getGrantOptions();
    if (portalName == 'NPAL' || portalName == 'DMV')
      getGrantYearOptions();
    else
      getYearOptions();
    if (youthId == null)
      getYPRs();
  }

  public void getYPRs() {
    sizeErrorMessage = '';
    items.clear();
    activeYouth = 0;
    leftPast30 = 0;
    joinedPast30 = 0;

    Id aId = userAcct.Id;
    if (localOrgId != null)
      aId = localOrgId;
    else if (siteId != null)
      aId = siteId;
    Set<Id> ids = new Set<Id>();

    if (reportType == 'grant') {
      for (
        Grant__c g : gc.getRelatedSubGrants(
          aId,
          grantId,
          null,
          'Name',
          null,
          null,
          null
        )
      ) {
        if (!ids.contains(g.Id) && g.Year__c == year)
          ids.add(g.Id);
      }
      allItems = yprc.getRelatedGrantYPRList(ids, sortBy);
    } else {
      for (
        Program_Report__c pr : prc.getRelatedReportList(
          userAcct.Id,
          userAcctType,
          localOrgId,
          siteId,
          grantId,
          ' AND RecordType.Name = \'Youth Data\''
        )
      ) {
        if (
          !ids.contains(pr.Id) &&
          (pr.Grant_Year__c == year ||
          year == 'View All')
        )
          ids.add(pr.Id);
      }
      allItems = yprc.getRelatedYPRList(ids, sortBy);
    }
    for (Youth_in_Program_Report__c ypr : allItems) {
      if (ypr.Active_Status__c == 'Active')
        activeYouth++;
      if (ypr.Active_Date__c > dt.addDays(-30))
        joinedPast30++;
      if (ypr.Exited_Date__c > dt.addDays(-30))
        leftPast30++;
    }
    totalSize = allItems.size();
    if (totalSize > 999)
      sizeErrorMessage =
        'List of ' +
        totalSize +
        ' results is too large to display. Please narrow search criteria and refresh results';
    else
      first();
  }

  public void clear() {
    localOrgId = null;
    siteId = null;
    grantId = null;
    getCurrentYear();
    getLists();
  }
  // END getLists

  // BEGIN getYPR
  public void getYPR() {
    if (yprId != null || (youthId != null && report.Id != null))
      ypr = yprc.getYPR(yprId, youthId, report.Id, grantId);
    if (ypr.Site_Id__c != null)
      siteId = ypr.Site_Id__c;
    if (ypr.Grant_Id__c != null)
      grantId = ypr.Grant_Id__c;
    if (ypr.Grant_Year__c != null)
      year = ypr.Grant_Year__c;
  }
  // END getYPR

  // BEGIN getYouthYPRList
  public void getYouthYPRList() {
    includeClosedGrants = false;
    if (youthId != null) {
      youth = cc.getContact(youthId);
      if (hasSites)
        siteId = youth.AccountId;
      else
        localOrgId = youth.AccountId;
      items = yprc.getYouthYPRList(youth.Id);
      getLists();
    }
  }
  // END getYouthYPRList

  // BEGIN getYouth
  public void getYouth() {
    includeClosedGrants = false;
    if (youthId != null) {
      youth = cc.getContact(youthId);
    } else {
      youth = new Contact();
      if (siteId != null)
        youth.AccountId = siteId;
    }
    getLists();

    getYPR();
    if (ypr.Id != null) {
      if (ypr.Site_Id__c != null && siteId == null)
        siteId = ypr.Site_Id__c;
      if (ypr.Site_Name__c != null)
        siteName = ypr.Site_Name__c;
      if (ypr.Program_Report_Name__c != null)
        reportName = ypr.Program_Report_Name__c;
      if (ypr.Site_Name__c != null)
        siteName = ypr.Site_Name__c;
      if (ypr.Grant_Name__c != null)
        grantName = ypr.Grant_Name__c;
      if (ypr.Grant_Year__c != null)
        grantYear = ypr.Grant_Year__c;
      if (ypr.Report_Date_Range__c != null)
        reportPeriod = ypr.Report_Date_Range__c;
    } else {
      getReport();
      ypr.Program_Report__c = report.Id;
      reportName = report.Name;
      if (report.Site_Id__c != null && siteId == null)
        siteId = ypr.Site_Id__c;
      if (report.Site_Name__c != null)
        siteName = ypr.Site_Name__c;
      if (report.Grant__r.Name != null)
        grantName = report.Grant__r.Name;
      if (report.Grant_Year__c != null)
        grantYear = report.Grant_Year__c;
      if (report.Start_Date__c != null && report.End_Date__c != null)
        reportPeriod =
          report.Start_Date__c.format() +
          ' - ' +
          report.End_Date__c.format();
    }
  }

  public void selectYouth() {
    if (youthId != null) {
      youth = cc.getContact(youthId);
      displayFindYouthPopup = false;
      system.debug('youth = ' + youth);
    }
  }
  // END getYouth

  // BEGIN getPACList
  public PageReference getPACList() {
    getYPR();
    if (yprId != null) {
      pac_list = pacc.getPACList(yprId);
    } else {
      PageReference pr = new PageReference('/YouthData');
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }
  // END getPACList

  // BEGIN getSurvey
  public PageReference getSurvey() {
    if (surveyId != null) {
      survey = sc.getSurvey(surveyId);
      if (survey.Date__c == null)
        survey.Date__c = date.today();
      ypr = [
        SELECT Id, Grant_Status__c
        FROM Youth_in_Program_Report__c
        WHERE Pre_Test__c = :survey.Id OR Post_Test__c = :survey.Id
      ];
      if (ypr.Grant_Status__c == 'Closed' || survey.Status__c == 'Complete')
        surveyReadOnly = true;
      else
        surveyReadOnly = false;
    } else {
      PageReference pr = new PageReference('/YouthData');
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }
  // END getSurvey

  // BEGIN getReport
  public void getReport() {
    report = prc.getYouthDataReport(null, siteId, grantId, year);
  }
  // END getReport

  // BEGIN save ypr
  public void saveYPR() {
    yprc.upsertYPR(ypr);
    displayEditYPRPopup = false;
    yprId = null;
    ypr = new Youth_in_Program_Report__c();
    if (youth.Id != null)
      getYouthYPRList();
    else
      getYPRs();
  }
  // END save ypr

  // BEGIN deleteypr
  public void deleteypr() {
    yprc.deleteYPR(ypr);
    displayDeleteYPRPopup = false;
    yprId = null;
    ypr = new Youth_in_Program_Report__c();
    if (youth.Id != null)
      getYouthYPRList();
    else
      getYPRs();
  }
  // END deleteypr

  // BEGIN save youth
  public void clearYouthForm() {
    ypr = new Youth_in_Program_Report__c(Program_Report__c = report.Id);
    duplicateYPR = new Youth_in_Program_Report__c();
    youth = new Contact(AccountId = siteId);
    duplicateYouth = new Contact();
    youthId = null;
  }

  public void youthDupCheck() {
    errorMessage = '';
    successMessage = '';
    confirmMessage = '';

    if (
      youth.FirstName == null ||
      youth.LastName == null ||
      youth.Gender__c == null ||
      (reportType == 'program' &&
      (youth.Birth_Month__c == null ||
      youth.Birth_Year__c == null)) ||
      (reportType == 'grant' &&
      youth.Birthdate == null) ||
      (hasSites && siteId == null) ||
      grantId == null
    ) {
      errorMessage = 'Please fill out all required fields.';
    }

    if (errorMessage == '') {
      if (youth.Id == null) {
        Contact[] dups = cc.getDuplicateContact(userAcct.Id, youth);
        if (dups.size() > 0) {
          duplicateYouth = dups[0];
          confirmMessage =
            'A record for ' +
            youth.FirstName +
            ' ' +
            youth.LastName +
            ' already exists. Would you like add a new youth record or update existing information?';
          displayConfirmPopup = true;
        }
      }
      if (confirmMessage == '')
        yprDupCheck();
    }
  }

  public void yprDupCheck() {
    if (ypr.Id == null) {
      getReport();
      if (youth.Id != null && (report.Id != null || grantId != null)) {
        duplicateYPR = yprc.getYPR(null, youth.Id, report.Id, grantId);
        if (duplicateYPR.Id != null) {
          confirmMessage =
            'A record for ' +
            youth.FirstName +
            ' ' +
            youth.LastName +
            ' already exists for this Grant Year. Would you like add a duplicate youth record?';
          displayConfirmPopup = true;
        }
      }
      if (confirmMessage == '')
        saveYouth();
    } else {
      saveYouth();
    }
  }

  public void updateExistingYouth() {
    displayConfirmPopup = false;
    if (duplicateYouth.Id != null && duplicateYouth.Id != youth.Id) {
      youth.Id = duplicateYouth.Id;
      yprDupCheck();
    } else if (duplicateYPR.Id != null && duplicateYPR.Id != ypr.Id) {
      ypr.Id = duplicateYPR.Id;
      saveYouth();
    } else {
      saveYouth();
    }
  }

  public PageReference saveYouth() {
    errorMessage = '';
    displayConfirmPopup = false;
    displayAddYouthToGrantPopup = false;
    Boolean clearForm = true;
    if (youthId != null)
      clearForm = false;

    youth.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Youth')
      .getRecordTypeId();
    if (youth.AccountId == null) {
      if (siteId != null)
        youth.AccountId = siteId;
      else if (localOrgId != null)
        youth.AccountId = localOrgId;
      else
        youth.AccountId = userAcct.Id;
    }
    if (portalName.contains('NCAI')) {
      if (youth.LastName == null || youth.LastName.length() > 1)
        errorMessage = 'Last Initial should not have more than one character';
      if (youth.Birth_Year__c.length() < 4)
        errorMessage = 'Birth Year should be four digits long.';
    }

    if (errorMessage == '') {
      cc.upsertContact(youth);
      /*
            if(ypr == null) {
                youthId = youth.Id;
                getYPR();
            } 
            */

      if (ypr.Id == null) {
        ypr.Contact__c = youth.Id;
        if (portalName.contains('NCAI') && report.Id == null) {
          if (siteId != null && grantId != null && year != null) {
            getReport();
            if (report.Id == null)
              prc.createYouthDataReport(siteId, grantId, year);
          } else {
            errorMessage = 'Please fill out all required fields.';
          }
        }
        if (errorMessage == '') {
          ypr.Program_Report__c = report.Id;
          ypr.Grant__c = grantId;
          ypr.Active_Status__c = 'Active';
          ypr.Active_Date__c = date.today();
          yprc.upsertYPR(ypr);

          if (portalName != 'NPAL') {
            Survey__c s1 = new Survey__c(
              Contact__c = youth.Id,
              Type__c = 'Pre-Test',
              Status__c = 'Not Started'
            );
            if (grantName != null && grantYear != null)
              s1.Title__c = grantName + ' Year ' + grantYear + ' Pre-Test';
            sc.upsertSurvey(s1);

            Survey__c s2 = new Survey__c(
              Contact__c = youth.Id,
              Type__c = 'Post-Test',
              Status__c = 'Not Started'
            );
            if (grantName != null && grantYear != null)
              s2.Title__c = grantName + ' Year ' + grantYear + ' Post-Test';
            sc.upsertSurvey(s2);

            ypr.Pre_Test__c = s1.Id;
            ypr.Post_Test__c = s2.Id;
            yprc.upsertYPR(ypr);

            pac_list = new List<PA_Challenge__c>();
            Schema.DescribeFieldResult fieldResult = PA_Challenge__c.Title__c.getDescribe();
            for (Schema.PicklistEntry s : fieldResult.getPicklistValues()) {
              PA_Challenge__c pac = new PA_Challenge__c(
                Youth_in_Program_Report__c = ypr.Id,
                Title__c = s.getValue()
              );
              pac_list.add(pac);
            }
            pacc.upsertPACs(pac_list);

            Chapter_Report__c cr = new Chapter_Report__c(
              Youth_in_Program_Report__c = ypr.Id
            );
            crc.upsertCR(cr);
          }
        }
      }

      if (ApexPages.hasMessages()) {
        errorMessage = String.valueOf(ApexPages.getMessages());
        return null;
      }
      successMessage = 'Save successful.';
      if (clearForm)
        clearYouthForm();
      else
        getYouthYPRList();
    }
    ypr = new Youth_in_Program_Report__c();
    return null;
  }

  public void saveYouthDetails() {
    errorMessage = '';
    successMessage = '';
    if (portalName.contains('NCAI')) {
      if (youth.LastName == null || youth.LastName.length() > 1)
        errorMessage = 'Last Initial should not have more than one character';
      if (youth.Birth_Year__c.length() < 4)
        errorMessage = 'Birth Year should be four digits long.';
    }
    if (errorMessage == '') {
      cc.upsertContact(youth);
      if (!ApexPages.hasMessages())
        successMessage = 'Save Successful';
    }
  }
  // END save youth

  // BEGIN save PACs
  public void savePACs() {
    if (ypr.PA_Challenge_Status__c != 'Complete')
      ypr.PA_Challenge_Status__c = 'Incomplete';
    upsertPACs();
  }

  public PageReference saveAndExitPACs() {
    if (ypr.PA_Challenge_Status__c != 'Complete')
      ypr.PA_Challenge_Status__c = 'Incomplete';
    upsertPACs();
    PageReference pr = new PageReference(
      '/YouthData?siteId=' +
      siteId +
      '&grantId=' +
      grantId +
      '&year=' +
      year
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference submitPACs() {
    ypr.PA_Challenge_Status__c = 'Submitted';
    upsertPACs();
    PageReference pr = new PageReference(
      '/YouthData?siteId=' +
      siteId +
      '&grantId=' +
      grantId +
      '&year=' +
      year
    );
    pr.setRedirect(true);
    return pr;
  }

  public void sendBackPACs() {
    ypr.PA_Challenge_Status__c = 'Incomplete';
    upsertPACs();
    displaySendBackPopup = false;
  }

  public void approvePACs() {
    ypr.PA_Challenge_Status__c = 'Complete';
    upsertPACs();
    displayApprovePopup = false;
  }

  public PageReference upsertPACs() {
    if (pac_list.size() > 0) {
      pacc.upsertPACs(pac_list);
      yprc.upsertYPR(ypr);
      if (ApexPages.hasMessages())
        return null;
      successMessage = 'Save successful.';
    }
    return null;
  }
  // END save PACs

  // BEGIN save surveys
  public PageReference saveSurvey() {
    if (survey.Status__c != 'Complete')
      survey.Status__c = 'Incomplete';
    sc.upsertSurvey(survey);
    if (ApexPages.hasMessages())
      return null;
    successMessage = 'Save successful.';
    return null;
  }

  public PageReference submitSurvey() {
    successMessage = '';
    errorMessage = '';
    if (
      survey.Adults_in_House_Eat_Fruits_Vegetables__c == null ||
      survey.An_Ad_Tells_People_About_a_Product__c == null ||
      survey.Cheese_Pizza_Instead_of_Pepperoni__c == null ||
      survey.Eat_a_Piece_of_Fruit_Every_Day__c == null ||
      survey.Eat_a_Vegetable_Every_Day__c == null ||
      survey.Example_of_Being_Emotionally_Healthy__c == null ||
      survey.Example_of_Being_Physically_Healthy__c == null ||
      survey.French_Fries_Come_From_an_Animal__c == null ||
      survey.Fresh_Fruit_Instead_of_Ice_Cream__c == null ||
      survey.Fruits_and_Vegetables_per_Day__c == null ||
      survey.Healthy_Ways_to_Handle_Stress__c == null ||
      survey.Minimum_Minutes_of_Physical_Activity__c == null ||
      survey.Most_Important_Drink__c == null ||
      survey.Names_of_Food_Groups__c == null ||
      survey.Number_of_Food_Groups__c == null ||
      survey.Nuts_Instead_of_Chips__c == null ||
      survey.Physically_Active_Every_Day__c == null ||
      survey.Play_Hard_During_Free_Time__c == null ||
      survey.Play_Hard_During_PE_Class__c == null ||
      survey.Play_Hard_During_Recess__c == null ||
      survey.Processed_Foods_Found_in_Boxes__c == null ||
      survey.Type_2_Diabetes__c == null ||
      survey.Water_Instead_of_Soda__c == null ||
      survey.Ways_to_Prevent_Type_2_Diabetes__c == null
    ) {
      errorMessage = 'All fields are required.';
    } else {
      survey.Status__c = 'Complete';
      survey.Submitted_Date__c = date.today();
      survey.Submitted_By__c = currentUser.ContactID;
      sc.upsertSurvey(survey);
      if (ApexPages.hasMessages())
        return null;
      PageReference pr = new PageReference(
        '/YouthData?siteId=' +
        siteId +
        '&grantId=' +
        grantId +
        '&year=' +
        year
      );
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }
  // END save surveys

  // BEGIN pagination
  public void first() {
    counter = 0;
    items = pc.first(allItems, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = true;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void next() {
    counter = counter + limitSize;
    items = pc.next(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = pc.getDisableNext(counter, limitSize, totalSize);
  }

  public void previous() {
    counter = counter - limitSize;
    items = pc.previous(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = pc.getDisablePrevious(counter);
    disableNext = false;
  }

  public void last() {
    counter = pc.getLastCounter(counter, limitSize, totalSize);
    items = pc.last(allItems, counter, limitSize);
    recordCount = pc.getRecordCount(counter, limitSize, totalSize);
    disablePrevious = false;
    disableNext = true;
  }
  // END pagination

  // BEGIN popups
  public void showFindYouthPopup() {
    errorMessage = '';
    successMessage = '';
    youth_list.clear();

    Id cId = userAcct.Id;
    if (siteId != null)
      cId = siteId;
    else if (localOrgId != null)
      cId = localOrgId;
    for (Contact c : cc.getRelatedContactList(cId, 'Youth', null, null)) {
      youth_list.add(c);
    }

    displayFindYouthPopup = true;
  }
  public void hideFindYouthPopup() {
    displayFindYouthPopup = false;
  }

  public void showAddYouthToGrantPopup() {
    getGrantOptions();
    displayAddYouthToGrantPopup = true;
  }
  public void hideAddYouthToGrantPopup() {
    displayAddYouthToGrantPopup = false;
  }

  public void showSendBackPopup() {
    displaySendBackPopup = true;
  }
  public void hideSendBackPopup() {
    displaySendBackPopup = false;
  }

  public void showApprovePopup() {
    displayApprovePopup = true;
  }
  public void hideApprovePopup() {
    displayApprovePopup = false;
  }

  public void hideConfirmPopup() {
    displayConfirmPopup = false;
    if (duplicateYouth.Id == youth.Id)
      youth.Id = null;
    else if (duplicateYPR.Id == ypr.Id)
      ypr.Id = null;
  }

  public void showEditYPRPopup() {
    ypr = yprc.getYPR(yprId, null, report.Id, null);
    displayEditYPRPopup = true;
  }
  public void hideEditYPRPopup() {
    yprId = null;
    ypr = new Youth_in_Program_Report__c();
    displayEditYPRPopup = false;
  }

  public void showDeleteYPRPopup() {
    ypr = yprc.getYPR(yprId, null, null, null);
    displayDeleteYPRPopup = true;
  }
  public void hideDeleteYPRPopup() {
    yprId = null;
    ypr = new Youth_in_Program_Report__c();
    displayDeleteYPRPopup = false;
  }
  // END popups
}
