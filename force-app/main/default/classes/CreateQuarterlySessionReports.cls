public class CreateQuarterlySessionReports implements Schedulable {
  private GetMonthAsString gms = new GetMonthAsString();

  public void execute(SchedulableContext sc) {
    Date dt = date.today();
    GetMonthAsString gms = new GetMonthAsString();
    String month = gms.getMonth(dt.month());
    String thisYear = string.valueOf(dt.year());
    String nextYear = string.valueOf(dt.year() + 1);
    String prevYear = string.valueOf(dt.year() - 1);
    String reportingPeriod = '';
    String yearRange = prevYear + '-' + thisYear;
    if (month == 'February') {
      reportingPeriod = yearRange + ' Q2';
    } else if (month == 'May') {
      reportingPeriod = yearRange + ' Q3';
    } else if (month == 'August') {
      reportingPeriod = yearRange + ' Q4';
    } else if (month == 'November') {
      yearRange = thisYear + '-' + nextYear;
      reportingPeriod = yearRange + ' Q1';
    }

    if (
      month == 'February' ||
      month == 'May' ||
      month == 'August' ||
      month == 'November'
    ) {
      List<Session_Report__c> reports = new List<Session_Report__c>();
      for (Account a : [
        SELECT
          Id,
          Name,
          Local_Organization__r.CEO__c,
          Local_Organization__r.CEO_Email__c,
          Local_Organization__r.Program_Coordinator__c,
          Local_Organization__r.Program_Coordinator_Email__c,
          Local_Organization__r.DOD_Email__c
        FROM Account
        WHERE
          FirstPic_National_Org_Code__c = 'NCAI'
          AND RecordType.Name = 'Site'
          AND Is_Active__c = TRUE
      ]) {
        String name = a.Name;
        List<String> elems = name.split(' ');
        name = '';
        for (String x : elems) {
          name += x.substring(0, 1).toUpperCase();
        }
        name = name.replace('&', '');
        name = name.replace('(', '');
        name = name.replace('-', '');

        Session_Report__c report = new Session_Report__c(
          Name = name + ' ' + reportingPeriod + ' Progress Report',
          Status__c = 'Not Started',
          Site__c = a.Id,
          Reporting_Period__c = reportingPeriod,
          Year__c = yearRange,
          CEO__c = a.Local_Organization__r.CEO__c,
          CEO_Email__c = a.Local_Organization__r.CEO_Email__c,
          Program_Coordinator__c = a.Local_Organization__r.Program_Coordinator__c,
          Program_Coordinator_Email__c = a.Local_Organization__r.Program_Coordinator_Email__c,
          DOD_Email__c = a.Local_Organization__r.DOD_Email__c,
          RecordTypeID = Schema.SObjectType.Session_Report__c.getRecordTypeInfosByName()
            .get('Progress Report')
            .getRecordTypeId()
        );
        reports.add(report);
      }
      insert reports;
    }
  }
}
