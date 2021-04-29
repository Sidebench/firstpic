global class DailyDateUpdate implements Schedulable {
  public static String CRON_EXP = '0 0 0 * * ?';

  global static String scheduleIt() {
    DailyDateUpdate d = new DailyDateUpdate();
    return System.schedule('Daily Date Update', CRON_EXP, d);
  }

  global void execute(SchedulableContext sc) {
    List<Account> acct_list = new List<Account>();
    for (Account a : [SELECT Id, Today__c FROM Account]) {
      a.Today__c = date.today();
      acct_list.add(a);
    }
    try {
      update acct_list;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }
}
