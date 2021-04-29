public with sharing class LEGOFinanceReportCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public Account acct { get; set; }
  public AccountClass acctClass = new AccountClass();

  public String SiteId { get; set; }

  public Boolean editMode { get; set; }
  public String statusColor { get; set; }
  public String errorMessage { get; set; }

  public Boolean displayAttPopup { get; set; }
  public List<Attachment> att_list { get; set; }
  public Id deleteAttId { get; set; }

  public LEGOFinanceReportCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    editMode = false;
    statusColor = 'text-warning';

    SiteId = ApexPages.currentPage().getParameters().get('SiteId');
    system.debug('>>> SiteId = ' + SiteId);
    String soql = 'SELECT Name, Finance_Report_Status__c, Funds_Received_from_First__c, Tablets_Purchased__c, Tablets_Purchased_Notes__c, How_Funds_Where_Used__c, Were_Funds_Helpful__c FROM Account';
    if (userAcctType == 'Site') {
      soql += ' WHERE Id = \'' + userAcct.Id + '\'';
    } else if (SiteId != null && SiteId != '') {
      soql += ' WHERE Id = \'' + SiteId + '\'';
    }
    system.debug('>>> soql = ' + soql);

    Account[] accts = database.query(soql);
    if (accts.size() > 0) {
      acct = accts[0];
      if (acct.Finance_Report_Status__c != 'Submitted') {
        editMode = true;
      } else {
        statusColor = 'text-success';
      }
    }
  }

  public void getAttList() {
    att_list = new List<Attachment>();
    displayAttPopup = false;
    if (acct != null) {
      Account[] accts = [
        SELECT
          Id,
          (
            SELECT Id, Name, Description
            FROM Attachments
            ORDER BY LastModifiedDate DESC
          )
        FROM Account
        WHERE Id = :acct.Id
      ];
      if (accts.size() > 0) {
        for (Attachment a : accts[0].Attachments) {
          String name = a.Name;
          att_list.add(a);
        }
      }
    }
  }

  public PageReference save() {
    if (acct != null) {
      if (
        acct.Finance_Report_Status__c == null ||
        acct.Finance_Report_Status__c == 'Not Started'
      ) {
        acct.Finance_Report_Status__c = 'In Progress';
      }
      try {
        acctClass.upsertAccount(acct);
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
    if (acct != null) {
      acct.Finance_Report_Status__c = 'Submitted';
      try {
        acctClass.upsertAccount(acct);
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
    if (acct != null) {
      acct.Finance_Report_Status__c = 'In Progress';
      try {
        acctClass.upsertAccount(acct);
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
    displayAttPopup = true;
  }

  public void closeAttPopup() {
    displayAttPopup = false;
    getAttList();
  }
  // END popups
}
