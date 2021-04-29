public with sharing class LEGOReportsCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public ID SiteId { get; set; }
  public Account site { get; set; }
  public Id SessionId { get; set; }
  public List<SelectOption> options { get; set; }
  public Session__c session { get; set; }
  public List<SelectOption> sessionNameOptions { get; set; }
  public String sessionName { get; set; }
  public Session_Report__c programReport { get; set; }
  public List<innerClass> siteReport_list { get; set; }
  public String keyword { get; set; }

  public Boolean incompleteReport { get; set; }
  public String errorMessage { get; set; }

  public LEGOReportsCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    session = new Session__c();
    programReport = new Session_Report__c();
    siteReport_list = new List<innerClass>();

    SessionSelectOptionsCtrl ssoc = new SessionSelectOptionsCtrl();
    options = ssoc.options;
    String s1Id = ApexPages.currentPage().getParameters().get('SessionId');
    if (s1Id == null || s1Id == '')
      s1Id = ssoc.sessionId;
    if (s1Id != null && s1Id != '') {
      SessionId = s1Id;
    }
    sessionNameOptions = new List<SelectOption>();

    keyword = '';
    sessionName = '';
  }

  public void getSessionReports() {
    siteReport_list.clear();
    sessionNameOptions.clear();
    sessionNameOptions.add(new SelectOption('', 'Select a Session'));

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

    Set<String> names = new Set<String>();
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
        if (!names.contains(s.Name)) {
          names.add(s.Name);
          sessionNameOptions.add(new SelectOption(s.Name, s.Name));
        }
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
        if (sessionName == '' || sessionName == s.Name) {
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
      }
      system.debug('>>> siteReport_list = ' + siteReport_list);
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
