public without sharing class PublicApplicationCtrl {
  private FieldLabelClass flc = new FieldLabelClass();
  private AccountClass acctClass = new AccountClass();
  private ApplicationClass appClass = new ApplicationClass();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public Map<String, String> fields { get; set; }
  public String appType { get; set; }
  public Application__c app { get; set; }
  public String title { get; set; }

  public List<SelectOption> serviceOptions {
    get {
      return spf.getPicklistOptions(
        'Application__c',
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
          this.app.Areas_of_Service__c != null &&
          this.app.Areas_of_Service__c.contains(s.getValue())
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
      app.Areas_of_Service__c = selectedConcat;
    }
  }

  Date dt = date.today();
  public Boolean showSuccess { get; set; }
  public String errorMessage { get; set; }

  public PublicApplicationCtrl() {
    fields = new Map<String, String>();
    app = new Application__c();
    app.Previous_Support_Received__c = 'No';
  }

  public void setOVCAppType() {
    app.National_Organization_Id__c = '0013600001Pxcii';
    app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName()
      .get('NCAI - OVC')
      .getRecordTypeId();
    app.Grant_Year__c = '2021 - 2022';
    fields = flc.getFieldLabelMap(
      'Application__c',
      app.Grant_Type__c,
      app.Type__c,
      ' AND Year__c includes (\'' +
      app.Grant_Year__c +
      '\')'
    );
  }
  // END getFields

  // BEGIN getTotal
  public void getTotal() {
    Decimal total = 0;
    if (app.Personnel_Budget__c != null) {
      total += app.Personnel_Budget__c;
    }
    if (app.Fringe_Benefits_Budget__c != null) {
      total += app.Fringe_Benefits_Budget__c;
    }
    if (app.Travel_Budget__c != null) {
      total += app.Travel_Budget__c;
    }
    if (app.Supplies_Budget__c != null) {
      total += app.Supplies_Budget__c;
    }
    if (app.Contracts_Budget__c != null) {
      total += app.Contracts_Budget__c;
    }
    if (app.Contractor_Travel_Budget__c != null) {
      total += app.Contractor_Travel_Budget__c;
    }
    if (app.Other_Costs_Budget__c != null) {
      total += app.Other_Costs_Budget__c;
    }
    if (app.Indirect_Costs_Budget__c != null) {
      total += app.Indirect_Costs_Budget__c;
    }
    app.Total_Amount_Requested__c = total;
  }
  // END getTotal

  // BEGIN submit
  public void submit() {
    app.Status__c = 'Submitted';
    app.Submitted_Date__c = date.today();
    getTotal();
    appClass.upsertApplication(app);

    if (ApexPages.hasMessages())
      errorMessage += string.valueOf(ApexPages.getMessages());
    else
      showSuccess = true;
  }
  // END submit
}
