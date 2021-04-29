@isTest
public class TestVictimsServedReport {
  static testMethod void testVictimsServedReports() {
    system.test.startTest();

    Account a = new Account(Name = 'Test Account');
    insert a;

    Victims_Served_Report__c report = new Victims_Served_Report__c(
      Organization__c = a.Id,
      Month__c = 'Jan - Mar',
      Year__c = 2020,
      Tracking_New_Individuals__c = true,
      Race_Ethnicity_Tracked__c = true,
      Gender_Tracked__c = true,
      Age_Tracked__c = true,
      Info_and_Referral_Services_Provided__c = true,
      Personal_Advocacy_Services_Provided__c = true,
      Emotional_Support_Services_Provided__c = true,
      Shelter_Housing_Services_Provided__c = true,
      Justice_System_Services_Provided__c = true,
      Clients_Surveyed_for_Feedback__c = true,
      On_Track_Fiscally__c = true,
      Adult_Physical_Assault__c = 'nt',
      Adult_Sexual_Assault__c = 'nt',
      Adults_Sexually_Abused__c = 'nt',
      Arson__c = 'nt',
      Bullying__c = 'nt',
      Burglary__c = 'nt',
      Child_Physical_Abuse__c = 'nt',
      Child_Pornography__c = 'nt',
      Child_Sexual_Abuse__c = 'nt',
      Domestic_Violence__c = 'nt',
      DUI_DWI__c = 'nt',
      Elder_Abuse__c = 'nt',
      Hate_Crime__c = 'nt',
      Human_Trafficking_Labor__c = 'nt',
      Human_Trafficking_Sex__c = 'nt',
      Identity_Theft__c = 'nt',
      Kidnapping_Non_custodial__c = 'nt',
      Kidnapping_Custodial__c = 'nt',
      Mass_Violence__c = 'nt',
      Other_Vehicular_Victimization__c = 'nt',
      Robbery__c = 'nt',
      Stalking__c = 'nt',
      Survivors_of_Homicide_Victims__c = 'nt',
      Teen_Dating_Victimization__c = 'nt',
      Terrorism__c = 'nt',
      Other_Victimization__c = 'nt',
      Number_w_Multiple_Type_of_Victimization__c = 'nt',
      Deaf_Hard_of_Hearing__c = 'nt',
      Homeless__c = 'nt',
      Immigrants_Refugees_Asylum_Seekers__c = 'nt',
      LGBTQ__c = 'nt',
      Veterans__c = 'nt',
      Victims_with_Disabilities__c = 'nt',
      Victims_with_Limited_English_Proficiency__c = 'nt',
      Other_Special_Classification__c = 'nt'
    );
    insert report;

    List<Victims_Served_Report__c> reports = new List<Victims_Served_Report__c>();
    for (Integer i = 0; i < 50; i++) {
      Victims_Served_Report__c r = new Victims_Served_Report__c(
        Organization__c = a.Id,
        Month__c = 'Jan - Mar',
        Year__c = 2020
      );
      reports.add(r);
    }
    insert reports;

    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'OVC Level Three'];
    Contact c1 = new Contact(
      accountId = a.Id,
      lastName = 'Contact',
      firstName = 'Test1',
      Email = 'newtest1@example.com'
    );
    insert c1;
    User u1 = new User(
      Alias = 'testu',
      Email = 'test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = p1.Id,
      UserName = 'levelthree@test1.com',
      Contact = c1,
      ContactId = c1.Id
    );
    insert u1;

    System.runAs(u1) {
      system.test.setCurrentPageReference(
        new PageReference('Page.OVCProgramReport?reportId=' + report.Id)
      );
      VictimsServedReportCtrl ctrl1 = new VictimsServedReportCtrl();
      ctrl1.updateFieldVisibility();
      ctrl1.next();
      ctrl1.next();
      ctrl1.next();
      ctrl1.previous();
      ctrl1.save();
      ctrl1.submit();
      ctrl1.showValidationPopup();
      ctrl1.hideValidationPopup();
      ctrl1.hideValidationPopupAndContinue();
      //            Victims_Served_Report__c result = [SELECT Burglary__c FROM Victims_Served_Report__c WHERE Id = :report.id];
      //            system.assertEquals('N/T', result.Burglary__c);

      VictimsServedReportsCtrl ctrl2 = new VictimsServedReportsCtrl();
      ctrl2.getLists();
      ctrl2.next();
      ctrl2.previous();
      ctrl2.last();
      ctrl2.getLastCounter();
      ctrl2.getRecordCount();
      ctrl2.getDisableNext();
      ctrl2.getDisablePrevious();
    }

    system.test.stopTest();
  }
}
