public with sharing class SelectOptionsClass {
  public Decimal getNumberOfApprovals(Id grantId, String objectType) {
    Decimal numberOfApprovals = 1;
    String soql = 'SELECT RecordType.Name, National_Grant__r.Number_of_Approvals_Required__c, Number_of_Approvals_Required__c, National_Grant__r.Number_Reimbursement_Approvals_Required__c, Number_Reimbursement_Approvals_Required__c FROM Grant__c';
    if (grantId != null)
      soql += ' WHERE Id = \'' + grantId + '\'';
    for (Grant__c g : database.query(soql)) {
      if (objectType == 'grant') {
        if (
          g.RecordType.Name == 'Grant' &&
          g.Number_of_Approvals_Required__c > numberOfApprovals
        )
          numberOfApprovals = g.Number_of_Approvals_Required__c;
        else if (
          g.National_Grant__r.Number_of_Approvals_Required__c >
          numberOfApprovals
        )
          numberOfApprovals = g.National_Grant__r.Number_of_Approvals_Required__c;
      } else {
        if (
          g.RecordType.Name == 'Grant' &&
          g.Number_Reimbursement_Approvals_Required__c > numberOfApprovals
        )
          numberOfApprovals = g.Number_Reimbursement_Approvals_Required__c;
        else if (
          g.National_Grant__r.Number_Reimbursement_Approvals_Required__c >
          numberOfApprovals
        )
          numberOfApprovals = g.National_Grant__r.Number_Reimbursement_Approvals_Required__c;
      }
    }
    return numberOfApprovals;
  }

  public List<SelectOption> getStatusOptions(
    String userAcctType,
    String portalName,
    Id grantId,
    String objectType
  ) {
    Decimal numberOfApprovals = getNumberOfApprovals(grantId, objectType);
    if (portalName == '')
      portalName = 'BBBS';

    List<SelectOption> statusOptions = new List<SelectOption>();
    if (grantId != null || userAcctType == 'Local Organization')
      statusOptions.add(new SelectOption('View All', 'View All'));
    statusOptions.add(new SelectOption('Incomplete', 'Incomplete'));
    if (userAcctType == 'Local Organization') {
      statusOptions.add(new SelectOption('All In Progress', 'All In Progress'));
      statusOptions.add(new SelectOption('All Revisions', 'Revisions Needed'));
      if (
        objectType == 'grant' && (portalName == 'NPAL' || portalName == 'BBBS')
      )
        statusOptions.add(new SelectOption('Pending Review', 'Pending Review'));
      else
        statusOptions.add(
          new SelectOption('Pending Approval', 'Pending Approval')
        );
    } else {
      statusOptions.add(
        new SelectOption('Revisions Needed', 'Revisions Needed')
      );
      statusOptions.add(
        new SelectOption('Revision in Progress', 'Revision in Progress')
      );

      if (portalName == 'NPAL' || portalName == 'BBBS') {
        if (objectType == 'grant')
          statusOptions.add(
            new SelectOption('Pending Review', 'Pending Review')
          );
        else {
          statusOptions.add(
            new SelectOption('Pending Approval', 'All Pending Approval')
          );
          statusOptions.add(
            new SelectOption('Pending First Approval', 'Pending First Approval')
          );
          statusOptions.add(
            new SelectOption(
              'Pending Second Approval',
              'Pending Second Approval'
            )
          );
          statusOptions.add(
            new SelectOption('Pending Final Approval', 'Pending Final Approval')
          );
        }
      } else {
        if (numberOfApprovals > 1)
          statusOptions.add(
            new SelectOption('Pending Approval', 'All Pending Approval')
          );
        statusOptions.add(
          new SelectOption('Pending First Approval', 'Pending First Approval')
        );
        if (numberOfApprovals > 1)
          statusOptions.add(
            new SelectOption(
              'Pending Second Approval',
              'Pending Second Approval'
            )
          );
        if (numberOfApprovals > 2)
          statusOptions.add(
            new SelectOption('Pending Third Approval', 'Pending Third Approval')
          );
        if (numberOfApprovals > 3)
          statusOptions.add(
            new SelectOption(
              'Pending Fourth Approval',
              'Pending Fourth Approval'
            )
          );
      }
    }
    statusOptions.add(new SelectOption('Approved', 'Approved'));
    if (objectType != 'grant') {
      statusOptions.add(new SelectOption('Paid', 'Paid'));
      statusOptions.add(new SelectOption('Denied', 'Denied'));
    }
    if (userAcctType == 'National Organization') {
      statusOptions.add(new SelectOption('Closed', 'Closed'));
    }
    return statusOptions;
  }

  public String getDefaultStatus(
    String portalName,
    String userAcctType,
    Id grantId,
    String objectType,
    String approverLevel,
    String status
  ) {
    Decimal numberOfApprovals = getNumberOfApprovals(grantId, objectType);
    if (portalName == '')
      portalName = 'BBBS';

    if (userAcctType == 'Local Organization') {
      if (status == null || status == '') {
        if (objectType == 'grant')
          status = 'View All';
        else
          status = 'All In Progress';
      }
      if (status.contains('pending'))
        status = 'Pending Approval';
    } else {
      if (status == null || status == '' || status == 'pending') {
        if (
          (portalName == 'NPAL' || portalName == 'BBBS') &&
          objectType == 'grant'
        )
          status = 'Pending Review';
        else if (approverLevel == 'Level One' || numberOfApprovals == 1)
          status = 'Pending First Approval';
        else if (approverLevel.contains('Level Two') || numberOfApprovals == 2)
          status = 'Pending Second Approval';
        else if (
          portalName != 'NPAL' &&
          portalName != 'BBBS' &&
          (approverLevel == 'Level Three' ||
          numberOfApprovals == 3)
        )
          status = 'Pending Third Approval';
        else if (
          (portalName == 'NPAL' || portalName == 'BBBS') &&
          approverLevel == 'Level Three'
        )
          status = 'Pending Final Approval';
        else if (approverLevel == 'Level Four')
          status = 'Pending Fourth Approval';
      }
    }
    return status;
  }

  public List<SelectOption> getGrantYearOptions(
    Id acctId,
    String userAcctType
  ) {
    List<SelectOption> selectOptions = new List<SelectOption>();
    Account acct = [
      SELECT Grant_Year_Options__c, National_Grant_Year_Options__c
      FROM Account
      WHERE ID = :acctId
    ];

    String options = acct.National_Grant_Year_Options__c;
    if (userAcctType == 'National Organization')
      options = acct.Grant_Year_Options__c;
    if (options != null) {
      for (String n : options.split(';')) {
        if (n != '')
          selectOptions.add(new SelectOption(n, n));
      }
    }
    return selectOptions;
  }
}
