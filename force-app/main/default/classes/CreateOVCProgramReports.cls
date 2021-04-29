public class CreateOVCProgramReports implements Schedulable {
  private GetMonthAsString gms = new GetMonthAsString();

  public void execute(SchedulableContext sc) {
    Date dt = date.today();
    GetMonthAsString gms = new GetMonthAsString();
    String month = gms.getMonth(dt.month());

    if (
      month == 'March' ||
      month == 'June' ||
      month == 'September' ||
      month == 'December'
    ) {
      if (month == 'March')
        month = 'Jan - Mar';
      if (month == 'June')
        month = 'Apr - Jun';
      if (month == 'September')
        month = 'Jul - Sep';
      if (month == 'December')
        month = 'Oct - Dec';

      List<Victims_Served_Report__c> pr_list = new List<Victims_Served_Report__c>();

      List<Grant__c> g_list = [
        SELECT Id, Account__r.Id
        FROM Grant__c
        WHERE
          RecordType.Name = 'Sub-Grant'
          AND LOA_Submitted_Date__c != NULL
          AND Grant_Type__c = 'OVC'
      ];
      for (Grant__c g : g_list) {
        Victims_Served_Report__c pr = new Victims_Served_Report__c(
          Month__c = month,
          Year__c = dt.year(),
          Organization__c = g.Account__r.Id,
          Status__c = 'Requested'
        );
        pr_list.add(pr);
      }
      insert pr_list;
    }
  }
}
