public class CreateMonthlyProgressReports implements Schedulable {
  private GetMonthAsString gms = new GetMonthAsString();

  public void execute(SchedulableContext sc) {
    Date dt = date.today();
    Date due = date.newinstance(dt.year(), dt.month() + 1, 5);
    GetMonthAsString gms = new GetMonthAsString();
    String month = gms.getMonth(dt.month());

    if (
      month != 'March' &&
      month != 'June' &&
      month != 'September' &&
      month != 'December'
    ) {
      List<Progress_Report__c> pr_list = new List<Progress_Report__c>();
      List<Grant__c> g_list = [
        SELECT
          Id,
          Account__r.Id,
          Account__r.CEO__c,
          Account__r.CEO_Email__c,
          Account__r.Program_Coordinator__c,
          Account__r.Program_Coordinator_Email__c
        FROM Grant__c
        WHERE
          RecordType.Name = 'Sub-Grant'
          AND FirstPic_National_Org_Code__c = 'NPAL'
          AND National_Grant__r.Reporting_Period_Start_Date__c <= :dt
          AND National_Grant__r.Reporting_Period_End_Date__c >= :dt
          AND Grant_Status__c != 'Closed'
      ];
      for (Grant__c g : g_list) {
        Progress_Report__c pr = new Progress_Report__c(
          Month__c = month,
          Year__c = string.valueOf(dt.year()),
          Grant__c = g.Id,
          Organization__c = g.Account__r.Id,
          Status__c = 'Not Started',
          Due_Date__c = due,
          CEO__c = g.Account__r.CEO__c,
          CEO_Email__c = g.Account__r.CEO_Email__c,
          Program_Coordinator__c = g.Account__r.Program_Coordinator__c,
          Program_Coordinator_Email__c = g.Account__r.Program_Coordinator_Email__c
        );
        pr_list.add(pr);
      }
      insert pr_list;
    } else {
      // DCTAT code here
    }
  }
}
