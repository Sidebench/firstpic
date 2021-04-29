public without sharing class ProgressReportsCtrl {
  /*
    private UserClass userClass = new UserClass();
    public User currentUser { get; set; }
    public Account userAcct { get; set; }
    public String userAcctType { get; set; }
    
    private SessionReportClass src = new SessionReportClass();
    private PaginationClass pc = new PaginationClass();
    
    public Id siteId { get; set; }
    public List<Session_Report__c> allReports { get; set; }
    public List<Session_Report__c> reports { get; set; }
    
    public String orgName { get; set; }
    public String reportName { get; set; }
    public String status { get; set; }
    public List<SelectOption> statusOptions { get; set; }
    public String sortBy { get; set; }
    public List<SelectOption> sortByOptions { get; set; }
    
    Integer counter = 0;
    Integer limitSize = 40; 
    Integer totalSize = 0;
    public String recordCount { get; set;}
    public Boolean disablePrevious { get; set; }
    public Boolean disableNext { get; set; }
    
    public ProgressReportsCtrl() {
        currentUser = userClass.currentUser;
        userAcct = userClass.userAcct;
        userAcctType = userClass.userAcctType;
        
        siteId = null;
        if(userAcctType == 'Site') siteId = userAcct.Id;
        String urlSiteId = ApexPages.currentPage().getParameters().get('siteId'); 
        if(urlSiteId != '' && urlSiteId != null) {
            if(Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(urlSiteId).matches() ){
                siteId = Id.valueOf(urlSiteId);
            }
        }
        
        statusOptions = new List<SelectOption>();
        statusOptions.add(new SelectOption('All Reports', 'View All'));
        Schema.DescribeFieldResult fieldResult = Session_Report__c.Status__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        status = 'All Reports';
            
        sortByOptions = new List<SelectOption>();
        sortByOptions.add(new SelectOption('Name','Name'));
        if(userAcctType != 'Site') sortByOptions.add(new SelectOption('Site__r.Name','Site'));
        sortByOptions.add(new SelectOption('Status__c','Status'));
        sortByOptions.add(new SelectOption('Submitted_Date__c', 'Submitted Date'));
        sortBy = 'Name';
        
        allReports = new List<Session_Report__c>();
        reports = new List<Session_Report__c>();
    }
    
    public void getLists() {
        allReports = src.getRelatedReportList(userAcct.Id, siteId, userAcctType, orgName, reportName, status, sortBy, null);
        totalSize = allReports.size();
        first();
    }
    
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
