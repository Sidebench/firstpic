public with sharing class ReportListCtrl {
  // DEPRECATED. Only used by NPAL National Users for viewing old DCTAT Reports
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  public ID accountId { get; set; }
  public ID GrantID { get; set; }
  public String grantName { get; set; }
  public Set<ID> grantID_set { get; set; }
  public ID SubGrantID { get; set; }
  public Map<Id, List<String>> grant_map { get; set; }

  public List<Grantee_Report__c> report_list { get; set; }
  public ID ReportID { get; set; }
  public Grantee_Report__c report { get; set; }
  public Boolean displayDeleteReportPopup { get; set; }

  public List<Grantee_Report__c> incomplete_report_list { get; set; }
  public List<Grantee_Report__c> submitted_report_list { get; set; }
  public List<Grantee_Report__c> approved_report_list { get; set; }

  public ID SiteId { get; set; }
  public Account site { get; set; }
  public Id SessionId { get; set; }
  public List<SelectOption> options { get; set; }
  public Session__c session { get; set; }
  public Session_Report__c programReport { get; set; }
  public List<innerClass> siteReport_list { get; set; }

  public Boolean incompleteReport { get; set; }
  public String errorMessage { get; set; }

  public String listType { get; set; }
  public String keyword { get; set; }
  public String reportPeriod { get; set; }
  public List<SelectOption> reportPeriodOptions { get; set; }

  public ReportListCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;

    GrantId = ApexPages.currentPage().getParameters().get('GrantId');
    listType = ApexPages.currentPage().getParameters().get('type');
    if (listType == null)
      listType = '';
    keyword = '';
    grantID_set = new Set<ID>();
    grant_map = new Map<Id, List<String>>();

    report = new Grantee_Report__c();
    session = new Session__c();
    programReport = new Session_Report__c();

    report_list = new List<Grantee_Report__c>();
    incomplete_report_list = new List<Grantee_Report__c>();
    submitted_report_list = new List<Grantee_Report__c>();
    approved_report_list = new List<Grantee_Report__c>();
    siteReport_list = new List<innerClass>();

    displayDeleteReportPopup = false;

    SessionSelectOptionsCtrl ssoc = new SessionSelectOptionsCtrl();
    options = ssoc.options;
    SessionId = ssoc.sessionId;

    reportPeriod = '';
    reportPeriodOptions = new List<SelectOption>();
    reportPeriodOptions.add(new SelectOption('', ''));
    Schema.DescribeFieldResult fieldResult = Grantee_Report__c.Reporting_Period__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f : ple) {
      reportPeriodOptions.add(new SelectOption(f.getLabel(), f.getValue()));
    }
  }

  public void getSessionReports() {
    siteReport_list.clear();

    String s2Id = ApexPages.currentPage().getParameters().get('SiteId');
    if (userAcctType == 'Site' || (s2Id != null && s2Id != '')) {
      SiteId = s2Id;
      Account[] accts = [
        SELECT Id, Finance_Report_Status__c
        FROM Account
        WHERE Id = :userAcct.Id OR Id = :SiteId
      ];
      if (accts.size() > 0) {
        site = accts[0];
      }
    }

    String s1Id = ApexPages.currentPage().getParameters().get('SessionId');
    if ((s1Id == null || s1Id == '') && options.size() == 2) {
      String i = options[1].getValue();
      s1Id = Id.valueOf(i);
    }
    if (s1Id != null && s1Id != '') {
      SessionId = s1Id;
    }

    Map<Id, Session_Report__c> site_map = new Map<Id, Session_Report__c>();
    Session__c[] sessions = [
      SELECT
        Id,
        Name,
        Site__r.Id,
        Site__r.Name,
        Site__r.Finance_Report_Status__c,
        Expo_Report_Status__c
      FROM Session__c
      WHERE
        (Id = :SessionId
        OR Season__c = :SessionId)
        AND RecordType.Name = 'Session'
      ORDER BY Site__r.Name
    ];
    if (sessions.size() > 0) {
      session = sessions[0];
      for (Session__c s : sessions) {
        site_map.put(s.Site__r.Id, new Session_Report__c());
      }
    }
    Session_Report__c[] reports = [
      SELECT Id, Status__c, Site__r.Id
      FROM Session_Report__c
      WHERE Site__c IN :site_map.keySet() AND Session__c = :SessionId
    ];
    if (userAcctType == 'Site') {
      if (reports.size() > 0) {
        programReport = reports[0];
        system.debug('>>> programReport = ' + programReport);
      }
    } else {
      for (Session_Report__c s : reports) {
        site_map.put(s.Site__r.Id, s);
      }
      for (Session__c s : sessions) {
        String name = s.Site__r.Name.toLowerCase();
        if (
          keyword == '' ||
          (keyword != '' && name.contains(keyword.toLowerCase()))
        ) {
          innerClass ic = new innerClass(
            s.Site__c,
            s.Site__r.Name,
            s.Id,
            s.Name,
            s.Expo_Report_Status__c,
            site_map.get(s.Site__c).Id,
            site_map.get(s.Site__c).Status__c,
            s.Site__r.Finance_Report_Status__c
          );
          siteReport_list.add(ic);
        }
      }
      system.debug('>>> siteReport_list = ' + siteReport_list);
    }
  }

  public void getLists() {
    report_list.clear();
    incomplete_report_list.clear();
    submitted_report_list.clear();
    approved_report_list.clear();
    grantID_set.clear();
    grant_map.clear();
    siteReport_list.clear();

    if (GrantID != null) {
      Grant__c[] grants = [SELECT Id, Name FROM Grant__c WHERE Id = :GrantId];
      if (grants.size() > 0) {
        grantName = grants[0].Name;
      }
      for (Grantee_Report__c gr : [
        SELECT Id, Name, Report_Status__c
        FROM Grantee_Report__c
        WHERE Grant__r.Id = :GrantId
      ]) {
        if (
          gr.Report_Status__c == 'In Progress' ||
          gr.Report_Status__c == 'Requested'
        ) {
          incompleteReport = true;
        }
      }
    }
    for (Grant__c g : [
      SELECT Id, Name, Account__r.Id, Account__r.National_Organization__c
      FROM Grant__c
    ]) {
      grantID_set.add(g.ID);
    }

    String soql = 'SELECT Id, Grant__c, Grant__r.Name, Name, Report_Status__c, Submitted_Date__c, Reporting_Period__c FROM Grantee_Report__c';
    if (reportPeriod != '' && reportPeriod != null) {
      soql += ' WHERE Reporting_Period__c = \'' + reportPeriod + '\'';
    }
    soql += ' ORDER BY Report_Status__c, Submitted_Date__c';
    for (Grantee_Report__c gr : database.query(soql)) {
      if (
        (listType == 'incomplete' || listType == '') &&
        (gr.Report_Status__c == 'In Progress' ||
        gr.Report_Status__c == 'Revisions Needed' ||
        gr.Report_Status__c == 'Requested')
      ) {
        incomplete_report_list.add(gr);
      } else if (
        (listType == 'submitted' || listType == '') &&
        gr.Report_Status__c == 'Submitted'
      ) {
        submitted_report_list.add(gr);
      } else if (
        (listType == 'approved' || listType == '') &&
        gr.Report_Status__c == 'Approved'
      ) {
        approved_report_list.add(gr);
      } else {
        report_list.add(gr);
      }

      List<String> s_list = new List<String>();
      s_list.add(gr.Grant__r.Name);
      if (gr.Report_Status__c == 'In Progress') {
        s_list.add('true');
        grant_map.put(gr.Grant__c, s_list);
      } else {
        s_list.add('false');
        grant_map.put(gr.Grant__c, s_list);
      }
    }

    for (Grant__c g : [
      SELECT Id, Name
      FROM Grant__c
      WHERE Id IN :grantID_set
    ]) {
      if (!grant_map.containsKey(g.Id)) {
        List<String> s_list = new List<String>();
        s_list.add(g.Name);
        s_list.add('false');
        grantID_set.add(g.ID);
        grant_map.put(g.Id, s_list);
      }
    }
    system.debug('>>> grant_map = ' + grant_map);
  }

  public void deleteReport() {
    if (ReportId != null) {
      Grantee_Report__c gr = [
        SELECT Id
        FROM Grantee_Report__c
        WHERE Id = :ReportId
      ];
      try {
        delete gr;
        getLists();
        displayDeleteReportPopup = false;
        //PageReference pr = new PageReference('/' + portalName + 'ReportList');
        //pr.setRedirect(True);
        //return pr;
      } catch (Exception e) {
        errorMessage = e.getMessage();
        system.debug('error = ' + e.getMessage());
      }
    }
  }

  public void deleteReportPopup() {
    if (displayDeleteReportPopup == true) {
      displayDeleteReportPopup = false;
    } else {
      if (ReportId != null) {
        Grantee_Report__c[] reports = [
          SELECT Id, Grant__r.Name
          FROM Grantee_Report__c
          WHERE Id = :ReportId
        ];
        if (reports.size() > 0) {
          report = reports[0];
        }
      }
      displayDeleteReportPopup = true;
    }
  }

  // BEGIN Inner Class
  public class innerClass {
    public Id siteId { get; set; }
    public String siteName { get; set; }
    public Id sessionId { get; set; }
    public String sessionName { get; set; }
    public String expoStatus { get; set; }
    public Id programId { get; set; }
    public String programStatus { get; set; }
    public String financeStatus { get; set; }

    public innerClass(
      Id sId,
      String sName,
      Id sesId,
      String sesName,
      String expo,
      Id pId,
      String program,
      String finance
    ) {
      siteId = sId;
      siteName = sName;
      sessionId = sesId;
      sessionName = sesName;
      expoStatus = expo;
      programId = pId;
      programStatus = program;
      financeStatus = finance;
    }
  }
}
