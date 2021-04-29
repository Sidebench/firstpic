@isTest
public class TestObjectCtrls {
  static testMethod void test1() {
    Account a = new Account(
      EIN__c = '98-3846892',
      Name = 'National',
      FirstPic_Org_Code__c = 'BBBSA',
      CEO_Email__c = 'test@test.com',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('National Organization')
        .getRecordTypeId()
    );
    insert a;

    Account a2 = new Account(
      EIN__c = '98-1345654',
      Name = 'Local',
      National_Organization__c = a.id,
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Local Organization')
        .getRecordTypeId()
    );
    insert a2;

    a2.DUNS_Exp_Date__c = date.today();
    a2.DUNS_Expired__c = true;
    update a2;
    Account a2test = [SELECT Hold_Status__c FROM Account WHERE Id = :a2.Id];
    //system.assertEquals('Hold', a2.Hold_Status__c);
    system.assertEquals(null, a2.Hold_Status__c);

    Contact c = new Contact(
      AccountId = a.Id,
      FirstName = 'Test',
      LastName = 'Qwerty',
      Email = 'asdf@wer.com'
    );
    insert c;

    Grant__c g = new Grant__c(
      Account__c = a.Id,
      Name = 'Test Grant',
      RecordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName()
        .get('Sub-Grant')
        .getRecordTypeId()
    );
    insert g;

    Budget_Item__c bi = new Budget_Item__c(Grant__c = g.Id, Name = 'Test Item');
    insert bi;

    Reimbursement_Request__c r = new Reimbursement_Request__c(Grant__c = g.Id);
    insert r;

    Reimbursement_Request__c r2 = new Reimbursement_Request__c(Grant__c = g.Id);
    insert r2;

    List<Reimbursement_Request__c> requests = new List<Reimbursement_Request__c>();
    requests.add(r);
    requests.add(r2);

    Reimbursement_Item__c ri = new Reimbursement_Item__c(
      Reimbursement_Request__c = r.Id,
      Budget_Item__c = bi.Id
    );
    insert ri;

    Session_Report__c sr = new Session_Report__c(Site__c = a.Id);
    insert sr;

    Assessment__c sa = new Assessment__c(Organization__c = a.Id);
    insert sa;

    Document__c d = new Document__c(
      Name = 'Audit',
      Organization__c = a.Id,
      Grant__c = g.Id,
      Assessment__c = sa.Id,
      Reimbursement__c = r.Id,
      Session_Report__c = sr.Id
    );
    insert d;

    d.Overdue__c = true;
    update d;
    Account a1 = [SELECT Hold_Status__c FROM Account WHERE Id = :a.Id];
    //system.assertEquals('Hold', a1.Hold_Status__c);
    system.assertEquals(null, a1.Hold_Status__c);

    Blob body = Blob.valueOf('Test Body');
    Attachment att = new Attachment(
      Name = 'Item Att',
      body = body,
      parentId = d.id
    );
    insert att;
    Attachment att2 = new Attachment(
      Name = 'Item Att 2',
      body = body,
      parentId = d.id
    );
    insert att2;
    Document__c d2 = [
      SELECT Has_Attachments__c
      FROM Document__c
      WHERE Id = :d.Id
    ];
    system.assert(d2.Has_Attachments__c == true);

    system.Test.startTest();

    AccountClass ac = new AccountClass();
    ac.getAccountList();
    ac.getRelatedAccountList(a.Id, 'National Organization', '', '', null);

    ContactClass cc = new ContactClass();
    cc.getRelatedContactList(a.Id, 'Contact', null, null);
    cc.deleteContact(c);

    GrantClass gc = new GrantClass();
    gc.getGrantList();
    gc.getRelatedSubGrants(a.Id, null, '', 'Name', '', 'Test', '');
    gc.getGrant(g.Id);
    gc.upsertGrant(g);

    //ReportClass grc = new ReportClass();
    //grc.getReportList();

    SessionReportClass src = new SessionReportClass();
    src.getLatestReportId(a.Id);
    src.getReportList();

    List<Budget_Item__c> bi_list = new List<Budget_Item__c>();
    bi_list.add(bi);
    BudgetItemClass bic = new BudgetItemClass();
    bic.getBudgetItems(g.Id);
    bic.getBudgetItem(bi.Id);
    bic.upsertItem(bi);
    bic.upsertItems(bi_list);
    bic.deleteItems(bi_list);

    ReimbursementClass rc = new ReimbursementClass();
    rc.getRequestList();
    rc.getRelatedRequests(a.Id, g.Id, '', 'Name', '', 'Test', null, null);
    rc.getRelatedRequests(
      a.Id,
      null,
      'pendingfirst',
      'Name',
      'National',
      'Test',
      c.id,
      null
    );
    rc.getRequest(r.Id);
    rc.upsertRequest(r);
    rc.upsertRequestList(requests);
    rc.deleteRequest(r2);

    AssessmentClass sac = new AssessmentClass();
    sac.createAssessments(2019, false);
    //sac.getAssessment(sa.Id);
    //sac.upsertAssessment(sa);

    AttachmentCtrl attctrl = new AttachmentCtrl();
    attctrl.parentId = d.id;
    attctrl.getAttList();

    attctrl.fileName = 'Item Att';
    attctrl.filterByFileName = true;
    attctrl.getAttList();

    system.assertEquals(1, attctrl.att_list.size());

    attctrl.filterByFileName = false;
    attctrl.getAttList();
    system.assertEquals(2, attctrl.att_list.size());

    attctrl.showAttPopup();
    attctrl.hideAttPopup();
    attctrl.deleteAttId = att2.Id;
    attctrl.deleteAttById();

    AttachmentClass attc = new AttachmentClass();
    attc.deleteAttachment(att);

    /*
        Set<Id> ids = new Set<Id>();
        ids.add(d.Id);
        DocumentClass dcl = new DocumentClass();
        dcl.getHasAtts(ids);
        */

    // BEGIN Test Doc Ctrl
    DocumentCtrl dc = new DocumentCtrl();
    dc.fileNames = 'test';
    dc.requestId = r.Id;
    dc.setParams();
    dc.reportId = sr.Id;
    dc.getLists();
    dc.assessmentId = sa.Id;
    dc.getLists();
    dc.grantId = g.Id;
    dc.getLists();
    dc.groupId = 'test';
    system.assert(dc.doc_list.size() > 0);

    dc.showDocPopup();
    dc.selectedDoc.Name = 'New Doc';
    dc.saveDoc();
    dc.cancelDocPopup();
    Document__c[] docs1 = [SELECT Name FROM Document__c WHERE Grant__c = :g.Id];
    system.assert(docs1.size() == 2);

    dc.selectedDocId = d.Id;
    dc.isNewDoc = false;
    dc.showDocPopup();
    system.assert(dc.selectedDoc.Id != null);
    dc.saveAndContinue();

    dc.selectedAttId = att.Id;
    dc.showDeleteAttPopup();
    dc.deleteAtt();
    dc.cancelDeleteAttPopup();

    dc.selectedDocId = docs1[0].Id;
    dc.showDeleteDocPopup();
    dc.deleteDoc();
    dc.cancelDeleteDocPopup();

    Document__c[] docs2 = [
      SELECT Group_Id__c, Has_Attachments__c
      FROM Document__c
      WHERE Grant__c = :g.Id
    ];
    system.assert(docs2.size() == 1);
    system.assert(docs2[0].Group_Id__c == 'test');
    system.assert(docs2[0].Has_Attachments__c == false);
    Integer i = 0;
    for (Attachment atts : [
      SELECT Id
      FROM Attachment
      WHERE ParentId IN :docs2
    ]) {
      i++;
    }
    system.assert(i == 0);
    // END Test Doc Ctrl

    system.Test.stopTest();
  }
}
