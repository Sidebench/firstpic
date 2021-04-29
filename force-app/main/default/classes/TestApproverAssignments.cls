@isTest
public class TestApproverAssignments {
  static testMethod void testApproverAssignments() {
    Contact c = new Contact(
      LastName = '11',
      FirstName = 'Test1',
      Is_Primary_Approver__c = true
    );
    insert c;

    Account no = new Account(
      EIN__c = '00-7654321',
      Name = 'Ripken',
      Primary_Approver__c = c.Id,
      Primary_Approver_On_Leave__c = true,
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

    c.AccountId = no.Id;
    update c;

    Grant__c g = new Grant__c(
      Account__c = no.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert g;

    Grant__c sg = new Grant__c(
      Account__c = lo.Id,
      Name = 'sg',
      National_Grant__c = g.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert sg;

    Reimbursement_Request__c r = new Reimbursement_Request__c(
      Grant__c = sg.Id,
      Status__c = 'Incomplete'
    );
    insert r;

    system.Test.startTest();
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Ripken Level Three'];
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
        new PageReference('Page.ApproverAssignments')
      );
      ApproverAssignmentsCtrl ctrl1 = new ApproverAssignmentsCtrl();
      ctrl1.getLists();
      ctrl1.clear();
      ctrl1.removeFromLeave();
      ctrl1.markAllOnLeave();
      ctrl1.save();

      system.test.setCurrentPageReference(
        new PageReference('Page.ApproverReimbursements')
      );
      ApproverDashboardsCtrl ctrl2 = new ApproverDashboardsCtrl();
      ctrl2.getReimbursementLists();
      ctrl2.testInnerClasses();
    }
  }
}
