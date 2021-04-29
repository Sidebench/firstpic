public with sharing class HeaderCtrl {
  private UserClass uc = new UserClass();
  private AccountClass ac = new AccountClass();
  private TALogClass lc = new TALogClass();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public TA_Log__c log { get; set; }
  public List<SelectOption> orgOptions { get; set; }

  public Boolean hasOVC { get; set; }
  public Boolean displayHoldPopup { get; set; }
  public Boolean displayTALogPopup { get; set; }

  public HeaderCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    System.debug('userAcctType: ' + uc.userAcctType);
    userAcctType = uc.userAcctType;

    Account a = ac.getAccount(userAcct.Id);
    if (a.Hold_Status__c == 'Hold')
      displayHoldPopup = true;

    hasOVC = false;
    if (
      userAcct.National_Grants__c != null &&
      userAcct.National_Grants__c.contains('OVC')
    )
      hasOVC = true;
  }

  public void hideHoldPopup() {
    displayHoldPopup = false;
  }

  public void upsertTALog() {
    lc.upsertTALog(log, currentUser.ContactId);
    displayTALogPopup = false;
  }
  public void showTALogPopup() {
    orgOptions = ac.getOrgOptions(userAcct.Id, userAcctType, uc.userProfile);
    log = new TA_Log__c(
      TA_By__c = currentUser.ContactId,
      Date__c = date.today()
    );
    displayTALogPopup = true;
  }
  public void hideTALogPopup() {
    displayTALogPopup = false;
  }
}
