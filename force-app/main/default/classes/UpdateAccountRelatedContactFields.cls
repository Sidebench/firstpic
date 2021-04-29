public class UpdateAccountRelatedContactFields implements Schedulable {
  public void execute(SchedulableContext sc) {
    List<Account> items = new List<Account>();
    for (Account i : [
      SELECT
        Local_Organization__r.CEO__c,
        CEO__c,
        CEO_Email__c,
        CEO_Email_text__c,
        Local_Organization__r.DOD__c,
        DOD__c,
        DOD_Email__c,
        DOD_Email_text__c,
        Local_Organization__r.Program_Coordinator__c,
        Program_Coordinator__c,
        Program_Coordinator_Email__c,
        Program_Coordinator_Email_text__c
      FROM Account
      WHERE
        Contacts_Need_Updating__c = TRUE
        OR (Local_Organization__r.CEO__c != NULL
        AND CEO__c = NULL)
        OR (CEO_Email__c != NULL
        AND CEO_Email_text__c = NULL)
        OR (Local_Organization__r.DOD__c != NULL
        AND DOD__c = NULL)
        OR (DOD_Email__c != NULL
        AND DOD_Email_text__c = NULL)
        OR (Local_Organization__r.Program_Coordinator__c != NULL
        AND Program_Coordinator__c = NULL)
        OR (Program_Coordinator_Email__c != NULL
        AND Program_Coordinator_Email_text__c = NULL)
    ]) {
      if (i.Local_Organization__r.CEO__c != null && i.CEO__c == null)
        i.CEO__c = i.Local_Organization__r.CEO__c;
      if (i.CEO_Email__c != i.CEO_Email_text__c && i.CEO_Email_text__c != null)
        i.CEO_Email__c = i.CEO_Email_text__c;
      if (i.Local_Organization__r.DOD__c != null && i.DOD__c == null)
        i.DOD__c = i.Local_Organization__r.DOD__c;
      if (i.DOD_Email__c != i.DOD_Email_text__c && i.DOD_Email_text__c != null)
        i.DOD_Email__c = i.DOD_Email_text__c;
      if (
        i.Local_Organization__r.Program_Coordinator__c != null &&
        i.Program_Coordinator__c == null
      )
        i.Program_Coordinator__c = i.Local_Organization__r.Program_Coordinator__c;
      if (
        i.Program_Coordinator_Email__c != i.Program_Coordinator_Email_text__c &&
        i.Program_Coordinator_Email_text__c != null
      )
        i.Program_Coordinator_Email__c = i.Program_Coordinator_Email_text__c;
      items.add(i);
    }
    update items;
  }
}
