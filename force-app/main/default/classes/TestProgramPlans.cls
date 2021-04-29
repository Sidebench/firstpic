@isTest
public class TestProgramPlans {
  static testMethod void testListAndDetailsPages() {
    system.test.startTest();
    Date dt = date.today();

    Account no = new Account(
      EIN__c = '00-7654321',
      Name = 'National Congress of American Indians',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert no;

    Account lo = new Account(
      EIN__c = '00-2837563',
      National_Organization__c = no.Id,
      Name = 'Local',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert lo;

    Program_Plan__c pp1 = new Program_Plan__c(Organization__c = lo.Id);
    insert pp1;

    Program_Plan__c pp2 = new Program_Plan__c(
      Organization__c = lo.Id,
      Biggest_Issue_Organization_is_Facing__c = 'test',
      How_Funds_Utilized__c = 'test',
      Has_Needs_Assessment__c = false,
      Has_Strategic_Plan__c = false,
      Areas_of_Service__c = 'Other',
      Current_Program_Description__c = 'test',
      Equipment_and_Supplies__c = 'test',
      Responsibilities__c = 'test',
      Able_to_Recruit__c = 'test',
      Other_Challenges__c = 'test'
    );
    insert pp2;

    List<Program_Plan__c> plans = new List<Program_Plan__c>();
    for (Integer i = 0; i < 50; i++) {
      Program_Plan__c pp = new Program_Plan__c(Organization__c = lo.Id);
      plans.add(pp);
    }
    insert plans;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Three'];
    Contact noc = new Contact(
      accountId = no.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com',
      Role__c = 'CEO'
    );
    insert noc;
    User nou = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p.Id,
      UserName = 'test1@qerjda.com',
      Contact = noc,
      ContactId = noc.Id
    );
    insert nou;

    System.runAs(nou) {
      system.test.setCurrentPageReference(
        new PageReference('Page.ProgramPlans')
      );
      ProgramPlansCtrl ctrl1 = new ProgramPlansCtrl();
      ctrl1.getLists();
      ctrl1.next();
      ctrl1.previous();
      ctrl1.last();

      // Test with empty program plan
      system.test.setCurrentPageReference(
        new PageReference(
          'Page.ProgramPlan?orgId=' +
          lo.Id +
          'planId=' +
          pp1.Id
        )
      );
      ProgramPlanCtrl ctrl2 = new ProgramPlanCtrl();
      ctrl2.updatePlan();
      ctrl2.submit();
      ctrl2.approve();
      ctrl2.sendBack();

      // Test with completed program plan
      ctrl2.plan = pp2;
      ctrl2.updatePlan();
      ctrl2.submit();
      ctrl2.approve();
      ctrl2.sendBack();

      ProgramPlanClass ctrl3 = new ProgramPlanClass();
      ctrl3.getPlan(pp1.Id);
    }
  }
}
