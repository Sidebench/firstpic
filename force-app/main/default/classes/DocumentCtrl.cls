public without sharing class DocumentCtrl {
  private getIdFromString gifs = new getIdFromString();
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }

  public Id orgId { get; set; }
  public String orgCode { get; set; }
  public Id grantId { get; set; }
  public Id assessmentId { get; set; }
  public Id reportId { get; set; }
  public Id requestId { get; set; }

  public String groupId { get; set; }
  public String newDocGroupId { get; set; }
  public String reportType { get; set; }
  public String objectType { get; set; }
  public String reportTitle { get; set; }
  public String year { get; set; }
  public String years { get; set; }
  public List<SelectOption> yearOptions { get; set; }

  private DocumentClass docClass = new DocumentClass();
  private AttachmentClass attClass = new AttachmentClass();
  public List<Document__c> doc_list { get; set; }
  public List<Attachment> att_list { get; set; }
  public List<Attachment> oldAtt_list { get; set; }

  public String fileNames { get; set; }
  public List<SelectOption> names_list { get; set; }
  public Boolean isNewDoc { get; set; }
  public Boolean attachNewDoc { get; set; }

  public String selectedDocId { get; set; }
  public Document__c selectedDoc { get; set; }
  public Date dueDate { get; set; }
  public Boolean displayDocPopup { get; set; }
  public Boolean displayDeleteDocPopup { get; set; }
  public String selectedAttId { get; set; }
  public Attachment selectedAtt { get; set; }
  public Boolean displayDeleteAttPopup { get; set; }

  private Date dt = date.today();
  private String fdt = dt.format();
  private String modHist = '';
  public String errorMessage { get; set; }

  public DocumentCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    String urlorg = ApexPages.currentPage().getParameters().get('org');
    if (urlorg != null)
      orgCode = urlorg.toUpperCase();

    String urlorgId = ApexPages.currentPage().getParameters().get('orgId');
    String urlsiteId = ApexPages.currentPage().getParameters().get('siteId');
    if (urlorgId != null)
      orgId = gifs.getId(urlorgId);
    if (urlsiteId != null)
      orgId = gifs.getId(urlsiteId);

    String urlgrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlgrantId);

    String urlassessmentId = ApexPages.currentPage()
      .getParameters()
      .get('assessmentId');
    assessmentId = gifs.getId(urlassessmentId);

    String urlReportId = ApexPages.currentPage()
      .getParameters()
      .get('reportId');
    reportId = gifs.getId(urlReportId);

    String urlRequestId = ApexPages.currentPage()
      .getParameters()
      .get('requestId');
    requestId = gifs.getId(urlRequestId);

    reportType = ApexPages.currentPage().getParameters().get('reportType');
    objectType = ApexPages.currentPage().getParameters().get('objectType');
    if (objectType != null)
      objectType.capitalize();
    String urlYear = ApexPages.currentPage().getParameters().get('year');
    if (urlYear != null)
      year = urlYear;

    doc_list = new List<Document__c>();
    att_list = new List<Attachment>();
    oldAtt_list = new List<Attachment>();
    names_list = new List<SelectOption>();
    yearOptions = new List<SelectOption>();
    selectedDoc = new Document__c();
    isNewDoc = true;
    selectedAtt = new Attachment();
    errorMessage = '';

    reportTitle = 'Documents';
    if (portalName.contains('NCAI')) {
      reportTitle = 'All Required Documents';
    } else {
      if (reportType == 'compliance')
        reportTitle = 'All Grant Compliance Documents';
      if (reportType == 'grant')
        reportTitle = 'Grant Specific Documents';
    }
  }

  public PageReference setParams() {
    names_list.clear();
    if (fileNames != null) {
      for (String n : fileNames.split(',')) {
        if (n != '') {
          names_list.add(new SelectOption(n.capitalize(), n.capitalize()));
        }
      }
    }

    if (years != null) {
      yearOptions.add(new SelectOption('', 'Filter by Year'));
      for (String n : years.split(';')) {
        if (n != '') {
          yearOptions.add(new SelectOption(n, n));
        }
      }
    }
    getLists();
    return null;
  }

  public String getSOQL() {
    String soqlAND = '';
    if (userAcctType == 'Local Organization')
      soqlAND += ' AND (Access_Mode__c = null OR Access_Mode__c = \'\' OR Access_Mode__c = \'Local Read Only\')';
    else if (!approverLevel.contains('Admin'))
      soqlAND += ' AND Access_Mode__c != \'National L2a/L3a Access Only\'';
    if (reportType == 'required')
      soqlAND += ' AND Required__c = true';
    if (objectType != null && objectType != '')
      soqlAND = ' AND Object_Type__c = \'' + objectType + '\'';
    //        if(year != null && year != '') soqlAND = ' AND Year__c = \'' + year + '\'';
    if (year != null && year != '')
      soqlAND =
        ' AND (Year__c = \'' +
        year +
        '\' OR Name LIKE \'%' +
        year +
        '%\')';
    if (orgCode != null && orgCode != '')
      soqlAND += ' AND FirstPic_National_Org_Code__c  = \'' + orgCode + '\'';
    system.debug('>>>> DocumentCtrl soqlAND = ' + soqlAND);
    return soqlAND;
  }

  public void getLists() {
    String soqlAND = getSOQL();
    Boolean hasId = false;
    if (
      orgId != null ||
      grantId != null ||
      assessmentId != null ||
      reportId != null ||
      requestId != null
    ) {
      hasId = true;
    } else {
      orgId = userAcct.Id;
    }

    doc_list = docClass.getDocList(
      orgId,
      grantId,
      assessmentId,
      reportId,
      requestId,
      groupId,
      soqlAND
    );

    att_list = docClass.getAttList();
    system.debug('>>>> DocumentCtrl docClass soql = ' + docClass.soql);
    system.debug('>>>> DocumentCtrl soqlAND = ' + soqlAND);
    //if(soqlAND == '') att_list = docClass.getAttList();
    if (assessmentId != null) {
      oldAtt_list.clear();
      oldAtt_list = [
        SELECT Id, Name, ParentId
        FROM Attachment
        WHERE ParentId = :assessmentId
      ];
    }
  }

  public void getListWithAtts() {
    String soqlAND = getSOQL();
    if (reportType == 'compliance')
      soqlAND += ' AND Object_Type__c = null';
    if (reportType == 'grant')
      soqlAND += ' AND Object_Type__c = \'Grant\'';
    doc_list = docClass.getDocWithAttList(
      orgId,
      grantId,
      assessmentId,
      reportId,
      requestId,
      groupId,
      soqlAND
    );
  }

  public void saveAndContinue() {
    errorMessage = '';
    if (selectedDoc != null && selectedDoc.Name != null) {
      if (groupId != null && groupId != '')
        selectedDoc.Group_Id__c = groupId;
      selectedDoc.Due_Date__c = dueDate;
      if (dueDate <= date.today())
        selectedDoc.Overdue__c = true;
      docClass.upsertDoc(selectedDoc);
      attachNewDoc = true;
    } else {
      errorMessage = 'Please enter a Document Name';
    }
  }

  public void saveDoc() {
    errorMessage = '';
    if (selectedDoc != null && selectedDoc.Name != null) {
      if (groupId != null && groupId != '')
        selectedDoc.Group_Id__c = groupId;
      selectedDoc.Due_Date__c = dueDate;
      if (dueDate <= date.today())
        selectedDoc.Overdue__c = true;
      else
        selectedDoc.Overdue__c = false;
      modHist =
        fdt +
        ': Modification Submitted by ' +
        currentUser.Contact.Name +
        ' (' +
        currentUser.Id +
        ')';
      if (selectedDoc.Modification_History__c == null)
        selectedDoc.Modification_History__c = modHist;
      else
        selectedDoc.Modification_History__c += ' \r\n' + modHist;
      docClass.upsertDoc(selectedDoc);
      displayDocPopup = false;
      getLists();
    } else {
      errorMessage = 'Please enter a Document Name';
    }
  }

  public void deleteDoc() {
    docClass.deleteDoc(selectedDoc);
    displayDeleteDocPopup = false;
    getLists();
  }

  public void deleteAtt() {
    attClass.deleteAttachment(selectedAtt);
    Document__c[] docs = [
      SELECT Status__c, (SELECT Id FROM Attachments)
      FROM Document__c
      WHERE Id = :selectedAtt.ParentId
    ];
    if (docs.size() > 0) {
      Document__c d = docs[0];
      if (d.Attachments.size() == 0) {
        d.Status__c = 'Requested';
        docClass.upsertDoc(d);
      }
    }
    displayDeleteAttPopup = false;
    getLists();
  }

  // BEGIN Popups
  public void showDocPopup() {
    selectedDoc = new Document__c();
    if (isNewDoc) {
      if (orgId != null) {
        selectedDoc.Organization__c = orgId;
        Account[] accts = [SELECT CEO_Email__c FROM Account WHERE Id = :orgId];
        if (accts.size() > 0)
          selectedDoc.CEO_Email__c = accts[0].CEO_Email__c;
      }
      if (grantId != null)
        selectedDoc.Grant__c = grantId;
      if (assessmentId != null)
        selectedDoc.Assessment__c = assessmentId;
      if (reportId != null)
        selectedDoc.Session_Report__c = reportId;
      if (requestId != null)
        selectedDoc.Reimbursement__c = requestId;
      if (newDocGroupId != null)
        selectedDoc.Group_Id__c = newDocGroupId;
    } else if (selectedDocId != null && selectedDocId != '') {
      List<Document__c> selectedDocs = docClass.getDocList(
        null,
        null,
        null,
        null,
        null,
        null,
        ' AND Id = \'' +
        selectedDocId +
        '\''
      );
      if (selectedDocs.size() > 0)
        selectedDoc = selectedDocs[0];
      if (selectedDoc.CEO_Email__c != null && selectedDoc.Recipient__c == null)
        selectedDoc.Recipient__c = selectedDoc.CEO_Email__c;
      selectedDoc.Previous_Due_Date__c = selectedDoc.Due_Date__c;
      dueDate = selectedDoc.Due_Date__c;
    }
    displayDocPopup = true;
  }
  public void cancelDocPopup() {
    errorMessage = '';
    if (attachNewDoc == true) {
      getLists();
    }
    selectedDocId = null;
    selectedDoc = new Document__c();
    displayDocPopup = false;
  }

  public void showDeleteDocPopup() {
    if (selectedDocId != null && selectedDocId != '') {
      Document__c[] docs = [
        SELECT Name, Status__c, Notes__c
        FROM Document__c
        WHERE Id = :Id.valueOf(selectedDocId)
      ];
      if (docs.size() > 0)
        selectedDoc = docs[0];
    }
    displayDeleteDocPopup = true;
  }
  public void cancelDeleteDocPopup() {
    selectedDocId = null;
    selectedDoc = new Document__c();
    displayDeleteDocPopup = false;
  }

  public void showDeleteAttPopup() {
    if (selectedAttId != null && selectedAttId != '') {
      Attachment[] atts = [
        SELECT Name, ParentId
        FROM Attachment
        WHERE Id = :Id.valueOf(selectedAttId)
      ];
      if (atts.size() > 0)
        selectedAtt = atts[0];
    }
    displayDeleteAttPopup = true;
  }
  public void cancelDeleteAttPopup() {
    selectedAttId = null;
    selectedAtt = new Attachment();
    displayDeleteAttPopup = false;
  }
}
