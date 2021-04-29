public with sharing class GrantCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String portalName { get; set; }

  private GrantClass gc = new GrantClass();
  private ReimbursementClass rc = new ReimbursementClass();
  private BudgetItemClass bic = new BudgetItemClass();
  private getIdFromString gifs = new getIdFromString();

  public List<Grant__c> grants { get; set; }
  public Grant__c grant { get; set; }
  public ID grantId { get; set; }
  public Decimal totalAwarded { get; set; }
  public Decimal totalBudgeted { get; set; }
  public Decimal totalRequested { get; set; }
  public Decimal totalApproved { get; set; }

  public Boolean canCloseGrant { get; set; }
  public Boolean displayCloseGrantPopup { get; set; }

  public GrantCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    portalName = uc.userProfile;

    grants = new List<Grant__c>();
    grant = new Grant__c();

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);
  }

  public void getGrants() {
    String soql = 'SELECT Id, Name, Amount__c, Balance__c, Start_Date__c, End_Date__c, Grant_Status__c FROM Grant__c WHERE RecordType.Name = \'Grant\'';
    if (portalName.contains('TRAIL'))
      soql += ' AND (Grant_Type__c = \'TRAIL\' OR National_Grant_Type__c = \'TRAIL\')';
    if (portalName.contains('OVC'))
      soql += ' AND (Grant_Type__c = \'OVC\' OR National_Grant_Type__c = \'OVC\')';
    grants = database.query(soql);
  }

  public PageReference getGrantDetails() {
    if (grantId == null)
      return new PageReference('/Grants');
    grant = gc.getGrant(grantId);

    totalAwarded = 0;
    totalBudgeted = 0;
    totalRequested = 0;
    totalApproved = 0;
    if (grant.Grant_Status__c != 'Closed')
      canCloseGrant = true;
    for (
      Grant__c sg : gc.getRelatedSubGrants(
        userAcct.Id,
        grantId,
        null,
        null,
        null,
        null,
        null
      )
    ) {
      if (sg.Amount__c != null)
        totalAwarded += sg.Amount__c;
      if (sg.Total_Item_Budget__c != null)
        totalBudgeted += sg.Total_Item_Budget__c;
      if (sg.Reimbursement_Requested_Amount__c != null)
        totalRequested += sg.Reimbursement_Requested_Amount__c;
      if (sg.Reimbursement_Approved_Amount__c != null)
        totalApproved += sg.Reimbursement_Approved_Amount__c;
      if (sg.Reimbursements_Pending_Approval__c > 0)
        canCloseGrant = false;
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
}
