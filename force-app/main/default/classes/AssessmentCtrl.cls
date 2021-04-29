public with sharing class AssessmentCtrl {
  private UserClass userClass = new UserClass();
  private AccountClass ac = new AccountClass();
  private AssessmentClass assessClass = new AssessmentClass();
  private DocumentClass dc = new DocumentClass();
  private getIdFromString gifs = new getIdFromString();
  private FieldLabelClass flc = new FieldLabelClass();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }

  public List<Field_Label__c> fields { get; set; }
  public Map<String, String> labels { get; set; }
  public Map<String, String> fieldNames { get; set; }

  public Account acct { get; set; }
  public ID GrantID { get; set; }

  public ID AssessmentID { get; set; }
  public Assessment__c assess { get; set; }
  public Map<String, String> out_map { get; set; }
  public String url { get; set; }
  public Integer nextTabId { get; set; }

  public List<Document__c> doc_list { get; set; }
  public List<Attachment> att_list { get; set; }
  public List<Attachment> oldAtt_list { get; set; }
  public String additionalDocNames { get; set; }
  public Boolean displayAttPopup { get; set; }
  public String fileName { get; set; }
  public Id deleteAttId { get; set; }

  public Date insExp1 { get; set; }
  public Date insExp2 { get; set; }

  public String successMessage { get; set; }
  public String errorMessage { get; set; }
  public String fileErrorMessage { get; set; }
  public String additionalReqsErrorMessage { get; set; }
  public Boolean displayDeletePopup { get; set; }

  public Id parentId { get; set; }
  public Id strategic_parentId { get; set; }
  public Id fund_parentId { get; set; }
  public Id separation_parentId { get; set; }
  public Id board_parentId { get; set; }
  public Id succession_parentId { get; set; }
  public Id program_parentId { get; set; }
  public Id previousAudit_parentId { get; set; }
  public Id audit_parentId { get; set; }
  public Id verification_parentId { get; set; }
  public Id affiliation_parentId { get; set; }
  public Id aim_parentId { get; set; }
  public Id insurance_parentId { get; set; }
  public Id income_parentId { get; set; }
  public Id supporting_parentId { get; set; }
  public Id orgChart_parentId { get; set; }
  public Id bylaws_parentId { get; set; }
  public Id advisoryPlan_parentId { get; set; }
  public Id growth_parentId { get; set; }
  public Id manual_parentId { get; set; }
  public Id tech_parentId { get; set; }

  public AssessmentCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;

    String urlGrantId = ApexPages.currentPage().getParameters().get('grantId');
    grantId = gifs.getId(urlGrantId);
    String urlAssessId = ApexPages.currentPage()
      .getParameters()
      .get('assessmentId');
    assessmentId = gifs.getId(urlAssessId);
    if (url == null)
      url = ApexPages.currentPage().getUrl();

    errorMessage = '';
    fileErrorMessage = '';
    additionalReqsErrorMessage = '';
    displayAttPopup = false;
    displayDeletePopup = false;

    assess = assessClass.getAssessment(AssessmentID);
    if (assess != null) {
      if (assess.Year__c >= 2019)
        nextTabId = 9;
      else
        nextTabId = 10;

      AccountClass ac = new AccountClass();
      acct = ac.getAccount(assess.Organization__c);
      if (acct.Insurance_Provider__c != null) {
        insExp2 = acct.Insurance_Expiration_Date__c;
      } else {
        insExp1 = acct.Insurance_Expiration_Date__c;
      }
      //if(assess.Compliance_Status__c == null) {
      //    assess.Compliance_Status__c = 'In Compliance';
      //}

      String soqlAND =
        ' AND (Year__c  INCLUDES(\'' +
        String.valueOf(assess.Year__c) +
        '\') OR Year__c = null)';
      soqlAND +=
        ' AND (Organization_Type__c  = \'' +
        acct.Type +
        '\' OR Organization_Type__c = \'All\')';
      fields = flc.getFields('Assessment__c', null, null, soqlAND);
      labels = flc.getFieldLabelMap('Assessment__c', null, null, soqlAND);
      fieldNames = flc.getFieldNameMap('Assessment__c', null, null, soqlAND);
    }

    doc_list = new List<Document__c>();
    oldAtt_list = new List<Attachment>();
    att_list = new List<Attachment>();
    additionalDocNames = 'Affiliation Fee Form,Income Statement,Supporting Documentation,Organizational Chart,Verification Letter,Technology Licenses Form';
    //additionalDocNames = 'Affiliation Fee Form,AIM Fee Form,Proof of Insurance,Income Statement,Supporting Documentation,Organizational Chart,Verification Letter';
  }

  public ApexPages.PageReference init() {
    if (AssessmentID == null || assess == null) {
      PageReference pageRef = new PageReference('/Error');
      return pageRef;
    } else {
      getAttList();
      getSummary();
    }
    return null;
  }

  public PageReference setParams() {
    return null;
  }

  public List<SelectOption> getOptions() {
    List<SelectOption> options = new List<SelectOption>();

    Schema.DescribeFieldResult fieldResult = Assessment__c.S1_Board_Governance_Standards__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

    for (Schema.PicklistEntry f : ple) {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
    }
    return options;
  }

  // BEGIN getAttList
  public void getOldAttList() {
    oldAtt_list.clear();
    if (assess.Id != null) {
      oldAtt_list = [
        SELECT Id, Name, ParentId
        FROM Attachment
        WHERE ParentId = :assess.Id
      ];
    }
  }

  public void getAttList() {
    // gets attachments from old Assessments prior to Document creation
    att_list.clear();
    Set<Id> docIds = new Set<Id>();
    //Set<String> docAttNames = new Set<String>();
    Set<String> attNames = new Set<String>();

    doc_list = dc.getDocWithAttList(
      null,
      null,
      assess.Id,
      null,
      null,
      null,
      null
    );
    for (Document__c d : doc_list) {
      docIds.add(d.Id);
      // Year < 2019
      if (d.Name.contains('Strategic'))
        strategic_parentId = d.Id;
      if (d.Name == 'Fund Development Plan')
        fund_parentId = d.Id;
      if (d.Name == 'Separation of Duties for Fiscal Control')
        separation_parentId = d.Id;
      if (d.Name == 'Board Development Plan')
        board_parentId = d.Id;
      if (d.Name == 'Written Succession Plan')
        succession_parentId = d.Id;
      if (d.Name == 'Program Manual')
        program_parentId = d.Id;
      if (d.Name == 'Previous Audit')
        previousAudit_parentId = d.Id;
      if (d.Name == 'AIM Fee Form')
        aim_parentId = d.Id;
      if (d.Name == 'Bylaws')
        bylaws_parentId = d.Id;
      if (d.Name == 'Advisory Plan')
        advisoryPlan_parentId = d.Id;

      // Year >= 2019
      if (d.Name == 'Audit')
        audit_parentId = d.Id;
      if (d.Name == 'Affiliation Fee Form')
        affiliation_parentId = d.Id;
      if (d.Name == 'Income Statement')
        income_parentId = d.Id;
      if (d.Name == 'Network Growth Goals')
        growth_parentId = d.Id;
      if (d.Name == 'Organizational Chart')
        orgChart_parentId = d.Id;
      if (d.Name == 'Program Manual')
        manual_parentId = d.Id;
      if (d.Name == 'Proof of Insurance')
        insurance_parentId = d.Id;
      if (d.Name == 'Supporting Documentation')
        supporting_parentId = d.Id;
      if (d.Name == 'Technology Licenses Form')
        tech_parentId = d.Id;
      if (d.Name == 'Verification Letter')
        verification_parentId = d.Id;
    }

    for (Attachment att : [
      SELECT Id, Name, Description, ParentId
      FROM Attachment
      WHERE ParentId = :assess.Id OR ParentId IN :docIds
      ORDER BY LastModifiedDate DESC
    ]) {
      if (!attNames.contains(att.Name)) {
        att_list.add(att);
        attNames.add(att.Name);
      }
    }
    system.debug('>>> att_list = ' + att_list);
  }
  // END getAttList

  // BEGIN getAttValidaiton
  public void getAttValidaiton() {
    getAttList();

    fileErrorMessage = '';
    List<String> val_list = new List<String>();
    Set<String> allDocs = new Set<String>();
    Set<String> submittedDocs = new Set<String>();

    for (Document__c d : doc_list) {
      if (d.Required__c) {
        allDocs.add(d.Name);
        if (d.Status__c != 'Requested' && d.Status__c != 'Sent Back')
          submittedDocs.add(d.Name);
      }
    }

    for (String s : allDocs) {
      if (!submittedDocs.contains(s))
        val_list.add(s);
    }

    for (String s : val_list)
      if (s != '')
        fileErrorMessage += s + ', ';
    if (fileErrorMessage != '')
      fileErrorMessage =
        'The following attachments are missing: ' +
        fileErrorMessage.removeEnd(', ') +
        '.';
  }
  // END getAttValidaiton

  public void updateAuditDate() {
    if (assess.Fiscal_Year_Ended__c == null)
      assess.Audit_Completed_Date__c = null;
    else
      assess.Audit_Completed_Date__c = assess.Fiscal_Year_Ended__c.addMonths(9);
  }

  // BEGIN getSummary
  public void getSummary() {
    getAttValidaiton();
    out_map = new Map<String, String>();
    errorMessage = '';
    additionalReqsErrorMessage = '';
    assess.Compliance_Status__c = 'In Compliance';

    system.debug('>>> fieldNames: ' + fieldNames);
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Assessment__c.fields.getMap();
    system.debug('>>> schemaFieldMap = ' + schemaFieldMap);
    if (assess.Hide_Standards__c == false) {
      for (String fieldName : schemaFieldMap.keySet()) {
        if (assess.get(fieldName) == 'Out') {
          String field = fieldNames.get(fieldName);
          if (assess.Year__c < 2019)
            field = schemaFieldMap.get(fieldName).getDescribe().getLabel();
          String textField = fieldName.replace('__c', '_text__c');
          String text = string.valueOf(assess.get(textField));
          if (text == null) {
            errorMessage += field + ', ';
            text = '';
          }
          out_map.put(field, text);
        }
      }
    }
    if (errorMessage != '') {
      errorMessage =
        'The following fields are missing descriptions: ' +
        errorMessage.removeEnd(', ') +
        '.  ';
    }
    if (insExp1 == null && insExp2 == null) {
      additionalReqsErrorMessage += 'Insurance expiration date is missing.  ';
    }
    if (out_map.size() > 0) {
      assess.Compliance_Status__c = 'Out of Compliance';
    } else {
      assess.Compliance_Status__c = 'In Compliance';
    }
  }
  // END getSummary

  public void handleTabClick() {
    save();
  }

  public void save() {
    getSummary();
    if (assess.Assessment_Status__c == 'Not Started') {
      assess.Assessment_Status__c = 'In Progress';
      acct.Current_Assessment_Status__c = 'In Progress';
    }
    assessClass.upsertAssessment(assess);

    if (insExp1 != null) {
      acct.Insurance_Expiration_Date__c = insExp1;
    } else if (insExp2 != null) {
      acct.Insurance_Expiration_Date__c = insExp2;
    }
    ac.upsertAccount(acct);
  }

  public void upsertAssessment() {
    if (assess.Hide_Standards__c)
      save();
    else
      assessClass.upsertAssessment(assess);
    if (ApexPages.hasMessages())
      errorMessage = string.valueOf(ApexPages.getMessages());
    else
      successMessage = 'Save successful';
  }

  public PageReference saveAndContinue() {
    save();
    String url =
      '/AssessmentPage' +
      nextTabId +
      '?AssessmentId=' +
      AssessmentId;
    if (assess.Year__c >= 2019)
      url = '/AssessmentP0' + nextTabId + '?AssessmentId=' + AssessmentId;
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference saveAndExit() {
    save();
    PageReference pr = new PageReference('/BBBSAbout');
    pr.setRedirect(true);
    return pr;
  }

  public PageReference saveAndRefresh() {
    save();
    PageReference pr = new PageReference(url);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference submit() {
    if (insExp1 != null) {
      acct.Insurance_Expiration_Date__c = insExp1;
    } else if (insExp2 != null) {
      acct.Insurance_Expiration_Date__c = insExp2;
    }
    getAttList();
    getAttValidaiton();

    if (fileErrorMessage == '') {
      assess.Assessment_Status__c = 'Submitted';
      assess.Submitted_Date__c = Date.today();
      acct.Current_Assessment_Status__c = 'Submitted';
      try {
        ac.upsertAccount(acct);
        System.Debug('>>>> Account update successful. acct = ' + acct);
        assessClass.upsertAssessment(assess);
        System.Debug('>>>> Assessment update successful. assess = ' + assess);
      } catch (Exception e) {
        system.debug('error = ' + e.getMessage());
        return null;
      }
    } else {
      PageReference pr = new PageReference('/BBBSAbout');
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }

  public void markAsReviewed() {
    assess.Reviewed__c = 'Yes';
    assessClass.upsertAssessment(assess);
  }

  // BEGIN deleteAtt
  public void deleteAtt() {
    if (deleteAttId != null) {
      Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteAttId];
      if (a != null) {
        delete a;
      }
    }
    getAttList();
  }
  // END deleteAtt

  // BEGIN deleteAssessment
  /*
    public PageReference deleteAssessment() {
        delete assess;
                
        PageReference pr = new PageReference('/BBBSAbout');
        pr.setRedirect(True);
        return pr;
    }
    */
  // END deleteAssessment

  // BEGIN popups
  public void attPopup() {
    if (parentId != null)
      displayAttPopup = true;
  }

  public void closeAttPopup() {
    displayAttPopup = false;
    getAttList();
  }

  public void deletePopup() {
    if (displayDeletePopup == true) {
      displayDeletePopup = false;
    } else {
      displayDeletePopup = true;
    }
  }
  // END popups
}
