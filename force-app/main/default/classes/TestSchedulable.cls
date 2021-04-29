@isTest
class TestSchedulable {
  public static CronTrigger fetchCronTrigger(String jobId) {
    return [
      SELECT CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE Id = :jobId
    ];
  }

  static testMethod void testCreateMonthlyPALogs() {
    Account no = new Account(
      EIN__c = '00-2947562',
      Name = 'National Congress of American Indians',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert no;

    Account lo = new Account(
      EIN__c = '00-2938746',
      National_Organization__c = no.Id,
      Name = 'Local Organization',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert lo;

    Account site = new Account(
      EIN__c = '00-2568462',
      National_Organization__c = no.Id,
      Local_Organization__c = lo.Id,
      Name = 'Site',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert site;

    Grant__c grant = new Grant__c(
      Account__c = no.Id,
      Name = 'name',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert grant;

    Grant__c subgrant = new Grant__c(
      Account__c = lo.Id,
      Name = 'name',
      National_Grant__c = grant.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert subgrant;

    System.Test.startTest();

    String jobId = System.schedule(
      '_unittest_scheduled_: 001',
      CreateMonthlyPALogs.CRON_EXP,
      new CreateMonthlyPALogs()
    );

    CronTrigger ct = fetchCronTrigger(jobId);

    System.assertEquals(
      CreateMonthlyPALogs.CRON_EXP,
      ct.CronExpression,
      'Did not get the same Cron Expression back'
    );
    System.assertEquals(
      0,
      ct.TimesTriggered,
      'The job has been run and should not have'
    );

    System.Test.stopTest();
  }

  static testMethod void testSendReimbursementReminderEmail() {
    Account no = new Account(
      EIN__c = '00-2947562',
      Name = 'Ripken',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert no;

    Account lo = new Account(
      EIN__c = '00-2938746',
      National_Organization__c = no.Id,
      Name = 'Local Organization',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert lo;

    Grant__c grant = new Grant__c(
      Account__c = no.Id,
      Name = 'name',
      Program_Coordinator_Email__c = 'test@test.com',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert grant;

    Grant__c subgrant = new Grant__c(
      Account__c = lo.Id,
      Name = 'name',
      National_Grant__c = grant.Id,
      Is_Active__c = true,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert subgrant;

    System.Test.startTest();

    String jobId = System.schedule(
      '_unittest_scheduled_: 001',
      SendReimbursementReminderEmail.CRON_EXP,
      new SendReimbursementReminderEmail()
    );

    CronTrigger ct = fetchCronTrigger(jobId);

    System.assertEquals(
      SendReimbursementReminderEmail.CRON_EXP,
      ct.CronExpression,
      'Did not get the same Cron Expression back'
    );
    System.assertEquals(
      0,
      ct.TimesTriggered,
      'The job has been run and should not have'
    );

    System.Test.stopTest();
  }

  static testMethod void testUpdateAccountRelatedContactFields() {
    Account lo = new Account(
      Name = 'Local Organization',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert lo;

    Account site = new Account(
      Local_Organization__c = lo.Id,
      Name = 'Site',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId()
    );
    insert site;

    Contact ceo = new Contact(Account = lo, LastName = 'CEO');
    insert ceo;

    Contact dod = new Contact(Account = lo, LastName = 'DOD');
    insert dod;

    Contact pc = new Contact(Account = lo, LastName = 'PC');
    insert pc;

    lo.CEO__c = ceo.Id;
    lo.DOD__c = dod.Id;
    lo.Program_Coordinator__c = pc.Id;
    update lo;

    System.Test.startTest();

    UpdateAccountRelatedContactFields sh1 = new UpdateAccountRelatedContactFields();
    String sch = '0 0 23 * * ?';
    system.schedule('Test UpdateAccountRelatedContactFields', sch, sh1);

    System.Test.stopTest();
  }
}
