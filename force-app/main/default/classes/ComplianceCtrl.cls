public with sharing class ComplianceCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  public Id OrgId { get; set; }
  public String orgName { get; set; }
  public Integer currentYear { get; set; }

  public Id AssessmentId { get; set; }
  public Assessment__c assess { get; set; }
  public List<Assessment__c> sa_list { get; set; }

  private GrantClass gc = new GrantClass();
  public List<SelectOption> grantOptions { get; set; }
  public Id grantId { get; set; }

  public List<SelectOption> years { get; set; }
  public String year { get; set; }
  public String keyword { get; set; }
  public String sortBy { get; set; }

  public List<Contact> contact_list { get; set; }
  public Boolean displayContactPopup { get; set; }

  public String reportType { get; set; }
  public String reportTitle { get; set; }
  public List<itemClass> item_list { get; set; }

  public Boolean runGetLists { get; set; }

  public ComplianceCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    Assessment__c assess = new Assessment__c();
    sa_list = new List<Assessment__c>();
    contact_list = new List<Contact>();

    grantOptions = new List<SelectOption>();
    for (Grant__c g : [
      SELECT Id, Name
      FROM Grant__c
      WHERE Account__c = :userAcct.Id AND RecordType.Name = 'Grant'
      ORDER BY Name DESC
    ]) {
      grantOptions.add(new SelectOption(g.Id, g.Name));
    }
    if (grantOptions.size() > 0)
      grantId = grantOptions[0].getValue();

    year = ApexPages.currentPage().getParameters().get('year');
    currentYear = 2020;
    years = new List<SelectOption>();
    years.add(new SelectOption('2020', '2020'));
    years.add(new SelectOption('2019', '2019'));
    years.add(new SelectOption('2018', '2018'));
    years.add(new SelectOption('2017', '2017'));
    years.add(new SelectOption('2016', '2016'));

    reportType = '';
    String urlType = ApexPages.currentPage().getParameters().get('type');
    if (urlType != null && urlType != '')
      reportType = urlType;
    reportTitle = 'Contacts Report';
    if (reportType == 'audit')
      reportTitle = 'Compliance Audit Report';
    if (reportType == 'ins')
      reportTitle = 'Compliance Insurance Report';
    if (reportType == 'incomplete')
      reportTitle = 'Incomplete Self-Assessments';
    item_list = new List<itemClass>();

    runGetLists = true;
  }

  // BEGIN getLists
  public void getLists() {
    if (runGetLists) {
      sa_list.clear();
      system.debug('>>> sortBy = ' + sortBy);
      system.debug('>>> keyword = ' + keyword);

      String soql = 'SELECT Year__c, Reviewed__c, Submitted_Date__c, Hide_Standards__c, LastModifiedDate, Organization__r.Name, Organization__r.BBBS_Id__c, Organization__r.Insurance_Provider__c, Organization__r.Insurance_Expiration_Date__c, Assessment_Status__c, Compliance_Status__c, Attachment_Status__c, Attachment_Notes__c, Fiscal_Year_Ended__c';
      soql += ', Organization__r.CEO__r.Name, Organization__r.CEO__r.Email, Organization__r.Finance_Lead__r.Name, Organization__r.Finance_Lead__r.Email';
      soql += ' FROM Assessment__c';
      if (year != null) {
        soql +=
          ' WHERE Year__c = ' +
          year +
          ' AND Organization__r.Is_Active__c = true';
      } else {
        soql +=
          ' WHERE Year__c = ' +
          currentYear +
          ' AND Organization__r.Is_Active__c = true';
      }
      if (sortBy != '' && sortBy != null) {
        soql += ' ORDER BY ' + sortBy + ' asc, LastModifiedDate desc';
      } else {
        soql += ' ORDER BY LastModifiedDate desc';
      }

      Set<Id> aIds = new Set<Id>();
      for (Assessment__c a : Database.query(soql)) {
        String s1 = a.Organization__r.Name;
        String s2 = '';
        if (a.Organization__r.BBBS_Id__c != null)
          s2 = String.valueOf(a.Organization__r.BBBS_Id__c);
        String k = '';
        if (keyword != null && keyword != '')
          k = String.valueOf(keyword).toLowerCase();

        if (k == '' || s1.toLowerCase().contains(k) || s2.contains(k)) {
          sa_list.add(a);
          aIds.add(a.Id);
        }
      }

      List<Document__c> docs = new List<Document__c>();
      docs = [
        SELECT Name, Assessment__c
        FROM Document__c
        WHERE Assessment__c IN :aIds
      ];
      for (Assessment__c a : sa_list) {
        if (reportType != '') {
          if (
            reportType != 'incomplete' ||
            (reportType == 'incomplete' &&
            a.Assessment_Status__c != 'Submitted' &&
            a.Assessment_Status__c != 'Closed')
          ) {
            itemClass ic = new itemClass(a, null, docs);
            item_list.add(ic);
          }
        }
      }
      runGetLists = false;
    }
  }
  // END getLists

  // BEGIN getContactList
  public void getContactList() {
    contact_list.clear();
    contact_list = [
      SELECT Id, Account.Name, Name, Title, Role__c, Email, Phone
      FROM Contact
      WHERE AccountId = :OrgId
    ];
  }
  // END getContactList

  // BEGIN popups
  public void contactPopup() {
    displayContactPopup = true;
    getContactList();
  }

  public void closeContactPopup() {
    displayContactPopup = false;
  }
  // END popups

  // BEGIN Inner Class
  public class itemClass {
    public Assessment__c sa { get; set; }
    public Decimal bbbsId { get; set; }
    public String name { get; set; }
    public Boolean hasAIM { get; set; }
    public Boolean hasFeeForm { get; set; }
    public Boolean hasAudit { get; set; }
    public Boolean hasIns { get; set; }
    public Date fiscal { get; set; }
    public Date afterFiscal { get; set; }
    public String insKirby { get; set; }
    public String insName { get; set; }
    public Date insDate { get; set; }
    public String ceoName { get; set; }
    public String ceoEmail { get; set; }
    public String leadName { get; set; }
    public String leadEmail { get; set; }

    // BEGIN Inner Class Constructor
    public itemClass(Assessment__c a, Account acct, List<Document__c> docs) {
      Id acctId;

      if (a != null) {
        sa = a;
        acctId = a.Organization__r.Id;
        bbbsId = a.Organization__r.BBBS_Id__c;
        name = a.Organization__r.Name;

        if (a.Organization__r.CEO__r.Name != null) {
          ceoName = a.Organization__r.CEO__r.Name;
          ceoEmail = a.Organization__r.CEO__r.Email;
        }
        if (a.Organization__r.Finance_Lead__r.Name != null) {
          leadName = a.Organization__r.Finance_Lead__r.Name;
          leadEmail = a.Organization__r.Finance_Lead__r.Email;
        }

        hasAIM = false;
        hasFeeForm = false;
        if (a.Fiscal_Year_Ended__c != null) {
          fiscal = a.Fiscal_Year_Ended__c;
          afterFiscal = fiscal.addMonths(9);
        }

        if (a.Organization__r.Insurance_Expiration_Date__c != null) {
          insDate = a.Organization__r.Insurance_Expiration_Date__c;

          if (a.Organization__r.Insurance_Provider__c != null) {
            insName = a.Organization__r.Insurance_Provider__c;
            insKirby = 'false';
          } else {
            insKirby = 'true';
          }
        }

        for (Document__c d : docs) {
          if (d.Assessment__c == a.Id) {
            String name = d.Name;
            if (name.contains('AIM Fee Form')) {
              hasAIM = true;
            }
            if (name.contains('Affiliation Fee Form')) {
              hasFeeForm = true;
            }
            if (name.contains('Audit')) {
              hasAudit = true;
            }
            if (name.contains('Proof of Insurance')) {
              hasIns = true;
            }
          }
        }
      } else if (acct != null) {
        acctId = acct.Id;
        bbbsId = acct.BBBS_Id__c;
        name = acct.Name;

        if (acct.CEO__r.Name != null) {
          ceoName = acct.CEO__r.Name;
          ceoEmail = acct.CEO__r.Email;
        }
        if (acct.Finance_Lead__r.Name != null) {
          leadName = acct.Finance_Lead__r.Name;
          leadEmail = acct.Finance_Lead__r.Email;
        }
      }
    }
    // END Inner class Constructor
  }
  // END inner Class

  public void testInnerClasses() {
    Account acct = new Account();
    Assessment__c assess = new Assessment__c();
    List<Document__c> docs = new List<Document__c>();
    itemClass ic = new itemClass(assess, acct, docs);
  }
}
