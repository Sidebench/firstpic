public with sharing class SubGrantBudgetPersonnelController {
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
    public Boolean isNationalSubGrant { get; set; }
    public Id laborId { get; set; }
    public Decimal duration { get; set; }
    public Decimal durationWks { get; set; }
    public Decimal expenseRequestedAmount { get; set; } 
    public Decimal totalRequestedAmount { get; set; } 
    public Decimal totalHours = 0;
    public Decimal grantHours = 0;
    
    public String errorMessage { get; set; }    
    public Boolean amountError { get; set; } 
    public Boolean displayRatePopup { get; set; }
    public Boolean displayLaborNotesPopup { get; set; }
    public Boolean displayNewLaborNotesPopup { get; set; }
    
    public List<Budget_Item__c> budgetItem_list { get; set; }
    public List<itemClass> labor_list { get; set; }
    public List<itemClass> newLabor_list { get; set; }
    public Integer selectedLabor { get; set; } 
    public Integer laborCount = 0;
    public Integer selectedNewLabor { get; set; } 
    public Integer newLaborCount = 0;
    
    public Boolean hasReimbursements { get; set; }
    public List<SelectOption> options { get; set; }
    public string bulkAction { get; set; }
    public List<Budget_Item__c> active_list { get; set; }
    public List<Budget_Item__c> delete_list { get; set; }
    
    // BEGIN Constructor
    public SubGrantBudgetPersonnelController () {
        currentUser = userClass.currentUser;
        userAcct = userClass.userAcct;
        userAcctType = userClass.userAcctType;
        portalName = userClass.userProfile;
        
        GrantId = ApexPages.currentPage().getParameters().get('GrantId');  
        laborId = Schema.SObjectType.Budget_Item__c.getRecordTypeInfosByName().get('Labor').getRecordTypeId();
        
        acct = new Account();
        grant = new Grant__c();
        
        expenseRequestedAmount = 0;
        totalRequestedAmount = 0;
        selectedLabor = 0;
        selectedNewLabor = 0;
        errorMessage = '';
        amountError = false;
        isNationalSubGrant = false;
        displayRatePopup = false;
        displayLaborNotesPopup = false; 
        displayNewLaborNotesPopup = false; 
        
        budgetItem_list = new List<Budget_Item__c>();
        labor_list = new List<itemClass>();
        newLabor_list = new List<itemClass>();
        
        active_list = new List<Budget_Item__c>();
        delete_list = new List<Budget_Item__c>();

        if(GrantID != null) {
            grant = grantClass.getGrant(GrantId);
            acct = [SELECT ID, Name, RecordType.Name FROM Account WHERE ID = :grant.Account__r.Id];
            duration = grant.Grant_Duration__c;
            if(duration != null) {
                durationWks = grant.Grant_Duration__c / 7;
            }
            if(userAcctType == 'National Organization' && grant.Account__r.Id == userAcct.Id) {
                isNationalSubGrant = true;
            }
            
            Reimbursement_Request__c[] requests = [SELECT Id FROM Reimbursement_Request__c WHERE Grant__r.Id = :GrantId];
            if(requests.size() > 0) {
                hasReimbursements = true;
            }
            
            //getList();
        }

        options = new List<SelectOption>();
        options.add(new SelectOption('','Select an Action'));
        options.add(new SelectOption('delete','Delete'));
        options.add(new SelectOption('disable','Mark Inactive'));
    }
    // END Constructor
    
    public void getLists() {
        budgetItem_list.clear();
        labor_list.clear();
        expenseRequestedAmount = 0;
        totalRequestedAmount = 0;
        
        for(Budget_Item__c bi : budgetItemClass.getBudgetItems(GrantId)) {
            if(bi.RecordType.Name == 'Labor') {
                budgetItem_list.add(bi);
            } 
            else {
                if(bi.New_Item_Budget__c != null) {
                    expenseRequestedAmount += bi.New_Item_Budget__c;
                } else if(bi.Item_Budget__c != null) {
                    expenseRequestedAmount += bi.Item_Budget__c;
                }
            }
        }
        totalRequestedAmount = expenseRequestedAmount;
        
        if(budgetItem_list.size() > 0) {
            if(labor_list.size() == 0) {
                for(Budget_Item__c bi : budgetItem_list) {
                    itemClass ic = new itemClass(this, laborCount, bi);
                    labor_list.add(ic);
                    if(bi.New_Item_Budget__c != null) {
                        totalRequestedAmount += bi.New_Item_Budget__c;
                    } else if(bi.Item_Budget__c != null) {
                        totalRequestedAmount += bi.Item_Budget__c;
                    }
                    if(bi.New_Fringe_Benefits__c != null) {
                        totalRequestedAmount += bi.New_Fringe_Benefits__c; 
                    } else if(bi.Fringe_Benefits__c != null) {
                        totalRequestedAmount += bi.Fringe_Benefits__c; 
                    }
                    laborCount += 1;
                }
            }
        }
        if(grant.Amount__c != null && (totalRequestedAmount.setScale(2) - 0.001) > grant.Amount__c) {
            amountError = true;
        }
        
        updateAmounts();
    }
    
    // BEGIN updateAmounts
    public void updateAmounts() {
        totalRequestedAmount = 0;
        totalHours = 0;
        grantHours = 0;
        errorMessage = '';
        
        if(grant.Youth_Served_with_Grant_Funding__c > 0 && grant.Youth_Served__c > 0) {
            grant.Youth_Served_Percent__c = (grant.Youth_Served_with_Grant_Funding__c / grant.Youth_Served__c * 100).setScale(1);
        }      
        if(grant.Youth_Served_Percent__c > 100) {
            errorMessage = 'The projected # of children served with grant funding during the Grant performance period should not exceed the total # of children served.';
        } 
        system.debug('>>> grant.Youth_Served_Percent__c = ' + grant.Youth_Served_Percent__c);
        
        for(ItemClass ic : labor_list) {
            itemCalc(ic);
        }
        for(ItemClass ic : newLabor_list) {
            itemCalc(ic);
            ic.item.Previous_Hourly_Rate__c = 0;
            ic.item.Previous_Grant_Hours_Per_Week__c = 0;
            ic.item.Previous_Fringe_Benefits__c = 0;
        }
        if(grantHours != 0 && totalHours != 0 && grant.FTE_at_Affiliate__c != null && grant.FTE_at_Affiliate__c != 0) {
            //    grant.Estimated_FTE__c = grantHours / totalHours * 100;
            grant.Estimated_FTE__c = (grantHours / (grant.FTE_at_Affiliate__c * 40) * 100).setScale(1);
        }
        if(grant.Amount__c != null && (totalRequestedAmount.setScale(2) + 0.1) > grant.Amount__c) {
            amountError = true;
            // errorMessage = 'Requested Amount Exceeds Sub-Grant Amount';
        } else {
            amountError = false;
        }
    }
    
    public void itemCalc(ItemClass ic) {
        system.debug('>>> ic = ' + ic); 
        if(ic.item.Is_Active__c == false) {
            if(ic.item.Total_Approved_Salary__c != null) {
                ic.total = ic.item.Total_Approved_Salary__c;
                totalRequestedAmount += ic.total; 
            }
            if(ic.item.New_Fringe_Benefits__c != null) {
                totalRequestedAmount += ic.item.New_Fringe_Benefits__c; 
            }
        } else {
            ic.total = 0;
            if(ic.item.Projected_Hours_Per_Week__c != 0 && ic.item.Projected_Grant_Hours_Per_Week__c  != null) {
                ic.item.Projected_Percent_Time_on_Grant__c = (ic.item.Projected_Grant_Hours_Per_Week__c / ic.item.Projected_Hours_Per_Week__c * 100).setScale(1);        
                if(ic.item.Projected_Percent_Time_on_Grant__c > 100) {
                    errorMessage = 'The hours worked on grant should not exceed total number of hours worked';
                }              
                if(ic.rate != null) {
                    if(ic.item.Is_Hourly__c) {
                        ic.item.Hourly_Rate__c = ic.rate;
                    } else {
                        Decimal hr = ic.item.Projected_Hours_Per_Week__c * (365 / 7);
                        ic.item.Salary__c = ic.rate;
                        ic.item.Hourly_Rate__c = (ic.item.Salary__c / hr).setScale(2);
                    }
                    
                    Decimal fb = 0;   
                    ic.item.New_Fringe_Benefits__c = 0;
                    if(ic.item.Medical__c != null) {
                        fb += ic.item.Medical__c;
                    }
                    if(ic.item.Dental__c != null) {
                        fb += ic.item.Dental__c;
                    }
                    if(ic.item.Short_Term_Disability__c != null) {
                        fb += ic.item.Short_Term_Disability__c;
                    }
                    if(ic.item.Long_Term_Disability__c != null) {
                        fb += ic.item.Long_Term_Disability__c;
                    }
                    if(ic.item.Life__c != null) {
                        fb += ic.item.Life__c;
                    }
                    if(ic.item.Other_Benefits__c != null) {
                        fb += ic.item.Other_Benefits__c;
                    }      
                    
                    if(ic.item.Effective_Date__c != null) {
                        if(ic.item.Effective_Date__c < grant.Grant_Start_Date__c || ic.item.Effective_Date__c >= grant.Grant_End_Date__c) {
                            errorMessage = 'Effective date should fall within the grant period';
                        } else {
                            Integer firstRateDays = grant.Grant_Start_Date__c.daysBetween(ic.item.Effective_Date__c);
                            Integer secondRateDays = (ic.item.Effective_Date__c.daysBetween(grant.Grant_End_Date__c)) + 1;
                            if(ic.item.Previous_Hourly_Rate__c != null) {
                                if(ic.item.Previous_Grant_Hours_Per_Week__c != null) {
                                    ic.total = ic.item.Previous_Hourly_Rate__c * (ic.item.Previous_Grant_Hours_Per_Week__c / 7) * firstRateDays;
                                }  else if(ic.item.Projected_Grant_Hours_Per_Week__c != null) {
                                    ic.total = ic.item.Previous_Hourly_Rate__c * (ic.item.Projected_Grant_Hours_Per_Week__c / 7) * firstRateDays;
                                }
                            }
                            ic.total += ic.item.Hourly_Rate__c * (ic.item.Projected_Grant_Hours_Per_Week__c / 7) * secondRateDays;  
                            
                            if(fb > 0) {
                                if(ic.item.Previous_Percent_Time_on_Grant__c!= null) {
                                    ic.item.New_Fringe_Benefits__c = (fb / 365) * firstRateDays * (ic.item.Previous_Percent_Time_on_Grant__c / 100);
                                }
                                if(ic.item.Projected_Percent_Time_on_Grant__c != null) {
                                    ic.item.New_Fringe_Benefits__c += (fb / 365) * secondRateDays * (ic.item.Projected_Percent_Time_on_Grant__c / 100);
                                }
                            }  
                        }
                    } else {
                        ic.total = (ic.item.Hourly_Rate__c * ic.item.Projected_Grant_Hours_Per_Week__c * durationWks).setScale(2);
                        if(fb > 0) {
                            ic.item.New_Fringe_Benefits__c = (fb / 365) * duration * (ic.item.Projected_Percent_Time_on_Grant__c / 100);
                        }  
                    } 
                    
                    if(ic.total != null) {
                        ic.item.FICA__c = (ic.total * .0765).setScale(2);
                        ic.item.New_Fringe_Benefits__c += ic.item.FICA__c;
                    } 
                    ic.item.New_Fringe_Benefits__c = ic.item.New_Fringe_Benefits__c.setScale(2);
                    totalRequestedAmount += ic.total; 
                    totalRequestedAmount += ic.item.New_Fringe_Benefits__c; 
                    ic.item.New_Rate__c = ic.rate;
                    totalHours += ic.item.Projected_Hours_Per_Week__c;
                    grantHours += ic.item.Projected_Grant_Hours_Per_Week__c;
                }
            }
        }
    }
    // END updateAmounts
    
    // BEGIN updateSelected
    public void updateSelected() {
        system.debug('bulkAction = ' + bulkAction);
        if(bulkAction != '') {
            for(ItemClass ic : labor_list) {
                if(ic.item.Selected__c) {
                    system.debug('ic = ' + ic);
                    if(bulkAction.toLowerCase() == 'disable') {
                        ic.item.Is_Active__c = false;
                        if(ic.item.Total_Approved_Salary__c != null) {
                            ic.item.New_Item_Budget__c = ic.item.Total_Approved_Salary__c;
                            ic.total = ic.item.Total_Approved_Salary__c;
                        } else {
                            ic.item.New_Item_Budget__c = 0;
                        }
                        if(ic.item.Total_Approved_Benefits__c != null) {
                            ic.item.New_Fringe_Benefits__c = ic.item.Total_Approved_Benefits__c;
                        } else {
                            ic.item.New_Fringe_Benefits__c = 0;
                        }
                        ic.item.Projected_Grant_Hours_Per_Week__c = 0;
                        ic.item.Projected_Hours_Per_Week__c = 0;
                        ic.item.Projected_Percent_Time_on_Grant__c = 0;
                        ic.item.Effective_Date__c = null;
                        active_list.add(ic.item);
                    }
                    if(bulkAction.toLowerCase() == 'enable') {
                        ic.item.Is_Active__c = true;
                        active_list.add(ic.item);
                    }
                    if(bulkAction.toLowerCase() == 'delete') {
                        if(ic.item.Total_Approved_Amount__c > 0) {
                            errorMessage = 'Item cannot be deleted';
                        } else {
                            ic.item.Is_Active__c = false;
                            ic.item.Projected_Grant_Hours_Per_Week__c = 0;
                            ic.item.Projected_Hours_Per_Week__c = 0;
                            ic.item.Projected_Percent_Time_on_Grant__c = 0;
                            ic.item.Effective_Date__c = null;
                            ic.item.New_Item_Budget__c = 0;
                            ic.item.New_Fringe_Benefits__c = 0;
                            delete_list.add(ic.item);
                        }
                    }
                }
                ic.item.Selected__c = false;
            }
        }
        bulkAction = '';
        //getList();
        updateAmounts();
    }
    // END updateSelected
    
    // BEGIN saveLabor
    public void saveLabor()
    {
        updateAmounts();
        grantClass.upsertGrant(grant);
        
        if(active_list.size() > 0) {
            budgetItemClass.upsertItems(active_list);
        }
        if(delete_list.size() > 0) {
            budgetItemClass.deleteItems(delete_list);
        }
        
        system.debug('>>> labor_list = ' + labor_list);
        List<Budget_Item__c> labor_upsert_list = new List<Budget_Item__c>();
        //List<Budget_Item__c> labor_delete_list = new List<Budget_Item__c>();
        
        for(ItemClass ic : newLabor_list) {
            system.debug('>>> ic = ' + ic);
            if(ic.item.Name != null && ic.item.Title__c != null) {
                Budget_Item__c bi = new Budget_Item__c();
                bi = ic.item;
                if(ic.total != null) {
                    bi.New_Item_Budget__c = ic.total;
                    labor_upsert_list.add(bi);
                }
            }
        }
        
        for(ItemClass ic : labor_list) {
            system.debug('>>> ic = ' + ic);
            for(Budget_Item__c bi : budgetItem_list) {
                system.debug('>>> bi = ' + bi);
                if(ic.item.Id == bi.Id) {
                    if(ic.total != null) {
                        bi.New_Item_Budget__c = ic.total;
                        if(bi.Item_Budget__c != null && bi.New_Item_Budget__c != null) {
                            if(bi.Item_Budget__c.round(System.RoundingMode.CEILING) == bi.New_Item_Budget__c.round(System.RoundingMode.CEILING)) {
                                bi.New_Item_Budget__c = null;
                            }
                        }
                        if(bi.Fringe_Benefits__c != null && bi.New_Fringe_Benefits__c != null) {
                            if(bi.Fringe_Benefits__c.round(System.RoundingMode.CEILING) == bi.New_Fringe_Benefits__c.round(System.RoundingMode.CEILING)) {
                                bi.New_Fringe_Benefits__c = null;
                            }
                        }
                    }
                    labor_upsert_list.add(bi);
                }
            }
        }
        
        budgetItemClass.upsertItems(labor_upsert_list);
    }
    // END saveLabor
    
    // BEGIN saveAndContinue
    public PageReference saveAndContinue()
    {   
        displayRatePopup = false; 
        saveLabor();   
        
        if(!isNationalSubGrant && (grant.Youth_Served__c == null || grant.Youth_Served__c == 0)) {
            errorMessage = 'Projected # of children served during the Grant performance period must be greater than zero.';
        } 
        if(portalName == 'BBBS') {
            if(!isNationalSubGrant && (grant.Youth_Served_with_Grant_Funding__c == null || grant.Youth_Served_with_Grant_Funding__c == 0)) {
                errorMessage = 'Projected # of children served with grant funding must be greater than zero.';
            } 
            if(grant.FTE_at_Affiliate__c == null || grant.FTE_at_Affiliate__c == 0) {
                errorMessage = 'Number of Full Time Equivalent staff at Affiliate must be greater than zero.';
            } 
        }
        
        if(String.isBlank(errorMessage)) {
            String sg = '';
            if(portalName == 'BBBS') {
                sg = 'SubGrant';
            }
            PageReference pr = new PageReference('/' + portalName + sg + 'BudgetExpenses?GrantID=' + GrantID);
            pr.setRedirect(True);
            return pr;
        }
        return null;
    }
    // END saveAndContinue
    
    // BEGIN saveAndExit
    public PageReference saveAndExit()
    {   
        saveLabor();     
        
        PageReference pr = new PageReference('/' + portalName + 'SubGrantDetails?GrantID=' + GrantID);
        pr.setRedirect(True);
        return pr;
        
    }
    // END saveAndExit
    
    public void ratePopup() {  
        if(displayRatePopup == true) {
            displayRatePopup = false; 
        } else {
            displayRatePopup = true; 
        }
    }
    
    public void laborNotesPopup() {  
        if(displayLaborNotesPopup == true) {
            displayLaborNotesPopup = false; 
        } else {
            displayLaborNotesPopup = true; 
        }
    }
    
    public void newLaborNotesPopup() {  
        if(displayNewLaborNotesPopup == true) {
            displayNewLaborNotesPopup = false; 
        } else {
            displayNewLaborNotesPopup = true; 
        }
    }
    
    
    // BEGIN Inner Class
    public class itemClass
    {       
        SubGrantBudgetPersonnelController outerClass; 
        
        public Budget_Item__c item { get; set; }
        public Integer itemIndex { get; set; }    
        public Decimal rate { get; set; }
        public Decimal total { get; set; }
        //public String effectiveMonth { get; set; }
        
        // BEGIN Inner Class Constructor
        public itemClass(SubGrantBudgetPersonnelController outerClass, Integer intCount, Budget_Item__c bi)
        {
            itemIndex = intCount; 
            item = bi;  
            bi.Selected__c = false;
            
            if(bi.Is_Hourly__c == null) {
                bi.Is_Hourly__c = false;
            }
            if(bi.Is_Hourly__c) {
                rate = bi.Hourly_Rate__c;
            } else {
                rate = bi.Salary__c;
            }
            if(rate == null) {
                if(bi.New_Rate__c != null) {
                    rate = bi.New_Rate__c.setScale(2);
                } else if(bi.Item_Budget__c != null) {
                    rate = bi.Item_Budget__c.setScale(2);
                }
            }
            if(bi.Previous_Hourly_Rate__c == null) {
                bi.Previous_Hourly_Rate__c = bi.Hourly_Rate__c;
            }
            if(bi.Previous_Grant_Hours_Per_Week__c  == null) {
                bi.Previous_Grant_Hours_Per_Week__c = bi.Projected_Grant_Hours_Per_Week__c;
            }
            if(bi.Previous_Percent_Time_on_Grant__c == null && bi.Projected_Percent_Time_on_Grant__c != null) {
                bi.Projected_Percent_Time_on_Grant__c = bi.Projected_Percent_Time_on_Grant__c;
            }
            if(bi.Previous_Fringe_Benefits__c == null) {
                bi.Previous_Fringe_Benefits__c = bi.Fringe_Benefits__c;
            }
            if(bi.New_Fringe_Benefits__c == null) {
                bi.New_Fringe_Benefits__c = bi.Fringe_Benefits__c;
            }
            
            if(bi.Is_Active__c == false) {
                total = bi.Total_Approved_Salary__c;
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
        
        bi.RecordTypeId = laborId;
        bi.Category__c = 'Personnel';
        bi.Is_Active__c = true;
        
        //call to the inner class constructor
        itemClass ic = new itemClass(this, newLaborCount, bi);
        newLaborCount += 1;
        
        //add the record to the inner class list
        newLabor_list.add(ic);
        
    }
    // END addItem
    
    // BEGIN delete
    public void deleteItem()
    {
        newLabor_list.remove(selectedLabor);
        newLaborCount = 0;
        for(itemClass ic : newLabor_list) {
            ic.itemIndex = newLaborCount;
            newLaborCount = newLaborCount + 1;
        }
    }
    // END delete
}
*/
