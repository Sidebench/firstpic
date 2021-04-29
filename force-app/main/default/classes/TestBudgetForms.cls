@isTest
public class TestBudgetForms {
  static testMethod void test() {
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
      RecordTypeId = rtId1
    );
    insert a;

    Grant__c ng = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(600),
      Grant_Status__c = 'Approved',
      Name = 'name',
      Project_Description__c = 'National Grant',
      Project_Name__c = 'name',
      Start_Date__c = dt.addDays(-200)
    );
    insert ng;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      National_Grant__c = ng.Id,
      Amount__c = 500000,
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Youth_Served__c = 100,
      Youth_Served_with_Grant_Funding__c = 50,
      Estimated_FTE__c = 200
    );
    insert g;

    Budget_Item__c bi1 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId2,
      Name = 'Test Item',
      Title__c = 'Test Title',
      Category__c = 'Test Cat',
      Selected__c = true,
      Is_Hourly__c = true,
      Hourly_Rate__c = 20,
      New_Item_Budget__c = 200,
      Projected_Grant_Hours_Per_Week__c = 30,
      Projected_Hours_Per_Week__c = 40,
      Projected_Percent_Time_on_Grant__c = .75,
      Medical__c = 100,
      Dental__c = 100,
      Short_Term_Disability__c = 100,
      SUTA__c = 100,
      Long_Term_Disability__c = 100,
      Other_Benefits__c = 100,
      Effective_Date__c = dt.addDays(-100),
      Factor_Type__c = 'TCS'
    );
    insert bi1;

    Budget_Item__c bi2 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId2,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = false,
      Factor_Type__c = 'FTE',
      Monthly_Rate__c = 1000,
      New_Item_Budget__c = 4321,
      Projected_Grant_Hours_Per_Week__c = 30,
      Projected_Hours_Per_Week__c = 40,
      Projected_Percent_Time_on_Grant__c = .75,
      Medical__c = 100,
      Dental__c = 100,
      Short_Term_Disability__c = 100,
      SUTA__c = 100,
      Long_Term_Disability__c = 100,
      Other_Benefits__c = 100
    );
    insert bi2;

    Budget_Item__c bi3 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId2,
      Name = 'Benefits',
      Category__c = 'Test Cat',
      Selected__c = false,
      Item_Budget__c = 1234,
      New_Item_Budget__c = 200,
      Factor_Type__c = 'TCS',
      Monthly_Rate__c = 1000,
      Projected_Grant_Hours_Per_Week__c = 30,
      Projected_Hours_Per_Week__c = 40,
      Projected_Percent_Time_on_Grant__c = .75,
      Medical__c = 100,
      Dental__c = 100,
      Short_Term_Disability__c = 100,
      SUTA__c = 100,
      Long_Term_Disability__c = 100,
      Other_Benefits__c = 100
    );
    insert bi3;

    Budget_Item__c bi4 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId3,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = false,
      New_Rate__c = 100,
      New_Item_Budget__c = 200,
      Factor_Type__c = 'TCS'
    );
    insert bi4;

    Budget_Item__c bi5 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId3,
      Name = 'Test Item',
      Selected__c = true,
      Category__c = 'Test Cat 2',
      Factor_Type__c = 'Other',
      Item_Note__c = 'test',
      New_Item_Budget__c = 200,
      Other_Factor_Percent__c = 10
    );
    insert bi5;

    Budget_Item__c bi6 = new Budget_Item__c(
      Grant__c = g.Id,
      RecordTypeId = rtId3,
      Name = 'Test Item',
      New_Rate__c = 100,
      Factor_Type__c = 'FTE'
    );
    insert bi6;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test123@example.com',
      accountId = a.Id
    );
    insert c1;
    User u = new User(
      Alias = 'testu',
      Email = 'test123@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p.Id,
      UserName = 'test1232@example.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u;

    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'NPAL Level Three'];
    Contact c2 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'newtest@example.com',
      accountId = a.Id
    );
    insert c2;
    User u2 = new User(
      Alias = 'testu',
      Email = 'newtest@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p2.Id,
      UserName = 'newtest1@asdfawer.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;

    //        System.runAs(u) {
    System.Test.setCurrentPageReference(
      new PageReference('Page.BBBSBudgetPersonnel')
    );
    System.currentPageReference().getParameters().put('GrantID', g.Id);
    BudgetPersonnelCtrl ctrl1 = new BudgetPersonnelCtrl();
    ctrl1.getLists();
    ctrl1.duration = 600;
    /*
        BudgetPersonnelCtrl.itemClass ic1 = new BudgetPersonnelCtrl.itemClass('', 0, bi1);
        BudgetPersonnelCtrl.itemClass ic2 = new BudgetPersonnelCtrl.itemClass('', 1, bi2);
        BudgetPersonnelCtrl.itemClass ic3 = new BudgetPersonnelCtrl.itemClass('', 1, bi3);
        ctrl1.labor_list.add(ic1);
        ctrl1.labor_list.add(ic2);
        ctrl1.newLabor_list.add(ic3);
		*/
    ctrl1.laborCount = 2;
    ctrl1.addItem();
    ctrl1.addItem();
    ctrl1.updateAmounts();
    ctrl1.bulkAction = 'disable';
    ctrl1.updateSelected();
    ctrl1.deleteItems();
    ctrl1.saveAndContinue();
    ctrl1.saveAndExit();
    ctrl1.laborNotesPopup();
    ctrl1.laborNotesPopup();
    ctrl1.ratePopup();
    ctrl1.ratePopup();
    ctrl1.newLaborNotesPopup();
    ctrl1.newLaborNotesPopup();

    System.Test.setCurrentPageReference(
      new PageReference('Page.BBBSBudgetExpenses')
    );
    System.currentPageReference().getParameters().put('GrantID', g.Id);
    BudgetExpensesCtrl ctrl2 = new BudgetExpensesCtrl();
    //BudgetExpensesCtrl.itemClass ic3 = new BudgetExpensesCtrl.itemClass(0, bi2);
    //BudgetExpensesCtrl.itemClass ic4 = new BudgetExpensesCtrl.itemClass(1, bi4);
    ctrl2.addItem();
    List<Budget_Item__c> bi_list = new List<Budget_Item__c>();
    bi_list.add(bi5);
    bi_list.add(bi6);
    ctrl2.expense_map.put('test', bi_list);
    ctrl2.portalName = '';
    ctrl2.addItem();
    ctrl2.addItem();
    for (Budget_Item__c bi : ctrl2.newExpense_list) {
      bi.New_Item_Budget__c = 100;
      bi.New_Rate__c = 100;
    }
    ctrl2.updateAmounts();
    ctrl2.selectedExpense = 1;
    ctrl2.deleteItems();
    ctrl2.previous();
    ctrl2.submit();
    ctrl2.bulkAction = 'disable';
    ctrl2.updateSelected();
    List<List<Budget_Item__c>> expense_list = ctrl2.expense_map.values();
    for (Budget_Item__c bi : expense_list.get(0)) {
      bi.Selected__c = true;
    }
    ctrl2.bulkAction = 'enable';
    ctrl2.updateSelected();
    for (Budget_Item__c bi : expense_list.get(0)) {
      bi.Selected__c = true;
    }
    ctrl2.bulkAction = 'delete';
    ctrl2.updateSelected();
    ctrl2.deleteAtt();
    ctrl2.expenseNotesPopup();
    ctrl2.expenseNotesPopup();
    ctrl2.newExpenseNotesPopup();
    ctrl2.newExpenseNotesPopup();
    ctrl2.attPopup();
    ctrl2.attPopup();
    ctrl2.saveAndExit();

    g.Use_Indirect_Rate__c = 'Yes';
    g.Indirect_Rate__c = 10;
    g.Youth_Served_Percent__c = 75;
    g.Estimated_FTE__c = 50;
    update g;
    ctrl2.errorMessage = '';
    ctrl2.submit();

    System.runAs(u) {
      System.Test.setCurrentPageReference(
        new PageReference('Page.NPALBudgetPersonnel')
      );
      System.currentPageReference().getParameters().put('GrantID', g.Id);
      BudgetPersonnelCtrl ctrl3 = new BudgetPersonnelCtrl();
      ctrl3.duration = 600;
      ctrl3.portalName = 'NPAL';
      ctrl3.laborCount = 2;
      ctrl3.addItem();
      ctrl3.addItem();
      ctrl3.updateAmounts();
      ctrl3.bulkAction = 'delete';
      ctrl3.updateSelected();
      for (Budget_Item__c bi : ctrl3.labor_list) {
        bi.Selected__c = true;
      }

      Budget_Item__c bi = new Budget_Item__c(
        Grant__c = g.Id,
        RecordTypeId = rtId2,
        Name = 'Test Item',
        Is_Hourly__c = true,
        Hourly_Rate__c = 20,
        Projected_Grant_Hours_Per_Week__c = 30,
        Projected_Hours_Per_Week__c = 40,
        Number_of_Weeks_on_Grant__c = 10
      );
      ctrl3.newLabor_list.add(bi);
      ctrl3.updateAmounts();
      ctrl3.bulkAction = 'disable';
      ctrl3.updateSelected();
      ctrl3.deleteItems();
      ctrl3.saveAndContinue();
      ctrl3.saveAndExit();
      ctrl3.laborNotesPopup();
      ctrl3.laborNotesPopup();
      ctrl3.ratePopup();
      ctrl3.ratePopup();
      ctrl3.newLaborNotesPopup();
      ctrl3.newLaborNotesPopup();
      //        }
    }
  }
}
