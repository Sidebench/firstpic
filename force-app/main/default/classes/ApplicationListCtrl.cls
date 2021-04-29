public with sharing class ApplicationListCtrl {
  private UserClass userClass = new UserClass();
  private User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  private SchemaPicklistFields spf = new SchemaPicklistFields();
  private GrantClass gc = new GrantClass();

  public Map<String, List<Application__c>> app_map { get; set; }
  public List<Application__c> app_list { get; set; }
  public String appId { get; set; }
  public String name { get; set; }
  public String EIN { get; set; }
  public String filterByStatus { get; set; }
  public String filterByLocation { get; set; }
  public String appType { get; set; }
  public List<SelectOption> appTypeOptions { get; set; }
  public String reviewer { get; set; }
  public List<SelectOption> reviewerOptions { get; set; }
  public Boolean showMore { get; set; }
  public Boolean noResults { get; set; }
  public Boolean limitReached { get; set; }

  public ApplicationListCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    app_map = new Map<String, List<Application__c>>();
    app_list = new List<Application__c>();
    appId = '';
    name = '';
    EIN = '';

    filterByStatus = ApexPages.currentPage().getParameters().get('status');
    if (filterByStatus == '' || filterByStatus == null) {
      filterByStatus = 'Show All';
    }
    filterByLocation = ApexPages.currentPage().getParameters().get('loc');
    if (filterByLocation == '' || filterByLocation == null) {
      filterByLocation = 'Show All';
    }

    appType = '';
    appTypeOptions = new List<SelectOption>();
    appTypeOptions.add(new SelectOption('Show All', 'Show All'));
    appTypeOptions.add(new SelectOption('UA Catalyst', 'Catalyst'));
    appTypeOptions.add(new SelectOption('UA Freedom', 'Freedom'));
    appTypeOptions.add(new SelectOption('UA Pride', 'Pride'));

    reviewer = '';
    reviewerOptions = new List<SelectOption>();
    reviewerOptions = spf.getPicklistOptions(
      'Application__c',
      'Reviewers__c',
      'Show All'
    );
  }

  public List<SelectOption> getFilterByStatusOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Show All', 'Show All'));
    options.add(new SelectOption('Submitted', 'Submitted'));
    options.add(new SelectOption('Reviewed', 'Reviewed'));
    options.add(new SelectOption('Awarded', 'Awarded'));
    options.add(new SelectOption('Closed', 'Closed'));
    return options;
  }

  public List<SelectOption> getFilterByLocationOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Show All', 'Show All'));

    Schema.DescribeFieldResult fieldResult = Application__c.Cities_Served__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f : ple) {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
    }
    return options;
  }

  public void getMap() {
    app_map.clear();
    showMore = false;
    noResults = false;

    if (userAcct != null) {
      //if(filterByStatus == null || filterByStatus == '') filterByStatus = 'Show All';
      //if(filterByLocation == null || filterByLocation == '') filterByLocation = 'Show All';

      String soql = 'SELECT Name, Organization_Name__c, EIN__c, Status__c, Cities_Served__c, Total_Amount_Requested__c, Submitted_Date__c';
      soql +=
        ' FROM Application__c WHERE National_Organization__c = \'' +
        userAcct.Id +
        '\'';
      if (name != '') {
        soql += ' AND Organization_Name__c LIKE \'%' + name + '%\'';
      }
      if (EIN != '') {
        soql += ' AND EIN__c LIKE \'%' + EIN + '%\'';
      }
      if (filterByStatus != 'Show All') {
        soql += ' AND Status__c = \'' + filterByStatus + '\'';
      }
      if (reviewer != 'Show All') {
        soql += ' AND Reviewers__c INCLUDES (\'' + reviewer + '\')';
      }
      if (appType != 'Show All') {
        soql += ' AND RecordType.Name = \'' + appType + '\'';
      }
      if (filterByStatus == 'Show All' || filterByLocation == 'Show All') {
        soql += ' LIMIT 100';
      }
      system.debug('soql = ' + soql);

      Integer count = 0;
      for (Application__c a : Database.query(soql)) {
        String name = a.Name;
        String cities = '';
        if (a.Cities_Served__c != null)
          cities = a.Cities_Served__c;
        if (count <= 80) {
          if (
            appId == '' ||
            name.toLowerCase().contains(String.valueOf(appId).toLowerCase())
          ) {
            if (
              filterByLocation == '' ||
              filterByLocation == 'Show All' ||
              cities.toLowerCase()
                .contains(String.valueOf(filterByLocation).toLowerCase())
            ) {
              if (app_map.containsKey(a.Cities_Served__c)) {
                List<Application__c> app_list = app_map.get(a.Cities_Served__c);
                app_list.add(a);
                app_map.put(a.Cities_Served__c, app_list);
              } else {
                app_map.put(a.Cities_Served__c, new List<Application__c>{ a });
              }
              count++;
            }
          }
        } else {
          showMore = true;
          if (filterByStatus != 'Show All' && filterByLocation != 'Show All') {
            limitReached = true;
          }
        }
      }
      if (count < 1) {
        noResults = true;
      }
    }
  }

  public void getList() {
    app_list.clear();
    if (userAcct != null) {
      String soql = 'SELECT Name, Organization_Name__c, Status__c, Cities_Served__c, Total_Amount_Requested__c';
      soql +=
        ' FROM Application__c WHERE National_Organization__c = \'' +
        userAcct.Id +
        '\'';
      if (filterByStatus != 'Show All') {
        soql += ' AND Status__c = \'' + filterByStatus + '\'';
      }
      if (filterByLocation != 'Show All') {
        soql += ' AND Cities_Served__c = \'' + filterByLocation + '\'';
      }

      for (Application__c a : Database.query(soql)) {
        app_list.add(a);
      }
    }
  }
}
