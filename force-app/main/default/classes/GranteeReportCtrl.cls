public class GranteeReportCtrl {
  public ID GrantID { get; set; }
  public Grant__c grant { get; set; }
  public Boolean showSuccess { get; set; }

  public GranteeReportCtrl() {
    GrantID = ApexPages.currentPage().getParameters().get('GrantId');
    grant = new Grant__c();

    if (GrantID != null) {
      grant = [
        SELECT
          Name,
          Account__r.Name,
          Project_Name__c,
          Overview_of_Outcomes_Achieved__c,
          Successes_Challenges_Experiencesd__c,
          Opportunities_Provided_by_Funding__c,
          Breakdown_of_Expenses__c,
          Unmet_Needs_Description__c
        FROM Grant__c
        WHERE Id = :GrantId
      ];
    }
  }

  public void save() {
    grant.Report_Submitted_Date__c = date.today();
    try {
      update grant;
      showSuccess = true;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }
  }
}
