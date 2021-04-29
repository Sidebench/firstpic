public with sharing class TAPlanCtrl {
  private UserClass uc = new UserClass();
  private TAPlanClass tapc = new TAPlanClass();
  private FieldLabelClass flc = new FieldLabelClass();
  private GetIdFromString gifs = new GetIdFromString();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public Id orgId { get; set; }
  public Id planId { get; set; }
  public TA_Plan__c plan { get; set; }

  public Boolean readOnly { get; set; }

  public TAPlanCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;

    readOnly = true;

    plan = new TA_Plan__c();
    String urlPlanId = ApexPages.currentPage().getParameters().get('planId');
    planId = gifs.getId(urlPlanId);

    String urlOrgId = ApexPages.currentPage().getParameters().get('orgId');
    orgId = gifs.getId(urlOrgId);

    plan = tapc.getPlan(orgId, planId);
  }

  public void updatePlan() {
    readOnly = false;
  }

  public PageReference savePlan() {
    tapc.upsertPlan(plan);
    if (!ApexPages.hasMessages()) {
      readOnly = true;
      return new PageReference('/TAPlans');
    }
    return null;
  }
}
