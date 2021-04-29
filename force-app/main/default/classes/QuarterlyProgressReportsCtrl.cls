public without sharing class QuarterlyProgressReportsCtrl {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  private AccountClass ac = new AccountClass();
  private ProgressReportClass prc = new ProgressReportClass();
  private DCTATReportClass drc = new DCTATReportClass();
  private PaginationClass pc = new PaginationClass();
  private GetIdFromString gifs = new GetIdFromString();
  private SchemaPicklistFields spf = new SchemaPicklistFields();

  public List<innerClass> allItems { get; set; }
  public List<innerClass> items { get; set; }

  public String orgName { get; set; }
  public String grantId { get; set; }
  public String grantStatus { get; set; }
  public Id siteId { get; set; }
  public List<SelectOption> siteOptions { get; set; }
  public String siteName { get; set; }
  public String year { get; set; }
  public List<SelectOption> yearOptions { get; set; }
  public Boolean viewAll { get; set; }

  public Date dt = date.today();
  public String errorMessage { get; set; }
  public String successMessage { get; set; }

  Integer counter = 0;
  Integer limitSize = 40;
  Integer totalSize = 0;
  public String recordCount { get; set; }
  public Boolean disablePrevious { get; set; }
  public Boolean disableNext { get; set; }

  public QuarterlyProgressReportsCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    allItems = new List<innerClass>();
    items = new List<innerClass>();

    orgName = ApexPages.currentPage().getParameters().get('orgName');

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);
    grantStatus = ApexPages.currentPage().getParameters().get('grantStatus');

    siteOptions = new List<SelectOption>();
    String urlSiteId = ApexPages.currentPage().getParameters().get('siteId');
    siteId = gifs.getId(urlSiteId);
    getSiteOptions();

    yearOptions = new List<SelectOption>();
    year = ApexPages.currentPage().getParameters().get('year');
    if (portalName == 'Ripken') {
      yearOptions = spf.getPicklistOptions(
        'Grantee_Report__c',
        'Year__c',
        null
      );
      if (year == null)
        year = String.valueOf(dt.year());
    }

    /*
        status = ApexPages.currentPage().getParameters().get('status'); 
        sortByOptions = new List<SelectOption>();
        sortByOptions.add(new SelectOption('Name','Report Title'));
        sortByOptions.add(new SelectOption('Status__c', 'Status'));
        sortBy = 'Name';
		*/

    viewAll = true;
    String urlViewAll = ApexPages.currentPage().getParameters().get('viewAll');
    if (
      urlViewAll == 'false' ||
      (urlViewAll == null &&
      approverLevel == 'Level One')
    )
      viewAll = false;

    if (portalName == 'Ripken')
      getDCTATLists();
    else
      getLists();
  }

  public void getSiteOptions() {
    siteOptions.clear();
    if (userAcctType != 'Site')
      siteOptions.add(new SelectOption('', 'View All'));
    for (
      Account a : ac.getRelatedAccountList(
        userAcct.Id,
        userAcctType,
        '',
        orgName,
        null
      )
    ) {
      if (a.RecordType.Name == 'Site')
        siteOptions.add(new SelectOption(a.Id, a.Name));
    }
  }

  public void getLists() {
    system.debug('BEGIN getLists');
    allItems.clear();
    yearOptions.clear();
    getSiteOptions();

    Map<String, String> siteName_orgName_map = new Map<String, String>();
    Map<String, Id> q1 = new Map<String, Id>();
    Map<String, String> q1s = new Map<String, String>();
    Map<String, Id> q2 = new Map<String, Id>();
    Map<String, String> q2s = new Map<String, String>();
    Map<String, Id> q3 = new Map<String, Id>();
    Map<String, String> q3s = new Map<String, String>();
    Map<String, Id> q4 = new Map<String, Id>();
    Map<String, String> q4s = new Map<String, String>();

    Set<String> years = new Set<String>();
    years.add(String.valueOf(dt.year()));
    yearOptions.add(
      new SelectOption(String.valueOf(dt.year()), String.valueOf(dt.year()))
    );
    if (year == null)
      year = String.valueOf(dt.year());

    Id aId = userAcct.Id;
    if (siteId != null)
      aId = siteId;

    String soqlAND = '';
    if (grantId != null)
      soqlAND += ' AND Grant__c = \'' + grantId + '\'';
    if (grantStatus == 'Closed')
      soqlAND += ' AND Grant_Status__c = \'Closed\'';
    else
      soqlAND += ' AND Grant_Status__c != \'Closed\'';
    String prAND = soqlAND + ' AND RecordType.Name = \'Quarterly\'';

    if (siteId != null) {
      String organization = '';
      for (
        Progress_Report__c r : prc.getRelatedReportList(
          userAcct.Id,
          aId,
          userAcctType,
          orgName,
          null,
          null,
          null,
          null,
          null,
          prAND
        )
      ) {
        if (year == 'View All' || year == '' || r.Year__c == year) {
          if (r.Quarter__c == 'Q1') {
            q1.put(r.Year__c, r.Id);
            q1s.put(r.Year__c, r.Status__c);
          } else {
            q3.put(r.Year__c, r.Id);
            q3s.put(r.Year__c, r.Status__c);
          }
        }

        String y = String.valueOf(r.Year__c);
        if (!years.contains(y) && y != null) {
          years.add(y);
          yearOptions.add(new SelectOption(y, y));
        }

        organization = r.Local_Organization_Name__c;
        siteName = r.Organization_Name__c;
      }

      for (
        Grantee_Report__c r : drc.getRelatedReportList(
          aId,
          orgName,
          null,
          null,
          soqlAND
        )
      ) {
        if (year == 'View All' || year == '' || r.Year__c == year) {
          if (r.Quarter__c == 'Q2') {
            q2.put(r.Year__c, r.Id);
            q2s.put(r.Year__c, r.Report_Status__c);
          } else {
            q4.put(r.Year__c, r.Id);
            q4s.put(r.Year__c, r.Report_Status__c);
          }
        }

        String y = String.valueOf(r.Year__c);
        if (!years.contains(y) && y != null) {
          years.add(y);
          yearOptions.add(new SelectOption(y, y));
        }

        organization = r.Local_Organization_Name__c;
        siteName = r.Organization_Name__c;
      }

      for (String i : years) {
        if (year == 'View All' || year == '' || i == year) {
          innerClass ic = new innerClass(
            this,
            organization,
            siteName,
            i,
            null,
            null,
            null,
            q1.get(i),
            q1s.get(i),
            q2.get(i),
            q2s.get(i),
            q3.get(i),
            q3s.get(i),
            q4.get(i),
            q4s.get(i)
          );
          allItems.add(ic);
        }
      }
    } else {
      for (
        Progress_Report__c r : prc.getRelatedReportList(
          aId,
          null,
          userAcctType,
          orgName,
          null,
          null,
          null,
          null,
          null,
          prAND
        )
      ) {
        if (year == 'View All' || year == '' || r.Year__c == year) {
          if (!siteName_orgName_map.containsKey(r.Organization_Name__c))
            siteName_orgName_map.put(
              r.Organization_Name__c,
              r.Local_Organization_Name__c
            );
          if (r.Quarter__c == 'Q1') {
            q1.put(r.Organization_Name__c, r.Id);
            q1s.put(r.Organization_Name__c, r.Status__c);
          } else {
            q3.put(r.Organization_Name__c, r.Id);
            q3s.put(r.Organization_Name__c, r.Status__c);
          }
        }

        String y = String.valueOf(r.Year__c);
        if (!years.contains(y) && y != null) {
          years.add(y);
          yearOptions.add(new SelectOption(y, y));
        }
      }

      for (
        Grantee_Report__c r : drc.getRelatedReportList(
          aId,
          orgName,
          null,
          null,
          soqlAND
        )
      ) {
        if (year == 'View All' || year == '' || r.Year__c == year) {
          if (!siteName_orgName_map.containsKey(r.Organization_Name__c))
            siteName_orgName_map.put(
              r.Organization_Name__c,
              r.Local_Organization_Name__c
            );
          if (r.Quarter__c == 'Q2') {
            q2.put(r.Organization_Name__c, r.Id);
            q2s.put(r.Organization_Name__c, r.Report_Status__c);
          } else {
            q4.put(r.Organization_Name__c, r.Id);
            q4s.put(r.Organization_Name__c, r.Report_Status__c);
          }
        }

        String y = String.valueOf(r.Year__c);
        if (!years.contains(y) && y != null) {
          years.add(y);
          yearOptions.add(new SelectOption(y, y));
        }
      }

      for (String i : siteName_orgName_map.keyset()) {
        innerClass ic = new innerClass(
          this,
          siteName_orgName_map.get(i),
          i,
          year,
          null,
          null,
          null,
          q1.get(i),
          q1s.get(i),
          q2.get(i),
          q2s.get(i),
          q3.get(i),
          q3s.get(i),
          q4.get(i),
          q4s.get(i)
        );
        allItems.add(ic);
      }
    }

    totalSize = allItems.size();
    allItems.sort();
    first();
  }

  public void getDCTATLists() {
    system.debug('BEGIN getDCTATLists');
    allItems.clear();

    Map<Id, Grantee_Report__c> dctat = new Map<Id, Grantee_Report__c>();
    Map<Id, Id> q2 = new Map<Id, Id>();
    Map<Id, String> q2s = new Map<Id, String>();
    Map<Id, Id> q4 = new Map<Id, Id>();
    Map<Id, String> q4s = new Map<Id, String>();

    String soqlAND = '';
    if (
      userAcctType == 'National Organization' &&
      portalName == 'Ripken' &&
      viewAll == false
    ) {
      soqlAND +=
        ' AND (Primary_Approver_Id__c = \'' +
        currentUser.ContactId +
        '\'';
      soqlAND +=
        ' OR (Secondary_Approver_Id__c = \'' +
        currentUser.ContactId +
        '\'';
      soqlAND += ' AND (Primary_Approver_On_Leave__c = true OR FirstPic_National_Org_Code__c = \'Ripken\')))';
    }

    if (grantStatus == 'Closed')
      soqlAND += ' AND Grant_Status__c = \'Closed\'';
    else
      soqlAND += ' AND Grant_Status__c != \'Closed\'';

    soqlAND += ' AND Year__c = \'' + year + '\'';
    system.debug('soqlAND = ' + soqlAND);

    for (
      Grantee_Report__c r : drc.getRelatedReportList(
        userAcct.Id,
        orgName,
        null,
        null,
        soqlAND
      )
    ) {
      dctat.put(r.Grant__r.Id, r);
      if (r.Quarter__c == 'Q2') {
        q2.put(r.Grant__r.Id, r.Id);
        q2s.put(r.Grant__r.Id, r.Report_Status__c);
      } else {
        q4.put(r.Grant__r.Id, r.Id);
        q4s.put(r.Grant__r.Id, r.Report_Status__c);
      }
    }

    for (Id i : dctat.keyset()) {
      innerClass ic = new innerClass(
        this,
        dctat.get(i).Organization_Name__c,
        null,
        null,
        dctat.get(i).Primary_Approver_Name__c,
        dctat.get(i).Grant_Type__c,
        dctat.get(i).Grant_Name__c,
        null,
        null,
        q2.get(i),
        q2s.get(i),
        null,
        null,
        q4.get(i),
        q4s.get(i)
      );
      allItems.add(ic);
    }

    totalSize = allItems.size();
    allItems.sort();
    first();
  }

  // BEGIN Inner Class
  public class innerClass implements Comparable {
    QuarterlyProgressReportsCtrl outerClass;

    public String orgName { get; set; }
    public String siteName { get; set; }
    public String year { get; set; }
    public String approver { get; set; }
    public String grantType { get; set; }
    public String grantName { get; set; }
    public Id q1Id { get; set; }
    public String q1Status { get; set; }
    public Id q2Id { get; set; }
    public String q2Status { get; set; }
    public Id q3Id { get; set; }
    public String q3Status { get; set; }
    public Id q4Id { get; set; }
    public String q4Status { get; set; }

    public innerClass(
      QuarterlyProgressReportsCtrl oc,
      String oname,
      String sname,
      String y,
      String aname,
      String gtype,
      String gname,
      Id q1,
      String q1s,
      Id q2,
      String q2s,
      Id q3,
      String q3s,
      Id q4,
      String q4s
    ) {
      this.outerClass = oc;
      orgName = oname;
      siteName = sname;
      year = y;
      approver = aname;
      grantType = gtype;
      grantName = gname;
      q1Id = q1;
      q1Status = q1s;
      q2Id = q2;
      q2Status = q2s;
      q3Id = q3;
      q3Status = q3s;
      q4Id = q4;
      q4Status = q4s;
    }

    public Integer compareTo(Object obj) {
      innerClass i = (innerClass) (obj);

      if (outerClass.siteName != null) {
        if (this.year < i.year)
          return 1;
        if (this.year == i.year)
          return 0;
      } else {
        if (this.orgName > i.orgName)
          return 1;
        if (this.orgName == i.orgName)
          return 0;
      }
      return -1;
    }
  }
  // END inner Class

  // BEGIN pagination
  public void first() {
    items.clear();
    counter = 0;
    if (limitSize <= allItems.size()) {
      for (Integer i = 0; i < limitSize; i++)
        items.add(allItems.get(i));
    } else {
      for (Integer i = 0; i < allItems.size(); i++)
        items.add(allItems.get(i));
    }
    getRecordCount();
    disablePrevious = true;
    getDisableNext();
  }

  public void next() {
    items.clear();
    counter = counter + limitSize;
    if ((counter + limitSize) <= allItems.size()) {
      for (Integer i = counter - 1; i < (counter + limitSize); i++)
        items.add(allItems.get(i));
    } else {
      for (Integer i = counter; i < allItems.size(); i++)
        items.add(allItems.get(i));
    }
    getRecordCount();
    disablePrevious = false;
    getDisableNext();
  }

  public void previous() {
    items.clear();
    counter = counter - limitSize;
    Integer totalSize = counter + limitSize;
    if (counter + limitSize > allItems.size())
      totalSize = allItems.size();
    else
      for (Integer i = counter; i < totalSize; i++)
        items.add(allItems.get(i));
    getRecordCount();
    getDisablePrevious();
    disableNext = false;
  }

  public void last() {
    items.clear();
    getLastCounter();
    for (Integer i = counter; i < allItems.size(); i++)
      items.add(allItems.get(i));
    getRecordCount();
    disablePrevious = false;
    disableNext = true;
  }

  public void getLastCounter() {
    if (math.mod(totalSize, limitSize) == 0) {
      counter = limitSize * ((totalSize / limitSize) - 1);
    } else if (math.mod(totalSize, limitSize) != 0) {
      counter = limitSize * ((totalSize / limitSize));
    }
    if (totalSize == 0)
      counter = 0;
  }

  public void getRecordCount() {
    recordCount = '';
    if (totalSize != 0) {
      recordCount += (counter + 1) + ' - ';
      if ((counter + limitSize) <= totalSize)
        recordCount += counter + limitSize;
      else
        recordCount += totalSize;
      recordCount += ' of ' + totalSize;
    }
  }

  public void getDisableNext() {
    if ((counter + limitSize) >= totalSize)
      disableNext = true;
    else
      disableNext = false;
  }

  public void getDisablePrevious() {
    if (counter == 0)
      disablePrevious = true;
    else
      disablePrevious = false;
  }
  // END pagination
}
