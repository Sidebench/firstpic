public class AffiliateListCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }

  public List<Account> acct_list { get; set; }
  public Id approverId { get; set; }
  public List<SelectOption> approvers { get; set; }
  public List<Contact> onLeave_list { get; set; }

  public String keyword { get; set; }
  public String primary { get; set; }
  public String secondary { get; set; }
  public String missingSecondary { get; set; }

  public AffiliateListCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    acct_list = new List<Account>();
    approvers = new List<SelectOption>();
    onLeave_list = new List<Contact>();

    approvers.add(new SelectOption('', '-- Select Approver --'));
    keyword = '';
    primary = '';
    secondary = '';
    missingSecondary = '';

    Set<Id> cId_set = new Set<Id>();
    for (Contact c : [SELECT Id FROM Contact]) {
      cId_set.add(c.Id);
    }
    for (User u : [
      SELECT Id, ContactID, Contact.Name, Profile.Name
      FROM User
      WHERE ContactId IN :cId_set AND Profile.Name = 'BBBSA Level One'
    ]) {
      //String pn = u.Profile.Name;
      //if(pn.contains('Level One')) {
      approvers.add(new SelectOption(u.ContactId, u.Contact.Name));
      //}
    }

    getLists();
  }

  public void getLists() {
    acct_list.clear();
    onLeave_list.clear();
    missingSecondary = '';

    if (userAcct != null) {
      Set<Id> leaveId_set = new Set<Id>();
      for (Account a : [
        SELECT
          Id,
          Name,
          BBBS_Id__c,
          National_Organization__c,
          Primary_Approver__c,
          Primary_Approver__r.Name,
          Primary_Approver_On_Leave__c,
          Secondary_Approver__c
        FROM Account
        WHERE National_Organization__c = :userAcct.Id
      ]) {
        acct_list.add(a);
        if (a.Primary_Approver_On_Leave__c) {
          leaveId_set.add(a.Primary_Approver__c);
          if (a.Secondary_Approver__c == null) {
            missingSecondary =
              a.Primary_Approver__r.Name +
              ' does not have a Secondary Approver assigned for ' +
              a.Name;
          }
        }
      }
      for (Contact c : [
        SELECT Id, Name
        FROM Contact
        WHERE Id IN :leaveId_set
      ]) {
        onLeave_list.add(c);
      }
    }
  }

  public void filterLists() {
    getLists();
    Integer i = 0;
    while (i < acct_list.size()) {
      String name = acct_list.get(i).Name;
      String bbbsId = '';
      String ap1 = '';
      String ap2 = '';

      if (acct_list.get(i).BBBS_Id__c != null) {
        bbbsId = String.valueOf(acct_list.get(i).BBBS_Id__c);
      }
      if (acct_list.get(i).Primary_Approver__c != null) {
        ap1 = String.valueOf(acct_list.get(i).Primary_Approver__r.Name);
      }
      if (acct_list.get(i).Secondary_Approver__c != null) {
        ap2 = String.valueOf(acct_list.get(i).Secondary_Approver__r.Name);
      }

      if (
        keyword != '' &&
        (!name.toLowerCase().contains(String.valueOf(keyword).toLowerCase()) &&
        !bbbsId.contains(String.valueOf(keyword).toLowerCase()))
      ) {
        acct_list.remove(i);
      } else if (
        (primary != '' && ap1 == '') ||
        (primary != '' &&
        ap1 != '' &&
        !ap1.toLowerCase().contains(String.valueOf(primary).toLowerCase()))
      ) {
        acct_list.remove(i);
      } else if (
        (secondary != '' && ap2 == '') ||
        (secondary != '' &&
        ap2 != '' &&
        !ap2.toLowerCase().contains(String.valueOf(secondary).toLowerCase()))
      ) {
        acct_list.remove(i);
      } else {
        i++;
      }
    }
  }

  public void removeFromLeave() {
    if (approverId != null) {
      for (Account a : acct_list) {
        if (a.Primary_Approver__c == approverId) {
          a.Primary_Approver_On_Leave__c = false;
        }
      }
    }
    save();
  }

  public void markAllOnLeave() {
    for (Account a : acct_list) {
      a.Primary_Approver_On_Leave__c = true;
    }
  }

  public void save() {
    try {
      update acct_list;
      system.debug(
        '>>> Affiliates updated successfully. acct_list = ' + acct_list
      );
    } catch (Exception e) {
      system.debug(e.getMessage());
    }
    keyword = '';
    primary = '';
    secondary = '';
    getLists();
  }
}
