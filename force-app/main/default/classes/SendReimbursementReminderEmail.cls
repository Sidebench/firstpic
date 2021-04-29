global class SendReimbursementReminderEmail implements Schedulable {
  public static String CRON_EXP = '0 0 1 1 * ? *';
  private UserClassWithoutSharing ucws = new UserClassWithoutSharing();

  global void execute(SchedulableContext sc) {
    sendEmail();
  }

  public void sendEmail() {
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    List<Task> taskList = new List<Task>();
    User u = ucws.getUser(' WHERE Alias = \'fpadmin\'');
    OrgWideEmailAddress[] owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE Address = 'support@firstpic.org'
    ];
    EmailTemplate template = [
      SELECT Id, Name, Subject, Body
      FROM EmailTemplate
      WHERE Name = 'Ripken Reimbursement Reminder'
    ];

    Integer count = 0;
    for (Grant__c g : [
      SELECT
        Name,
        Account__r.Program_Coordinator__c,
        Account__r.Program_Coordinator__r.Email
      FROM Grant__c
      WHERE
        FirstPic_National_Org_Code__c = 'Ripken'
        AND Is_Active__c = TRUE
        AND Grant_Status__c != 'Closed'
        AND Account__r.Program_Coordinator__c != NULL
        AND Account__r.Program_Coordinator__r.Email != NULL
    ]) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setTargetObjectId(g.Account__r.Program_Coordinator__c);
      email.setTreatTargetObjectAsRecipient(false);
      email.setWhatId(g.Id);
      email.setTemplateId(template.Id);
      String[] toAddresses = new List<String>{
        g.Account__r.Program_Coordinator__r.Email
      };
      email.setToAddresses(toAddresses);
      if (owea.size() > 0) {
        email.setOrgWideEmailAddressId(owea.get(0).Id);
      }
      emailList.add(email);
      count++;

      Task task = new Task(
        OwnerId = u.Id,
        WhatId = g.Id,
        Subject = 'Send Reimbursement Reminder E-mail',
        Priority = 'Normal',
        Status = 'Complete'
      );
      taskList.add(task);
    }
    system.debug(count);

    if (!emailList.isEmpty()) {
      try {
        Messaging.sendEmail(emailList);
        system.debug('Emails sent to: ' + emailList);
        insert taskList;
      } catch (Exception ex) {
        system.debug('Unable to send email to: ' + ex.getStackTraceString());
      }
    }
  }
}
