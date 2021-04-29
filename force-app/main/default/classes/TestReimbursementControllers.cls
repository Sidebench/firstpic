@isTest
public class TestReimbursementControllers {
  static testMethod void test1() {
    Date dt = Date.today();

    Account na = new Account(
      EIN__c = '98-3846892',
      Name = 'National',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert na;

    Id aId = na.Id;

    Account[] accts = [
      SELECT Id
      FROM Account
      WHERE RecordType.Name = 'National Organization'
    ];
    system.debug('accts = ' + accts);

    if (accts.size() > 0) {
      aId = accts[0].Id;
    }
    Account a = new Account(
      National_Organization__c = aId,
      EIN__c = '98-7654321',
      Name = 'Local',
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
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a;

    Grant__c natgrant = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert natgrant;

    Grant__c grant = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt,
      National_Grant__c = natgrant.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert grant;

    Budget_Item__c bi1 = new Budget_Item__c(
      Grant__c = grant.Id,
      Name = 'Test Item',
      Category__c = 'Travel',
      Selected__c = true,
      New_Item_Budget__c = 11000,
      Item_Budget__c = 10000,
      New_Rate__c = 10,
      Mileage_Rate__c = 1.123,
      Type__c = 'Mileage',
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId()
    );
    insert bi1;

    Budget_Item__c bi2 = new Budget_Item__c(
      Grant__c = grant.Id,
      Name = 'Test Item',
      Category__c = 'Test Cat 2',
      Selected__c = true,
      New_Rate__c = 10,
      Rate__c = 10,
      Item_Budget__c = 10000,
      Is_Hourly__c = true,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Labor')
        .getRecordTypeId()
    );
    insert bi2;

    Budget_Item__c bi3 = new Budget_Item__c(
      Grant__c = grant.Id,
      Name = 'Test Item',
      Category__c = 'Test Cat',
      Selected__c = true,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId()
    );
    insert bi3;

    Reimbursement_Request__c r1 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt.addDays(-100),
      Status__c = 'Pending First Approval',
      Total_FTE_at_Affiliate__c = 50,
      Approved_Amount__c = 1000,
      Drawdown_Status__c = 'In Report',
      Report_Id__c = 'test',
      Modification_Last_Submitted_Date__c = dt,
      EFT__c = 'test',
      Number_of_Pay_Periods__c = 2
    );
    insert r1;

    Reimbursement_Request__c r2 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Request_Date__c = dt,
      Status__c = 'Incomplete',
      Total_FTE_at_Affiliate__c = 50,
      Approved_Amount__c = 1000,
      Youth_Served__c = 10,
      Youth_Served_with_Grant_Funding__c = 5,
      Drawdown_Status__c = 'Drawndown',
      Report_Id__c = 'test'
    );
    insert r2;

    Reimbursement_Request__c r3 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Status__c = 'Paid',
      Drawdown_Status__c = 'Drawndown',
      Paid_Date__c = dt
    );
    insert r3;

