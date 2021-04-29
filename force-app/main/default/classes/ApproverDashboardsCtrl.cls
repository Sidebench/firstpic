public with sharing class ApproverDashboardsCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String portalName { get; set; }

  public Id grantId { get; set; }
  public List<SelectOption> grantOptions { get; set; }
  public String status { get; set; }
  public List<SelectOption> statusOptions { get; set; }

  private GrantClass gc = new GrantClass();

  private ReimbursementClass rc = new ReimbursementClass();
  public Map<Id, approverClass> approver_map { get; set; }
  public List<requestClass> request_list { get; set; }

  private ContactClass cc = new ContactClass();
  public Id approverId { get; set; }
  public Contact approver { get; set; }
  public Decimal totalActiveCount { get; set; }
  public Decimal totalAverageTime { get; set; }
  public Decimal totalAverageSendBacks { get; set; }
  public Integer numberOfApprovals { get; set; }
  public Date dt = date.today();

  public ApproverDashboardsCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    portalName = uc.userProfile;

    approver = new Contact();
    approver_map = new Map<Id, approverClass>();
    request_list = new List<requestClass>();

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    if (urlGrantId != '' && urlGrantId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlGrantId)
          .matches()
      ) {
        grantId = Id.valueOf(urlGrantId);
      }
    }
    grantOptions = new List<SelectOption>();
    grantOptions = gc.getGrantOptions(
      uc.userAcctType,
      userAcct.Id,
      null,
      '',
      '',
      'grant',
      ''
    );

    statusOptions = new List<SelectOption>();
    statusOptions.add(new SelectOption('View All', 'View All'));

    String urlApproverId = ApexPages.currentPage()
      .getParameters()
      .get('approverId');
    if (
      urlApproverId != '' &&
      urlApproverId != null &&
      Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
        .matcher(urlApproverId)
        .matches()
    ) {
      approverId = Id.valueOf(urlApproverId);
    }
    if (approverId != null)
      approver = cc.getContact(approverId);

    totalActiveCount = 0;
    totalAverageTime = 0;
    totalAverageSendBacks = 0;
    numberOfApprovals = 3;
  }

  public void getReimbursementLists() {
    approver_map.clear();
    request_list.clear();
    totalActiveCount = 0;
    totalAverageTime = 0;
    totalAverageSendBacks = 0;

    Map<Id, String> names = new Map<Id, String>();
    Map<Id, Decimal> activeRequests_map = new Map<Id, Decimal>();
    Map<Id, Decimal> avgTimeSinceLastSubmitted_map = new Map<Id, Decimal>();
    Map<Id, Decimal> sendBacks_L2 = new Map<Id, Decimal>();
    Map<Id, Decimal> sendBacks_L3 = new Map<Id, Decimal>();
    Map<Id, Decimal> sendBacks_L4 = new Map<Id, Decimal>();
    Map<Id, Decimal> daysWithAffiliate = new Map<Id, Decimal>();
    Map<Id, List<Reimbursement_Request__c>> r_map = new Map<Id, List<Reimbursement_Request__c>>();

    String soqlAND = '';
    if (approverId != null)
      soqlAND = ' AND Primary_Approver_Id__c = \'' + approverId + '\'';
    if (grantId != null)
      soqlAND += ' AND Grant__r.National_Grant__c = \'' + grantId + '\'';

    Set<String> statuses = new Set<String>();
    if (status == null || status == '')
      soqlAND += ' AND (Status__c LIKE \'Pending%\' OR Status__c LIKE \'Revision%\')';
    else
      soqlAND += ' AND Status__c = \'' + status + '\'';

    system.debug('ApproverDashboardsCtrl soqlAND = ' + soqlAND);
    for (
      Reimbursement_Request__c r : rc.getRelatedRequests(
        userAcct.Id,
        null,
        null,
        null,
        null,
        null,
        null,
        soqlAND
      )
    ) {
      if (r.Number_of_Approvals_Required__c == 4)
        numberOfApprovals = 4;
      totalActiveCount++;
      Id paId = r.Primary_Approver_Id__c;
      names.put(paId, r.Primary_Approver_Name__c);

      if (activeRequests_map.containsKey(paId))
        activeRequests_map.put(paId, activeRequests_map.get(paId) + 1);
      else
        activeRequests_map.put(paId, 1);

      if (r_map.containsKey(paId)) {
        List<Reimbursement_Request__c> rs = r_map.get(paId);
        rs.add(r);
        r_map.put(paId, rs);
      } else {
        r_map.put(paId, new List<Reimbursement_Request__c>{ r });
      }

      if (approverId != null) {
        requestClass rc = new requestClass(r);
        request_list.add(rc);

        if (!statuses.contains(r.Status__c)) {
          statusOptions.add(new SelectOption(r.Status__c, r.Status__c));
          statuses.add(r.Status__c);
        }
      }
    }

    Decimal totalSendBacks = 0;
    Decimal totalCount = 0;
    for (Id i : r_map.keySet()) {
      Decimal count = 0;
      Decimal daysInProcess = 0;
      Decimal totalSendBacksL2 = 0;
      Decimal totalSendBacksL3 = 0;
      Decimal totalSendBacksL4 = 0;
      Decimal totalDaysWithAffiliate = 0;

      for (Reimbursement_Request__c r : r_map.get(i)) {
        totalCount++;
        count++;
        if (r.Request_Date__c != null) {
          daysInProcess += (r.Request_Date__c).daysBetween(dt);
        }
        if (r.Level_One_Sent_Back_Date__c != null) {
          if (
            r.Status__c == 'Revisions Needed' ||
            r.Status__c == 'Revision in Progress'
          ) {
            totalDaysWithAffiliate += (r.Level_One_Sent_Back_Date__c)
              .daysBetween(dt);
          } else {
            totalDaysWithAffiliate += (r.Level_One_Sent_Back_Date__c)
              .daysBetween(r.Request_Date__c);
          }
        }
        if (r.Level_One_Sent_Back_Count__c != null) {
          totalSendBacks += r.Level_One_Sent_Back_Count__c;
        }
        if (r.Level_One_Sent_Back_Count__c != null) {
          totalSendBacks += r.Level_One_Sent_Back_Count__c;
        }
        if (r.Level_Two_Sent_Back_Count__c != null) {
          totalSendBacks += r.Level_Two_Sent_Back_Count__c;
          totalSendBacksL2 += r.Level_Two_Sent_Back_Count__c;
        }
        if (r.Level_Three_Sent_Back_Count__c != null) {
          totalSendBacks += r.Level_Three_Sent_Back_Count__c;
          totalSendBacksL3 += r.Level_Three_Sent_Back_Count__c;
        }
        if (r.Level_Four_Sent_Back_Count__c != null) {
          totalSendBacks += r.Level_Four_Sent_Back_Count__c;
          totalSendBacksL4 += r.Level_Four_Sent_Back_Count__c;
        }
      }
      if (daysInProcess > 0)
        avgTimeSinceLastSubmitted_map.put(i, daysInProcess.divide(count, 1));
      else
        avgTimeSinceLastSubmitted_map.put(i, 0);
      if (totalSendBacksL2 > 0)
        sendBacks_L2.put(i, totalSendBacksL2.divide(count, 1));
      else
        sendBacks_L2.put(i, 0);
      if (totalSendBacksL3 > 0)
        sendBacks_L3.put(i, totalSendBacksL3.divide(count, 1));
      else
        sendBacks_L3.put(i, 0);
      if (totalSendBacksL4 > 0)
        sendBacks_L4.put(i, totalSendBacksL4.divide(count, 1));
      else
        sendBacks_L4.put(i, 0);
      if (totalDaysWithAffiliate > 0)
        daysWithAffiliate.put(i, totalDaysWithAffiliate.divide(count, 1));
      else
        daysWithAffiliate.put(i, 0);
    }

    // 	Avg. time with reimbursement (days)
    Decimal totalDaysAllApprovers = 0;
    Integer count = 0;
    for (Decimal d : avgTimeSinceLastSubmitted_map.values()) {
      totalDaysAllApprovers += d;
      count++;
    }
    if (totalDaysAllApprovers > 0 && count > 0)
      totalAverageTime = totalDaysAllApprovers.divide(count, 1);
    if (totalDaysAllApprovers > 0 && totalCount > 0)
      totalAverageSendBacks = totalSendBacks.divide(totalCount, 1);

    if (approverId == null) {
      for (Id i : names.keySet()) {
        String n = names.get(i);
        Decimal d1 = 0;
        Decimal d2 = 0;
        Decimal d3 = 0;
        Decimal d4 = 0;
        Decimal d5 = 0;
        Decimal d6 = 0;

        if (activeRequests_map.containsKey(i))
          d1 = activeRequests_map.get(i);
        if (avgTimeSinceLastSubmitted_map.containsKey(i))
          d2 = avgTimeSinceLastSubmitted_map.get(i);
        if (sendBacks_L2.containsKey(i))
          d3 = sendBacks_L2.get(i);
        if (sendBacks_L3.containsKey(i))
          d4 = sendBacks_L3.get(i);
        if (sendBacks_L4.containsKey(i))
          d5 = sendBacks_L4.get(i);
        if (daysWithAffiliate.containsKey(i))
          d6 = daysWithAffiliate.get(i);

        approverClass ac = new approverClass(n, d1, d2, d3, d4, d5, d6);
        approver_map.put(i, ac);
      }
    }
  }

  // BEGIN Inner Classes
  public class approverClass {
    public String name { get; set; }
    public Decimal activeCount { get; set; }
    public Decimal averageTime { get; set; }
    public Decimal averageL2SendBacks { get; set; }
    public Decimal averageL3SendBacks { get; set; }
    public Decimal averageL4SendBacks { get; set; }
    public Decimal averageDaysWithAffiliate { get; set; }

    public approverClass(
      String n,
      Decimal d1,
      Decimal d2,
      Decimal d3,
      Decimal d4,
      Decimal d5,
      Decimal d6
    ) {
      name = n;
      activeCount = d1;
      averageTime = d2;
      if (d3 > 0)
        averageL2SendBacks = d3.setScale(1);
      else
        averageL2SendBacks = 0;
      if (d4 > 0)
        averageL3SendBacks = d4.setScale(1);
      else
        averageL3SendBacks = 0;
      if (d5 > 0)
        averageL4SendBacks = d5.setScale(1);
      else
        averageL4SendBacks = 0;
      if (d6 > 0)
        averageDaysWithAffiliate = d6.setScale(1);
      else
        averageDaysWithAffiliate = 0;
    }
  }

  public class requestClass {
    public Id rId { get; set; }
    public String affiliateName { get; set; }
    public String grantName { get; set; }
    public String name { get; set; }
    public String status { get; set; }
    public Decimal daysInProcess { get; set; }
    public Decimal daysWithAffiliate { get; set; }
    public Decimal daysWithL1 { get; set; }
    public Decimal daysWithL2 { get; set; }
    public Decimal daysWithL3 { get; set; }
    public Decimal daysWithL4 { get; set; }

    // BEGIN Inner Class Constructor
    public requestClass(Reimbursement_Request__c r) {
      rId = r.Id;
      affiliateName = r.Organization__c;
      grantName = r.Grant__r.Name;
      name = r.Name;
      status = r.Status__c;

      daysInProcess = 0;
      daysWithL1 = 0;
      daysWithL2 = 0;
      daysWithL3 = 0;
      daysWithL4 = 0;
      daysWithAffiliate = 0;

      Date dt = date.today();
      Date rd = r.Request_Date__c;
      Date l1a = r.Level_One_Approved_Date__c;
      Date l2a = r.Level_Two_Approved_Date__c;
      Date l3a = r.Level_Three_Approved_Date__c;
      Date l1sb = r.Level_One_Sent_Back_Date__c;
      Date l2sb = r.Level_Two_Sent_Back_Date__c;
      Date l3sb = r.Level_Three_Sent_Back_Date__c;
      Date l4sb = r.Level_Four_Sent_Back_Date__c;
      Date md = r.Modification_Last_Submitted_Date__c;

      if (rd != null)
        daysInProcess = rd.daysBetween(dt);
      /*
            if(r.Request_Date__c != null) {
                if(r.Number_of_Approvals_Required__c == 3 && l3a != null) daysInProcess = requestDate.daysBetween(l3a);
                else if(r.Number_of_Approvals_Required__c == 4 && l4a != null) daysInProcess = requestDate.daysBetween(l4a);
                else daysInProcess = requestDate.daysBetween(dt);
            }
			*/

      if (r.Status__c == 'Pending First Approval') {
        if (md != null)
          daysWithL1 = md.daysBetween(dt);
        else if (l2sb != null) {
          daysWithL1 = l2sb.daysBetween(dt);
          if (l1a != null)
            daysWithL2 = l1a.daysBetween(l2sb);
        } else {
          daysWithL1 = rd.daysBetween(dt);
        }
      } else if (r.Status__c == 'Pending Second Approval') {
        if (l1a != null) {
          if (md != null)
            daysWithL1 = md.daysBetween(l1a);
          else if (rd != null)
            daysWithL1 = rd.daysBetween(l1a);
        }
        if (l3sb != null) {
          daysWithL2 = l3sb.daysBetween(dt);
          if (l2a != null)
            daysWithL3 = l2a.daysBetween(l3sb);
        } else {
          daysWithL2 = l1a.daysBetween(dt);
        }
      } else if (r.Status__c == 'Pending Third Approval') {
        if (l1a != null) {
          if (md != null)
            daysWithL1 = md.daysBetween(l1a);
          else if (rd != null)
            daysWithL1 = rd.daysBetween(l1a);
          if (l2a != null)
            daysWithL2 = l1a.daysBetween(l2a);
        }
        if (l2a != null)
          daysWithL3 = l2a.daysBetween(dt);
      } else if (r.Status__c == 'Pending Fourth Approval') {
        if (l1a != null) {
          if (md != null)
            daysWithL1 = md.daysBetween(l1a);
          else if (rd != null)
            daysWithL1 = rd.daysBetween(l1a);
          if (l2a != null)
            daysWithL2 = l1a.daysBetween(l2a);
        }
        if (l3a != null) {
          if (l2a != null)
            daysWithL3 = l2a.daysBetween(l3a);
          daysWithL3 = l3a.daysBetween(dt);
        }
      }
      if (
        (r.Status__c == 'Revisions Needed' ||
        r.Status__c == 'Revision in Progress') && l1sb != null
      ) {
        daysWithAffiliate = l1sb.daysBetween(dt);
        daysWithL1 = rd.daysBetween(l1sb);
      }
    }
  }

  public void testInnerClasses() {
    approverClass ac = new approverClass('n', 1, 2, 3, 4, 5, 6);
    Reimbursement_Request__c r1 = new Reimbursement_Request__c(
      Status__c = 'Pending First Approval',
      Request_Date__c = date.today(),
      Level_Two_Sent_Back_Date__c = date.today()
    );
    requestClass rc1 = new requestClass(r1);

    Reimbursement_Request__c r2 = new Reimbursement_Request__c(
      Status__c = 'Pending Second Approval',
      Request_Date__c = date.today(),
      Level_One_Approved_Date__c = date.today(),
      Level_Three_Sent_Back_Date__c = date.today()
    );
    requestClass rc2 = new requestClass(r2);

    Reimbursement_Request__c r3 = new Reimbursement_Request__c(
      Status__c = 'Pending Third Approval',
      Request_Date__c = date.today(),
      Level_One_Approved_Date__c = date.today(),
      Level_Two_Approved_Date__c = date.today()
    );
    requestClass rc3 = new requestClass(r3);

    Reimbursement_Request__c r4 = new Reimbursement_Request__c(
      Status__c = 'Pending Fourth Approval',
      Request_Date__c = date.today(),
      Level_One_Approved_Date__c = date.today(),
      Level_Three_Approved_Date__c = date.today()
    );
    requestClass rc4 = new requestClass(r4);
  }
}
