@isTest(SeeAllData=true)
public class TestSertifiController {
  static testMethod void test1() {
    Date dt = Date.today();
    Account a = new Account(
      EIN__c = '98-7654321',
      Name = 'Name',
      Status__c = 'Application Submitted',
      Application_Submitted_Date__c = dt
    );
    insert a;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt,
      Grant_Type__c = 'Badges for Baseball'
    );
    insert g;

    Contact c1 = new Contact(
      AccountId = a.Id,
      FirstName = 'Test1',
      LastName = 'Contact1',
      Email = 'test1@test1.com'
    );
    insert c1;

    Contact c2 = new Contact(
      AccountId = a.Id,
      FirstName = 'Test2',
      LastName = 'Contact2',
      Email = 'test2@test2.com'
    );
    insert c2;

    CreateMOUCtrl mou = new CreateMOUCtrl();
    mou.CreateMOU(c1.Email, c2.Email, g.Id, g.LOA__c);
  }
}
