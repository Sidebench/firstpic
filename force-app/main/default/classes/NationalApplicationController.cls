public class NationalApplicationController {
  public ID AccountId { get; set; }
  public Account acct { get; set; }
  public String errorMessage { get; set; }

  public NationalApplicationController() {
    acct = new Account();
    AccountId = ApexPages.currentPage().getParameters().get('AccountId');

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
    try {
      upsert a;
      System.Debug('>>>> Account update successful. a = ' + a);
    } catch (Exception e) {
      errorMessage = e.getMessage();
      system.debug('error = ' + e.getMessage());
      return null;
    }
    return null;
  }
}
