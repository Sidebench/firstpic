public class CreateMonthlyPALogs implements Schedulable {
  public static String CRON_EXP = '0 0 1 1 * ? *';
  /*
    global static String schedule() {
        CreateMonthlyPALogs s = new CreateMonthlyPALogs();
        return System.schedule('Monthly', CRON_EXP, s);
    }
    */
  public void execute(SchedulableContext sc) {
    Date dt = date.today();
    Integer numberOfDays = Date.daysInMonth(dt.year(), dt.month());
    Date firstDayOfMonth = Date.newInstance(dt.year(), dt.month(), 1);
    Date lastDayOfMonth = Date.newInstance(dt.year(), dt.month(), numberOfDays);
    String month = '';
    if (dt.month() == 1)
      month = 'January';
    if (dt.month() == 2)
      month = 'February';
    if (dt.month() == 3)
      month = 'March';
    if (dt.month() == 4)
      month = 'April';
    if (dt.month() == 5)
      month = 'May';
    if (dt.month() == 6)
      month = 'June';
    if (dt.month() == 7)
      month = 'July';
    if (dt.month() == 8)
      month = 'August';
    if (dt.month() == 9)
      month = 'September';
    if (dt.month() == 10)
      month = 'October';
    if (dt.month() == 11)
      month = 'November';
    if (dt.month() == 12)
      month = 'December';

    List<Program_Report__c> pr_list = new List<Program_Report__c>();
    List<Grant__c> g_list = [
      SELECT Id, Account__r.Id
      FROM Grant__c
      WHERE
        RecordType.Name = 'Sub-Grant'
        AND FirstPic_National_Org_Code__c = 'NCAI'
        AND National_Grant__r.Reporting_Period_Start_Date__c <= :dt
        AND National_Grant__r.Reporting_Period_End_Date__c >= :dt
        AND Grant_Status__c != 'Closed'
    ];
    for (Account a : [
      SELECT
        Id,
        Local_Organization__r.Id,
        Local_Organization__r.CEO__c,
        Local_Organization__r.CEO_Email__c,
        Local_Organization__r.Program_Coordinator__c,
        Local_Organization__r.Program_Coordinator_Email__c,
        Local_Organization__r.DOD_Email__c
      FROM Account
      WHERE
        FirstPic_National_Org_Code__c = 'NCAI'
        AND RecordType.Name = 'Site'
        AND Is_Active__c = TRUE
    ]) {
      for (Grant__c g : g_list) {
        if (g.Account__r.Id == a.Local_Organization__r.Id) {
          Program_Report__c pr = new Program_Report__c(
            RecordTypeId = Schema.SObjectType.Program_Report__c.getRecordTypeInfosByName()
              .get('Monthly PA Logs')
              .getRecordTypeId(),
            Name = month + ' ' + dt.year() + ' PA Logs',
            Start_Date__c = firstDayOfMonth,
            End_Date__c = lastDayOfMonth,
            Month__c = month,
            Year__c = string.valueOf(dt.year()),
            Grant__c = g.Id,
            //Grant_Year__c = string.valueOf(g.Current_Grant_Year__c),
            Site__c = a.Id,
            Status__c = 'Not Started',
            CEO__c = a.Local_Organization__r.CEO__c,
            CEO_Email__c = a.Local_Organization__r.CEO_Email__c,
            Program_Coordinator__c = a.Local_Organization__r.Program_Coordinator__c,
            Program_Coordinator_Email__c = a.Local_Organization__r.Program_Coordinator_Email__c,
            DOD_Email__c = a.Local_Organization__r.DOD_Email__c
          );
          pr_list.add(pr);
        }
      }
    }
    insert pr_list;

    List<PA_Log__c> pa_list = new List<PA_Log__c>();
    for (Program_Report__c pr : pr_list) {
      for (
        integer i = 0; i <= pr.Start_Date__c.daysBetween(pr.End_Date__c); i++
      ) {
        Date d = pr.Start_Date__c.addDays(i);
        PA_Log__c pa = new PA_Log__c(
          Date__c = d,
          Monthly_PA_Report__c = pr.Id,
          Site__c = pr.Site__c
        );
        pa_list.add(pa);
      }
    }
    insert pa_list;
  }
}
