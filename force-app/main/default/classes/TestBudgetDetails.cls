@isTest
public class TestBudgetDetails {
  static testMethod void test() {
    Date dt = Date.today();

    Account a = new Account(
      Name = 'Account Name',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a;

    Grant__c ng = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(600),
      Name = 'Grant',
      Start_Date__c = dt.addDays(-200),
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert ng;

    Grant__c sg = new Grant__c(
      Account__c = a.Id,
      National_Grant__c = ng.Id,
      Amount__c = 500000,
      Name = 'Sub-Grant',
      Grant_Status__c = 'Pending Final Approval',
      Youth_Served__c = 100,
      Youth_Served_with_Grant_Funding__c = 50,
      Estimated_FTE__c = 200,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert sg;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Three'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'test123@example.com',
      accountId = a.Id
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'test123@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'test1232@example.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    system.Test.startTest();
    System.runAs(u1) {
      // BEGIN Test BudgetCtrl
      system.Test.setCurrentPageReference(
        new PageReference('Page.BudgetDetails')
      );
      System.currentPageReference().getParameters().put('grantId', sg.Id);
      BudgetCtrl ctrl1 = new BudgetCtrl();
      ctrl1.getBudgetCtrl();
      ctrl1.init();
      ctrl1.durationWks = 52.14;
      system.assertEquals(ctrl1.statusColor, 'text-warning');

      ctrl1.addLaborItem();
      ctrl1.newLaborItem_list[0].Projected_Hours_Per_Week__c = 20;
      ctrl1.newLaborItem_list[0].Projected_Grant_Hours_Per_Week__c = 10;
      ctrl1.newLaborItem_list[0].New_Rate__c = 10;
      ctrl1.newLaborItem_list[0].Is_Hourly__c = true;

      ctrl1.addLaborItem();
      ctrl1.newLaborItem_list[1].Projected_Hours_Per_Week__c = 20;
      ctrl1.newLaborItem_list[1].Projected_Grant_Hours_Per_Week__c = 10;
      ctrl1.newLaborItem_list[1].New_Rate__c = 10000;
      ctrl1.newLaborItem_list[1].Fica_Percent__c = 1;
      ctrl1.newLaborItem_list[1].SUTA_Percent__c = 1;
      ctrl1.newLaborItem_list[1].Workers_Comp_Percent__c = 1;
      ctrl1.newLaborItem_list[1].Retirement_Percent__c = 1;
      ctrl1.newLaborItem_list[1].Other_Percent__c = 1;
      ctrl1.newLaborItem_list[1].Medical_Premium__c = 100;
      ctrl1.newLaborItem_list[1].Dental_Premium__c = 100;
      ctrl1.newLaborItem_list[1].Vision_Premium__c = 100;
      ctrl1.newLaborItem_list[1].Short_Term_Premium__c = 100;
      ctrl1.newLaborItem_list[1].Long_Term_Premium__c = 100;
      ctrl1.newLaborItem_list[1].Life_Premium__c = 100;
      ctrl1.newLaborItem_list[1].Other_Premium__c = 100;

      ctrl1.updateNewLaborAmounts();
      system.assertEquals(
        50,
        ctrl1.newLaborItem_list[0].Projected_Percent_Time_on_Grant__c
      );
      system.assertEquals(5214, ctrl1.newLaborItem_list[0].New_Wages__c);
      system.assertEquals(5000, ctrl1.newLaborItem_list[1].New_Wages__c);
      system.assertEquals(ctrl1.newLaborItem_list.size(), 2);
      ctrl1.savePersonnel();

      ctrl1.addExpenseItem();
      ctrl1.newExpenseItem_list[0].Is_Active__c = true;
      ctrl1.newExpenseItem_list[0].New_Rate__c = 100;
      ctrl1.newExpenseItem_list[0].Quantity__c = 10;

      ctrl1.addMileageItem();
      ctrl1.newExpenseItem_list[1].Type__c = 'Mileage';
      ctrl1.newExpenseItem_list[1].Mileage_Rate__c = 1.123;
      ctrl1.newExpenseItem_list[1].Quantity__c = 1;

      ctrl1.updateNewExpenseAmounts();
      system.assertEquals(
        1000,
        ctrl1.newExpenseItem_list[0].New_Item_Budget__c
      );
      system.assertEquals(
        1.12,
        ctrl1.newExpenseItem_list[1].New_Item_Budget__c
      );
      system.assertEquals(ctrl1.newExpenseItem_list.size(), 2);
      ctrl1.saveExpenses();

      ctrl1.getBudgetItems();

      ctrl1.laborItem_list[0].Projected_Grant_Hours_Per_Week__c = 0;
      ctrl1.updateExistingLaborAmounts();
      ctrl1.updateAllLaborAmounts();
      system.assertEquals(
        0,
        ctrl1.laborItem_list[0].Projected_Percent_Time_on_Grant__c
      );

      ctrl1.laborItem_list[0].Selected__c = true;
      ctrl1.markPersonnelInactive();
      system.assertEquals(ctrl1.laborItem_list[0].New_Wages__c, 0);
      system.assertEquals(ctrl1.laborItem_list[0].New_Fringe_Benefits__c, 0);

      Integer laborSize = ctrl1.laborItem_list.size();
      ctrl1.laborItem_list[0].Selected__c = true;
      ctrl1.deleteLaborItems();
      ctrl1.deleteNewLaborItems();
      ctrl1.deleteExpenseItems();
      ctrl1.deleteNewExpenseItems();
      system.assertEquals(ctrl1.laborItem_list.size(), laborSize - 1);

      ctrl1.expenseItem_list[0].Quantity__c = 0;
      ctrl1.updateExistingExpenseAmounts();
      ctrl1.updateAllExpenseAmounts();
      system.assertEquals(ctrl1.expenseItem_list[0].New_Item_Budget__c, 0);

      ctrl1.expenseItem_list[0].Selected__c = true;
      ctrl1.markExpensesInactive();
      system.assertEquals(ctrl1.expenseItem_list[0].Is_Active__c, false);

      ctrl1.selectedItemId = ctrl1.laborItem_list[0].Id;
      ctrl1.showNotesPopup();
      ctrl1.selectedItem.Item_Note__c = 'test';
      ctrl1.selectedItemType = 'labor';
      ctrl1.upsertItem();
      Budget_Item__c noteTest = [
        SELECT Item_Note__c
        FROM Budget_Item__c
        WHERE Id = :ctrl1.selectedItemId
      ];
      system.assertEquals('test', noteTest.Item_Note__c);

      ctrl1.hideNotesPopup();
      ctrl1.showNewExpenseNotesPopup();
      ctrl1.hideNewExpenseNotesPopup();
      ctrl1.showNewLaborNotesPopup();
      ctrl1.hideNewLaborNotesPopup();
      ctrl1.showSendBackPopup();
      ctrl1.hideSendBackPopup();
      ctrl1.showApprovePopup();
      ctrl1.hideApprovePopup();

      ctrl1.getTotals();
      ctrl1.next();
      ctrl1.previous();
      ctrl1.review();
      ctrl1.submit();
      Grant__c grantTest1 = [
        SELECT Grant_Status__c, Modification_History__c
        FROM Grant__c
        WHERE Id = :ctrl1.grant.Id
      ];
      system.assertEquals('Pending First Approval', grantTest1.Grant_Status__c);
      system.assert(grantTest1.Modification_History__c != null);

      ctrl1.approverLevel = 'Level One';
      ctrl1.approve();
      Grant__c grantTest2 = [
        SELECT Grant_Status__c
        FROM Grant__c
        WHERE Id = :ctrl1.grant.Id
      ];
      system.assertEquals(
        'Pending Second Approval',
        grantTest2.Grant_Status__c
      );

      ctrl1.approverLevel = 'Level Two';
      ctrl1.approve();
      ctrl1.approverLevel = 'Level Three';
      ctrl1.approve();

      ctrl1.sendBackTo = 'levelone';
      ctrl1.sendBack();
      Grant__c grantTest3 = [
        SELECT Grant_Status__c
        FROM Grant__c
        WHERE Id = :ctrl1.grant.Id
      ];
      system.assertEquals('Pending First Approval', grantTest3.Grant_Status__c);
      ctrl1.sendBackTo = 'levelthree';
      ctrl1.sendBack();
      ctrl1.sendBackTo = 'leveltwo';
      ctrl1.sendBack();
      ctrl1.sendBackTo = 'affiliate';
      ctrl1.sendBack();

      ctrl1.createMOU();
      ctrl1.sendFFATA();
      ctrl1.showUpdatePopup();
      ctrl1.updateBudget();
      ctrl1.hideUpdatePopup();
      ctrl1.showCloseGrantPopup();
      ctrl1.closeGrant();
      ctrl1.hideCloseGrantPopup();
      ctrl1.reopenGrant();

      // END Test BudgetCtrl
    }
    system.Test.stopTest();
  }
}
