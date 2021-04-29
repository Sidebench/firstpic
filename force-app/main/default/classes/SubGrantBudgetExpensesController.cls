public with sharing class SubGrantBudgetExpensesController {
}
/*
    public UserClass userClass = new UserClass();
    public User currentUser { get; set; }
    public Account userAcct { get; set; }
    public String userAcctType { get; set; }
    public String portalName { get; set; }
    
    public GrantClass grantClass = new GrantClass();
    public BudgetItemClass budgetItemClass = new BudgetItemClass();
    
    public Account acct { get; set; }
    public ID GrantId { get; set; }
    public Grant__c grant { get; set; }
    public Id expenseId { get; set; }
    public Decimal laborRequestedAmount { get; set; }
    public Decimal expenseRequestedAmount { get; set; }
    public Decimal totalRequestedAmount { get; set; }
    public String errorMessage { get; set; }    
    public Boolean amountError { get; set; } 
    public Boolean displayExpenseNotesPopup { get; set; }
    public Boolean displayNewExpenseNotesPopup { get; set; }
    public Boolean displayAttPopup { get; set; }
    
    public List<SelectOption> categories { get; set; } 
    public List<SelectOption> factorTypes { get; set; } 
    
    public Map<String, List<Budget_Item__c>> expense_map { get; set; }
    public boolean hasExpenses { get; set; }
    public List<itemClass> newExpense_list { get; set; }
    public Integer selectedExpense { get; set; } 
    public Integer expenseCount = 0;
    
    public Attachment att { get; set; }
    public List<Attachment> att_list { get; set; }
    public Id deleteAttId { get; set; }
    
    public Boolean hasReimbursements { get; set; }
    public List<SelectOption> options { get; set; }
    public string bulkAction { get; set; }
    
    // BEGIN Constructor
    public SubGrantBudgetExpensesController () {
        currentUser = userClass.currentUser;
        userAcct = userClass.userAcct;
        userAcctType = userClass.userAcctType;
        portalName = userClass.userProfile;
        
        GrantId = ApexPages.currentPage().getParameters().get('GrantId');  
        expenseId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        
        acct = new Account();
        grant = new Grant__c();
        
        laborRequestedAmount = 0;
        expenseRequestedAmount = 0;
        totalRequestedAmount = 0;
        errorMessage = '';
        amountError = false;
        displayExpenseNotesPopup = false; 
        displayNewExpenseNotesPopup = false; 
        displayAttPopup = false;
            
        newExpense_list = new List<itemClass>();
        expense_map = new Map<String, List<Budget_Item__c>>();
        hasExpenses = false;
        selectedExpense = 0;  
        
        att = new Attachment();
        att_list = new List<Attachment>();
        
        if(GrantID != null) {
            grant = grantClass.getGrant(GrantID);
            system.debug('>>> grant = ' + grant);
            
            for(Attachment a : grant.Attachments) {
                att_list.add(a);
            }
            
            if(grant.Youth_Served_Percent__c == null && grant.Youth_Served_with_Grant_Funding__c > 0 && grant.Youth_Served__c > 0) {
                grant.Youth_Served_Percent__c = grant.Youth_Served_with_Grant_Funding__c / grant.Youth_Served__c;
            }      
            acct = [SELECT ID, Name, RecordType.Name FROM Account WHERE ID = :grant.Account__r.Id];
            
            Reimbursement_Request__c[] requests = [SELECT Id FROM Reimbursement_Request__c WHERE Grant__r.Id = :GrantId];
            if(requests.size() > 0) {
                hasReimbursements = true;
            }
        }
        
        categories = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult1 = Budget_Item__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for(Schema.PicklistEntry f1 : ple1)
        {
            categories.add(new SelectOption(f1.getLabel(), f1.getValue()));
        }
        
        factorTypes = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult2 = Budget_Item__c.Factor_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        for(Schema.PicklistEntry f2 : ple2)
        {
            factorTypes.add(new SelectOption(f2.getLabel(), f2.getValue()));
        }
        
        options = new List<SelectOption>();
        options.add(new SelectOption('','Select an Action'));
        options.add(new SelectOption('delete','Delete'));
        options.add(new SelectOption('disable','Mark Inactive'));
        //options.add(new SelectOption('enable','Mark Active'));
    }
    // END Constructor
    
    // BEGIN getLists
    public void getLists() {
        expense_map.clear();
        laborRequestedAmount = 0;
        expenseRequestedAmount = 0;
        totalRequestedAmount = 0;
        
        for(itemClass i : newExpense_list) {
            if(i.item.New_Item_Budget__c != null) {
                expenseRequestedAmount += i.item.New_Item_Budget__c;
            }
        }
        BudgetItemClass bic = new BudgetItemClass();
        for(Budget_Item__c bi : bic.getBudgetItems(GrantId)) {
            if(bi.RecordType.Name == 'Expense') {
                if(bi.Is_Active__c == false && bi.Total_Approved_Amount__c != null) {
                    expenseRequestedAmount += bi.Total_Approved_Amount__c;
                }
                if(bi.New_Item_Budget__c == null && bi.Item_Budget__c != null) {
                    bi.New_Item_Budget__c = bi.Item_Budget__c;
                }
                if(bi.New_Rate__c == null) {
                    if(bi.Total_Expense__c != null) {
                        bi.New_Rate__c = bi.Total_Expense__c;
                    } else if(bi.Monthly_Rate__c != null) {
                        bi.New_Rate__c = bi.Monthly_Rate__c;
                    }
                }
                if(bi.New_Item_Budget__c != null) {
                    if(bi.New_Rate__c > 0) {
                        if(grant.Use_Indirect_Rate__c == 'Yes') {
                            bi.New_Item_Budget__c = bi.New_Rate__c;//(bi.New_Rate__c * grant.Indirect_Rate__c / 100).setScale(2);
                        } else {
                            if(bi.Factor_Type__c == 'FTE' && grant.Estimated_FTE__c != null) {
                                bi.New_Item_Budget__c = (bi.New_Rate__c * grant.Estimated_FTE__c / 100).setScale(2);
                            } else if(bi.Factor_Type__c == 'TCS' && grant.Youth_Served_Percent__c != null) {
                                bi.New_Item_Budget__c = (bi.New_Rate__c * grant.Youth_Served_Percent__c / 100).setScale(2);
                            }  else if(bi.Factor_Type__c == 'Other') {
                                bi.New_Item_Budget__c = (bi.New_Rate__c * bi.Other_Factor_Percent__c / 100).setScale(2);
                            } else {
                                bi.New_Item_Budget__c = bi.New_Rate__c;
                            }
                        }
                        expenseRequestedAmount += bi.New_Item_Budget__c;
                    } 
                }
                if(expense_map.containsKey(bi.Category__c)) {
                    List<Budget_Item__c> bi_list = expense_map.get(bi.Category__c);
                    bi_list.add(bi);
                    expense_map.put(bi.Category__c, bi_list);
                } else {
                    expense_map.put(bi.Category__c, new List<Budget_Item__c>{bi});
                }
                if(expense_map.keySet() != null) {
                    hasExpenses = true;
                }
            } else {
                if(portalName == 'NPAL' && bi.New_Wages__c != null) {
                    laborRequestedAmount += bi.New_Wages__c;
                } else if(portalName == 'NPAL' && bi.Wages__c != null) {
                    laborRequestedAmount += bi.Wages__c;
                } else if(bi.New_Item_Budget__c != null) {
                    laborRequestedAmount += bi.New_Item_Budget__c;
                } else if(bi.Item_Budget__c != null) {
                    laborRequestedAmount += bi.Item_Budget__c;
                }
                if(bi.New_Fringe_Benefits__c != null) {
                    laborRequestedAmount += bi.New_Fringe_Benefits__c; 
                } else if(bi.Fringe_Benefits__c != null) {
                    laborRequestedAmount += bi.Fringe_Benefits__c; 
                }
            }
            system.debug('>>> expense_map = ' + expense_map);
        }
        getTotals();
    }
    // END getList
    
    // BEGIN getAttList
    public void getAttList() { 
        att_list.clear();
        Grant__c g = [
            SELECT Id
            ,(SELECT Id, Name, Description FROM Attachments ORDER BY LastModifiedDate desc) 
            FROM Grant__c
            WHERE Id = :grant.Id
        ];
        for(Attachment a : g.Attachments) {
            att_list.add(a);
        }
    }
    // END getAttList
    
    // BEGIN updateAmounts
    public void updateAmounts()
    {
        errorMessage = '';
        expenseRequestedAmount = 0;
            
        for(ItemClass ic : newExpense_list) {   
            system.debug('>>> ic = ' + ic);               
            if(ic.item.New_Rate__c != null && ic.item.New_Rate__c != 0) {
                if(grant.Use_Indirect_Rate__c == 'Yes') {
                    ic.item.New_Item_Budget__c = ic.item.New_Rate__c;//(ic.item.New_Rate__c * grant.Indirect_Rate__c / 100).setScale(2);
                    expenseRequestedAmount += ic.item.New_Rate__c.setScale(2);
                } else if (portalName == '') {
                    if(ic.factorType == 'FTE') {
                        ic.item.New_Item_Budget__c = (ic.item.New_Rate__c * grant.Estimated_FTE__c / 100).setScale(2);
                    } else if(ic.factorType == 'TCS') {
                        ic.item.New_Item_Budget__c = (ic.item.New_Rate__c * grant.Youth_Served_Percent__c / 100).setScale(2);
                    }  else if(ic.factorType == 'Other') {
                        if(ic.item.Other_Factor_Percent__c > 0) {
                            ic.item.New_Item_Budget__c = (ic.item.New_Rate__c * ic.item.Other_Factor_Percent__c / 100).setScale(2);
                        } else {
                            errorMessage = 'Factor Percent is required for ' + ic.item.Name;
                        }
                    } else {
                        errorMessage = 'Total Expense is required for ' + ic.item.Name;
                    }
                } else {
                    ic.item.New_Item_Budget__c = ic.item.New_Rate__c;
                }
                if(ic.item.New_Item_Budget__c != null) {
                    expenseRequestedAmount += ic.item.New_Item_Budget__c.setScale(2);
                }
            } else {
                errorMessage = 'Please enter a valid amount for ' + ic.item.Name;
            }
            if(portalName == '' && ic.factorType == 'Other' && String.isBlank(ic.itemNote)) {
                errorMessage = 'Please enter a note for ' + ic.item.Name;
            }
        }
        
        List<Budget_Item__c> expense_update_list = new List<Budget_Item__c>();
        List<List<Budget_Item__c>> expense_list = expense_map.values();
        for(Integer i = 0; i < expense_list.size(); i++) {
            for(Budget_Item__c bi : expense_list.get(i)) {
                system.debug('>>> bi = ' + bi);   
                if(bi.Is_Active__c) {
                    if(bi.New_Rate__c > 0) {
                        if(grant.Use_Indirect_Rate__c == 'Yes') {
                            bi.New_Item_Budget__c = bi.New_Rate__c;//(bi.New_Rate__c * grant.Indirect_Rate__c / 100).setScale(2);
                        } else if (portalName == '') {
                            if(bi.Factor_Type__c == 'FTE' && grant.Estimated_FTE__c != null) {
                                bi.New_Item_Budget__c = (bi.New_Rate__c * grant.Estimated_FTE__c / 100).setScale(2);
                            } else if(bi.Factor_Type__c == 'TCS' && grant.Youth_Served_Percent__c != null) {
                                bi.New_Item_Budget__c = (bi.New_Rate__c * grant.Youth_Served_Percent__c / 100).setScale(2);
                            }  else if(bi.Factor_Type__c == 'Other') {
                                if(bi.Other_Factor_Percent__c > 0 && bi.Other_Factor_Percent__c != null) {
                                    bi.New_Item_Budget__c = (bi.New_Rate__c * bi.Other_Factor_Percent__c / 100).setScale(2);
                                } else {
                                    errorMessage = 'Factor Percent is required for ' + bi.Name;
                                }
                            } else {
                                errorMessage = 'Please enter a valid Factor Type for ' + bi.Name;
                            }
                        } else {
                            bi.New_Item_Budget__c = bi.New_Rate__c;
                        }
                        if(bi.New_Item_Budget__c != null) {
                            expenseRequestedAmount += bi.New_Item_Budget__c.setScale(2);
                        }
                    }
                } else if (bi.Total_Approved_Amount__c !=  null) {
                    bi.New_Item_Budget__c = bi.Total_Approved_Amount__c;
                    expenseRequestedAmount += bi.New_Item_Budget__c; 
                }
                if(portalName == '' && bi.Factor_Type__c == 'Other' && bi.Is_Active__c == true && String.isBlank(bi.Item_Note__c)) {
                    errorMessage = 'Please enter a note for ' + bi.Name;
                }
                expense_update_list.add(bi);
            }
        }
        budgetItemClass.upsertItems(expense_update_list);
        
        getTotals();
    }
    // END updateAmounts
    
    // BEGIN getTotals
    public void getTotals() {
        system.debug('>>> expenseRequestedAmount = ' + expenseRequestedAmount);
        if(grant.Use_Indirect_Rate__c == 'Yes') {
            grant.New_Indirect_Rate_Amount__c = ((laborRequestedAmount + expenseRequestedAmount) * grant.Indirect_Rate__c / 100).setScale(2);
            totalRequestedAmount = laborRequestedAmount + expenseRequestedAmount + grant.New_Indirect_Rate_Amount__c;
        } else {
            totalRequestedAmount = (laborRequestedAmount + expenseRequestedAmount).setScale(2);
        }
        if(grant.Amount__c != null && (totalRequestedAmount.setScale(2) - 0.001) > grant.Amount__c.setScale(2)) {
            amountError = true;
            errorMessage = 'Requested Amount Exceeds Sub-Grant Amount';
        } else {
            amountError = false;
        }
    }
    // END getTotals
    
    // BEGIN updateSelected
    public void updateSelected() {
        system.debug('bulkAction = ' + bulkAction);
        List<Budget_Item__c> active_list = new List<Budget_Item__c>();
        List<Budget_Item__c> delete_list = new List<Budget_Item__c>();
        List<List<Budget_Item__c>> expense_list = expense_map.values();
        
        if(bulkAction != '') {
            for(Integer i = 0; i < expense_list.size(); i++) {
                for(Budget_Item__c bi : expense_list.get(i)) {
                    if(bi.Selected__c) {
                        if(bulkAction.toLowerCase() == 'disable') {
                            bi.Is_Active__c = false;
                            if(bi.Total_Approved_Amount__c != null) {
                                bi.New_Item_Budget__c = bi.Total_Approved_Amount__c;
                                bi.New_Rate__c = bi.Total_Approved_Amount__c;
                            } else {
                                bi.New_Item_Budget__c = 0;
                            }
                            active_list.add(bi);
                        }
                        if(bulkAction.toLowerCase() == 'enable') {
                            bi.Is_Active__c = true;
                            active_list.add(bi);
                        }
                        if(bulkAction.toLowerCase() == 'delete') {
                            if(bi.Total_Approved_Amount__c > 0) {
                                errorMessage = 'Item cannot be deleted';
                            } else {
                                delete_list.add(bi);
                            }
                        }
                    }
                    bi.Selected__c = false;
                }
            }
            if(active_list.size() > 0) {
                budgetItemClass.upsertItems(active_list);
            }
            if(delete_list.size() > 0) {
                budgetItemClass.deleteItems(delete_list);
            }
        }
        bulkAction = '';
        getLists();
    }
    // END updateSelected
    
    // BEGIN saveExpenses
    public void saveExpenses()
    {
        updateAmounts();
        List<Budget_Item__c> expense_upsert_list = new List<Budget_Item__c>();
        
        // Add items in list for insert
        for(ItemClass ic : newExpense_list){
            system.debug('>>> ic = ' + ic);
            if(ic.item.Id == null && ic.item.Name != null && ic.item.New_Item_Budget__c != null) {
                Budget_Item__c bi = new Budget_Item__c();
                bi = ic.item;
                bi.Category__c = ic.category;
                bi.Factor_Type__c = ic.factorType;
                bi.Item_Note__c = ic.itemNote;
                expense_upsert_list.add(bi);
                system.debug('>>> bi = ' + bi);
            }
        }
        budgetItemClass.upsertItems(expense_upsert_list);
    }
    // END saveExpenses
    
    // BEGIN deleteAtt
    public void deleteAtt() {
        if(deleteAttId != null) {
            Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteAttId];
            if(a != null) {
                delete a;
            }
        }
        getAttList();
    }
    // END deleteAtt
    
    // BEGIN previous
    public PageReference previous()
    {
        saveExpenses();
        grantClass.upsertGrant(grant);
        
        PageReference pr = new PageReference('/' + portalName + 'BudgetPersonnel?GrantID=' + GrantID);
        pr.setRedirect(True);
        return pr;
    }
    // END previous
    
    // BEGIN saveAndExit
    public PageReference saveAndExit()
    {
        saveExpenses();
        grantClass.upsertGrant(grant);
        
        if(String.isBlank(errorMessage)) {
            PageReference pr = new PageReference('/' + portalName + 'SubGrantDetails?GrantID=' + GrantID);
            pr.setRedirect(True);
            return pr;
        }
        return null;
    }
    // END saveAndExit
    
    // BEGIN submit
    public PageReference submit()
    {
        errorMessage = '';
        saveExpenses();
        
        if(portalName == '' && (grant.Youth_Served_Percent__c == null || grant.Youth_Served_Percent__c == 0)) {
            errorMessage = 'TCS must be greater than zero.';
        } 
        if (portalName == '' && (grant.Estimated_FTE__c == null || grant.Estimated_FTE__c == 0)) {
            errorMessage = 'FTE must be greater than zero.';
        } 
        
        if(errorMessage == '') {
            Date dt = date.today();
            String fdt = dt.format();
            String mh = fdt + ': Modification Submitted by ' + currentUser.Contact.Name + ' (' + currentUser.Id + ')';
            if(grant.Modification_History__c == null) {
                grant.Modification_History__c = '';
            } 
            grant.Modification_History__c += ' \r\n' + mh;
            
            grant.Previous_Status__c = grant.Grant_Status__c;
            if(grant.Grant_Status__c == 'Approved') {
                grant.Grant_Status__c = 'Pending Review';
            } else {
                grant.Grant_Status__c = 'Budget Submitted';
            }
            grant.Primary_Contact__c = currentUser.ContactID;
            grantClass.upsertGrant(grant);
            
            PageReference pr = new PageReference('/' + portalName + 'SubGrantDetails?GrantID=' + GrantID);
            pr.setRedirect(True);
            return pr;
        }
        return null;
    }
    // END submit
    
    public void expenseNotesPopup() {  
        if(displayExpenseNotesPopup == true) {
            displayExpenseNotesPopup = false; 
        } else {
            displayExpenseNotesPopup = true; 
        }
    }
    
    public void newExpenseNotesPopup() {  
        if(displayNewExpenseNotesPopup == true) {
            displayNewExpenseNotesPopup = false; 
        } else {
            displayNewExpenseNotesPopup = true; 
        }
    }
    
    public void attPopup() {  
        getAttList();
        if(displayAttPopup == true) {
            displayAttPopup = false; 
        } else {
            displayAttPopup = true; 
        }
    }
    
    
    // BEGIN Inner Class
    public class itemClass
    {       
        SubGrantBudgetExpensesController outerClass; 
        
        public Budget_Item__c item { get; set; }
        public Integer itemIndex { get; set; }    
        public String category { get; set; }
        public String factorType { get; set; }
        public Decimal rate { get; set; }
        public String itemNote { get; set; }
        
        // BEGIN Inner Class Constructor
        public itemClass(SubGrantBudgetExpensesController outerClass, Integer intCount, Budget_Item__c bi)
        {
            system.debug('>>> bi = ' + bi);
            itemIndex = intCount;
            item = bi;  
            
            rate = bi.Monthly_Rate__c;
            if(rate == null) {
                if(bi.New_Rate__c != null) {
                    rate = bi.New_Rate__c.setScale(2);
                } else if(bi.Item_Budget__c != null) {
                    rate = bi.Item_Budget__c.setScale(2);
                }
            }
        }
        // END Inner class Constructor  
    }
    // END inner Class
    
    // BEGIN addItem
    public void addItem()
    {   
        Budget_Item__c bi = new Budget_Item__c();
        bi.Grant__c = grant.Id;
        bi.RecordTypeId = expenseId;
        bi.Category__c = 'Other Costs';
        bi.Is_Active__c = true;
        
        itemClass ic = new itemClass(this, expenseCount, bi);
        expenseCount = expenseCount + 1;
        newExpense_list.add(ic);
        system.debug('>>> newExpense_list = ' + newExpense_list);
    }
    // END addItem
    
    // BEGIN delete
    public void deleteItem()
    {
        newExpense_list.remove(selectedExpense);
        expenseCount = 0;
        for(itemClass ic : newExpense_list) {
            ic.itemIndex = expenseCount;
            expenseCount = expenseCount + 1;
        }
    }
    // END delete
}
*/
