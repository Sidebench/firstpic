public with sharing class GrantDetailsController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public Account acct { get; set; }
  public String portalName { get; set; }
  public String url { get; set; }
  public String approverLevel { get; set; }

  public GrantClass gc = new GrantClass();
  public BudgetItemClass bic = new BudgetItemClass();
  private getIdFromString gifs = new getIdFromString();

  public ID grantId { get; set; }
  public Grant__c grant { get; set; }
  public Decimal awarded { get; set; }
  public Decimal budgeted { get; set; }
  public Decimal requested { get; set; }
  public Decimal approved { get; set; }

  public Map<String, List<Budget_Item__c>> labor_map { get; set; }
  public Map<String, List<Budget_Item__c>> expense_map { get; set; }
  public Boolean hasLabor { get; set; }
  public Boolean hasExpenses { get; set; }
  public String errorMessage { get; set; }

  public Sertifi2_0__EDocument__c mou { get; set; }
  public Attachment mouAtt { get; set; }

  public Boolean canCloseGrant { get; set; }
  public Boolean displayCloseGrantPopup { get; set; }

  // BEGIN Constructor
  public GrantDetailsController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;
    approverLevel = userClass.approverLevel;

    url = '';
    if (portalName == 'NPAL')
      url = 'NPAL';

    labor_map = new Map<String, List<Budget_Item__c>>();
    expense_map = new Map<String, List<Budget_Item__c>>();
    hasLabor = false;
    hasExpenses = false;

    awarded = 0;
    budgeted = 0;
    requested = 0;
    approved = 0;

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);
    if (grantId != null) {
      grant = gc.getGrant(GrantId);
      acct = [
        SELECT ID, Name, RecordType.Name
        FROM Account
        WHERE ID = :grant.Account__r.Id
      ];

      Sertifi2_0__EDocument__c[] eDocs = [
        SELECT
          Id,
          Name,
          Sertifi2_0__Status__c,
          Sertifi2_0__SignedLink__c,
          (SELECT Id FROM Attachments)
        FROM Sertifi2_0__EDocument__c
        WHERE
          Sertifi2_0__TestContract__r.Grant__c = :GrantId
          AND Sertifi2_0__Name__c = 'Letter of Agreement'
      ];
      if (eDocs.size() > 0) {
        mou = eDocs[0];
        mouAtt = eDocs[0].attachments[0];
      }

      if (grant.Grant_Status__c != 'Closed')
        canCloseGrant = true;
      for (
        Grant__c g : gc.getRelatedSubGrants(
          acct.Id,
          grant.Id,
          null,
          null,
          null,
          null,
          null
        )
      ) {
        if (g.Amount__c != null) {
          awarded += g.Amount__c;
        }
        if (g.Total_Budgeted__c != null) {
          budgeted += g.Total_Budgeted__c;
        }
        if (g.Total_Requested_Amount__c != null) {
          requested += g.Reimbursement_Requested_Amount__c;
        }
        if (g.Total_Approved_Amount__c != null) {
          approved += g.Reimbursement_Approved_Amount__c;
        }
        if (g.Reimbursements_Pending_Approval__c > 0)
          canCloseGrant = false;
      }
      awarded = awarded.setScale(2);
      budgeted = budgeted.setScale(2);
      requested = requested.setScale(2);
      approved = approved.setScale(2);

      for (Budget_Item__c bi : bic.getBudgetItems(GrantId)) {
        if (bi.RecordType.Name == 'Expense') {
          system.debug('>>> expense item = ' + bi);
          if (expense_map.containsKey(bi.Category__c)) {
            List<Budget_Item__c> bi_list = expense_map.get(bi.Category__c);
            bi_list.add(bi);
            expense_map.put(bi.Category__c, bi_list);
          } else {
            expense_map.put(bi.Category__c, new List<Budget_Item__c>{ bi });
          }
          if (expense_map.keySet() != null) {
            hasExpenses = true;
          }
        } else {
          system.debug('>>> labor item = ' + bi);
          if (labor_map.containsKey(bi.Category__c)) {
            List<Budget_Item__c> bi_list = labor_map.get(bi.Category__c);
            bi_list.add(bi);
            labor_map.put(bi.Category__c, bi_list);
          } else {
            labor_map.put(bi.Category__c, new List<Budget_Item__c>{ bi });
          }
          if (labor_map.keySet() != null) {
            hasLabor = true;
          }
        }
      }
      system.debug('>>> expense_map count = ' + expense_map.size());
      system.debug('>>> labor_map count = ' + labor_map.size());
    }
  }
  // END Constructor

  public ApexPages.PageReference init() {
    if (grantId == null || grant == null) {
      PageReference pageRef = new PageReference('/Error');
      return pageRef;
    }
    return null;
  }

  // BEGIN closeGrant
  public void closeGrant() {
    gc.closeGrant(grant.Id);
    hideCloseGrantPopup();
  }
  // END closeGrant

  // BEGIN popups
  public void showCloseGrantPopup() {
    displayCloseGrantPopup = true;
  }
  public void hideCloseGrantPopup() {
    displayCloseGrantPopup = false;
  }
  // END popups

  public PageReference goToSubGrantList() {
    PageReference pr = new PageReference(
      '/' +
      url +
      'SubGrantList?grantId=' +
      grantId
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference goToReimbursementsList() {
    PageReference pr = new PageReference(
      '/' +
      url +
      'ReimbursementList?grantId=' +
      grantId
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference goToReportsList() {
    PageReference pr = new PageReference(
      '/' +
      url +
      'GranteeReportList?grantId=' +
      grantId
    );
    pr.setRedirect(true);
    return pr;
  }

  public PageReference createDrawdown() {
    PageReference pr = new PageReference('/DrawdownReport?grantId=' + grantId);
    pr.setRedirect(true);
    return pr;
  }
}
