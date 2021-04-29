public without sharing class ReimbursementClass {
  public String soql { get; set; }

  public ReimbursementClass() {
    getSOQL();
  }

  public String getSOQL() {
    String fields = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Reimbursement_Request__c.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      fields += fieldName + ', ';
    }
    //fields = fields.removeEnd(', ');
    fields += 'Grant__r.Name, Grant__r.Amount__c, Grant__r.Total_Item_Balance__c, Grant__r.Account__c, Grant__r.Account__r.Id, Grant__r.National_Grant__r.Account__c, Grant__r.National_Grant__r.Account__r.Id';
    fields += ', Level_One_Approver__r.Name, Level_Two_Approver__r.Name, Level_Three_Approver__r.Name';
    fields += ',(SELECT ID, Name, Description FROM Attachments ORDER BY LastModifiedDate desc)';

    soql = 'SELECT ' + fields + ' FROM Reimbursement_Request__c';
    return soql;
  }

  public Reimbursement_Request__c getRequest(Id requestId) {
    getSOQL();
    Reimbursement_Request__c request = new Reimbursement_Request__c();
    if (requestId != null) {
      soql += ' WHERE Id = \'' + requestId + '\'';
      Reimbursement_Request__c[] requests = Database.query(soql);
      if (requests.size() > 0) {
        request = requests[0];
      }
    }
    return request;
  }

  public List<Reimbursement_Request__c> getRequestList() {
    getSOQL();
    List<Reimbursement_Request__c> requestList = new List<Reimbursement_Request__c>();
    soql += ' ORDER BY Request_Date__c asc';
    requestList = Database.query(soql);
    return requestList;
  }

  public List<Reimbursement_Request__c> getRelatedRequests(
    Id acctId,
    Id grantId,
    String status,
    String sortBy,
    String orgName,
    String keyword,
    Id primaryApproverId,
    String soqlAND
  ) {
    List<Reimbursement_Request__c> requests = new List<Reimbursement_Request__c>();

    String qry = 'SELECT Id, Name, LastModifiedDate, Is_National_Request__c, Grant__r.Account__r.Id, Grant__r.Name, Grant__r.Grant_Type__c, Grant__r.National_Grant_Type__c, Primary_Approver_Id__c, Primary_Approver_Name__c, Number_of_Approvals_Required__c';
    qry += ', Organization__c, Request_Date__c, Start_Date__c, End_Date__c, Status__c, Paid_Date__c, Total_Approved_Amount__c, Total_Requested__c, Total_Requested_Amount__c, Prevent_Skip_Reimbursement_Approvals__c';
    qry += ', Level_One_Approved_Date__c, Level_Two_Approved_Date__c, Level_Three_Approved_Date__c, Level_Four_Approved_Date__c, Level_One_Sent_Back_Date__c, Level_Two_Sent_Back_Date__c, Level_Three_Sent_Back_Date__c, Level_Four_Sent_Back_Date__c, Level_One_Sent_Back_Count__c, Level_Two_Sent_Back_Count__c, Level_Three_Sent_Back_Count__c, Level_Four_Sent_Back_Count__c, Modification_Last_Submitted_Date__c';
    qry += ' FROM Reimbursement_Request__c WHERE Name != null';
    if (grantId != null) {
      qry +=
        ' AND (Grant__r.Id = \'' +
        grantId +
        '\' OR Grant__r.National_Grant__r.Id = \'' +
        grantId +
        '\')';
    } else if (acctId != null) {
      qry +=
        ' AND (Grant__r.Account__r.Id = \'' +
        acctId +
        '\' OR Grant__r.National_Grant__r.Account__r.Id = \'' +
        acctId +
        '\')';
    }
    if (keyword != '' && keyword != null) {
      qry +=
        ' AND (Name LIKE \'%' +
        keyword +
        '%\' OR Grant__r.Name LIKE \'%' +
        keyword +
        '%\')';
    } else {
      if (status != '' && status != null && status != 'View All') {
        if (status.toLowerCase() == 'pendingfirst')
          status = 'Pending First Approval';
        if (status.toLowerCase() == 'pendingsecond')
          status = 'Pending Second Approval';
        if (
          status.toLowerCase() == 'pendingfinal' ||
          status.toLowerCase() == 'pendingthird'
        )
          status = 'Pending Third Approval';

        if (status == 'Pending Approval')
          qry += ' AND Status__c LIKE \'Pending%\'';
        else if (status == 'All Revisions')
          qry += ' AND Status__c LIKE \'Revision%\'';
        else if (status == 'All In Progress')
          qry += ' AND (Status__c LIKE \'Pending%\' OR Status__c LIKE \'Revision%\' OR Status__c = \'Incomplete\')';
        else
          qry += ' AND Status__c = \'' + status + '\'';

        if (status == 'Pending First Approval' && primaryApproverId != null) {
          qry += ' AND (Primary_Approver_Id__c = \'' + primaryApproverId + '\'';
          qry +=
            ' OR (Secondary_Approver_Id__c = \'' +
            primaryApproverId +
            '\'';
          qry += ' AND (Primary_Approver_On_Leave__c = true OR FirstPic_National_Org_Code__c = \'Ripken\')))';
        }
      }
      if (orgName != '' && orgName != null)
        qry += ' AND Organization__c LIKE \'%' + orgName + '%\'';
      if (soqlAND != '' && soqlAND != null)
        qry += soqlAND;
    }
    if (sortBy != '' && sortBy != null)
      qry += ' ORDER BY ' + sortBy + ' ASC LIMIT 1000';
    system.debug('getRelatedRequests qry = ' + qry);

    requests = database.query(qry);
    return requests;
  }

  public void upsertRequest(Reimbursement_Request__c request) {
    try {
      upsert request;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void upsertRequestList(List<Reimbursement_Request__c> requestList) {
    try {
      upsert requestList;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void deleteRequest(Reimbursement_Request__c request) {
    try {
      delete request;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }
}
