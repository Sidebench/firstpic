public without sharing class GrantClass {
  public GrantClass() {
    getSOQL();
  }
  public UserClass uc = new UserClass();
  public BudgetItemClass bic = new BudgetItemClass();
  public String soql { get; set; }
  public Id selectedGrantId { get; set; }
  private Date dt = date.today();
  private String fdt = dt.format();

  public void getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Grant__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    //expr = expr.removeEnd(', ');
    expr += 'RecordType.Name, Account__r.Id, Account__r.Name, Account__r.National_Organization__c, Account__r.RecordType.Name, Account__r.Signatory_Email__c';
    expr += ', National_Grant__r.Account__c, National_Grant__r.Year__c, National_Grant__r.Start_Date__c, National_Grant__r.End_Date__c, National_Grant__r.Duration__c, National_Grant__r.Indirect_Rate_Allowed__c, National_Grant__r.Number_of_Approvals_Required__c, National_Grant__r.Allow_Budget_to_Exceed_Award__c';
    expr += ', Application__r.Id, Application__r.Name';
    expr += ',(SELECT ID, Name, Description FROM Attachments ORDER BY LastModifiedDate desc)';

    soql = 'SELECT ' + expr + ' FROM Grant__c';
  }

  public List<Grant__c> getGrantList() {
    getSOQL();
    List<Grant__c> grant_list = new List<Grant__c>();
    grant_list = Database.query(soql);
    return grant_list;
  }

  public List<Grant__c> getRelatedGrants(Id acctId, String soqlAND) {
    List<Grant__c> grants = new List<Grant__c>();

    String qry = 'SELECT Id, Name, Grant_Status__c ';
    qry += ' FROM Grant__c WHERE RecordType.Name = \'Grant\'';
    if (acctId != null) {
      qry += ' AND Account__r.Id = \'' + acctId + '\'';
    }
    if (soqlAND != '' && soqlAND != null)
      qry += soqlAND;
    system.debug('getRelatedGrants qry = ' + qry);

    grants = database.query(qry);
    return grants;
  }

  public List<Grant__c> getRelatedSubGrants(
    Id acctId,
    Id grantId,
    String status,
    String sortBy,
    String orgName,
    String grantName,
    String soqlAND
  ) {
    List<Grant__c> grants = new List<Grant__c>();

    String qry = 'SELECT Id, Name, LastModifiedDate, Organization_Name__c, Amount__c, Balance__c, Grant_Status__c, Is_Active__c, Year__c, Reimbursements_Pending_Approval__c, Submitted_Balance__c ';
    qry += ', Total_Budgeted__c, Total_Item_Budget__c, Total_Item_Balance__c, Total_Requested_Amount__c, Total_Approved_Amount__c, Reimbursement_Requested_Amount__c, Reimbursement_Approved_Amount__c';
    qry += ', Account__r.Id, Account__r.Name, National_Grant__r.Account__c, Account__r.BBBS_Id__c';
    qry += ', Equipment_and_Materials_Value__c, EIN__c, Account_Address__c, Account_City__c, Account_State__c, Account_Zip__c';
    qry += ' FROM Grant__c WHERE RecordType.Name = \'Sub-Grant\'';
    if (grantId != null) {
      qry +=
        ' AND (Id = \'' +
        grantId +
        '\' OR National_Grant__r.Id = \'' +
        grantId +
        '\')';
    } else if (acctId != null) {
      qry +=
        ' AND (Account__r.Id = \'' +
        acctId +
        '\' OR National_Grant__r.Account__r.Id = \'' +
        acctId +
        '\')';
    }
    if (grantName != '' && grantName != null) {
      qry += ' AND Name LIKE \'%' + grantName + '%\'';
    } else {
      if (status != '' && status != null && status != 'View All') {
        if (status.toLowerCase() == 'pendingfirst')
          status = 'Pending First Approval';
        if (status.toLowerCase() == 'pendingsecond')
          status = 'Pending Second Approval';
        if (status.toLowerCase() == 'pendingfinal')
          status = 'Pending Final Approval';

        if (status == 'Pending Approval')
          qry += ' AND (Grant_Status__c LIKE \'Pending%\' OR Grant_Status__c = \'Pending Review\')';
        else if (status == 'All Revisions')
          qry += ' AND Grant_Status__c LIKE \'Revision%\'';
        else if (status == 'All In Progress')
          qry += ' AND (Grant_Status__c = \'\' OR Grant_Status__c LIKE \'Pending%\' OR Grant_Status__c LIKE \'Revision%\' OR Grant_Status__c = \'Incomplete\')';
        else
          qry += ' AND Grant_Status__c = \'' + status + '\'';
      }
      if (orgName != '' && orgName != null)
        qry += ' AND Account__r.Name LIKE \'%' + orgName + '%\'';
    }
    if (soqlAND != '' && soqlAND != null)
      qry += soqlAND;
    if (sortBy != '' && sortBy != null)
      qry += ' ORDER BY ' + sortBy + ' ASC';
    qry += ' LIMIT 1000';
    system.debug('getRelatedSubGrants qry = ' + qry);
    system.debug('getRelatedSubGrants grantId = ' + grantId);

    grants = database.query(qry);
    return grants;
  }

  public List<SelectOption> getGrantOptions(
    String userAcctType,
    Id acctId,
    Id grantId,
    String sortBy,
    String keyword,
    String listType,
    String soqlAND
  ) {
    List<SelectOption> grantOptions = new List<SelectOption>();

    String qry = 'SELECT Id, Name, Is_Active__c FROM Grant__c WHERE Name != \'null\'';
    if (acctId != null)
      qry +=
        ' AND (Account__r.Id = \'' +
        acctId +
        '\' OR National_Grant__r.Account__r.Id = \'' +
        acctId +
        '\')';
    if (grantId != null)
      qry +=
        ' AND (Id = \'' +
        grantId +
        '\' OR National_Grant__r.Id = \'' +
        grantId +
        '\')';
    if (keyword != '' && keyword != null)
      qry += ' AND Name LIKE \'%' + keyword + '%\'';
    if (soqlAND != '' && soqlAND != null)
      qry += soqlAND;

    String grantQry = qry + ' AND RecordType.Name = \'Grant\'';
    String subGrantQry = qry + ' AND RecordType.Name = \'Sub-Grant\'';
    if (sortBy != '') {
      grantQry += ' ORDER BY ' + sortBy + ' ASC';
      subGrantQry += ' ORDER BY ' + sortBy + ' ASC';
    }
    system.debug('grantQry = ' + grantQry);
    system.debug('subGrantQry = ' + subGrantQry);

    grantOptions.add(new SelectOption('', 'View All'));
    if (
      userAcctType == 'National Organization' &&
      (listType == null ||
      listType == '' ||
      listType == 'grant')
    ) {
      if (database.query(grantQry).size() > 0)
        grantOptions.add(new SelectOption('', 'Grants', true));
      for (Grant__c g : database.query(grantQry)) {
        grantOptions.add(new SelectOption(g.Id, g.Name));
        if (g.Is_Active__c)
          selectedGrantId = g.Id;
      }
    }
    if (listType == null || listType == '' || listType == 'subgrant') {
      if (database.query(subGrantQry).size() > 0)
        grantOptions.add(new SelectOption('', 'Sub-Grants', true));
      for (Grant__c g : database.query(subGrantQry))
        grantOptions.add(new SelectOption(g.Id, g.Name));
    }
    //if(grantOptions.size() == 1 && selectedGrantId == null) selectedGrantId = grantOptions.get(0);
    /*
        if(grantOptions.size() == 3) {
            grantOptions.remove(0);
            grantOptions.remove(0);
        }
        */
    return grantOptions;
  }

  public List<Grant__c> getGrantYears(Id acctId) {
    String qry = 'SELECT Year__c FROM Grant__c WHERE Name != \'null\'';
    if (acctId != null)
      qry +=
        ' AND (Account__r.Id = \'' +
        acctId +
        '\' OR National_Grant__r.Account__r.Id = \'' +
        acctId +
        '\')';
    qry += ' ORDER BY Name';
    List<Grant__c> grants = database.query(qry);
    return grants;
  }

  public Grant__c getGrant(Id grantId) {
    getSOQL();
    Grant__c grant = new Grant__c();
    if (grantId != null) {
      soql += ' WHERE Id = \'' + grantId + '\'';
      Grant__c[] grants = Database.query(soql);
      if (grants.size() > 0) {
        grant = grants[0];
      }
    }
    return grant;
  }

  public void upsertGrant(Grant__c grant) {
    try {
      upsert grant;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void upsertGrants(List<Grant__c> grants) {
    try {
      upsert grants;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void updateGrantDocStatus(Map<Id, Document__c> grantDocs) {
    List<Grant__c> grants = new List<Grant__c>();
    for (Grant__c g : [
      SELECT Id
      FROM Grant__c
      WHERE Id IN :grantDocs.keySet()
    ]) {
    }
  }

  public void closeGrant(Id grantId) {
    Grant__c grant = [
      SELECT
        Id,
        RecordType.Name,
        Grant_Status__c,
        Modification_History__c,
        FirstPic_National_Org_Code__c
      FROM Grant__c
      WHERE Id = :grantId
    ];
    system.debug('GrantClass closeGrant grant: ' + grant);

    List<Budget_Item__c> items = [
      SELECT
        RecordType.Name,
        Is_Active__c,
        Total_Approved_Salary__c,
        Wages__c,
        Total_Approved_Benefits__c,
        Fringe_Benefits__c,
        Item_Budget__c,
        Total_Approved_Amount__c
      FROM Budget_Item__c
      WHERE Grant__r.National_Grant__c = :grant.Id OR Grant__c = :grant.Id
    ];
    for (Budget_Item__c bi : items) {
      bi.Is_Active__c = false;
      if (bi.Total_Approved_Amount__c != null)
        bi.Item_Budget__c = bi.Total_Approved_Amount__c;
      if (bi.RecordType.Name == 'Labor') {
        if (bi.Total_Approved_Salary__c != null) {
          bi.Wages__c = bi.Total_Approved_Salary__c;
        } else {
          bi.Wages__c = 0;
        }
        if (bi.Total_Approved_Benefits__c != null) {
          bi.Fringe_Benefits__c = bi.Total_Approved_Benefits__c;
        } else {
          bi.Fringe_Benefits__c = 0;
        }
        if (grant.FirstPic_National_Org_Code__c == 'BBBSA')
          bi.Item_Budget__c = bi.Total_Approved_Salary__c;
        else
          bi.Item_Budget__c = bi.Wages__c + bi.Fringe_Benefits__c;
      }
    }
    bic.upsertItems(items);
    system.debug('GrantClass closeGrant budgetItems: ' + items);

    String modHist =
      fdt +
      ': Closed by ' +
      uc.currentUser.Contact.Name +
      ' (' +
      uc.currentUser.Id +
      ')';

    if (grant.RecordType.Name == 'Grant') {
      List<Grant__c> subgrants = [
        SELECT Grant_Status__c, Modification_History__c
        FROM Grant__c
        WHERE National_Grant__c = :grant.Id
      ];
      for (Grant__c i : subgrants) {
        if (i.Modification_History__c == null)
          i.Modification_History__c = modHist;
        else
          i.Modification_History__c += ' \r\n' + modHist;
        i.Grant_Status__c = 'Closed';
      }
      upsertGrants(subgrants);
    }

    if (grant.Modification_History__c == null)
      grant.Modification_History__c = modHist;
    else
      grant.Modification_History__c += ' \r\n' + modHist;
    grant.Grant_Status__c = 'Closed';
    upsertGrant(grant);
    system.debug('GrantClass closeGrant grant: ' + grant);

    List<Reimbursement_Request__c> requests = [
      SELECT Status__c
      FROM Reimbursement_Request__c
      WHERE Grant__r.National_Grant__c = :grant.Id OR Grant__c = :grant.Id
    ];
    for (Reimbursement_Request__c i : requests) {
      if (
        i.Status__c == 'Approved' ||
        i.Status__c == 'Paid' ||
        i.Status__c == 'Closed'
      ) {
        i.Status__c = 'Closed';
      } else {
        i.Status__c = 'Denied';
      }
    }
    ReimbursementClass rc = new ReimbursementClass();
    rc.upsertRequestList(requests);
    system.debug('GrantClass closeGrant requests: ' + requests);
  }

  public void reopenGrant(Id grantId) {
    Grant__c grant = [
      SELECT
        Id,
        RecordType.Name,
        Grant_Status__c,
        Modification_History__c,
        FirstPic_National_Org_Code__c
      FROM Grant__c
      WHERE Id = :grantId
    ];
    system.debug('GrantClass reopenGrant grant: ' + grant);

    List<Budget_Item__c> items = [
      SELECT
        RecordType.Name,
        Is_Active__c,
        Total_Approved_Salary__c,
        Wages__c,
        Total_Approved_Benefits__c,
        Fringe_Benefits__c,
        Item_Budget__c,
        Total_Approved_Amount__c
      FROM Budget_Item__c
      WHERE Grant__r.National_Grant__c = :grant.Id OR Grant__c = :grant.Id
    ];
    for (Budget_Item__c bi : items) {
      bi.Is_Active__c = true;
    }
    bic.upsertItems(items);
    system.debug('GrantClass closeGrant budgetItems: ' + items);

    String modHist =
      fdt +
      ': Reopened by ' +
      uc.currentUser.Contact.Name +
      ' (' +
      uc.currentUser.Id +
      ')';
    if (grant.Modification_History__c == null)
      grant.Modification_History__c = modHist;
    else
      grant.Modification_History__c += ' \r\n' + modHist;
    grant.Grant_Status__c = 'Revisions Needed';
    upsertGrant(grant);
    system.debug('GrantClass closeGrant grant: ' + grant);
  }
}
