@isTest
public class TestGrantControllers {
  static testMethod void test1() {
    Date dt = Date.today();

    ID rtId1 = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Local Organization')
      .getRecordTypeId();
    ID rtId2 = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
      .get('Labor')
      .getRecordTypeId();
    ID rtId3 = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
      .get('Expense')
      .getRecordTypeId();
    Account na = new Account(
      EIN__c = '98-1932745',
      Name = 'Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert na;

    Account a = new Account(
      EIN__c = '98-7654321',
      Name = 'Name',
      Status__c = 'Application Submitted',
      Application_Submitted_Date__c = dt,
      Phone = '5555555555',
      BillingStreet = 'Street',
      BillingCity = 'City',
      BillingState = 'CA',
      BillingPostalCode = '12345',
      Youth_Served__c = 100,
      Number_of_Mentors__c = 10,
      Number_of_Sites__c = 10,
      Names_of_Sites__c = 'Names of Sites',
      RecordTypeId = rtId1,
      National_Organization__c = na.Id
    );
    insert a;

    Grant__c ng = new Grant__c(
      Account__c = na.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt,
      Youth_Served_Percent__c = 25,
      Estimated_FTE__c = 25,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert ng;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt,
      Youth_Served_Percent__c = 25,
      Estimated_FTE__c = 25,
      National_Grant__c = ng.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g;

    Grant__c g2 = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending First Approval',
      Name = 'name',
      National_Grant__c = ng.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g2;

    Grant__c g3 = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Approved',
      Name = 'name',
      National_Grant__c = ng.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g3;

    List<Grant__c> subgrants = new List<Grant__c>();
    for (Integer i = 0; i < 50; i++) {
      Grant__c sg = new Grant__c(
        Account__c = a.Id,
        Amount__c = 500000,
        End_Date__c = dt.addDays(30),
        Grant_Status__c = 'Approved',
        Name = 'name',
        National_Grant__c = ng.Id,
        RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
          .get('Sub-Grant')
          .getRecordTypeId()
      );
      subgrants.add(sg);
    }
    insert subgrants;

    Budget_Item__c bi1 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId2,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = true,
      New_Rate__c = 100,
      New_Item_Budget__c = 200
    );
    insert bi1;

    Budget_Item__c bi2 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId3,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = true,
      Item_Budget__c = 100
    );
    insert bi2;

    Budget_Item__c bi3 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId2,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = true,
      Item_Budget__c = 100
    );
    insert bi3;

    Budget_Item__c bi4 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId3,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = true,
      New_Rate__c = 100,
      New_Item_Budget__c = 200
    );
    insert bi4;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@exampleqwere.com',
      accountId = a.Id
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'test@exampleasdf.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'test@asdfkf.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
    Contact c2 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test@national.com',
      accountId = na.Id
    );
    insert c2;
    User u2 = new User(
      Alias = 'testu',
      Email = 'test@nationaldfgr.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p2.Id,
      UserName = 'test@qweei8r.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;

    System.Test.startTest();
    System.Test.setCurrentPageReference(
      new PageReference('Page.SubGrantDetails')
    );
    System.currentPageReference().getParameters().put('GrantID', g.Id);
    SubGrantDetailsController ctrl1 = new SubGrantDetailsController();
    ctrl1.approveBudget();
    ctrl1.denyBudget();
    ctrl1.saveAndClose();
    ctrl1.sendBack = true;
    ctrl1.sendBack();
    ctrl1.updateNotesPopup();
    ctrl1.sendBackPopup();
    ctrl1.denyPopup();
    ctrl1.saveModification();
    ctrl1.showLaborNotesPopup();
    ctrl1.closeLaborNotesPopup();
    ctrl1.showExpenseNotesPopup();
    ctrl1.closeExpenseNotesPopup();
    ctrl1.cancelBudgetNotesPopup();
    ctrl1.modificationPopup();
    ctrl1.cancelModificationPopup();
    ctrl1.updatePopup();
    ctrl1.cancelUpdatePopup();

    System.runAs(u1) {
      System.Test.setCurrentPageReference(
        new PageReference('Page.GrantDetails')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      GrantDetailsController ctrl2 = new GrantDetailsController();
      ctrl2.init();
      ctrl2.goToReimbursementsList();
      ctrl2.goToReportsList();

      System.Test.setCurrentPageReference(new PageReference('Page.GrantList'));
      GrantListController ctrl3 = new GrantListController();
      ctrl3.goToGrant();
      ctrl3.goToSubGrant();

      System.Test.setCurrentPageReference(new PageReference('Page.Grant'));
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      GrantCtrl ctrl6 = new GrantCtrl();
      ctrl6.getGrants();
      ctrl6.getGrantDetails();
      ctrl6.showCloseGrantPopup();
      ctrl6.closeGrant();
      ctrl6.hideCloseGrantPopup();
    }

    System.runAs(u2) {
      System.Test.setCurrentPageReference(
        new PageReference('Page.SubGrantList')
      );
      SubGrantListCtrl ctrl4 = new SubGrantListCtrl();
      ctrl4.getLists();
      ctrl4.getRelatedGrants();

      System.Test.setCurrentPageReference(new PageReference('Page.SubGrants'));
      SubGrantsCtrl ctrl5 = new SubGrantsCtrl();
      ctrl5.getOptions();
      ctrl5.getLists();
      ctrl5.getStatusOptions();
      ctrl5.next();
      ctrl5.previous();
      ctrl5.last();
    }
    System.Test.stopTest();
  }
}
