public without sharing class AccountClass {
  public String soql { get; set; }

  public String getSOQL() {
    String expr = '';
    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
    for (String fieldName : schemaFieldMap.keySet()) {
      expr += fieldName + ', ';
    }
    //expr = expr.removeEnd(', ');
    expr += 'RecordType.Name, Primary_Approver__r.Name, Secondary_Approver__r.Name, National_Organization__r.Grant_Year_Options__c, National_Organization__r.Current_Grant_Year__c';

    soql = 'SELECT ' + expr + ' FROM Account';
    return soql;
  }

  public Account getAccount(Id acctId) {
    getSOQL();
    Account acct = new Account();
    if (acctId != null) {
      soql += ' WHERE Id = \'' + acctId + '\'';
      Account[] accts = Database.query(soql);
      if (accts.size() > 0) {
        acct = accts[0];
      }
    }
    return acct;
  }

  public List<Account> getAccountList() {
    getSOQL();
    List<Account> account_list = new List<Account>();
    account_list = Database.query(soql);
    return account_list;
  }

  public List<Account> getRelatedAccountList(
    Id acctId,
    String userAcctType,
    String recordType,
    String keyword,
    String soqlAND
  ) {
    soql = 'SELECT Id, Name, RecordType.Name, Is_Active__c, Active_Status__c, Local_Organization__r.Name, Local_Organization_Id__c, Hold_Status__c, Hold_Reason__c, Hold_Date__c, Hold_History__c, DUNS_Current_Status__c ';
    soql += ', Primary_Approver__c, Primary_Approver_Name__c, Secondary_Approver__c, Secondary_Approver_Name__c, Primary_Approver_On_Leave__c, BBBS_Id__c, Active_Grant_Status__c FROM Account';
    if (userAcctType == 'National Organization') {
      soql +=
        ' WHERE (National_Organization__c = \'' +
        acctId +
        '\' OR Local_Organization__c = \'' +
        acctId +
        '\' OR Id = \'' +
        acctId +
        '\')';
    } else if (userAcctType == 'Local Organization') {
      soql +=
        ' WHERE (Local_Organization__c = \'' +
        acctId +
        '\' OR Id = \'' +
        acctId +
        '\')';
    } else {
      soql += ' WHERE Id = \'' + acctId + '\'';
    }
    if (recordType != null && recordType != '')
      soql += ' AND RecordType.Name = \'' + recordType + '\'';
    if (keyword != null && keyword != '')
      soql +=
        ' AND (Name LIKE \'%' +
        keyword +
        '%\' OR Local_Organization__r.Name LIKE \'%' +
        keyword +
        '%\')';
    if (soqlAND != null && soqlAND != '')
      soql += soqlAND;
    soql += ' ORDER BY Name';
    system.debug('Account soql = ' + soql);
    List<Account> accts = Database.query(soql);
    return accts;
  }

  public List<Account> getSiteList(Id localAcctId, String soqlAND) {
    soql = 'SELECT Id, Name, Active_Status__c, Is_Active__c FROM Account';
    soql += ' WHERE Local_Organization__c = \'' + localAcctId + '\'';
    if (soqlAND != null && soqlAND != '')
      soql += soqlAND;
    soql += ' ORDER BY Name';
    system.debug('Account getSiteList soql = ' + soql);
    List<Account> accts = Database.query(soql);
    return accts;
  }

  public List<SelectOption> getOrgOptions(
    Id acctId,
    String userAcctType,
    String userProfile
  ) {
    String soqlAND = '';
    if (userProfile.contains('TRAIL'))
      soqlAND = ' AND National_Grants__c INCLUDES (\'TRAIL\')';
    else if (userProfile.contains('OVC'))
      soqlAND = ' AND National_Grants__c INCLUDES (\'OVC\')';
    List<SelectOption> orgOptions = new List<SelectOption>();
    orgOptions.add(new SelectOption('', '-- Select a Site --'));
    for (
      Account a : getRelatedAccountList(acctId, userAcctType, '', '', soqlAND)
    ) {
      orgOptions.add(new SelectOption(a.Id, a.Name));
    }
    return orgOptions;
  }

  public void upsertAccount(Account acct) {
    try {
      upsert acct;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void upsertAccounts(List<Account> accts) {
    try {
      upsert accts;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public String getHoldHistory(User currentUser, Account org) {
    Date dt = date.today();
    String fdt = dt.format();
    String mh = '<b>' + fdt + ':</b> Hold Status updated';
    if (currentUser != null)
      mh += ' by ' + currentUser.Contact.Name + ' (' + currentUser.Id + ')';
    else
      mh += ' by Auto-Hold';
    mh += '<br /> &nbsp;&nbsp;<b>Hold Status:</b> ';
    if (org.Hold_Status__c != null && org.Hold_Status__c != '')
      mh += org.Hold_Status__c;
    mh += '<br /> &nbsp;&nbsp;<b>Hold Reason:</b> ';
    if (org.Hold_Reason__c != null)
      mh += org.Hold_Reason__c;
    mh += '<br /> &nbsp;&nbsp;<b>Hold Notes:</b> ';
    if (org.Hold_Notes__c != null)
      mh += org.Hold_Notes__c;
    if (org.Hold_History__c == null)
      org.Hold_History__c = mh;
    else
      org.Hold_History__c = mh + '<hr />' + org.Hold_History__c;
    return org.Hold_History__c;
  }
}
