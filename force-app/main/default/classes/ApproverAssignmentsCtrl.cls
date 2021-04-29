public with sharing class ApproverAssignmentsCtrl {
  private UserClass uc = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String portalName { get; set; }

  private AccountClass ac = new AccountClass();
  public ContactClass cc = new ContactClass();

  public List<Account> accts { get; set; }
  public Id approverId { get; set; }
  public Set<Id> primApproverIds { get; set; }
  public Set<Id> secApproverIds { get; set; }
  public List<SelectOption> primApprovers { get; set; }
  public List<SelectOption> secApprovers { get; set; }
  public List<SelectOption> admin { get; set; }
  public List<Contact> onLeave { get; set; }

  public Boolean readOnly { get; set; }
  public String keyword { get; set; }
  public String primary { get; set; }
  public String secondary { get; set; }
  public String errorMessage { get; set; }

  public ApproverAssignmentsCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    portalName = uc.userProfile;

    accts = new List<Account>();
    primApproverIds = new Set<Id>();
    secApproverIds = new Set<Id>();
    primApprovers = new List<SelectOption>();
    secApprovers = new List<SelectOption>();
    primApprovers.add(new SelectOption('', '-- Select Approver --'));
    secApprovers.add(new SelectOption('', '-- Select Approver --'));
    admin = new List<SelectOption>();
    onLeave = new List<Contact>();

    readOnly = true;
    if (
      uc.approverLevel == 'Finance Admin' ||
      uc.approverLevel == 'Level Three' ||
      portalName != 'Ripken' &&
      uc.approverLevel == 'Level Two'
    )
      readOnly = false;
    keyword = '';
    primary = '';
    secondary = '';
    errorMessage = '';

    String contactAND = ' AND Is_Primary_Approver__c = true';
    for (
      Contact c : cc.getRelatedContactList(userAcct.Id, null, null, contactAND)
    ) {
      if (!primApproverIds.contains(c.Id)) {
        primApproverIds.add(c.Id);
        primApprovers.add(new SelectOption(c.Id, c.Name));
      }
      if (!secApproverIds.contains(c.Id)) {
        secApproverIds.add(c.Id);
        secApprovers.add(new SelectOption(c.Id, c.Name));
      }
    }
    for (User u : [
      SELECT ContactId, Contact.Name
      FROM User
      WHERE
        Profile.Name LIKE '%Finance Admin%'
        AND Contact.AccountId = :userAcct.Id
    ]) {
      if (!secApproverIds.contains(u.ContactId)) {
        secApproverIds.add(u.ContactId);
        secApprovers.add(new SelectOption(u.ContactId, u.Contact.Name));
      }
    }
  }

  public void getLists() {
    accts.clear();
    onLeave.clear();
    errorMessage = '';

    String acctAND = '';
    if (primary != null && primary != '')
      acctAND = ' AND Primary_Approver_Name__c LIKE \'%' + primary + '%\'';
    if (secondary != null && secondary != '')
      acctAND = ' AND Secondary_Approver_Name__c LIKE \'%' + secondary + '%\'';
    acctAND += ' AND RecordType.Name = \'Local Organization\'';
    Set<Id> leaveId_set = new Set<Id>();
    for (
      Account a : ac.getRelatedAccountList(
        userAcct.Id,
        uc.userAcctType,
        null,
        keyword,
        acctAND
      )
    ) {
      accts.add(a);
      if (
        !primApproverIds.contains(a.Primary_Approver__c) &&
        a.Primary_Approver__c != null
      ) {
        primApproverIds.add(a.Primary_Approver__c);
        primApprovers.add(
          new SelectOption(a.Primary_Approver__c, a.Primary_Approver_Name__c)
        );
        if (
          a.Secondary_Approver__c != null &&
          !secApproverIds.contains(a.Secondary_Approver__c)
        ) {
          secApproverIds.add(a.Secondary_Approver__c);
          secApprovers.add(
            new SelectOption(
              a.Secondary_Approver__c,
              a.Secondary_Approver_Name__c
            )
          );
        }
      }
      if (
        !secApproverIds.contains(a.Secondary_Approver__c) &&
        a.Secondary_Approver__c != null
      ) {
        secApproverIds.add(a.Secondary_Approver__c);
        secApprovers.add(
          new SelectOption(
            a.Secondary_Approver__c,
            a.Secondary_Approver_Name__c
          )
        );
      }
      if (a.Primary_Approver_On_Leave__c && a.Primary_Approver__c != null)
        leaveId_set.add(a.Primary_Approver__c);
    }

    if (leaveId_set.size() > 0) {
      String idIn = '(\'';
      for (Id i : leaveId_set) {
        if (i != null)
          idIn += i + '\',\'';
      }
      idIn = idIn.substring(0, idIn.length() - 2);
      idIn += ')';
      String contactAND = '';
      if (idIn != null)
        contactAND = ' AND Id IN ' + idIn;
      for (
        Contact c : cc.getRelatedContactList(
          userAcct.Id,
          null,
          null,
          contactAND
        )
      ) {
        onLeave.add(c);
      }
    }
  }

  public void clear() {
    keyword = '';
    primary = '';
    secondary = '';
    getLists();
  }

  public void removeFromLeave() {
    if (approverId != null) {
      for (Account a : accts) {
        if (a.Primary_Approver__c == approverId)
          a.Primary_Approver_On_Leave__c = false;
      }
    }
    save();
  }

  public void markAllOnLeave() {
    for (Account a : accts) {
      a.Primary_Approver_On_Leave__c = true;
    }
  }

  public void save() {
    errorMessage = '';
    ac.upsertAccounts(accts);
    if (ApexPages.hasMessages())
      errorMessage = string.valueOf(ApexPages.getMessages());
    getLists();
  }
}
