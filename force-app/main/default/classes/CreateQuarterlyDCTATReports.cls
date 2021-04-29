public class CreateQuarterlyDCTATReports implements Schedulable {
  private GetMonthAsString gms = new GetMonthAsString();

  public void execute(SchedulableContext sc) {
    Date dt = date.today();
    GetMonthAsString gms = new GetMonthAsString();
    String month = gms.getMonth(dt.month());
    String quarter = '';
    if (month == 'February')
      quarter = 'Q2';
    else if (month == 'May')
      quarter = 'Q3';
    else if (month == 'August')
      quarter = 'Q4';
    else if (month == 'November')
      quarter = 'Q1';

    if (
      month == 'February' ||
      month == 'May' ||
      month == 'August' ||
      month == 'November'
    ) {
      List<Grantee_Report__c> reports = new List<Grantee_Report__c>();
      for (Grant__c g : [
        SELECT
          Id,
          Account__r.Id,
          Account__r.CEO_Email__c,
          Account__r.CEO__c,
          Account__r.Primary_Approver__c,
          Account__r.Primary_Approver_Email_text__c
        FROM Grant__c
        WHERE
          RecordType.Name = 'Sub-Grant'
          AND FirstPic_National_Org_Code__c = 'Ripken'
      ]) {
        Grantee_Report__c r = new Grantee_Report__c(
          Year__c = string.valueOf(dt.year()),
          Grant__c = g.Id,
          Organization__c = g.Account__c,
          Report_Status__c = 'Not Started',
          Quarter__c = quarter,
          Primary_Approver__c = g.Account__r.Primary_Approver__c,
          Primary_Approver_Email__c = g.Account__r.Primary_Approver_Email_text__c,
          CEO__c = g.Account__r.CEO__c,
          CEO_Email__c = g.Account__r.CEO_Email__c
        );
        reports.add(r);
      }
      insert reports;
    }
  }
}
