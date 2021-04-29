public with sharing class RequestPersonnelFormController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  public GrantClass grantClass = new GrantClass();
  public ReimbursementClass requestClass = new ReimbursementClass();
  public ReimbursementItemClass requestItemClass = new ReimbursementItemClass();
  public AttachmentClass attachClass = new AttachmentClass();

  public Account acct { get; set; }
  public ID GrantID { get; set; }
  public ID RequestID { get; set; }
  public Grant__c grant { get; set; }
  public Reimbursement_Request__c request { get; set; }
  public List<Reimbursement_Item__c> ri_list { get; set; }
  public Set<ID> riId_set { get; set; }
  public Decimal FTE { get; set; }
  public Decimal totalRequestedAmount { get; set; }
  public Boolean amountError { get; set; }
  public String errorMessage { get; set; }

  public Id laborId { get; set; }
  public List<itemClass> labor_list { get; set; }
  public Integer selectedLabor { get; set; }
  public Integer laborCount = 0;
  public Boolean displayLaborNotesPopup { get; set; }
  public Boolean displayAttPopup { get; set; }

  public List<Attachment> att_list { get; set; }
  public Id deleteAttId { get; set; }

  public Decimal requestSub { get; set; }
  public Decimal fICASub { get; set; }
  public Decimal medicalSub { get; set; }
  public Decimal dentalSub { get; set; }
  public Decimal shortTermSub { get; set; }
  public Decimal longTermSub { get; set; }
  public Decimal lifeSub { get; set; }
  public Decimal otherSub { get; set; }
  public Decimal benefitsSub { get; set; }
  public Decimal requstedBenefitsSub { get; set; }

  // BEGIN Constructor
  public RequestPersonnelFormController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    userAcctType = userClass.userAcctType;
    portalName = userClass.userProfile;
    if (portalName == 'BBBS')
      portalName = '';

    GrantID = ApexPages.currentPage().getParameters().get('GrantId');
    RequestID = ApexPages.currentPage().getParameters().get('RequestID');
    laborId = Schema.SObjectType.Reimbursement_Item__c.getRecordTypeInfosByName()
      .get('Labor')
      .getRecordTypeId();

    request = new Reimbursement_Request__c();
    ri_list = new List<Reimbursement_Item__c>();
    riId_set = new Set<ID>();
    labor_list = new List<itemClass>();

    totalRequestedAmount = 0;
    amountError = false;

    att_list = new List<Attachment>();

    selectedLabor = 0;
    displayLaborNotesPopup = false;
    displayAttPopup = false;

    if (RequestID != null) {
      request = requestClass.getRequest(RequestId);
      FTE = request.FTE__c;
      GrantID = request.Grant__c;
      getAttList();
    }

    if (GrantID != null) {
      grant = grantClass.getGrant(GrantID);
      if (grant.Id != null) {
        acct = [
          SELECT ID, Name, RecordType.Name
          FROM Account
          WHERE ID = :grant.Account__r.Id
        ];
      }
    }
  }

  public Boolean initalized = false;
  public void getLists() {
    if (!initalized) {
      if (request.Id != null) {
        ri_list.clear();
        ri_list = requestItemClass.getRequestItems(request.Id, 'labor');

        for (Reimbursement_Item__c ri : ri_list) {
          if (ri.Requested_Amount__c != null) {
            totalRequestedAmount += ri.Requested_Amount__c;
          }
          itemClass ic = new itemClass(this, laborCount, ri, RequestID);
          laborCount = laborCount + 1;
          labor_list.add(ic);
        }
      }
      updateAmounts();
      initalized = true;
    }
  }

  // BEGIN getAttList
  public void getAttList() {
    att_list.clear();
    Reimbursement_Request__c r = [
      SELECT
        Id,
        (
          SELECT Id, Name, Description
          FROM Attachments
          ORDER BY LastModifiedDate DESC
        )
      FROM Reimbursement_Request__c
      WHERE Id = :request.Id
    ];
    Set<String> names = new Set<String>();
    for (Attachment a : r.Attachments) {
      if (
        a.Name == 'Payroll' ||
        a.Name == 'Timesheet' ||
        a.Name == 'Benefits' ||
        a.Name == 'Other Personnel Documentation'
      ) {
        if (!names.contains(a.Name)) {
          att_list.add(a);
          names.add(a.Name);
        }
      }
    }
  }
  // END getAttList

  // BEGIN deleteAtt
  public void deleteAtt() {
    if (deleteAttId != null) {
      Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteAttId];
      if (a != null) {
        attachClass.deleteAttachment(a);
      }
    }
    getAttList();
  }
  // END deleteAtt

  // BEGIN updateAmounts
  public void updateAmounts() {
    requestSub = 0;
    fICASub = 0;
    medicalSub = 0;
    dentalSub = 0;
    shortTermSub = 0;
    longTermSub = 0;
    lifeSub = 0;
    otherSub = 0;
    benefitsSub = 0;
    requstedBenefitsSub = 0;
    totalRequestedAmount = 0;
    errorMessage = '';
    FTE = 0;

    for (itemClass ic : labor_list) {
      if (
        ic.reimItem.Quantity__c > 0 &&
        ic.reimItem.Quantity_Towards_Grant__c > 0 &&
        ic.reimItem.Rate__c > 0
      ) {
        ic.monthlyTotal = (ic.reimItem.Quantity__c * ic.reimItem.Rate__c)
          .setScale(2);
        ic.reimItem.Percent_Towards_Grant__c =
          ic.reimItem.Quantity_Towards_Grant__c /
          ic.reimItem.Quantity__c *
          100;
        ic.reimItem.Requested_Salary__c = (ic.reimItem.Quantity_Towards_Grant__c *
          ic.reimItem.Rate__c)
          .setScale(2);

        Decimal fb = 0;
        ic.reimItem.Fringe_Benefit__c = 0;
        if (ic.reimItem.FICA__c != null) {
          fb += ic.reimItem.FICA__c;
          ficaSub += ic.reimItem.FICA__c;
        }
        if (ic.reimItem.Medical__c != null) {
          fb += ic.reimItem.Medical__c;
          medicalSub += ic.reimItem.Medical__c;
        }
        if (ic.reimItem.Dental__c != null) {
          fb += ic.reimItem.Dental__c;
          dentalSub += ic.reimItem.Dental__c;
        }
        if (ic.reimItem.Short_Term_Disability__c != null) {
          fb += ic.reimItem.Short_Term_Disability__c;
          shortTermSub += ic.reimItem.Short_Term_Disability__c;
        }
        if (ic.reimItem.Long_Term_Disability__c != null) {
          fb += ic.reimItem.Long_Term_Disability__c;
          longTermSub += ic.reimItem.Long_Term_Disability__c;
        }
        if (ic.reimItem.Life__c != null) {
          fb += ic.reimItem.Life__c;
          lifeSub += ic.reimItem.Life__c;
        }
        if (ic.reimItem.Other_Benefits__c != null) {
          fb += ic.reimItem.Other_Benefits__c;
          otherSub += ic.reimItem.Other_Benefits__c;
        }
        if (fb > 0) {
          ic.reimItem.Fringe_Benefit__c += fb;
          benefitsSub += fb;
        }
        ic.reimItem.Requested_Benefits__c = (ic.reimItem.Fringe_Benefit__c *
          ic.reimItem.Percent_Towards_Grant__c /
          100)
          .setScale(2);
        requstedBenefitsSub += ic.reimItem.Requested_Benefits__c;

        requestSub += ic.reimItem.Requested_Salary__c;
        ic.reimItem.Requested_Amount__c = (ic.reimItem.Requested_Salary__c +
          ic.reimItem.Requested_Benefits__c)
          .setScale(2);
        totalRequestedAmount += ic.reimItem.Requested_Amount__c;
        FTE += ic.reimItem.Quantity_Towards_Grant__c;
      } else {
        ic.monthlyTotal = 0;
        //ic.reimItem.Quantity__c = 0;
        ic.reimItem.Quantity_Towards_Grant__c = 0;
        ic.reimItem.Percent_Towards_Grant__c = 0;
        ic.reimItem.Requested_Salary__c = 0;
        ic.reimItem.Requested_Benefits__c = 0;
        ic.reimItem.Requested_Amount__c = 0;
      }
      if (ic.reimItem.Percent_Towards_Grant__c > 100) {
        errorMessage = 'The hours worked on grant should not exceed total number of hours worked';
      }
    }
    if (request.Total_FTE_at_Affiliate__c == 0) {
      FTE = 0;
    } else if (request.Total_FTE_at_Affiliate__c != null) {
      FTE = FTE / request.Total_FTE_at_Affiliate__c * 100;

      if (FTE > 100) {
        errorMessage = 'Invalid FTE';
      }
    }
    if (totalRequestedAmount > grant.Balance__c) {
      amountError = true;
      errorMessage = 'Requested Amount Exceeds Sub-Grant Balance';
    } else {
      amountError = false;
    }
  }
  // END updateAmounts

  // BEGIN saveLabor
  public void saveLabor() {
    updateAmounts();

    request.FTE__c = FTE;
    requestClass.upsertRequest(request);

    List<Reimbursement_Item__c> labor_update_list = new List<Reimbursement_Item__c>();

    // COMPARE EXISTING REIMBURSEMENT ITEMS TO NEW ITEMS
    for (itemClass ic : labor_list) {
      for (Reimbursement_Item__c ri : ri_list) {
        system.debug('>>> ri = ' + ri);
        if (
          ic.reimItem != null &&
          ic.reimItem.Id == ri.Id &&
          ri.RecordType.Name == 'Labor'
        ) {
          if (ic.itemNote != null) {
            ri.Item_Note__c = ic.ItemNote;
          }
          labor_update_list.add(ri);
        }
      }
    }

    requestItemClass.upsertItems(labor_update_list);
  }
  // END saveLabor

  // BEGIN previous
  public PageReference previous() {
    saveLabor();

    PageReference pr = new PageReference(
      '/' +
      portalName +
      'RequestForm?GrantID=' +
      GrantID +
      '&RequestID=' +
      RequestID
    );
    pr.setRedirect(true);
    return pr;
  }
  // END previous

  // BEGIN saveAndContinue
  public PageReference saveAndContinue() {
    saveLabor();

    if (totalRequestedAmount > 0 && portalName != 'DMV') {
      Boolean hasPayroll = false;
      Boolean hasTimesheet = false;
      for (Attachment a : att_list) {
        if (a.Name == 'Timesheet') {
          hasTimesheet = true;
        }
        if (a.Name == 'Payroll') {
          hasPayroll = true;
        }
      }
      if (!hasTimesheet) {
        errorMessage = 'A Timesheet is required';
      }
      if (!hasPayroll) {
        errorMessage = 'A Payroll document is required';
      }
    }

    if (String.isBlank(errorMessage)) {
      PageReference pr = new PageReference(
        '/' +
        portalName +
        'RequestExpensesForm?GrantID=' +
        GrantID +
        '&RequestID=' +
        RequestID
      );
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }
  // END saveAndContinue

  // BEGIN saveAndExit
  public PageReference saveAndExit() {
    saveLabor();

    if (String.isBlank(errorMessage)) {
      PageReference pr = new PageReference('/Reimbursements');
      pr.setRedirect(true);
      return pr;
    }
    return null;
  }
  // END saveAndExit

  // BEGIN popups
  public void laborNotesPopup() {
    system.debug('>>> selectedLabor = ' + selectedLabor);
    if (displayLaborNotesPopup == true) {
      displayLaborNotesPopup = false;
    } else {
      displayLaborNotesPopup = true;
    }
  }

  public void attPopup() {
    getAttList();
    if (displayAttPopup == true) {
      displayAttPopup = false;
    } else {
      displayAttPopup = true;
    }
  }
  // END popups

  // BEGIN INNER CLASS
  public class itemClass {
    RequestPersonnelFormController outerClass;

    public Integer itemIndex { get; set; }
    public Reimbursement_Item__c reimItem { get; set; }
    public String itemName { get; set; }
    public Id requestId { get; set; }
    public Id recordTypeId { get; set; }
    public Decimal monthlyTotal { get; set; } //Before deductions
    public Decimal factorPercent { get; set; }
    public String itemNote { get; set; }
    public String response { get; set; }
    public Integer noteCount { get; set; }

    public itemClass(
      RequestPersonnelFormController outerClass,
      Integer intCount,
      Reimbursement_Item__c ri,
      ID rId
    ) {
      this.outerClass = outerClass;
      itemIndex = intCount;
      reimItem = ri;
      requestId = rId;
      itemName = ri.Budget_Item__r.Name;
      itemNote = ri.Item_Note__c;
      response = ri.Response__c;
      noteCount = 0;
      if (itemNote != null) {
        noteCount = noteCount + 1;
      }
      if (response != null) {
        noteCount = noteCount + 1;
      }
      if (ri.Rate__c != null) {
        if (ri.Quantity__c != null) {
          monthlyTotal = (ri.Quantity__c * ri.Rate__c).setScale(2);
          if (ri.Quantity_Towards_Grant__c != null) {
            ri.Requested_Salary__c = (ri.Quantity_Towards_Grant__c * ri.Rate__c)
              .setScale(2);
          }
        }
      } else {
        monthlyTotal = 0;
        ri.Requested_Salary__c = 0;
      }
      if (ri.Fringe_Benefit__c != null && ri.Percent_Towards_Grant__c != null) {
        ri.Requested_Benefits__c = (ri.Fringe_Benefit__c *
          ri.Percent_Towards_Grant__c /
          100)
          .setScale(2);
      } else {
        ri.Requested_Benefits__c = 0;
      }
    }
  }
}
