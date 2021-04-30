public with sharing class ReimbursementDashboardCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }

  public Id ApproverId { get; set; }
  public Contact approver { get; set; }
  public Decimal totalActiveCount { get; set; }
  public Decimal totalAverageTime { get; set; }
  public Decimal totalAverageSendBacks { get; set; }

  public Map<Id, approverClass> approver_map { get; set; }
  public List<requestClass> request_list { get; set; }

  public ReimbursementDashboardCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    approver = new Contact();

    ApproverId = ApexPages.currentPage().getParameters().get('ApproverId');
    String qryWhere = ' WHERE Request_Date__c != null';
    if (userAcct != null) {
      qryWhere +=
        ' AND Grant__r.Account__r.National_Organization__c = \'' +
        userAcct.Id +
        '\'';
    }
    if (ApproverId != null) {
      qryWhere +=
        ' AND Grant__r.Account__r.Primary_Approver__c = \'' +
        ApproverID +
        '\'';
      approver = [SELECT Name FROM Contact WHERE Id = :ApproverId];
    } else {
      qryWhere += ' AND Grant__r.Account__r.Primary_Approver__c != null';
    }
    qryWhere += ' AND (Status__c = \'Pending First Approval\'';
    qryWhere += ' OR Status__c = \'Pending Second Approval\'';
    qryWhere += ' OR Status__c = \'Pending Final Approval\'';
    qryWhere += ' OR Status__c = \'Revisions Needed\'';
    qryWhere += ' OR Status__c = \'Revision in Progress\')';

    totalActiveCount = 0;
    totalAverageTime = 0;
    totalAverageSendBacks = 0;

    approver_map = new Map<Id, approverClass>();
    request_list = new List<requestClass>();

    Map<Id, String> name_map = new Map<Id, String>();
    String nameQry = 'SELECT Grant__r.Account__r.Primary_Approver__c, Grant__r.Account__r.Primary_Approver__r.Name';
    nameQry += ' FROM Reimbursement_Request__c ' + qryWhere;
    system.debug('>>> nameQry = ' + nameQry);
    for (Reimbursement_Request__c r : Database.query(nameQry)) {
      name_map.put(
        r.Grant__r.Account__r.Primary_Approver__c,
        r.Grant__r.Account__r.Primary_Approver__r.Name
      );
    }
    system.debug('>>> name_map = ' + name_map);

    Map<Id, Decimal> d1_map = new Map<Id, Decimal>();
    String d1Qry = 'SELECT count(Id) requestCount, Grant__r.Account__r.Primary_Approver__c';
    d1Qry += ' FROM Reimbursement_Request__c ' + qryWhere;
    d1Qry += ' GROUP BY Grant__r.Account__r.Primary_Approver__c';
    AggregateResult[] ar1 = Database.query(d1Qry);
    system.debug('>>> ar1 = ' + ar1);
    for (AggregateResult ar : ar1) {
      d1_map.put(
        (Id) ar.get('Primary_Approver__c'),
        (Decimal) ar.get('requestCount')
      );
      totalActiveCount += (Decimal) ar.get('requestCount');
    }
    system.debug('>>> d1_map = ' + d1_map);

    Map<Id, Decimal> d2_map = new Map<Id, Decimal>();
    Map<Id, List<Reimbursement_Request__c>> r_map = new Map<Id, List<Reimbursement_Request__c>>();
    String d2Qry = 'SELECT Name, Grant__r.Name, Grant__r.Account__r.Name, Grant__r.Account__r.National_Organization__c, Grant__r.Account__r.Primary_Approver__c, Grant__r.Account__r.Primary_Approver__r.Name';
    d2Qry += ', Status__c, Request_Date__c, Level_One_Approved_Date__c, Level_Two_Approved_Date__c, Level_Three_Approved_Date__c, Level_One_Sent_Back_Date__c, Level_Two_Sent_Back_Date__c, Level_Three_Sent_Back_Date__c, Modification_Last_Submitted_Date__c';
    d2Qry += ' FROM Reimbursement_Request__c ' + qryWhere;
    d2Qry += ' ORDER BY Status__c';
    for (Reimbursement_Request__c r : Database.query(d2Qry)) {
      if (userAcct != null) {
        if (r.Grant__r.Account__r.National_Organization__c == userAcct.Id) {
          if (r_map.containsKey(r.Grant__r.Account__r.Primary_Approver__r.Id)) {
            List<Reimbursement_Request__c> r_list = r_map.get(
              r.Grant__r.Account__r.Primary_Approver__r.Id
            );
            r_list.add(r);
            r_map.put(r.Grant__r.Account__r.Primary_Approver__r.Id, r_list);
          } else {
            r_map.put(
              r.Grant__r.Account__r.Primary_Approver__r.Id,
              new List<Reimbursement_Request__c>{ r }
            );
          }
        }
      }

      if (ApproverId != null) {
        requestClass rc = new requestClass(r);
        request_list.add(rc);
      }
    }
    system.debug('>>> r_map = ' + r_map);

    for (Id i : r_map.keySet()) {
      Integer[] myInts = new List<Integer>{};
      Decimal total = 0;
      for (Reimbursement_Request__c r : r_map.get(i)) {
        DateTime dt1 = r.Request_Date__c;
        DateTime dt2 = date.today();
        if (r.Level_Three_Approved_Date__c != null) {
          dt2 = r.Level_Three_Approved_Date__c;
        }
        Integer intDays = dt1.Date().daysBetween(dt2.Date());
        myInts.add(intDays);
      }
      for (Integer ii : myInts) {
        total += ii;
      }
      d2_map.put(i, total.divide(myInts.size(), 1, System.RoundingMode.UP));
    }
    system.debug('>>> d2_map = ' + d2_map);

    Decimal totalDays = 0;
    Integer count = 0;
    for (Decimal d : d2_map.values()) {
      totalDays += d;
      count++;
    }
    if (totalDays > 0 && count > 0) {
      totalAverageTime = totalDays.divide(count, 1, System.RoundingMode.UP);
    }

    Map<Id, Decimal> d3_map = new Map<Id, Decimal>();
    String d3Qry = 'SELECT Grant__r.Account__r.Primary_Approver__c, AVG(Level_Two_Sent_Back_Count__c)';
    d3Qry += ' FROM Reimbursement_Request__c ' + qryWhere;
    d3Qry += ' GROUP BY Grant__r.Account__r.Primary_Approver__c';
    AggregateResult[] ar3 = Database.query(d3Qry);
    system.debug('>>> ar3 = ' + ar3);
    for (AggregateResult ar : ar3) {
      d3_map.put((Id) ar.get('Primary_Approver__c'), (Decimal) ar.get('expr0'));
    }
    system.debug('>>> d3_map = ' + d3_map);

    Decimal totalCount = 0;
    Integer apCount = 0;
    for (Decimal d : d3_map.values()) {
      if (d > 0) {
        totalCount += d;
      }
      apCount++;
    }
    if (totalDays > 0 && apCount > 0) {
      totalAverageSendBacks = totalCount.divide(apCount, 2);
    }

    Map<Id, Decimal> d4_map = new Map<Id, Decimal>();
    String d4Qry = 'SELECT Grant__r.Account__r.Primary_Approver__c, AVG(Level_Three_Sent_Back_Count__c)';
    d4Qry += ' FROM Reimbursement_Request__c ' + qryWhere;
    d4Qry += ' GROUP BY Grant__r.Account__r.Primary_Approver__c';
    AggregateResult[] ar4 = Database.query(d4Qry);
    system.debug('>>> ar4 = ' + ar4);
    for (AggregateResult ar : ar4) {
      d4_map.put((Id) ar.get('Primary_Approver__c'), (Decimal) ar.get('expr0'));
    }
    system.debug('>>> d4_map = ' + d4_map);

    for (Id i : name_map.keySet()) {
      String n = name_map.get(i);
      Decimal d1 = 0;
      Decimal d2 = 0;
      Decimal d3 = 0;
      Decimal d4 = 0;

      if (d1_map.containsKey(i)) {
        d1 = d1_map.get(i);
      }

      if (d2_map.containsKey(i)) {
        d2 = d2_map.get(i);
      }

      if (d3_map.containsKey(i)) {
        d3 = d3_map.get(i);
      }

      if (d4_map.containsKey(i)) {
        d4 = d4_map.get(i);
      }

      if (ApproverId == null) {
        approverClass ac = new approverClass(n, d1, d2, d3, d4);
        approver_map.put(i, ac);
      }
    }
    system.debug('>>> approver_map = ' + approver_map);
  }

  // BEGIN Inner Classes
  public class approverClass {
    //ReimbursementDashboardCtrl outerClass;

    public String name { get; set; }
    public Decimal activeCount { get; set; }
    public Decimal averageTime { get; set; }
    public Decimal averageL2SendBacks { get; set; }
    public Decimal averageL3SendBacks { get; set; }

    // BEGIN Inner Class Constructor
    public approverClass(
      String n,
      Decimal d1,
      Decimal d2,
      Decimal d3,
      Decimal d4
    ) {
      name = n;
      activeCount = d1;
      averageTime = d2;
      if (d3 > 0) {
        averageL2SendBacks = d3.setScale(3);
      } else {
        averageL2SendBacks = 0;
      }
      if (d4 > 0) {
        averageL3SendBacks = d4.setScale(3);
      } else {
        averageL3SendBacks = 0;
      }
    }
  }

  public class requestClass {
    public Id rId { get; set; }
    public String affiliateName { get; set; }
    public String grantName { get; set; }
    public String name { get; set; }
    public String status { get; set; }
    public Decimal daysInProcess { get; set; }
    public Decimal daysWithL1 { get; set; }
    public Decimal daysWithL2 { get; set; }
    public Decimal daysWithL3 { get; set; }
    public Decimal daysWithAffiliate { get; set; }

    // BEGIN Inner Class Constructor
    public requestClass(Reimbursement_Request__c r) {
      rId = r.Id;
      affiliateName = r.Grant__r.Account__r.Name;
      grantName = r.Grant__r.Name;
      name = r.Name;
      status = r.Status__c;

      daysInProcess = 0;
      daysWithL1 = 0;
      daysWithL2 = 0;
      daysWithL3 = 0;
      daysWithAffiliate = 0;

      Date dt = date.today();
      Date requestDate = r.Request_Date__c;

      if (r.Request_Date__c != null) {
        if (r.Level_Three_Approved_Date__c != null) {
          Date d = r.Level_Three_Approved_Date__c;
          daysInProcess = requestDate.daysBetween(d);
        } else {
          daysInProcess = requestDate.daysBetween(dt);
        }
      }

      if (r.Status__c == 'Pending First Approval') {
        if (r.Modification_Last_Submitted_Date__c != null) {
          Date d = r.Modification_Last_Submitted_Date__c;
          daysWithL1 = d.daysBetween(dt);
        } else if (r.Level_Two_Sent_Back_Date__c != null) {
          Date d1 = r.Level_Two_Sent_Back_Date__c;
          daysWithL1 = d1.daysBetween(dt);

          if (r.Level_One_Approved_Date__c != null) {
            Date d2 = r.Level_One_Approved_Date__c;
            daysWithL2 = d2.daysBetween(d1);
          }
        } else {
          daysWithL1 = requestDate.daysBetween(dt);
        }
      }
      if (r.Status__c == 'Pending Second Approval') {
        Date d1 = r.Level_One_Approved_Date__c;

        if (r.Modification_Last_Submitted_Date__c != null) {
          Date d2 = r.Modification_Last_Submitted_Date__c;
          daysWithL1 = d2.daysBetween(d1);
        } else if (
          r.Request_Date__c != null &&
          r.Level_One_Approved_Date__c != null
        ) {
          daysWithL1 = requestDate.daysBetween(d1);
        }

        if (r.Level_Three_Sent_Back_Date__c != null) {
          Date d2 = r.Level_Three_Sent_Back_Date__c;
          daysWithL2 = d2.daysBetween(dt);

          if (r.Level_Two_Approved_Date__c != null) {
            Date d3 = r.Level_Two_Approved_Date__c;
            daysWithL3 = d3.daysBetween(d2);
          }
        } else {
          daysWithL2 = d1.daysBetween(dt);
        }
      }
      if (r.Status__c == 'Pending Final Approval') {
        Date d1 = r.Level_One_Approved_Date__c;
        Date d2 = r.Level_Two_Approved_Date__c;
        if (r.Modification_Last_Submitted_Date__c != null) {
          Date d3 = r.Modification_Last_Submitted_Date__c;
          daysWithL1 = d3.daysBetween(d1);
        } else if (r.Request_Date__c != null) {
          daysWithL1 = requestDate.daysBetween(d1);
        }
        daysWithL2 = d1.daysBetween(d2);
        daysWithL3 = d2.daysBetween(dt);
      }
      if (
        (r.Status__c == 'Revisions Needed' ||
        r.Status__c == 'Revision in Progress') &&
        r.Level_One_Sent_Back_Date__c != null
      ) {
        Date d = r.Level_One_Sent_Back_Date__c;
        daysWithAffiliate = d.daysBetween(dt);
        daysWithL1 = requestDate.daysBetween(d);
      }
    }
  }

  public void testInnerClasses() {
    approverClass ac = new approverClass('n', 1, 2, 3, 4);
    Reimbursement_Request__c testRequest1 = new Reimbursement_Request__c(
      Status__c = 'Pending First Approval',
      Request_Date__c = date.today()
    );
    requestClass rc1 = new requestClass(testRequest1);

    Reimbursement_Request__c testRequest2 = new Reimbursement_Request__c(
      Status__c = 'Pending Second Approval',
      Request_Date__c = date.today(),
      Level_One_Approved_Date__c = date.today()
    );
    requestClass rc2 = new requestClass(testRequest2);
  }
}
