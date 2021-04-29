public with sharing class UADashboardCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }

  public List<Application__c> submitted_app_list { get; set; }
  public List<Application__c> reviewed_app_list { get; set; }

  public Boolean more_submitted { get; set; }
  public Boolean more_reviewed { get; set; }

  public UADashboardCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;

    submitted_app_list = new List<Application__c>();
    reviewed_app_list = new List<Application__c>();

    if (userAcct != null) {
      Integer listLimit = 10;

      for (
        Application__c a : [
          SELECT Name, Organization_Name__c, Status__c
          FROM Application__c
          //WHERE (National_Organization__c = :userAcct.Id OR Organization__r.National_Organization__c = :userAcct.Id)
          WHERE National_Organization__c = :userAcct.Id
        ]
      ) {
        if (a.Status__c == 'Submitted') {
          if (submitted_app_list.size() < listLimit) {
            submitted_app_list.add(a);
          } else {
            more_submitted = true;
          }
        }
        if (a.Status__c == 'Reviewed') {
          if (reviewed_app_list.size() < listLimit) {
            reviewed_app_list.add(a);
          } else {
            more_reviewed = true;
          }
        }
      }
    }
  }

  public ApexPages.PageReference init() {
    if (currentUser == null || userAcct == null) {
      PageReference pageRef = new PageReference('/login');
      return pageRef;
    }
    if ((currentUser.Profile.Name).contains('Report Builder')) {
      PageReference pageRef = new PageReference('/00O/o');
      return pageRef;
    }
    return null;
  }
}
