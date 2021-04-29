public with sharing class LEGOProgramReportCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public SessionReportClass reportClass = new SessionReportClass();
  public Id ReportId { get; set; }
  public Id SessionId { get; set; }
  public List<SelectOption> options { get; set; }
  public Session_Report__c report { get; set; }

  public Boolean editMode { get; set; }
  public String statusColor { get; set; }
  public String errorMessage { get; set; }

  public Boolean displayAttPopup { get; set; }
  public List<Attachment> att_list { get; set; }
  public Id deleteAttId { get; set; }

  public LEGOProgramReportCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    editMode = false;
    statusColor = 'text-warning';

    options = new List<SelectOption>();
    options.add(new SelectOption('', 'Select a Season'));
    for (Session__c s : [
      SELECT Id, Name
      FROM Session__c
      WHERE RecordType.Name = 'Season'
      ORDER BY LastModifiedDate DESC
    ]) {
      options.add(new SelectOption(s.Id, s.Name));
    }

    String rId = ApexPages.currentPage().getParameters().get('ReportId');
    String sId = ApexPages.currentPage().getParameters().get('SessionId');
    if (rId != null && rId != '') {
      ReportId = rId;
      report = reportClass.getReport(ReportId, null, null);
      system.debug('>>> report = ' + report);
      init();
    } else {
      if (sId == null || sId == '') {
        String i = options[1].getValue();
        sId = Id.valueOf(i);
      }
      if (sId != null && sId != '') {
        SessionId = sId;
        init();
      }
    }
  }

  public void init() {
    if (userAcct != null) {
      if (SessionId != null) {
        report = new Session_Report__c();
        Session__c[] sessions = [
          SELECT Name, Site__r.Name
          FROM Session__c
          WHERE Id = :SessionId
        ];
        if (sessions.size() > 0) {
          report = reportClass.getReport(null, sessions[0].Id, userAcct.Id);
          if (report.Id == null) {
            report.Name =
              userAcct.Name.left(30) +
              ' - ' +
              sessions[0].Name.left(30) +
              ' Program Report';
            report.Session__c = SessionId;
            report.Site__c = userAcct.Id;
          }
        }
      }
      if (userAcctType == 'Site') {
        editMode = true;
      }
      if (report != null) {
        if (report.Status__c == 'Submitted') {
          editMode = false;
        } else {
          statusColor = 'text-success';
        }
      }
    }
    system.debug('>>> report = ' + report);
  }

  public void getAttList() {
    att_list = new List<Attachment>();
    displayAttPopup = false;
    if (report != null) {
      Session_Report__c[] reports = [
        SELECT
          Id,
          (
            SELECT Id, Name, Description
            FROM Attachments
            ORDER BY LastModifiedDate DESC
          )
        FROM Session_Report__c
        WHERE Id = :report.Id
      ];
      if (reports.size() > 0) {
        for (Attachment a : reports[0].Attachments) {
          String name = a.Name;
          att_list.add(a);
        }
      }
    }
  }

  public PageReference save() {
    if (report != null) {
      if (report.Status__c == null || report.Status__c == 'Not Started') {
        report.Status__c = 'In Progress';
      }

      try {
        reportClass.upsertReport(report);

        PageReference pr = new PageReference('/LEGOReportList');
        pr.setRedirect(true);
        return pr;
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    }
    return null;
  }

  public PageReference submit() {
    if (report != null) {
      report.Status__c = 'Submitted';
      report.Submitted_Date__c = date.today();
      try {
        reportClass.upsertReport(report);

        PageReference pr = new PageReference('/LEGOReportList');
        pr.setRedirect(true);
        return pr;
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
      }
    }
    return null;
  }

  public PageReference sendBack() {
    if (report != null) {
      report.Status__c = 'In Progress';
      try {
        reportClass.upsertReport(report);

        PageReference pr = new PageReference('/LEGOReportList');
        pr.setRedirect(true);
        return pr;
      } catch (Exception e) {
        system.debug(e.getMessage());
        errorMessage = e.getMessage();
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
    if (report.Id == null)
      reportClass.upsertReport(report);
    displayAttPopup = true;
  }

  public void closeAttPopup() {
    displayAttPopup = false;
    getAttList();
  }
  // END popups
}
