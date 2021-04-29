public with sharing class CohortDetailsCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  private SessionClass sc = new SessionClass(null, null);
  public Id sessionId { get; set; }
  public String sessionName { get; set; }
  public Id cohortId { get; set; }
  public Session__c cohort { get; set; }

  public List<SelectOption> coaches { get; set; }

  public string meetingAction { get; set; }
  public Id meetingId { get; set; }
  public Session__c meeting { get; set; }
  public Date meetingDate { get; set; }
  public List<Session__c> meeting_list { get; set; }

  public String lessonName { get; set; }
  public List<SelectOption> lessons { get; set; }

  public Boolean displayMeetingPopup { get; set; }
  public Boolean displayEditCohortPopup { get; set; }
  public Boolean displayDeleteMeetingPopup { get; set; }

  public CohortDetailsCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    portalName = uc.userProfile;

    displayMeetingPopup = false;
    displayEditCohortPopup = false;
    displayDeleteMeetingPopup = false;

    meetingDate = Date.today();
    meetingAction = '';
    meeting = new Session__c();

    lessons = new List<SelectOption>();
    meeting_list = new List<Session__c>();

    cohortId = ApexPages.currentPage().getParameters().get('cohortId');
    cohort = new Session__c();

    coaches = new List<SelectOption>();
    for (Contact c : [
      SELECT Id, Name, Email, Phone, RecordType.Name, AccountId
      FROM Contact
    ]) {
      if (c.RecordType.Name == 'Coach' && c.AccountId == userAcct.Id) {
        coaches.add(new SelectOption(c.Name, c.Name));
      }
    }
    getLists();
  }

  public void getLists() {
    meeting_list.clear();
    lessons.clear();

    if (cohortId != null) {
      cohort = sc.getSession(cohortId, false);
      if (userAcctType == 'Site') {
        sessionId = cohort.Session__r.Id;
      } else {
        sessionId = cohort.Session__r.Season__r.Id;
      }
      sessionName = cohort.Session__r.Name;

      meeting_list = sc.getSessionList(cohortId, 'meeting');
      if (sessionId != null) {
        for (Session__c s : sc.getSessionList(sessionId, 'lesson')) {
          if (s.Session__c == cohort.Session__c) {
            lessons.add(new SelectOption(s.Id, s.Name));
          }
        }
      }
    }
  }

  public void addMeeting() {
    if (meeting.Name == null && meeting.Lesson__c != null)
      meeting.Name = [SELECT Name FROM Session__c WHERE ID = :meeting.Lesson__c]
      .Name;
    meeting.RecordTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
      .get('Meeting')
      .getRecordTypeId();
    meeting.Cohort__c = cohortId;
    meeting.Meeting_Date__c = meetingDate;
    sc.upsertSession(meeting);
    meeting_list.add(meeting);
    meeting = new Session__c();
    meetingDate = Date.today();
    //getLists();
    displayMeetingPopup = false;
  }

  public void updateCohort() {
    if (cohort.Coaches__c != null) {
      String c = cohort.Coaches__c;
      c = c.replace('[', '');
      c = c.replace(']', '');
      cohort.Coaches__c = c;
    }
    sc.upsertSession(cohort);
    displayEditCohortPopup = false;
  }

  public void editMeetingPopup() {
    Session__c[] meetings = [
      SELECT
        Name,
        Lesson__c,
        Lesson__r.Name,
        Meeting_Date__c,
        Attendance__c,
        Notes__c
      FROM Session__c
      WHERE Id = :meetingId
    ];
    if (meetings.size() > 0) {
      meeting = meetings[0];
      lessonName = meetings[0].Lesson__r.Name;
      meetingDate = meetings[0].Meeting_Date__c;
    }
    if (meetingAction == 'delete') {
      deleteMeetingPopup();
    } else {
      addMeetingPopup();
    }
  }

  public void deleteMeeting() {
    if (meeting.Id != null) {
      sc.deleteSession(meeting);
      displayDeleteMeetingPopup = false;
      meetingAction = '';
      meeting = new Session__c();
      getLists();
    }
  }

  public void addMeetingPopup() {
    if (displayMeetingPopup == true) {
      displayMeetingPopup = false;
      meeting = new Session__c();
    } else {
      displayMeetingPopup = true;
    }
  }

  public void deleteMeetingPopup() {
    if (displayDeleteMeetingPopup == true) {
      displayDeleteMeetingPopup = false;
      meetingAction = '';
    } else {
      displayDeleteMeetingPopup = true;
    }
  }

  public void editCohortPopup() {
    if (displayEditCohortPopup == true) {
      displayEditCohortPopup = false;
    } else {
      displayEditCohortPopup = true;
    }
  }
}
