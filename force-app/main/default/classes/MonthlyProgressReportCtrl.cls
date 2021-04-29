public without sharing class MonthlyProgressReportCtrl {
  /*
    private UserClass userClass = new UserClass();
    public User currentUser { get; set; }
    public Account userAcct { get; set; }
    public String userAcctType { get; set; }
    
    private ProgressReportClass prc = new ProgressReportClass();
    private PaginationClass pc = new PaginationClass();
    
    public Id orgId { get; set; }
    public List<Progress_Report__c> allReports { get; set; }
    public List<Progress_Report__c> reports { get; set; }
    public Progress_Report__c report { get; set; }
    public List<Attachment> atts { get; set; }
    
    public String orgName { get; set; }
    public String reportId { get; set; }
    public String grantStatus { get; set; }
    public String month { get; set; }
    public List<SelectOption> monthOptions { get; set; }
    public Integer year { get; set; }
    public List<SelectOption> yearOptions { get; set; }
    public String status { get; set; }
    public List<SelectOption> statusOptions { get; set; }
    public String sortBy { get; set; }
    public List<SelectOption> sortByOptions { get; set; }
    
    public Boolean showOnlyNeedsAttention { get; set; }
    public Boolean showOnlyOverdue { get; set; }
    
    public Boolean displayAttPopup { get; set; }
    public Boolean displaySendBackPopup { get; set; }
    public String errorMessage { get; set; }
    public String successMessage { get; set; }
    
    Integer counter = 0;
    Integer limitSize = 40; 
    Integer totalSize = 0;
    public String recordCount { get; set;}
    public Boolean disablePrevious { get; set; }
    public Boolean disableNext { get; set; }
    
    public MonthlyProgressReportCtrl() {
        currentUser = userClass.currentUser;
        userAcct = userClass.userAcct;
        userAcctType = userClass.userAcctType;
        
        month = ApexPages.currentPage().getParameters().get('month'); 
        grantStatus = ApexPages.currentPage().getParameters().get('grantStatus'); 
        status = ApexPages.currentPage().getParameters().get('status'); 
        
        showOnlyNeedsAttention = false;
        showOnlyOverdue = false;
        String overdueUrl = ApexPages.currentPage().getParameters().get('overdue'); 
        if(overdueUrl == 'true') showOnlyOverdue = true;
        
        allReports = new List<Progress_Report__c>();
        reports = new List<Progress_Report__c>();
        report = new Progress_Report__c();
        atts = new List<Attachment>();
    }
    
    public void getOptions() {
        orgId = null;
        if(userAcctType == 'Site') orgId = userAcct.Id;
        String urlOrgId = ApexPages.currentPage().getParameters().get('orgId'); 
        if(urlOrgId != '' && urlOrgId != null) {
            if(Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(urlOrgId).matches() ){
                orgId = Id.valueOf(urlOrgId);
            }
        }
        
        Date dt = date.today();
        monthOptions = new List<SelectOption>();
        monthOptions.add(new SelectOption('', 'View All'));
        Schema.DescribeFieldResult fieldResult1 = Progress_Report__c.Month__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult1.getPicklistValues()) monthOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        
        yearOptions = new List<SelectOption>();
        yearOptions.add(new SelectOption('', 'View All'));
        Schema.DescribeFieldResult fieldResult2 = Progress_Report__c.Year__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult2.getPicklistValues()) yearOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        year = dt.year();
        
        statusOptions = new List<SelectOption>();
        statusOptions.add(new SelectOption('All Reports', 'View All'));
        Schema.DescribeFieldResult fieldResult3 = Progress_Report__c.Status__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult3.getPicklistValues()) statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        if(status == '' || status == null) status = 'All Reports';
            
        sortByOptions = new List<SelectOption>();
        sortByOptions.add(new SelectOption('Name','Report Id'));
        if(userAcctType != 'Site') sortByOptions.add(new SelectOption('Organization_Name__c','Organization'));
        sortByOptions.add(new SelectOption('Status__c','Status'));
        sortByOptions.add(new SelectOption('Submitted_Date__c', 'Submitted Date'));
        sortBy = 'Name';
        
        getLists();
    }
    
    public void getLists() {
        String soqlAND = '';
        if(showOnlyOverdue) soqlAND += ' AND Is_Overdue__c = true';
        if(showOnlyNeedsAttention) soqlAND += ' AND Needs_Attention__c = true';
        if(grantStatus == 'Closed') soqlAND += ' AND Grant_Status__c = \'Closed\'';
        else soqlAND += ' AND Grant_Status__c != \'Closed\'';
        allReports = prc.getRelatedReportList(userAcct.Id, orgId, userAcctType, orgName, reportId, month, year, status, sortBy, soqlAND);
        totalSize = allReports.size();
        first();
    }
    
    public void getReport() {
        String urlReportId = ApexPages.currentPage().getParameters().get('reportId'); 
        if(urlReportId != '' && urlReportId != null) {
            if(Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(urlReportId).matches() ){
                reportId = Id.valueOf(urlReportId);
            }
        }
        report = prc.getReport(reportId, null, null);
        report.Previous_Status__c = report.Status__c;
        getAtts();
    }
    
    public void getAtts() {
        Id rId;
        if(report.Id != null) rId = report.Id;
        else if(reportId != null) rId = reportId;
        atts = [SELECT Id, Name FROM Attachment WHERE ParentId = :report.Id ORDER BY CreatedDate desc LIMIT 1];
    }
    
    public void edit() {
        report.Status__c = 'In Progress';
        prc.upsertReport(report);
    }
    
    // BEGIN fieldValidation
    public void fieldValidation() {
        errorMessage = '';
        //report.Curriculum_Used__c == null ||
        if(report.Updated_Youth_Data__c == null) errorMessage += 'Question 1 is Required <br />';
        if(report.Number_of_Mentors__c == null) errorMessage += 'Question 4 is Required <br />';
        if(report.Number_of_Mentors_Left_Program__c == null) errorMessage += 'Question 5 is Required <br />';
        if(report.Number_of_New_Mentors_this_Month__c == null) errorMessage += 'Question 6 is Required <br />';
        if(report.Number_of_Mentors_Completed_Training__c == null) errorMessage += 'Question 7 is Required <br />';
        if(report.Mentor_Training_Survey_Completed__c == null) errorMessage += 'Question 8 is Required <br />';
        if(report.Accomplishments_this_Reporting_Period__c == null) errorMessage += 'Question 9 is Required <br />';
        if(report.Problems_Barriers_Encountered__c == null) errorMessage += 'Question 10 is Required <br />';
        if(report.Problems_Barriers_Encountered__c == 'Yes' && report.Problems_Barriers_Encountered_Details__c == null) errorMessage += 'Question 10a is Required <br />';
        if(report.Assistance_Needed__c == null) errorMessage += 'Question 11 is Required <br />';
        if(report.Assistance_Needed__c == 'Yes' && report.Assistance_Needed_Details__c == null) errorMessage += 'Question 11a is Required <br />';
        if(report.On_Track_to_Complete_Program__c == null) errorMessage += 'Question 12 is Required <br />';
        if(report.On_Track_to_Complete_Program__c == 'No' && report.On_Track_to_Complete_Program_Details__c == null) errorMessage += 'Question 12a is Required <br />';
        if(report.Major_Activities_Planned__c == null) errorMessage += 'Question 13 is Required <br />';
        if(report.Innovative_Programs_Accomplishments__c == null) errorMessage += 'Question 14 is Required <br />';
        if(report.Month__c == 'June' || report.Month__c == 'December') {
            if(report.Youth_Participated_More_Than_4_Hours__c == null) errorMessage += 'Question 15 is Required <br />';
            if(report.Youth_Participated_Less_Than_4_Hours__c == null) errorMessage += 'Question 16 is Required <br />';
            if(report.Increase_in_Perception_of_Social_Support__c == null) errorMessage += 'Question 17 is Required <br />';
            if(report.Youth_Who_Offend__c == null) errorMessage += 'Question 18 is Required <br />';
        }
        if(atts.size() == 0) errorMessage += 'Attendance Report is Required';
        if(errorMessage != '') successMessage = '';
    }
    // END fieldValidation
    
    public void save() {
        if(report.Status__c == 'Not Started') report.Status__c = 'In Progress';
        prc.upsertReport(report);
        if(ApexPages.hasMessages()) errorMessage += string.valueOf(ApexPages.getMessages());
        else successMessage = 'Save successful.';
    }
    
    public PageReference submit() {
        fieldValidation();
        if(errorMessage != '') return null;
        
        report.Status__c = 'Submitted';
        report.Submitted_By__c = currentUser.ContactId;
        report.Submitted_Date__c = date.today();
        report.Modification_History__c = getModHist('Submitted');
        prc.upsertReport(report);
        if(ApexPages.hasMessages()) return null;
        
        PageReference pr = new PageReference('/MonthlyProgressReports');
        pr.setRedirect(True);
        return pr;
    }
    
    public PageReference sendBack() {
        report.Status__c = 'Revisions Needed';
        report.Sent_Back_By__c = currentUser.ContactId;
        report.Modification_History__c = getModHist('Sent Back');
        prc.upsertReport(report);
        if(ApexPages.hasMessages()) return null;
        
        PageReference pr = new PageReference('/MonthlyProgressReports');
        pr.setRedirect(True);
        return pr;
    }
    
    // BEGIN modHist
    public String getModHist(String status) {
        Date dt = date.today();
        String fdt = dt.format();
        String modHist = fdt + ': Report '+ status +' by ' + currentUser.Contact.Name + ' (' + currentUser.Id + ')';
        if(modHist != '') {
            if(report.Modification_History__c == null) {
                report.Modification_History__c = modHist;
            } else {
                report.Modification_History__c += ' \r\n' + modHist;
            }
        }
        return modHist;
    }
    // END modHist
    
    // BEGIN popups
    public void showAttPopup() {
        displayAttPopup = true;
    }
    public void hideAttPopup() {
        displayAttPopup = false;
        getAtts();
    }
    
    public void showSendBackPopup() {
        displaySendBackPopup = true;
    }
    public void hideSendBackPopup() {
        displaySendBackPopup = false;
    }
    // END popups
    
    // BEGIN Pagination
    public void first() {
        counter = 0;
        reports = pc.first(allReports, limitSize);
        recordCount = pc.getRecordCount(counter, limitSize, totalSize);
        disablePrevious = true;
        disableNext = pc.getDisableNext(counter, limitSize, totalSize);
    }
    
    public void next() {
        counter = counter + limitSize;
        reports = pc.next(allReports, counter, limitSize);
        recordCount = pc.getRecordCount(counter, limitSize, totalSize);
        disablePrevious = false;
        disableNext = pc.getDisableNext(counter, limitSize, totalSize);
    }
    
    public void previous() {
        counter = counter - limitSize;       
        reports = pc.previous(allReports, counter, limitSize);
        recordCount = pc.getRecordCount(counter, limitSize, totalSize);
        disablePrevious = pc.getDisablePrevious(counter);
        disableNext = false;
    }

    public void last() {
        counter = pc.getLastCounter(counter, limitSize, totalSize);
        reports = pc.last(allReports, counter, limitSize);
        recordCount = pc.getRecordCount(counter, limitSize, totalSize);
        disablePrevious = false;
        disableNext = true;
    }
    // END Pagination
	*/
}
