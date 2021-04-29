global with sharing class UserClass {
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String userProfile { get; set; }
  public String approverLevel { get; set; }

  public UserClass() {
    currentUser = [
      SELECT
        ContactId,
        Contact.Name,
        Contact.FirstName,
        Contact.LastName,
        Contact.Email,
        Contact.Role__c,
        AccountId,
        Account.Name,
        Account.RecordType.Name,
        IsActive,
        Profile.Name
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    if (currentUser.AccountId != null) {
      Account[] accounts = [
        SELECT
          ID,
          Name,
          Account.Session__c,
          RecordType.Name,
          DUNS_Exp_Date__c,
          Local_Organization_Id__c,
          Current_Grant_Year__c,
          Has_Sites__c,
          National_Has_Sites__c,
          National_Grants__c,
          National_Grant_Year_Options__c,
          Grant_Year_Options__c
        FROM Account
        WHERE ID = :currentUser.AccountId
      ];
      if (accounts.size() > 0)
        userAcct = accounts[0];
      userAcctType = currentUser.Account.RecordType.Name;
    }

    userProfile = '';
    String profile = currentUser.Profile.Name;
    if (profile.contains('BBBS')) {
      userProfile = 'BBBS';
    } else if (profile.contains('DMV')) {
      userProfile = 'DMV';
    } else if (profile.contains('PAL')) {
      userProfile = 'NPAL';
    } else if (profile.contains('LEGO')) {
      userProfile = 'LEGO';
    } else if (profile.contains('NCAI')) {
      userProfile = 'NCAI';
    } else if (profile.contains('TRAIL')) {
      userProfile = 'NCAI - TRAIL';
    } else if (profile.contains('OVC')) {
      userProfile = 'NCAI - OVC';
    } else if (profile.contains('STEM')) {
      userProfile = 'STEM';
    } else if (profile.contains('Ripken')) {
      userProfile = 'Ripken';
    } else if (profile.contains('UA')) {
      userProfile = 'UA';
    }

    approverLevel = '';
    if (profile.contains('Level One')) {
      approverLevel = 'Level One';
    } else if (profile.contains('Level Two')) {
      if (profile.contains('Admin')) {
        approverLevel = 'Level Two Admin';
      } else {
        approverLevel = 'Level Two';
      }
    } else if (profile.contains('Level Three')) {
      if (profile.contains('Admin')) {
        approverLevel = 'Level Three Admin';
      } else {
        approverLevel = 'Level Three';
      }
    } else if (profile.contains('Level Four')) {
      approverLevel = 'Level Four';
    } else if (profile.contains('Finance Admin')) {
      approverLevel = 'Finance Admin';
    }
  }
}
