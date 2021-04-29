public with sharing class LEGODashboardCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public Integer totalYouth { get; set; }
  public Decimal percentGirls { get; set; }
  public Decimal percentUnderserved { get; set; }

  public Integer overdueCount { get; set; }
  public List<Session__c> overdue_list { get; set; }
  //public List<Session__c> delinquent_list { get; set; }
  //public List<Session__c> insufficient_list { get; set; }

  public String SessionId { get; set; }
  public Session__c session { get; set; }
  public Session_Report__c programReport { get; set; }

  //public Id SessionId { get; set; }
  public List<SelectOption> options { get; set; }

  public String SiteId { get; set; }
  public Account site { get; set; }
  public List<innerClass> site_list { get; set; }

  public LEGODashboardCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    totalYouth = 0;
    percentGirls = 0;
    percentUnderserved = 0;
    overdueCount = 0;

    overdue_list = new List<Session__c>();
    //delinquent_list = new List<Session__c>();
    //insufficient_list = new List<Session__c>();

    SiteId = ApexPages.currentPage().getParameters().get('SiteId');
    if (SiteId != null && SiteId != '') {
      Account[] sites = [SELECT Name FROM Account WHERE Id = :SiteId];
      if (sites.size() > 0) {
        site = sites[0];
      }
    }

    SessionId = ApexPages.currentPage().getParameters().get('SessionId');
    session = new Session__c();
    programReport = new Session_Report__c();
    site_list = new List<innerClass>();

    SessionSelectOptionsCtrl ssoc = new SessionSelectOptionsCtrl();
    options = ssoc.options;
    if (SessionId == null || SessionId == '')
      SessionId = ssoc.sessionId;
    if (SessionId != null && SessionId != '')
      getLists();
  }

  public List<AggregateResult> youthByRace {
    get {
      return [
        SELECT COUNT(Id) raceCount, Race__c
        FROM Contact
        WHERE
          Parent_Guardian__r.AccountId = :userAcct.Id
          AND RecordType.Name = 'Youth'
        GROUP BY Race__c
      ];
    }
  }

  public void getLists() {
    totalYouth = 0;
    percentGirls = 0;
    percentUnderserved = 0;
    overdueCount = 0;
    overdue_list.clear();
    site_list.clear();

    if (SessionId != null) {
      Date dt = Date.today();
      Date overdueDate = dt.addDays(-35);

      Session__c[] sessions = [
        SELECT
          Id,
          Name,
          Season__c,
          Site__r.Id,
          Site__r.Name,
          Site__r.Finance_Report_Status__c,
          Expo_Report_Status__c
        FROM Session__c
        WHERE Id = :SessionId
      ];
      if (sessions.size() > 0) {
        session = sessions[0];
      }
      system.debug('>>> session = ' + session);

      for (Session__c s : [
        SELECT Site__c, Site__r.Name
        FROM Session__c
        WHERE Season__c = :SessionId
        ORDER BY Site__r.Name
      ]) {
        innerClass ic = new innerClass(s);
        site_list.add(ic);
      }

      Session_Report__c[] reports = [
        SELECT Id, Status__c, Site__r.Id
        FROM Session_Report__c
        WHERE Session__c = :session.Id OR Session__c = :session.Season__c
      ];
      if (reports.size() > 0) {
        programReport = reports[0];
      }

      Set<Id> cohort_set = new Set<Id>();
      Map<Id, DateTime> cId_date_map = new Map<Id, DateTime>();
      for (
        Session__c cohort : [
          SELECT
            Id,
            Name,
            LastModifiedDate,
            Session__r.Season__c,
            Session__r.Site__r.Id,
            Session__r.Site__r.Name,
            Session__r.Site__r.National_Organization__r.Id
          FROM Session__c
          //WHERE Id IN :sessionClass.cohort_list AND Session__c.Id = :currentSession
          WHERE
            (Session__c = :SessionId
            OR Session__r.Season__c = :SessionId)
            AND RecordType.Name = 'Cohort'
          ORDER BY LastModifiedDate DESC
        ]
      ) {
        cId_date_map.put(cohort.Id, date.newinstance(1900, 1, 1));
        cohort_set.add(cohort.Id);
      }

      //Map<String, Integer> site_map = new Map<String, Integer>();
      Decimal count1 = 0;
      Decimal count2 = 0;
      for (Contact c : [
        SELECT
          Cohort__r.Id,
          Cohort__r.Site__r.Name,
          Gender__c,
          Free_Reduced_Lunch_Status__c,
          Single_Parent_Home__c,
          Race__c,
          Special_Education_Disability__c
        FROM Contact
        WHERE Cohort__r.Id IN :cohort_set AND RecordType.Name = 'Youth'
      ]) {
        totalYouth++;
        if (c.Gender__c == 'F') {
          count1++;
          count2++;
        } else if (
          c.Free_Reduced_Lunch_Status__c == 'Eligible' ||
          (c.Race__c != 'White or Caucasian' &&
          c.Race__c != null) ||
          c.Single_Parent_Home__c == true ||
          c.Special_Education_Disability__c == true
        ) {
          count2++;
        }
        //innerClass ic = new innerClass(c.Site__r.Name);
      }
      if (count1 > 0) {
        percentGirls = (count1.divide(totalYouth, 3) * 100).setScale(1);
      }
      if (count2 > 0) {
        percentUnderserved = (count2.divide(totalYouth, 3) * 100).setScale(1);
      }

      Set<Id> meetingIdSet = new Set<Id>();
      for (AggregateResult ar : [
        SELECT count(Id) meetingCount, Cohort__r.Id
        FROM Session__c
        WHERE Cohort__r.Id IN :cId_date_map.keySet()
        GROUP BY Cohort__r.Id
      ]) {
        if ((Decimal) ar.get('meetingCount') < 12) {
          meetingIdSet.add((Id) ar.get('Id'));
        } else {
          cId_date_map.remove((Id) ar.get('Id'));
        }
      }

      for (Session__c meeting : [
        SELECT
          Id,
          Cohort__r.Site__r.Id,
          Cohort__r.Site__r.Name,
          Cohort__r.Id,
          Cohort__r.Name,
          Name,
          Attendance__c,
          LastModifiedDate
        FROM Session__c
        WHERE Cohort__r.Id IN :cId_date_map.keySet()
        ORDER BY LastModifiedDate ASC
      ]) {
        cId_date_map.put(meeting.Cohort__r.Id, meeting.LastModifiedDate);
        //if(meeting.Attendance__c < 70) {
        //    insufficient_list.add(meeting);
        //}
      }

      Set<Id> overdue_set = new Set<Id>();
      for (String key : cId_date_map.keySet()) {
        if (cId_date_map.get(key) < overdueDate) {
          system.debug('key = ' + key);
          overdueCount += 1;
          overdue_set.add(key);
        }
      }
      for (Session__c cohort : [
        SELECT
          Id,
          Session__r.Site__r.Name,
          Cohort__r.Id,
          Cohort__r.Name,
          Name,
          LastModifiedDate
        FROM Session__c
        WHERE Id IN :overdue_set
        ORDER BY LastModifiedDate DESC
      ]) {
        overdue_list.add(cohort);
      }

      //            for(DateTime d : cId_date_map.values()) {
      //                if(d < overdueDate) {
      //                    overdueCount += 1;
      //                    overdue_set.add();
      //                }
      //            }
    }
  }
  /*
    public class innerClass {
        public String siteName { get; set; }
        public Integer totalYouth { get; set; }
        public Decimal percentGirls { get; set; }
        public Decimal percentUnderserved { get; set; }
        
        public innerClass(String name, Integer youth, Decimal girls, Decimal underserved) {
            siteName = name;
            totalYouth = youth;
            percentGirls = girls;
            percentUnderserved = underserved;
        }
    }
    */

  public class innerClass {
    public Id siteId { get; set; }
    public String siteName { get; set; }
    public Id sessionId { get; set; }

    public innerClass(Session__c s) {
      siteId = s.Site__c;
      siteName = s.Site__r.Name;
      sessionId = s.Id;
    }
  }

  public void testCoverage() {
    Integer i = 0;
    i++;
  }
}
