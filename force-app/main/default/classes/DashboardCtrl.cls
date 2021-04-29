public with sharing class DashboardCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public String profileName { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }
  public String approverLevel { get; set; }
  private Id primaryApproverId { get; set; }
  private String paSOQL = '';

  private AccountClass acctClass = new AccountClass();
  private DocumentClass dc = new DocumentClass();
  public List<Document__c> missingDocs { get; set; }
  public List<Account> onHold { get; set; }

  private TALogClass lc = new TALogClass();
  public List<TA_Log__c> logs { get; set; }

  private ApplicationClass ac = new ApplicationClass();
  public List<Application__c> apps_incomplete { get; set; }
  public Boolean more_apps_incomplete { get; set; }
  public Id appId { get; set; }

  private VictimsServedReportClass vsrc = new VictimsServedReportClass();
  public List<Victims_Served_Report__c> vsr_incomplete { get; set; }
  public Id OVCPRId { get; set; }

  private GrantClass gc = new GrantClass();
  public Id grantId { get; set; }
  public List<SelectOption> grantOptions { get; set; }
  public List<Grant__c> grants_incomplete { get; set; }
  public List<Grant__c> grants_pending { get; set; }
  public Boolean more_grants_incomplete { get; set; }
  public Boolean more_grants_pending { get; set; }

  private ReimbursementClass rc = new ReimbursementClass();
  public List<Reimbursement_Request__c> requests_incomplete { get; set; }
  public List<Reimbursement_Request__c> requests_pending { get; set; }
  public List<Reimbursement_Request__c> requests_pendingSecond { get; set; }
  public Boolean more_requests_incomplete { get; set; }
  public Boolean more_requests_pending { get; set; }
  public Boolean more_requests_pendingSecond { get; set; }

  private SessionReportClass src = new SessionReportClass();
  public List<Session_Report__c> sessionReports_incomplete { get; set; }
  public List<Session_Report__c> sessionReports_submitted { get; set; }
  public Boolean more_sessionReports_incomplete { get; set; }
  public Boolean more_sessionReports_submitted { get; set; }

  private ProgressReportClass prgsrc = new ProgressReportClass();
  public List<Progress_Report__c> progressReports_incomplete { get; set; }
  public List<Progress_Report__c> progressReports_submitted { get; set; }
  public Boolean more_progressReports_incomplete { get; set; }
  public Boolean more_progressReports_submitted { get; set; }

  private DCTATReportClass dctatrc = new DCTATReportClass();
  public List<Grantee_Report__c> dctatReports_incomplete { get; set; }
  public List<Grantee_Report__c> dctatReports_submitted { get; set; }
  public Boolean more_dctatReports_incomplete { get; set; }
  public Boolean more_dctatReports_submitted { get; set; }

  private ProgramReportClass prgmrc = new ProgramReportClass();
  public List<Program_Report__c> palogs_incomplete { get; set; }
  public List<Program_Report__c> palogs_submitted { get; set; }
  public Boolean more_palogs_incomplete { get; set; }
  public Boolean more_palogs_submitted { get; set; }

  public DashboardCtrl() {
    currentUser = uc.currentUser;
    profileName = currentUser.Profile.Name;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    portalName = uc.userProfile;
    approverLevel = uc.approverLevel;

    if (portalName == 'Ripken' && approverLevel == 'Level One') {
      primaryApproverId = currentUser.ContactId;
      paSOQL += ' AND (Primary_Approver_Id__c = \'' + primaryApproverId + '\'';
      paSOQL += ' OR (Secondary_Approver_Id__c = \'' + primaryApproverId + '\'';
      paSOQL += ' AND (Primary_Approver_On_Leave__c = true OR FirstPic_National_Org_Code__c = \'Ripken\')))';
    }

    String timeframe = DateTime.newInstance(
        System.today().addDays(15),
        Time.newInstance(0, 0, 0, 0)
      )
      .format('yyyy-MM-dd');
    String docSOQL =
      ' AND (Organization__c = \'' +
      userAcct.Id +
      '\' OR Local_Organization_Id__c = \'' +
      String.valueOf(userAcct.Id).substring(0, 15) +
      '\')';
    docSOQL += ' AND (Status__c = \'Requested\' OR Status__c = \'Sent Back\')  AND Required__c = true';
    docSOQL += ' AND Due_Date__c < ' + timeframe;
    missingDocs = dc.getDocList(null, null, null, null, null, null, docSOQL);

    onHold = new List<Account>();
    logs = new List<TA_Log__c>();
    apps_incomplete = new List<Application__c>();

    vsr_incomplete = new List<Victims_Served_Report__c>();

    grants_incomplete = new List<Grant__c>();
    grants_pending = new List<Grant__c>();
    grantOptions = gc.getGrantOptions(
      userAcctType,
      userAcct.Id,
      null,
      'Name',
      null,
      'grant',
      null
    );

    requests_incomplete = new List<Reimbursement_Request__c>();
    requests_pending = new List<Reimbursement_Request__c>();
    requests_pendingSecond = new List<Reimbursement_Request__c>();

    sessionReports_incomplete = new List<Session_Report__c>();
    sessionReports_submitted = new List<Session_Report__c>();

    progressReports_incomplete = new List<Progress_Report__c>();
    progressReports_submitted = new List<Progress_Report__c>();

    dctatReports_incomplete = new List<Grantee_Report__c>();
    dctatReports_submitted = new List<Grantee_Report__c>();

    palogs_incomplete = new List<Program_Report__c>();
    palogs_submitted = new List<Program_Report__c>();
  }

  public ApexPages.PageReference init() {
    if (currentUser == null || userAcct == null) {
      PageReference pageRef = new PageReference('/login');
      return pageRef;
    }
    if ((currentUser.Profile.Name).contains('Report Builder')) {
      PageReference pageRef = new PageReference('/00O/o');
      return pageRef;
    }
    getLists();
    return null;
  }

  public void resetLists() {
    onHold.clear();
    logs.clear();
    apps_incomplete.clear();
    grants_incomplete.clear();
    grants_pending.clear();
    requests_incomplete.clear();
    requests_pending.clear();
    requests_pendingSecond.clear();
    sessionReports_incomplete.clear();
    sessionReports_submitted.clear();
    progressReports_incomplete.clear();
    progressReports_submitted.clear();
    dctatReports_incomplete.clear();
    dctatReports_submitted.clear();
    palogs_incomplete.clear();
    palogs_submitted.clear();

    more_apps_incomplete = false;
    more_grants_incomplete = false;
    more_grants_pending = false;
    more_requests_incomplete = false;
    more_requests_pending = false;
    more_requests_pendingSecond = false;
    more_sessionReports_incomplete = false;
    more_sessionReports_submitted = false;
    more_progressReports_incomplete = false;
    more_progressReports_submitted = false;
    more_dctatReports_incomplete = false;
    more_dctatReports_submitted = false;
    more_palogs_incomplete = false;
    more_palogs_submitted = false;
  }

  public void getLists() {
    resetLists();
    Integer listLimit = 6;
    Id siteId = null;
    if (userAcctType == 'Site')
      siteId = userAcct.Id;

    String soqlAND = ' AND Grant_Status__c != \'Closed\'';
    String grantSOQL = paSOQL + soqlAND;
    String rrSOQL = soqlAND;
    String grantType = '';
    if (portalName.contains('TRAIL'))
      grantType = 'TRAIL';
    if (portalName.contains('OVC'))
      grantType = 'OVC';
    if (portalName.contains('NCAI') && grantType != '') {
      grantSOQL +=
        ' AND (Grant_Type__c = \'' +
        grantType +
        '\' OR National_Grant_Type__c = \'' +
        grantType +
        '\')';
      rrSOQL +=
        ' AND (Grant__r.Grant_Type__c = \'' +
        grantType +
        '\' OR Grant__r.National_Grant_Type__c = \'' +
        grantType +
        '\')';
    }

    for (
      Account i : acctClass.getRelatedAccountList(
        userAcct.Id,
        'National Organization',
        null,
        null,
        ' AND Hold_Status__c = \'Hold\''
      )
    ) {
      if (onHold.size() < listLimit)
        onHold.add(i);
    }

    if (userAcctType == 'National Organization') {
      logs = lc.getTALogs(
        siteId,
        false,
        6,
        profileName,
        ' AND Flagged_for_Follow_Up__c = true'
      );
    }

    if (userAcctType == 'Local Organization') {
      for (
        Application__c a : ac.getRelatedApplicationList(
          userAcct.Id,
          null,
          null,
          ' AND (Status__c = \'Sent to Applicant\' OR Status__c = \'Sent Back\' OR Status__c = \'In Progress\') AND Grant_Type__c != \'SOI\'',
          null,
          null
        )
      ) {
        if (apps_incomplete.size() < listLimit) {
          apps_incomplete.add(a);
          appId = a.Id;
        } else {
          more_apps_incomplete = true;
        }
      }
    }

    if (userAcctType == 'Local Organization') {
      for (
        Victims_Served_Report__c vsr : vsrc.getRelatedReportList(
          userAcct.Id,
          null,
          null,
          'AND (Status__c = \'Requested\' OR Status__c = \'In Progress\')'
        )
      ) {
        if (vsr_incomplete.size() < listLimit) {
          vsr_incomplete.add(vsr);
          OVCPRId = vsr.Id;
        }
      }
    }

    if (!profileName.contains('Program')) {
      for (
        Grant__c g : gc.getRelatedSubGrants(
          userAcct.Id,
          grantId,
          null,
          null,
          null,
          null,
          grantSOQL
        )
      ) {
        String status = '';
        if (g.Grant_Status__c != null)
          status = g.Grant_Status__c;

        if (
          status == '' ||
          status.contains('Incomplete') ||
          status == 'Revisions Needed'
        ) {
          if (grants_incomplete.size() < listLimit)
            grants_incomplete.add(g);
          else
            more_grants_incomplete = true;
        } else if (status.contains('Approval')) {
          if (
            status.contains('First') &&
            (approverLevel == 'Level One' ||
            approverLevel == 'Level Two')
          ) {
            if (grants_pending.size() < listLimit)
              grants_pending.add(g);
            else
              more_grants_pending = true;
          }
          if (status.contains('Second') && approverLevel == 'Level Two') {
            if (grants_pending.size() < listLimit)
              grants_pending.add(g);
            else
              more_grants_pending = true;
          }
          if (status.contains('Third') && approverLevel == 'Level Three') {
            if (grants_pending.size() < listLimit)
              grants_pending.add(g);
            else
              more_grants_pending = true;
          }
          if (status.contains('Fourth') && approverLevel == 'Level Four') {
            if (grants_pending.size() < listLimit)
              grants_pending.add(g);
            else
              more_grants_pending = true;
          }
        }
      }

      for (
        Reimbursement_Request__c r : rc.getRelatedRequests(
          userAcct.Id,
          grantId,
          '',
          null,
          null,
          null,
          primaryApproverId,
          rrSOQL
        )
      ) {
        String status = '';
        if (r.Status__c != null)
          status = r.Status__c;

        if (
          status == '' ||
          status.contains('Incomplete') ||
          status.contains('Revision')
        ) {
          if (requests_incomplete.size() < listLimit)
            requests_incomplete.add(r);
          else
            more_requests_incomplete = true;
        } else if (status.contains('Approval')) {
          if (
            status.contains('First') &&
            (approverLevel == 'Level One' ||
            (approverLevel == 'Level Two' &&
            !r.Prevent_Skip_Reimbursement_Approvals__c))
          ) {
            if (requests_pending.size() < listLimit)
              requests_pending.add(r);
            else
              more_requests_pending = true;
          }
          if (status.contains('Second') && approverLevel == 'Level Two') {
            if (requests_pending.size() < listLimit)
              requests_pending.add(r);
            else
              more_requests_pending = true;
            /*
                        if(r.Prevent_Skip_Reimbursement_Approvals__c) {
                        if(requests_pending.size() < listLimit) requests_pending.add(r);
                        else more_requests_pending = true;
                        } else {
                        if(requests_pendingSecond.size() < listLimit) requests_pendingSecond.add(r);
                        else more_requests_pendingSecond = true;
                        }
                        */
          }
          if (
            status.contains('Third') &&
            (approverLevel == 'Level Three' ||
            (approverLevel == 'Level Four' &&
            !r.Prevent_Skip_Reimbursement_Approvals__c))
          ) {
            if (requests_pending.size() < listLimit)
              requests_pending.add(r);
            else
              more_requests_pending = true;
          }
          if (status.contains('Fourth') && approverLevel == 'Level Four') {
            if (requests_pending.size() < listLimit)
              requests_pending.add(r);
            else
              more_requests_pending = true;
          }
        }
      }
    }

    for (
      Session_Report__c sr : src.getRelatedReportList(
        userAcct.Id,
        siteId,
        userAcctType,
        '',
        '',
        '',
        'LastModifiedDate desc',
        null
      )
    ) {
      if (sr.Status__c != 'Submitted' && sr.Status__c != 'Approved') {
        if (sessionReports_incomplete.size() < listLimit) {
          sessionReports_incomplete.add(sr);
        } else {
          more_sessionReports_incomplete = true;
        }
      } else if (sr.Status__c == 'Submitted') {
        if (sessionReports_submitted.size() < listLimit) {
          sessionReports_submitted.add(sr);
        } else {
          more_sessionReports_submitted = true;
        }
      }
    }

    for (
      Progress_Report__c pr : prgsrc.getRelatedReportList(
        userAcct.Id,
        null,
        userAcctType,
        null,
        null,
        null,
        null,
        null,
        null,
        soqlAND
      )
    ) {
      if (pr.Status__c != 'Submitted' && pr.Status__c != 'Approved') {
        if (progressReports_incomplete.size() < listLimit) {
          progressReports_incomplete.add(pr);
        } else {
          more_progressReports_incomplete = true;
        }
      } else if (pr.Status__c == 'Submitted') {
        if (progressReports_submitted.size() < listLimit) {
          progressReports_submitted.add(pr);
        } else {
          more_progressReports_submitted = true;
        }
      }
    }

    for (
      Grantee_Report__c gr : dctatrc.getRelatedReportList(
        userAcct.Id,
        null,
        null,
        null,
        paSOQL
      )
    ) {
      if (
        gr.Report_Status__c != 'Submitted' &&
        gr.Report_Status__c != 'Approved'
      ) {
        if (dctatReports_incomplete.size() < listLimit) {
          dctatReports_incomplete.add(gr);
        } else {
          more_dctatReports_incomplete = true;
        }
      } else if (gr.Report_Status__c == 'Submitted') {
        if (dctatReports_submitted.size() < listLimit) {
          dctatReports_submitted.add(gr);
        } else {
          more_dctatReports_submitted = true;
        }
      }
    }

    for (
      Program_Report__c pr : prgmrc.getRelatedReportList(
        userAcct.Id,
        userAcctType,
        null,
        null,
        null,
        soqlAND + ' AND RecordType.Name = \'Monthly PA Logs\''
      )
    ) {
      if (
        pr.Status__c == 'Incomplete' ||
        pr.Status__c == 'Not Started' ||
        pr.Status__c == 'In Progress' ||
        pr.Status__c == 'Revisions Needed'
      ) {
        if (palogs_incomplete.size() < listLimit) {
          palogs_incomplete.add(pr);
        } else {
          more_palogs_incomplete = true;
        }
      } else if (pr.Status__c == 'Submitted') {
        if (palogs_submitted.size() < listLimit) {
          palogs_submitted.add(pr);
        } else {
          more_palogs_submitted = true;
        }
      }
    }
  }
}