    Reimbursement_Request__c r4 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Status__c = 'Pending First Approval'
    );
    insert r4;

    Reimbursement_Request__c r5 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Status__c = 'Pending Second Approval'
    );
    insert r5;

    Reimbursement_Request__c r6 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Status__c = 'Pending Final Approval'
    );
    insert r6;

    Reimbursement_Request__c r7 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Status__c = 'Incomplete'
    );
    insert r7;

    Reimbursement_Request__c r8 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Status__c = 'Denied'
    );
    insert r8;

    Reimbursement_Request__c r9 = new Reimbursement_Request__c(
      Grant__c = grant.Id,
      Status__c = 'Approved'
    );
    insert r9;

    Reimbursement_Item__c ri1 = new Reimbursement_Item__c(
      Reimbursement_Request__c = r1.Id,
      Budget_Item__c = bi1.Id,
      RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
        .get('Labor')
        .getRecordTypeId(),
      Item_Note__c = 'test',
      Response__c = 'test',
      Quantity__c = 2,
      Quantity_Towards_Grant__c = 1,
      Rate__c = 10,
      FICA__c = 10,
      Medical__c = 10,
      Dental__c = 10,
      Short_Term_Disability__c = 10,
      Long_Term_Disability__c = 10,
      Life__c = 10,
      Other_Benefits__c = 10,
      Type__c = 'Fringe'
    );
    insert ri1;

    Reimbursement_Item__c ri2 = new Reimbursement_Item__c(
      Reimbursement_Request__c = r1.Id,
      Budget_Item__c = bi1.Id,
      RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
        .get('Labor')
        .getRecordTypeId(),
      Item_Note__c = 'test',
      Response__c = 'test',
      Quantity__c = 100,
      Rate__c = 10,
      Percent_Towards_Grant__c = .50,
      Requested_Amount__c = 100,
      Type__c = 'Personnel',
      Reimbursement_Item__c = ri1.Id,
      Pay_Period__c = 1
    );
    insert ri2;

    Reimbursement_Item__c ri5 = new Reimbursement_Item__c(
      Reimbursement_Request__c = r1.Id,
      Budget_Item__c = bi1.Id,
      RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
        .get('Labor')
        .getRecordTypeId(),
      Item_Note__c = 'test',
      Response__c = 'test',
      Quantity__c = 100,
      Rate__c = 10,
      Percent_Towards_Grant__c = .50,
      Requested_Amount__c = 100,
      Type__c = 'Personnel',
      Reimbursement_Item__c = ri1.Id,
      Pay_Period__c = 1
    );
    insert ri5;

    Reimbursement_Item__c ri3 = new Reimbursement_Item__c(
      Reimbursement_Request__c = r1.Id,
      Budget_Item__c = bi1.Id,
      RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId(),
      Item_Note__c = 'test',
      Response__c = 'test',
      Quantity__c = 100,
      Rate__c = 10,
      Percent_Towards_Grant__c = .50,
      Requested_Amount__c = 100
    );
    insert ri3;

    Reimbursement_Item__c ri4 = new Reimbursement_Item__c(
      Reimbursement_Request__c = r1.Id,
      Budget_Item__c = bi1.Id,
      RecordTypeId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId(),
      Item_Note__c = 'test',
      Response__c = 'test',
      Quantity__c = 100,
      Mileage_Rate__c = 1.123,
      Percent_Towards_Grant__c = .50,
      Requested_Amount__c = 100,
      Type__c = 'Mileage'
    );
    insert ri4;

    Blob bodyBlob1 = Blob.valueOf('Attachment Test Body');
    Attachment pd = new Attachment(
      Name = 'Payroll',
      body = bodyBlob1,
      parentId = r1.id
    );
    insert pd;

    Attachment ts = new Attachment(
      Name = 'Timesheet',
      body = bodyBlob1,
      parentId = r1.id
    );
    insert ts;

    Attachment ben = new Attachment(
      Name = 'Benefits',
      body = bodyBlob1,
      parentId = r1.id
    );
    insert ben;

    Attachment gl = new Attachment(
      Name = 'General Ledger',
      body = bodyBlob1,
      parentId = r1.id
    );
    insert gl;

    Attachment att1 = new Attachment(
      Name = 'Item Att',
      body = bodyBlob1,
      parentId = ri3.id
    );
    insert att1;

    Attachment att2 = new Attachment(
      Name = 'Item Att',
      body = bodyBlob1,
      parentId = ri3.id
    );
    insert att2;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'newtest@example.com',
      accountId = a.Id
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'newtest@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p.Id,
      UserName = 'newtest1@asdfawer.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    a.Primary_Approver__c = c1.Id;
    update a;

    System.Test.startTest();
    System.runAs(u1) {
      System.Test.setCurrentPageReference(
        new PageReference('Page.RequestForm')
      );
      System.currentPageReference().getParameters().put('GrantID', grant.Id);
      System.currentPageReference().getParameters().put('RequestID', r2.Id);
      RequestFormController ctrl1 = new RequestFormController();
      ctrl1.factorConfirm = false;
      ctrl1.portalName = 'BBBS';
      ctrl1.next();
      ctrl1.factorConfirm = true;
      r2.Youth_Served__c = null;
      ctrl1.next();
      r2.Youth_Served__c = 100;
      r2.Youth_Served_with_Grant_Funding__c = 0;
      ctrl1.next();
      r2.Youth_Served_with_Grant_Funding__c = 50;
      r2.Total_FTE_at_Affiliate__c = 0;
      ctrl1.next();
      r2.Total_FTE_at_Affiliate__c = 1000;
      ctrl1.next();
      ctrl1.cancel();

      System.Test.setCurrentPageReference(
        new PageReference('Page.RequestPersonnelForm')
      );
      System.currentPageReference().getParameters().put('GrantID', grant.Id);
      System.currentPageReference().getParameters().put('RequestID', r1.Id);
      RequestPersonnelFormController ctrl2 = new RequestPersonnelFormController();
      ctrl2.getLists();
      ctrl2.previous();
      ctrl2.saveAndContinue();
      ctrl2.saveAndExit();
      ctrl2.laborNotesPopup();
      ctrl2.deleteAtt();
      ctrl2.attPopup();
      ctrl2.attPopup();

      System.Test.setCurrentPageReference(
        new PageReference('Page.RequestExpensesForm')
      );
      System.currentPageReference().getParameters().put('RequestID', r1.Id);
      RequestExpensesFormController ctrl3 = new RequestExpensesFormController();
      ctrl3.getLists();
      ctrl3.previous();
      ctrl3.saveAndExit();
      ctrl3.submit();
      ctrl3.deleteAtt();
      ctrl3.deleteItemAtt();
      ctrl3.attPopup();
      ctrl3.attPopup();
      ctrl3.itemAttPopup();
      ctrl3.itemAttPopup();
      ctrl3.expenseNotesPopup();
      ctrl3.expenseNotesPopup();

      System.Test.setCurrentPageReference(
        new PageReference('Page.ReimbursementList')
      );
      System.currentPageReference()
        .getParameters()
        .put('type', 'pendingapproval');
      ReimbursementListCtrl ctrl4 = new ReimbursementListCtrl();
      ctrl4.getLists();
      ctrl4.listType = 'completed';
      ctrl4.getLists();

      System.Test.setCurrentPageReference(
        new PageReference('Page.ReimbursementDetails')
      );
      System.currentPageReference().getParameters().put('RequestID', r1.Id);
      ReimbursementDetailsController ctrl5 = new ReimbursementDetailsController();
      ctrl5.init();
      ctrl5.laborNotesPopup();
      ctrl5.laborNotesPopup();
      ctrl5.requestNotesPopup();
      ctrl5.requestNotesPopup();
      ctrl5.expenseNotesPopup();
      ctrl5.expenseNotesPopup();
      ctrl5.deleteRequestPopup();
      ctrl5.deleteRequestPopup();
      ctrl5.sendBackToLevelOne();
      ctrl5.sendBackToLevelTwo();
      ctrl5.sendBackPopup();
      ctrl5.sendBackPopup();
      ctrl5.denyPopup();
      ctrl5.denyPopup();
      ctrl5.approvePopup();
      ctrl5.approvePopup();
      ctrl5.save();
      ctrl5.saveAndClose();
      ctrl5.sendBack();
      ctrl5.denyRequest();
      ctrl5.approveRequest();
      ctrl5.editRequest();
      ctrl5.deleteRequest();

      System.Test.setCurrentPageReference(
        new PageReference('Page.DrawdownReport')
      );
      System.currentPageReference().getParameters().put('GrantID', natgrant.Id);
      DrawdownReportCtrl ctrl6 = new DrawdownReportCtrl();
      ctrl6.getLists();
      ctrl6.startDate = dt.addDays(-100);
      ctrl6.endDate = dt.addDays(100);
      ctrl6.selectAllApproved();
      ctrl6.selectAllApproved();
      ctrl6.selectAllInReport();
      ctrl6.selectAllInReport();
      ctrl6.createReport();
      ctrl6.updateReport();
      ctrl6.completeDrawdown();
      ctrl6.processEFT();
      ctrl6.saveAttach();
      ctrl6.ReportId = 'test';
      ctrl6.getLists();

      ReimbursementClass rc = new ReimbursementClass();
      rc.getRequest(r1.Id);
      rc.deleteRequest(r1);

      //Test.setCurrentPageReference(new PageReference('Page.DrawdownReport'));
      //DrawdownReportCtrl ctrl8 = new DrawdownReportCtrl();
    }
    system.Test.stopTest();
  }

  static testMethod void test2() {
    Date dt = Date.today();

    Account na = new Account(
      EIN__c = '98-3846892',
      Name = 'National',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert na;
    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'BBBSA Level Three'];
    Contact c2 = new Contact(
      lastName = 'Contact',
      firstName = 'Test2',
      Email = 'newtest2@example.com',
      AccountId = na.Id
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
      UserName = 'newtest2@asdfasd.com',
      Contact = c2,
      ContactId = c2.Id
    );
    insert u2;
    system.Test.startTest();
    System.runAs(u2) {
      System.Test.setCurrentPageReference(
        new PageReference('Page.ReimbursementDashboard')
      );
      ReimbursementDashboardCtrl ctrl7 = new ReimbursementDashboardCtrl();
      ctrl7.testInnerClasses();
    }
    system.Test.stopTest();
  }

  static testMethod void testReimbursementCtrl() {
    Date dt = Date.today();

    Account na = new Account(
      EIN__c = '98-3846892',
      Name = 'National',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert na;

    Account a = new Account(
      National_Organization__c = na.Id,
      Name = 'Local',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a;

    Grant__c ng = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      End_Date__c = dt.addDays(30),
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      Project_Description__c = 'description test',
      Project_Name__c = 'name',
      Start_Date__c = dt,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Grant')
        .getRecordTypeId()
    );
    insert ng;

    Grant__c sg = new Grant__c(
      Account__c = a.Id,
      Amount__c = 500000,
      Grant_Status__c = 'Pending Review',
      Name = 'name',
      National_Grant__c = ng.Id,
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert sg;

    Budget_Item__c bi1 = new Budget_Item__c(
      Grant__c = sg.Id,
      Name = 'Test Item 1',
      New_Rate__c = 10,
      Rate__c = 10,
      Item_Budget__c = 10000,
      Is_Hourly__c = true,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Labor')
        .getRecordTypeId()
    );
    insert bi1;

    Budget_Item__c bi2 = new Budget_Item__c(
      Grant__c = sg.Id,
      Name = 'Test Item 2',
      New_Rate__c = 10,
      Rate__c = 10,
      Item_Budget__c = 10000,
      Is_Hourly__c = false,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Labor')
        .getRecordTypeId()
    );
    insert bi2;

    Budget_Item__c bi3 = new Budget_Item__c(
      Grant__c = sg.Id,
      Name = 'Test Item 3',
      Category__c = 'Travel',
      Selected__c = true,
      New_Item_Budget__c = 11000,
      Item_Budget__c = 10000,
      New_Rate__c = 10,
      Mileage_Rate__c = 1.123,
      Type__c = 'Mileage',
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId()
    );
    insert bi3;

    Budget_Item__c bi4 = new Budget_Item__c(
      Grant__c = sg.Id,
      Name = 'Test Item 4',
      Category__c = 'Test Cat',
      Selected__c = true,
      RecordTypeId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName()
        .get('Expense')
        .getRecordTypeId()
    );
    insert bi4;

    List<Reimbursement_Request__c> rrs = new List<Reimbursement_Request__c>();
    for (Integer i = 0; i < 100; i++) {
      Reimbursement_Request__c rr = new Reimbursement_Request__c(
        Grant__c = sg.Id,
        Status__c = 'Approved',
        Drawdown_Status__c = 'Drawndown',
        Report_Id__c = 'test'
      );
      rrs.add(rr);
    }
    insert rrs;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'TRAIL Level Three'];
    Contact c1 = new Contact(
      lastName = 'Contact',
      firstName = 'Test',
      Email = 'newtest@example.com',
      accountId = na.Id
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'newtest@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p.Id,
      UserName = 'newtest1@asdfawer.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    system.Test.startTest();
    System.runAs(u1) {
      // BEGIN Test ReimbursementCtrl
      System.Test.setCurrentPageReference(
        new PageReference('Page.ReimbursementForm')
      );
      System.currentPageReference().getParameters().put('grantId', sg.Id);
      ReimbursementCtrl ctrl1 = new ReimbursementCtrl();
      ctrl1.getReimbursementCtrl();
      ctrl1.request.Number_of_Pay_Periods__c = 2;
      ctrl1.upsertRequest();
      ctrl1.cancel();

      Budget_Item__c[] bis1 = [
        SELECT Id
        FROM Budget_Item__c
        WHERE Grant__c = :ctrl1.grant.Id AND RecordType.Name = 'Labor'
      ];
      Budget_Item__c[] bis2 = [
        SELECT Id
        FROM Budget_Item__c
        WHERE Grant__c = :ctrl1.grant.Id AND RecordType.Name = 'Expense'
      ];
      Reimbursement_Item__c[] ris1 = [
        SELECT Id
        FROM Reimbursement_Item__c
        WHERE
          Reimbursement_Request__c = :ctrl1.request.Id
          AND Type__c = 'Personnel'
      ];
      Reimbursement_Item__c[] ris2 = [
        SELECT Id
        FROM Reimbursement_Item__c
        WHERE
          Reimbursement_Request__c = :ctrl1.request.Id
          AND Type__c = 'Fringe'
      ];
      Reimbursement_Item__c[] ris3 = [
        SELECT Id
        FROM Reimbursement_Item__c
        WHERE
          Reimbursement_Request__c = :ctrl1.request.Id
          AND RecordType.Name = 'Expense'
      ];
      system.assertEquals(bis1.size() * 2, ris1.size());
      system.assertEquals(bis1.size(), ris2.size());
      system.assertEquals(bis2.size(), ris3.size());

      ctrl1.payPeriod = 1;
      ctrl1.getRequest();
      ctrl1.getPersonnelItems();

      ctrl1.personnel_list[0].Quantity_Towards_Grant__c = 0;
      ctrl1.personnel_list[0].Approved_Salary__c = 0;
      ctrl1.personnel_list[1].Is_Hourly__c = true;
      ctrl1.personnel_list[1].Quantity_Towards_Grant__c = 11;
      ctrl1.personnel_list[1].Quantity__c = 21;
      ctrl1.personnel_list[1].Rate__c = 234;
      ctrl1.personnel_list[1].Approved_Salary__c = 100;
      ctrl1.personnel_list[1].Response__c = 'test';
      ctrl1.updatePersonnelAmounts();
      system.assertEquals(0, ctrl1.personnel_list[0].Requested_Salary__c);
      system.assertEquals(2574, ctrl1.personnel_list[1].Requested_Salary__c);

      ctrl1.savePersonnelAndExit();
      ctrl1.goToPersonnelForm();
      ctrl1.payPeriod = 2;
      ctrl1.previousFromPersonnel();
      ctrl1.nextFromPersonnel();

      ctrl1.getFringe();

      ctrl1.fringe_list[0].Personnel_Requested_Salary__c = 400;
      ctrl1.fringe_list[0].Personnel_Percent_Towards_Grant__c = 50;
      ctrl1.fringe_list[0].FICA_Percent__c = 10;
      ctrl1.fringe_list[0].SUTA_Percent__c = 10;
      ctrl1.fringe_list[0].Workers_Comp_Percent__c = 10;
      ctrl1.fringe_list[0].Retirement_Percent__c = 10;
      ctrl1.fringe_list[0].Other_Percent__c = 10;
      ctrl1.fringe_list[0].Medical_Premium__c = 100;
      ctrl1.fringe_list[0].Dental_Premium__c = 100;
      ctrl1.fringe_list[0].Vision_Premium__c = 100;
      ctrl1.fringe_list[0].Short_Term_Premium__c = 100;
      ctrl1.fringe_list[0].Long_Term_Premium__c = 100;
      ctrl1.fringe_list[0].Life_Premium__c = 100;
      ctrl1.fringe_list[0].Other_Premium__c = 100;
      ctrl1.fringe_list[0].Approved_Benefits__c = 100;
      ctrl1.fringe_list[0].Response__c = 'test';
      ctrl1.updateFringeAmounts();
      Decimal rb = ((.1 * 400) * 5) + ((100 * .5) * 7); // rb = 550
      system.assertEquals(rb, ctrl1.fringe_list[0].Requested_Benefits__c);

      ctrl1.saveFringeAndExit();
      ctrl1.previousFromFringe();
      ctrl1.goToExpensesForm();

      ctrl1.getExpenseItems();
      //system.assert(ctrl1.categories.keySet().contains('Travel'));

      ctrl1.expense_list[0].Type__c = 'Mileage';
      ctrl1.expense_list[0].Quantity__c = 1;
      ctrl1.expense_list[0].Mileage_Rate__c = 123.456;
      ctrl1.expense_list[0].Approved_Amount__c = 0;
      ctrl1.expense_list[0].Response__c = 'test';
      ctrl1.expense_list[1].Type__c = '';
      ctrl1.expense_list[1].Quantity__c = 10;
      ctrl1.expense_list[1].Rate__c = 123.45;
      ctrl1.expense_list[1].Approved_Amount__c = 100;
      ctrl1.expense_list[1].Response__c = 'test';
      ctrl1.updateExpenseAmounts();
      system.assertEquals(123.46, ctrl1.expense_list[0].Requested_Amount__c);
      system.assertEquals(1234.5, ctrl1.expense_list[1].Requested_Amount__c);
      //system.assertEquals(2030.53, ctrl1.totalRequested);

      ctrl1.saveAll();
      ctrl1.saveAndExit();
      ctrl1.saveExpensesAndExit();
      ctrl1.previousFromExpenses();

      ctrl1.selectedItemId = ctrl1.expense_list[0].Id;
      ctrl1.showNotesPopup();
      ctrl1.selectedItem.Item_Note__c = 'test';
      ctrl1.selectedItemType = 'personnel';
      ctrl1.upsertItem();

      ctrl1.hideNotesPopup();
      ctrl1.showSendBackPopup();
      ctrl1.hideSendBackPopup();
      ctrl1.showApprovePopup();
      ctrl1.hideApprovePopup();

      ctrl1.approverLevel = 'Level One';
      ctrl1.approve();
      ctrl1.approverLevel = 'Level Two';
      ctrl1.approve();
      ctrl1.approverLevel = 'Level Three';
      ctrl1.approve();
      ctrl1.approverLevel = 'Level Four';
      ctrl1.approve();

      ctrl1.sendBackTo = 'affiliate';
      ctrl1.sendBack();
      ctrl1.sendBackTo = 'levelone';
      ctrl1.sendBack();
      ctrl1.sendBackTo = 'leveltwo';
      ctrl1.sendBack();
      ctrl1.sendBackTo = 'levelthree';
      ctrl1.sendBack();
      ctrl1.review();
      ctrl1.errorMessage = '';
      ctrl1.submit();
      system.assertEquals('Pending First Approval', ctrl1.request.Status__c);

      ctrl1.approverLevel = 'Finance Admin';
      ctrl1.getRequest();
      ctrl1.getReviewMode();
      system.assertEquals(true, ctrl1.isReviewMode);
      // END Test ReimbursementCtrl

      // BEGIN Test ReimbursementsCtrl
      System.Test.setCurrentPageReference(
        new PageReference('Page.Reimbursements')
      );
      System.currentPageReference().getParameters().put('grantId', sg.Id);
      ReimbursementsCtrl ctrl2 = new ReimbursementsCtrl();
      ctrl2.status = 'Approved';
      ctrl2.grantId = sg.Id;
      ctrl2.getLists();
      ctrl2.next();
      ctrl2.previous();
      ctrl2.last();
      // END Test ReimbursementsCtrl

      // BEGIN Test DrawdownsCtrl
      System.Test.setCurrentPageReference(new PageReference('Page.Drawdowns'));
      System.currentPageReference().getParameters().put('grantID', ng.Id);
      DrawdownsCtrl ctrl3 = new DrawdownsCtrl();
      ctrl3.reportsStartDate = dt.addDays(-100);
      ctrl3.reportsEndDate = dt.addDays(100);
      ctrl3.selectAllApproved();
      ctrl3.selectAllApproved();
      ctrl3.selectAllInReport();
      ctrl3.selectAllInReport();
      ctrl3.createReport();
      ctrl3.removeItems();
      ctrl3.completeDrawdown();
      ctrl3.processEFT();

      ctrl3.approvedFirst();
      ctrl3.approvedNext();
      ctrl3.approvedPrevious();
      ctrl3.approvedLast();

      ctrl3.completedFirst();
      ctrl3.completedNext();
      ctrl3.completedPrevious();
      ctrl3.completedLast();
      // END Test DrawdownsCtrl
    }
    system.Test.stopTest();
  }
}
