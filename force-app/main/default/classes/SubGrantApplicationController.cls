public class SubGrantApplicationController {
  public ID AccountId { get; set; }
  public Account acct { get; set; }
  public ID GrantId { get; set; }
  public Grant__c grant { get; set; }
  public String errorMessage { get; set; }

  public SubGrantApplicationController() {
    AccountId = ApexPages.currentPage().getParameters().get('AccountId');
    GrantId = ApexPages.currentPage().getParameters().get('GrantId');
    acct = new Account();
    grant = new Grant__c();

    if (GrantID != null) {
      grant = [
        SELECT
          ID,
          Account__c,
          Account__r.Name,
          Name,
          A_133_Audit_Status__c,
          Amount__c,
          Application_Submitted_Date__c,
          Balance__c,
          Compliance_Notes__c,
          Compliance_Status__c,
          Duration__c,
          End_Date__c,
          Grant_Status__c,
          Previous_Status__c,
          Project_Description__c,
          Start_Date__c,
          Total_Approved_Amount__c,
          Total_Item_Budget__c,
          Total_Requested_Amount__c,
          Youth_Served__c
        FROM Grant__c
        WHERE ID = :GrantID
      ];
      AccountID = grant.Account__r.Id;
    }
    if (AccountId != null) {
      acct = [
        SELECT
          ID,
          RecordType.Name,
          Name,
          EIN__c,
          Status__c,
          Application_Submitted_Date__c,
          Phone,
          BillingStreet,
          BillingCity,
          BillingState,
          BillingPostalCode,
          Youth_Served__c,
          Number_of_Mentors__c,
          Number_of_Sites__c,
          Names_of_Sites__c
        FROM Account
        WHERE ID = :AccountId
      ];
    }
  }

  public PageReference Submit() {
    system.debug('>>>> acct ' + acct);
    Account a = new Account();
    Set<ID> aID_set = new Set<ID>();
    Grant__c g = new Grant__c();

    if (AccountId != null) {
      a = [SELECT ID, EIN__c, Name FROM Account WHERE ID = :AccountId];
    } else if (acct.EIN__c != null) {
      a.EIN__c = acct.EIN__c;
    }
    system.debug('>>>> a ' + a);
    a.Name = acct.Name;
    a.Status__c = 'Application Submitted';
    a.Application_Submitted_Date__c = Date.today();
    a.Phone = acct.Phone;
    a.BillingStreet = acct.BillingStreet;
    a.BillingCity = acct.BillingCity;
    a.BillingState = acct.BillingState;
    a.BillingPostalCode = acct.BillingPostalCode;
    a.Youth_Served__c = acct.Youth_Served__c;
    a.Number_of_Mentors__c = acct.Number_of_Mentors__c;
    a.Number_of_Sites__c = acct.Number_of_Sites__c;
    a.Names_of_Sites__c = acct.Names_of_Sites__c;
    try {
      upsert a;
      aID_set.add(a.Id);
      System.Debug('>>>> Account update successful. a = ' + a);
      System.Debug('>>>> aID_set = ' + aID_set);
    } catch (Exception e) {
      ApexPages.addmessage(
        new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())
      );
      return null;
    }

    for (Account aa : [SELECT ID FROM Account WHERE ID IN :aID_set]) {
      g.Account__c = aa.Id;
      //o.A_133_Audit_Status__c = opp.A_133_Audit_Status__c;
      g.Application_Submitted_Date__c = date.today();
      //o.Compliance_Notes__c = opp.Compliance_Notes__c;
      //o.Compliance_Status__c = opp.Compliance_Status__c;
      g.End_Date__c = grant.End_Date__c;
      //o.Names_of_Sites__c = opp.Names_of_Sites__c;
      //o.Mentors__c = opp.Mentors__c;
      //o.Number_of_Sites__c = opp.Number_of_Sites__c;
      //o.Youth_Served__c = opp.Youth_Served__c;
      g.Project_Description__c = grant.Project_Description__c;
      g.Name = grant.Name;
      g.Start_Date__c = grant.Start_Date__c;
      g.Grant_Status__c = 'Application Submitted';
    }
    try {
      insert g;
      System.Debug('>>>> Grant insert successful. g = ' + g);
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
      return null;
    }

    return null;
  }
}
