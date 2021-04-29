public class UpdateDateTodayFields implements Schedulable {
  public void execute(SchedulableContext sc) {
    Date dt = date.today();
    List<Grantee_Report__c> items = [SELECT Today__c FROM Grantee_Report__c];
    for (Grantee_Report__c i : items) {
      i.Today__c = dt;
    }
    try {
      update items;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }
}
