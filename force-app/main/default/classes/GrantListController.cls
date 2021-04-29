public class GrantListController {
  private UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String approverLevel { get; set; }
  public String portalName { get; set; }
  public String url { get; set; }

  public ID accountId { get; set; }
  public List<Grant__c> grant_list { get; set; }
  public ID GrantID { get; set; }
  public List<Grant__c> subgrant_list { get; set; }
  public String errorMessage { get; set; }

  public GrantListController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    approverLevel = userClass.approverLevel;
    portalName = userClass.userProfile;

    url = '';
    if (portalName == 'NPAL')
      url = 'NPAL';

    grant_list = new List<Grant__c>();
    subgrant_list = new List<Grant__c>();

    if (userAcct != null) {
      for (Grant__c g : [
        SELECT
          Id,
          Account__r.Id,
          Name,
          RecordType.Name,
          Amount__c,
          Balance__c,
          Start_Date__c,
          End_Date__c,
          Grant_Status__c,
          Total_Requested_Amount__c,
          Total_Approved_Amount__c
        FROM Grant__c
      ]) {
        if (g.Account__r.ID == userAcct.Id) {
          if (g.RecordType.Name == 'Grant') {
            grant_list.add(g);
          } else {
            subgrant_list.add(g);
          }
        }
      }
    }
  }

  public PageReference goToGrant() {
    PageReference pr = new PageReference('/GrantDetails?GrantID=' + GrantID);
    pr.setRedirect(true);
    return pr;
  }

  public PageReference goToSubGrant() {
    PageReference pr = new PageReference(
      '/' +
      url +
      'SubGrantDetails?GrantID=' +
      GrantID
    );
    pr.setRedirect(true);
    return pr;
  }
}
