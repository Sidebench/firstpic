public with sharing class LEGOExpoReportCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public Account acct { get; set; }

  public Id SessionId { get; set; }
  public List<SelectOption> options { get; set; }
  public Session__c session { get; set; }

  public Date expoDate { get; set; }
  public Boolean editMode { get; set; }
  public String statusColor { get; set; }

  public Boolean displayAttPopup { get; set; }
  public List<Attachment> att_list { get; set; }
  public Id deleteAttId { get; set; }

  public LEGOExpoReportCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    Account acct = new Account();
    Session__c session = new Session__c();

    editMode = true;
    statusColor = 'text-warning';

    SessionSelectOptionsCtrl ssoc = new SessionSelectOptionsCtrl();
    options = ssoc.options;

    String sId = ApexPages.currentPage().getParameters().get('SessionId');
    if (sId == null || sId == '')
      sId = ssoc.sessionId;
    if (sId != null && sId != '') {
      SessionId = sId;
      init();
    }
  }

  public void init() {
    if (userAcct != null) {
      Session__c[] sessions = [
        SELECT Id, Name, Site__c
        //(SELECT Id, Name, Description FROM Attachments ORDER BY LastModifiedDate desc)
        FROM Session__c
        WHERE Id = :SessionId
      ];

      if (sessions.size() > 0) {
        SessionClass sc = new SessionClass(null, null);
        session = sc.getSession(sessions[0].Id, false);
        if (session.Site__c != null) {
          Account[] accts = [
            SELECT
              Name,
              RecordType.Name,
              Type,
              Number_of_Cohorts__c,
              Team_Size__c,
              Implementation_Model__c,
              Start_Date__c,
              Estimated_Date_of_Expo__c
            FROM Account
            WHERE Id = :session.Site__c
          ];
          if (accts.size() > 0) {
            acct = accts[0];
          }
        }
        if (session.Date_of_Expo__c != null) {
          expoDate = session.Date_of_Expo__c;
        } else {
          expoDate = Date.today();
        }
        if (session.Expo_Report_Status__c == 'Submitted') {
          editMode = false;
          statusColor = 'text-success';
        } else {
          editMode = true;
        }
      }
    }
    getAttList();
  }

  public void getAttList() {
    att_list = new List<Attachment>();
    displayAttPopup = false;
    if (session != null) {
      att_list = [
        SELECT Id, Name, Description
        FROM Attachment
        WHERE ParentId = :session.Id
        ORDER BY LastModifiedDate DESC
      ];
    }
  }

  public PageReference save() {
    if (session != null) {
      if (
        session.Expo_Report_Status__c == null ||
        session.Expo_Report_Status__c == 'Not Started'
      ) {
        session.Expo_Report_Status__c = 'In Progress';
      }
      session.Date_of_Expo__c = expoDate;
      try {
        update session;
        PageReference pr = new PageReference('/LEGOReportList');
        pr.setRedirect(true);
        return pr;
      } catch (Exception e) {
        system.debug(e.getMessage());
      }
    }
    return null;
  }

  public PageReference submit() {
    if (session != null) {
      session.Expo_Report_Status__c = 'Submitted';
      session.Date_of_Expo__c = expoDate;
      try {
        update session;
        PageReference pr = new PageReference('/LEGOReportList');
        pr.setRedirect(true);
        return pr;
      } catch (Exception e) {
        system.debug(e.getMessage());
      }
    }
    return null;
  }

  public PageReference sendBack() {
    if (session != null) {
      session.Expo_Report_Status__c = 'In Progress';
      try {
        update session;
        PageReference pr = new PageReference('/LEGOReportList');
        pr.setRedirect(true);
        return pr;
      } catch (Exception e) {
        system.debug(e.getMessage());
      }
    }
    return null;
  }

  // BEGIN deleteAtt
  public void deleteAtt() {
    if (deleteAttId != null) {
      Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteAttId];
      if (a != null) {
        AttachmentClass ac = new AttachmentClass();
        ac.deleteAttachment(a);
      }
    }
    getAttList();
  }
  // END deleteAtt

  // BEGIN popups
  public void attPopup() {
    displayAttPopup = true;
  }

  public void closeAttPopup() {
    displayAttPopup = false;
    getAttList();
  }
  // END popups
}
