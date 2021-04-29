public with sharing class ProgramPlanCtrl {
  private UserClass uc = new UserClass();
  private ProgramPlanClass ppc = new ProgramPlanClass();
  private FieldLabelClass flc = new FieldLabelClass();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public Id planId { get; set; }
  public Program_Plan__c plan { get; set; }
  public Map<String, String> labels { get; set; }

  public Boolean readOnly { get; set; }
  public String errorMessage { get; set; }

  public List<SelectOption> serviceOptions {
    get {
      return spf.getPicklistOptions(
        'Program_Plan__c',
        'Areas_of_Service__c',
        null
      );
    }
    set;
  }
  public String[] services {
    get {
      String[] selected = new List<String>();
      List<SelectOption> sos = this.serviceOptions;
      for (SelectOption s : sos) {
        if (
          this.plan.Areas_of_Service__c != null &&
          this.plan.Areas_of_Service__c.contains(s.getValue())
        )
          selected.add(s.getValue());
      }
      return selected;
    }
    public set {
      String selectedConcat = '';
      for (String s : value) {
        if (selectedConcat == '')
          selectedConcat += s;
        else
          selectedConcat += ';' + s;
      }
      plan.Areas_of_Service__c = selectedConcat;
    }
  }

  public ProgramPlanCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;

    readOnly = true;

    plan = new Program_Plan__c();
    String urlPlanId = ApexPages.currentPage().getParameters().get('planId');
    if (urlPlanId != '' && urlPlanId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlPlanId)
          .matches()
      ) {
        planId = Id.valueOf(urlPlanId);
        plan = ppc.getPlan(planId);
      }
    }

    if (plan != null) {
      if (
        userAcctType == 'Local Organization' &&
        plan.Status__c == 'Revisions Needed'
      )
        readOnly = false;
      labels = flc.getFieldLabelMap('Program_Plan__c', null, null, null);
    }
  }

  public void updatePlan() {
    plan = plan.clone(false, true, false, false);
    readOnly = false;
  }

  public void submit() {
    errorMessage = '';

    if (plan.Biggest_Issue_Organization_is_Facing__c == null)
      errorMessage += 'Issue that will be addressed is required <br />';
    if (plan.How_Funds_Utilized__c == null)
      errorMessage += 'How you would like to use the requested funding is required <br />';

    if (
      plan.Has_Needs_Assessment__c == true &&
      (plan.Previous_Experiences__c == null ||
      plan.Needs_Assessment__c == null)
    )
      errorMessage += 'Needs Assessment questions are required <br />';

    if (
      plan.Has_Strategic_Plan__c == true &&
      (plan.Strategic_Plan__c == null ||
      plan.Additional_Resources_for_Strategic_Plan__c == null)
    )
      errorMessage += 'Strategic Plan questions are required <br />';

    if (
      plan.Areas_of_Service__c == null ||
      plan.Current_Program_Description__c == null
    )
      errorMessage += 'Support for Victim Services questions are required <br />';

    if (
      plan.Has_Equipment_and_Supplies__c == true &&
      plan.Equipment_and_Supplies__c == null
    )
      errorMessage += 'Equipment and Supplies questions are required <br />';

    if (plan.Responsibilities__c == null || plan.Able_to_Recruit__c == null)
      errorMessage += 'Capabilities and Competencies questions are required <br />';

    if (plan.Other_Challenges__c == null)
      errorMessage += 'Plan for Collecting Data is required <br />';

    if (errorMessage == '') {
      plan.Status__c = 'Submitted';
      plan.Submitted_Date__c = Date.today();
      ppc.upsertPlan(plan, true);
      readOnly = true;
    }
  }

  public void approve() {
    plan.Status__c = 'Approved';
    ppc.upsertPlan(plan, false);
    readOnly = true;
  }

  public void sendBack() {
    plan.Status__c = 'Revisions Needed';
    ppc.upsertPlan(plan, false);
    readOnly = true;
  }
}
