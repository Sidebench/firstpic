public with sharing class VictimsServedReportCtrl {
  private UserClass uc = new UserClass();
  private VictimsServedReportClass vsrc = new VictimsServedReportClass();
  private FieldLabelClass flc = new FieldLabelClass();

  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String userAcctType { get; set; }
  public String portalName { get; set; }

  public Id reportId { get; set; }
  public Victims_Served_Report__c report { get; set; }
  public List<Field_Label__c> fields { get; set; }
  public Map<String, String> labels { get; set; }

  public Boolean ableToTrack { get; set; }
  public Boolean raceTracked { get; set; }
  public Boolean genderTracked { get; set; }
  public Boolean ageTracked { get; set; }
  public Boolean infoProvided { get; set; }
  public Boolean advocacyProvided { get; set; }
  public Boolean supportProvided { get; set; }
  public Boolean housingProvided { get; set; }
  public Boolean justiceProvided { get; set; }
  public Boolean clientsSurveyed { get; set; }
  public Boolean onTrackFiscally { get; set; }

  public Boolean isFinalReport { get; set; }
  public Integer currentPage { get; set; }
  public Boolean readOnly { get; set; }
  public Boolean displayValidationPopup { get; set; }
  public Boolean displaySendBackPopup { get; set; }

  public String errorMessage { get; set; }
  public String pageTwoErrorMessage { get; set; }
  public String successMessage { get; set; }
  public String notTrackedMessage { get; set; }

  public VictimsServedReportCtrl() {
    currentUser = uc.currentUser;
    userAcct = uc.userAcct;
    userAcctType = uc.userAcctType;
    portalName = uc.userProfile;

    ableToTrack = false;
    raceTracked = false;
    genderTracked = false;
    ageTracked = false;
    infoProvided = false;
    advocacyProvided = false;
    supportProvided = false;
    housingProvided = false;
    justiceProvided = false;
    clientsSurveyed = false;
    onTrackFiscally = false;

    //errorMessage = '';

    isFinalReport = false;
    currentPage = 1;
    readOnly = false;

    report = new Victims_Served_Report__c();
    String urlReportId = ApexPages.currentPage()
      .getParameters()
      .get('reportId');
    if (urlReportId != '' && urlReportId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(urlReportId)
          .matches()
      ) {
        reportId = Id.valueOf(urlReportId);
      }
    }

    report = vsrc.getReport(reportId);
    if (report != null) {
      if (
        userAcctType == 'Local Organization' &&
        (report.Status__c == 'Submitted' ||
        report.Status__c == 'Approved')
      )
        readOnly = true;
      if (userAcctType == 'National Organization')
        readOnly = true;

      if (
        (report.Month__c == 'Jul - Sep' && report.Year__c == 2021) ||
        (report.Month__c == 'Apr - Jun' &&
        report.Year__c == 2022)
      )
        isFinalReport = true;

      fields = flc.getFields('Victims_Served_Report__c', 'OVC', null, null);
      labels = flc.getFieldLabelMap(
        'Victims_Served_Report__c',
        'OVC',
        null,
        null
      );

      ableToTrack = report.Tracking_New_Individuals__c;
      raceTracked = report.Race_Ethnicity_Tracked__c;
      genderTracked = report.Gender_Tracked__c;
      ageTracked = report.Age_Tracked__c;
      infoProvided = report.Info_and_Referral_Services_Provided__c;
      advocacyProvided = report.Personal_Advocacy_Services_Provided__c;
      supportProvided = report.Emotional_Support_Services_Provided__c;
      housingProvided = report.Shelter_Housing_Services_Provided__c;
      justiceProvided = report.Justice_System_Services_Provided__c;
      clientsSurveyed = report.Clients_Surveyed_for_Feedback__c;
      onTrackFiscally = report.On_Track_Fiscally__c;
    }
  }

  public void updateFieldVisibility() {
    if (ableToTrack)
      report.Tracking_New_Individuals__c = true;
    else
      report.Tracking_New_Individuals__c = false;

    if (raceTracked)
      report.Race_Ethnicity_Tracked__c = true;
    else
      report.Race_Ethnicity_Tracked__c = false;

    if (genderTracked)
      report.Gender_Tracked__c = true;
    else
      report.Gender_Tracked__c = false;

    if (ageTracked)
      report.Age_Tracked__c = true;
    else
      report.Age_Tracked__c = false;

    if (infoProvided)
      report.Info_and_Referral_Services_Provided__c = true;
    else
      report.Info_and_Referral_Services_Provided__c = false;

    if (advocacyProvided)
      report.Personal_Advocacy_Services_Provided__c = true;
    else
      report.Personal_Advocacy_Services_Provided__c = false;

    if (supportProvided)
      report.Emotional_Support_Services_Provided__c = true;
    else
      report.Emotional_Support_Services_Provided__c = false;

    if (housingProvided)
      report.Shelter_Housing_Services_Provided__c = true;
    else
      report.Shelter_Housing_Services_Provided__c = false;

    if (justiceProvided)
      report.Justice_System_Services_Provided__c = true;
    else
      report.Justice_System_Services_Provided__c = false;

    if (clientsSurveyed)
      report.Clients_Surveyed_for_Feedback__c = true;
    else
      report.Clients_Surveyed_for_Feedback__c = false;

    if (onTrackFiscally)
      report.On_Track_Fiscally__c = true;
    else
      report.On_Track_Fiscally__c = false;
  }

  public void next() {
    if (readOnly || userAcctType == 'National Organization')
      currentPage = currentPage + 1;
    else {
      save();
      if (
        currentPage == 2 &&
        notTrackedMessage != null &&
        notTrackedMessage != '' &&
        userAcctType == 'Local Organization' &&
        report.Status__c != 'Submitted' &&
        report.Status__c == 'Approved'
      ) {
        showValidationPopup();
      } else if (
        currentPage != 2 ||
        pageTwoErrorMessage == '' ||
        pageTwoErrorMessage == null
      ) {
        currentPage = currentPage + 1;
      }
    }
  }

  public void previous() {
    if (!readOnly)
      save();
    currentPage = currentPage - 1;
  }

  public void save() {
    if (report.Status__c == 'Requested' && userAcctType == 'Local Organization')
      report.Status__c = 'In Progress';
    if (
      report.Status__c == 'Revisions Needed' &&
      userAcctType == 'Local Organization'
    )
      report.Status__c = 'Revisions in Progress';
    if (currentPage == 2 && userAcctType == 'Local Organization')
      pageTwoValidation();
    if (errorMessage == '' || errorMessage == null) {
      vsrc.upsertReport(report);
      if (ApexPages.hasMessages())
        errorMessage += string.valueOf(ApexPages.getMessages());
      else
        successMessage = 'Save successful.';
    }
  }

  public PageReference submit() {
    errorMessage = '';
    successMessage = '';
    requiredFieldsValidation();
    if (errorMessage == '') {
      report.Status__c = 'Submitted';
      report.Submitted_Date__c = Date.today();
      vsrc.upsertReport(report);
      if (ApexPages.hasMessages()) {
        errorMessage += string.valueOf(ApexPages.getMessages());
      } else {
        successMessage = 'Submitted successfully.';
        readOnly = true;
        return new PageReference('/OVCProgramReports');
      }
    }
    return null;
  }

  public PageReference sendBack() {
    report.Status__c = 'Revisions Needed';
    vsrc.upsertReport(report);
    if (ApexPages.hasMessages()) {
      errorMessage += string.valueOf(ApexPages.getMessages());
    } else {
      successMessage = 'Sent back successfully.';
      readOnly = true;
      return new PageReference('/OVCProgramReports');
    }
    return null;
  }

  public PageReference approve() {
    report.Status__c = 'Approved';
    vsrc.upsertReport(report);
    if (ApexPages.hasMessages()) {
      errorMessage += string.valueOf(ApexPages.getMessages());
    } else {
      successMessage = 'Approved successfully.';
      readOnly = true;
      return new PageReference('/OVCProgramReports');
    }
    return null;
  }

  public void pageTwoValidation() {
    pageTwoErrorMessage = '';

    // Types of Victimization questions should be a number or N/T
    notTrackedMessage = '';
    String fieldsMarkedNotTracked = '';

    if (
      report.Adult_Physical_Assault__c == null ||
      report.Adult_Physical_Assault__c == ''
    )
      pageTwoErrorMessage += 'A value for Adult Physical Assault is required. <br />';
    else if (!report.Adult_Physical_Assault__c.isNumeric()) {
      report.Adult_Physical_Assault__c = 'N/T';
      fieldsMarkedNotTracked += 'Adult Physical Assault <br />';
    }
    if (
      report.Adult_Sexual_Assault__c == null ||
      report.Adult_Sexual_Assault__c == ''
    )
      pageTwoErrorMessage += 'A value for Adult Sexual Assault is required. <br />';
    else if (!report.Adult_Sexual_Assault__c.isNumeric()) {
      report.Adult_Sexual_Assault__c = 'N/T';
      fieldsMarkedNotTracked += 'Adult Sexual Assault <br />';
    }
    if (
      report.Adults_Sexually_Abused__c == null ||
      report.Adults_Sexually_Abused__c == ''
    )
      pageTwoErrorMessage += 'A value for Adults Sexually Abused/Assaulted as Children is required. <br />';
    else if (!report.Adults_Sexually_Abused__c.isNumeric()) {
      report.Adults_Sexually_Abused__c = 'N/T';
      fieldsMarkedNotTracked += 'Adults Sexually Abused/Assaulted as Children <br />';
    }
    if (report.Arson__c == null || report.Arson__c == '')
      pageTwoErrorMessage += 'A value for Arson is required. <br />';
    else if (!report.Arson__c.isNumeric()) {
      report.Arson__c = 'N/T';
      fieldsMarkedNotTracked += 'Arson <br />';
    }
    if (report.Bullying__c == null || report.Bullying__c == '')
      pageTwoErrorMessage += 'A value for Bullying (Verbal, Cyber, or Physical) is required. <br />';
    else if (!report.Bullying__c.isNumeric()) {
      report.Bullying__c = 'N/T';
      fieldsMarkedNotTracked += 'Bullying (Verbal, Cyber, or Physical) <br />';
    }
    if (report.Burglary__c == null || report.Burglary__c == '')
      pageTwoErrorMessage += 'A value for Burglary is required. <br />';
    else if (!report.Burglary__c.isNumeric()) {
      report.Burglary__c = 'N/T';
      fieldsMarkedNotTracked += 'Burglary <br />';
    }
    if (
      report.Child_Physical_Abuse__c == null ||
      report.Child_Physical_Abuse__c == ''
    )
      pageTwoErrorMessage += 'A value for Child Physical Abuse or Neglect is required. <br />';
    else if (!report.Child_Physical_Abuse__c.isNumeric()) {
      report.Child_Physical_Abuse__c = 'N/T';
      fieldsMarkedNotTracked += 'Child Physical Abuse or Neglect <br />';
    }
    if (
      report.Child_Pornography__c == null ||
      report.Child_Pornography__c == ''
    )
      pageTwoErrorMessage += 'A value for Child Pornography is required. <br />';
    else if (!report.Child_Pornography__c.isNumeric()) {
      report.Child_Pornography__c = 'N/T';
      fieldsMarkedNotTracked += 'Child Pornography <br />';
    }
    if (
      report.Child_Sexual_Abuse__c == null ||
      report.Child_Sexual_Abuse__c == ''
    )
      pageTwoErrorMessage += 'A value for Child Sexual Abuse/Assault is required. <br />';
    else if (!report.Child_Sexual_Abuse__c.isNumeric()) {
      report.Child_Sexual_Abuse__c = 'N/T';
      fieldsMarkedNotTracked += 'Child Sexual Abuse/Assault <br />';
    }
    if (
      report.Domestic_Violence__c == null ||
      report.Domestic_Violence__c == ''
    )
      pageTwoErrorMessage += 'A value for Domestic and/or Family Violence is required. <br />';
    else if (!report.Domestic_Violence__c.isNumeric()) {
      report.Domestic_Violence__c = 'N/T';
      fieldsMarkedNotTracked += 'Domestic and/or Family Violence <br />';
    }
    if (report.DUI_DWI__c == null || report.DUI_DWI__c == '')
      pageTwoErrorMessage += 'A value for DUI/DWI Incidents is required. <br />';
    else if (!report.DUI_DWI__c.isNumeric()) {
      report.DUI_DWI__c = 'N/T';
      fieldsMarkedNotTracked += 'DUI/DWI Incidents <br />';
    }
    if (report.Elder_Abuse__c == null || report.Elder_Abuse__c == '')
      pageTwoErrorMessage += 'A value for Elder Abuse or Neglect is required. <br />';
    else if (!report.Elder_Abuse__c.isNumeric()) {
      report.Elder_Abuse__c = 'N/T';
      fieldsMarkedNotTracked += 'Elder Abuse or Neglect <br />';
    }
    if (report.Hate_Crime__c == null || report.Hate_Crime__c == '')
      pageTwoErrorMessage += 'A value for Hate Crime is required. <br />';
    else if (!report.Hate_Crime__c.isNumeric()) {
      report.Hate_Crime__c = 'N/T';
      fieldsMarkedNotTracked += 'Hate Crime <br />';
    } else if (
      report.Hate_Crime__c.isNumeric() &&
      Integer.valueOf(report.Hate_Crime__c) > 0 &&
      (report.Hate_Crime_Explanation__c == null ||
      report.Hate_Crime_Explanation__c == '')
    ) {
      pageTwoErrorMessage += 'A value for Hate Crime Explanation is required if Hate Crime is greater than 0. <br />';
    }

    if (
      report.Human_Trafficking_Labor__c == null ||
      report.Human_Trafficking_Labor__c == ''
    )
      pageTwoErrorMessage += 'A value for Human Trafficking: Labor is required. <br />';
    else if (!report.Human_Trafficking_Labor__c.isNumeric()) {
      report.Human_Trafficking_Labor__c = 'N/T';
      fieldsMarkedNotTracked += 'Human Trafficking: Labor <br />';
    }
    if (
      report.Human_Trafficking_Sex__c == null ||
      report.Human_Trafficking_Sex__c == ''
    )
      pageTwoErrorMessage += 'A value for Human Trafficking: Sex is required. <br />';
    else if (!report.Human_Trafficking_Sex__c.isNumeric()) {
      report.Human_Trafficking_Sex__c = 'N/T';
      fieldsMarkedNotTracked += 'Human Trafficking: Sex <br />';
    }
    if (report.Identity_Theft__c == null || report.Identity_Theft__c == '')
      pageTwoErrorMessage += 'A value for Identity Theft/Fraud/Financial Crime is required. <br />';
    else if (!report.Identity_Theft__c.isNumeric()) {
      report.Identity_Theft__c = 'N/T';
      fieldsMarkedNotTracked += 'Identity Theft/Fraud/Financial Crime <br />';
    }
    if (
      report.Kidnapping_Non_custodial__c == null ||
      report.Kidnapping_Non_custodial__c == ''
    )
      pageTwoErrorMessage += 'A value for Kidnapping (Non-custodial) is required. <br />';
    else if (!report.Kidnapping_Non_custodial__c.isNumeric()) {
      report.Kidnapping_Non_custodial__c = 'N/T';
      fieldsMarkedNotTracked += 'Kidnapping (Non-custodial) <br />';
    }
    if (
      report.Kidnapping_Custodial__c == null ||
      report.Kidnapping_Custodial__c == ''
    )
      pageTwoErrorMessage += 'A value for Kidnapping (Custodial) is required. <br />';
    else if (!report.Kidnapping_Custodial__c.isNumeric()) {
      report.Kidnapping_Custodial__c = 'N/T';
      fieldsMarkedNotTracked += 'Kidnapping (Custodial) <br />';
    }
    if (report.Mass_Violence__c == null || report.Mass_Violence__c == '')
      pageTwoErrorMessage += 'A value for Mass Violence (Domestic/International) is required. <br />';
    else if (!report.Mass_Violence__c.isNumeric()) {
      report.Mass_Violence__c = 'N/T';
      fieldsMarkedNotTracked += 'Mass Violence (Domestic/International) <br />';
    }
    if (
      report.Other_Vehicular_Victimization__c == null ||
      report.Other_Vehicular_Victimization__c == ''
    )
      pageTwoErrorMessage += 'A value for Other Vehicular Victimization (e.g., Hit and Run) is required. <br />';
    else if (!report.Other_Vehicular_Victimization__c.isNumeric()) {
      report.Other_Vehicular_Victimization__c = 'N/T';
      fieldsMarkedNotTracked += 'Other Vehicular Victimization (e.g., Hit and Run)<br />';
    }
    if (report.Robbery__c == null || report.Robbery__c == '')
      pageTwoErrorMessage += 'A value for Robbery is required. <br />';
    else if (!report.Robbery__c.isNumeric()) {
      report.Robbery__c = 'N/T';
      fieldsMarkedNotTracked += 'Robbery <br />';
    }
    if (report.Stalking__c == null || report.Stalking__c == '')
      pageTwoErrorMessage += 'A value for Stalking/Harassment is required. <br />';
    else if (!report.Stalking__c.isNumeric()) {
      report.Stalking__c = 'N/T';
      fieldsMarkedNotTracked += 'Stalking/Harassment <br />';
    }
    if (
      report.Survivors_of_Homicide_Victims__c == null ||
      report.Survivors_of_Homicide_Victims__c == ''
    )
      pageTwoErrorMessage += 'A value for Survivors of Homicide Victims is required. <br />';
    else if (!report.Survivors_of_Homicide_Victims__c.isNumeric()) {
      report.Survivors_of_Homicide_Victims__c = 'N/T';
      fieldsMarkedNotTracked += 'Survivors of Homicide Victims <br />';
    }
    if (
      report.Teen_Dating_Victimization__c == null ||
      report.Teen_Dating_Victimization__c == ''
    )
      pageTwoErrorMessage += 'A value for Teen Dating Victimization is required. <br />';
    else if (!report.Teen_Dating_Victimization__c.isNumeric()) {
      report.Teen_Dating_Victimization__c = 'N/T';
      fieldsMarkedNotTracked += 'Teen Dating Victimization <br />';
    }
    if (report.Terrorism__c == null || report.Terrorism__c == '')
      pageTwoErrorMessage += 'A value for Terrorism (Domestic/International) is required. <br />';
    else if (!report.Terrorism__c.isNumeric()) {
      report.Terrorism__c = 'N/T';
      fieldsMarkedNotTracked += 'Terrorism (Domestic/International) <br />';
    }
    if (
      report.Other_Victimization__c == null ||
      report.Other_Victimization__c == ''
    )
      pageTwoErrorMessage += 'A value for Other Victimization is required. <br />';
    else if (!report.Other_Victimization__c.isNumeric()) {
      report.Other_Victimization__c = 'N/T';
      fieldsMarkedNotTracked += 'Other Victimization <br />';
    } else if (
      report.Other_Victimization__c.isNumeric() &&
      Integer.valueOf(report.Other_Victimization__c) > 0 &&
      (report.Other_Victimization_Explanation__c == null ||
      report.Other_Victimization_Explanation__c == '')
    ) {
      pageTwoErrorMessage += 'A value for Other Victimization Explanation is required if Other Victimization is greater than 0. <br />';
    }

    if (
      report.Number_w_Multiple_Type_of_Victimization__c == null ||
      report.Number_w_Multiple_Type_of_Victimization__c == ''
    )
      pageTwoErrorMessage += 'A value for Multiple Types of Victimization is required. <br />';
    else if (!report.Number_w_Multiple_Type_of_Victimization__c.isNumeric()) {
      report.Number_w_Multiple_Type_of_Victimization__c = 'N/T';
      fieldsMarkedNotTracked += 'Multiple Types of Victimization <br />';
    }
    if (
      report.Deaf_Hard_of_Hearing__c == null ||
      report.Deaf_Hard_of_Hearing__c == ''
    )
      pageTwoErrorMessage += 'A value for Deaf/Hard of Hearing is required. <br />';
    else if (!report.Deaf_Hard_of_Hearing__c.isNumeric()) {
      report.Deaf_Hard_of_Hearing__c = 'N/T';
      fieldsMarkedNotTracked += 'Deaf/Hard of Hearing <br />';
    }
    if (report.Homeless__c == null || report.Homeless__c == '')
      pageTwoErrorMessage += 'A value for Homeless is required. <br />';
    else if (!report.Homeless__c.isNumeric()) {
      report.Homeless__c = 'N/T';
      fieldsMarkedNotTracked += 'Homeless  <br />';
    }
    if (
      report.Immigrants_Refugees_Asylum_Seekers__c == null ||
      report.Immigrants_Refugees_Asylum_Seekers__c == ''
    )
      pageTwoErrorMessage += 'A value for Immigrants/Refugees/Asylum Seekers is required. <br />';
    else if (!report.Immigrants_Refugees_Asylum_Seekers__c.isNumeric()) {
      report.Immigrants_Refugees_Asylum_Seekers__c = 'N/T';
      fieldsMarkedNotTracked += 'Immigrants/Refugees/Asylum Seekers <br />';
    }
    if (report.LGBTQ__c == null || report.LGBTQ__c == '')
      pageTwoErrorMessage += 'A value for LGBTQ is required. <br />';
    else if (!report.LGBTQ__c.isNumeric()) {
      report.LGBTQ__c = 'N/T';
      fieldsMarkedNotTracked += 'LGBTQ <br />';
    }
    if (report.Veterans__c == null || report.Veterans__c == '')
      pageTwoErrorMessage += 'A value for Veterans is required. <br />';
    else if (!report.Veterans__c.isNumeric()) {
      report.Veterans__c = 'N/T';
      fieldsMarkedNotTracked += 'Veterans <br />';
    }
    if (
      report.Victims_with_Disabilities__c == null ||
      report.Victims_with_Disabilities__c == ''
    )
      pageTwoErrorMessage += 'A value for Victims with Disabilities: Cognitive/Physical/Mental is required. <br />';
    else if (!report.Victims_with_Disabilities__c.isNumeric()) {
      report.Victims_with_Disabilities__c = 'N/T';
      fieldsMarkedNotTracked += 'Victims with Disabilities: Cognitive/Physical/Mental <br />';
    }
    if (
      report.Victims_with_Limited_English_Proficiency__c == null ||
      report.Victims_with_Limited_English_Proficiency__c == ''
    )
      pageTwoErrorMessage += 'A value for Victims with Limited English Proficiency is required. <br />';
    else if (!report.Victims_with_Limited_English_Proficiency__c.isNumeric()) {
      report.Victims_with_Limited_English_Proficiency__c = 'N/T';
      fieldsMarkedNotTracked += 'Victims with Limited English Proficiency <br />';
    }
    if (
      report.Other_Special_Classification__c == null ||
      report.Other_Special_Classification__c == ''
    )
      pageTwoErrorMessage += 'A value for Other Special Classification is required. <br />';
    else if (!report.Other_Special_Classification__c.isNumeric()) {
      report.Other_Special_Classification__c = 'N/T';
      fieldsMarkedNotTracked += 'Other Special Classification <br />';
    } else if (
      report.Other_Special_Classification__c.isNumeric() &&
      Integer.valueOf(report.Other_Special_Classification__c) > 0 &&
      (report.Other_Special_Classification_Explanation__c == null ||
      report.Other_Special_Classification_Explanation__c == '')
    ) {
      pageTwoErrorMessage += 'A value for Other Special Classification Explanation is required if Other Special Classification is greater than 0. <br />';
    }

    if (fieldsMarkedNotTracked != '') {
      notTrackedMessage =
        '<strong>The following fields have been marked as <u>not tracked</u>. Please review this list carefully and confirm your organization does not track these victimization types. Click "cancel" if you need to enter data for a field listed below.</strong><br /><br />' +
        fieldsMarkedNotTracked;
    }
  }

  public void requiredFieldsValidation() {
    errorMessage = '';

    if (report.Number_of_Individuals_Received_Services__c == null)
      errorMessage += 'Page 1 Q1: Number of individuals who received services is required. <br />';
    if (report.Number_of_Anonymous_Contacts__c == null)
      errorMessage += 'Page 1 Q2: Number of anonymous contacts who received services is required. <br />';
    if (
      report.Number_of_New_Individuals__c == null &&
      report.Tracking_New_Individuals__c
    )
      errorMessage += 'Page 1 Q4: Number of new individuals who received services is required. <br />';

    // If tracking new individuals, each category should equal total tracked
    if (ableToTrack && report.Number_of_New_Individuals__c != null) {
      if (raceTracked) {
        if (
          report.American_Indian_Alaska_Native__c == null ||
          report.Asian__c == null ||
          report.Black_African_American__c == null ||
          report.Hispanic_or_Latino__c == null ||
          report.Native_Hawaiian_and_Other_Pacific_Island__c == null ||
          report.White_Non_Latino_Caucasian__c == null ||
          report.Some_Other_Race__c == null ||
          report.Multiple_Races__c == null ||
          report.Not_Reported__c == null
        ) {
          errorMessage += 'Page 1 Q5a: Please add a value for all races/ethnicities. <br />';
        } else {
          Decimal totalRaceTracked =
            report.American_Indian_Alaska_Native__c +
            report.Asian__c +
            report.Black_African_American__c +
            report.Hispanic_or_Latino__c +
            report.Native_Hawaiian_and_Other_Pacific_Island__c +
            report.White_Non_Latino_Caucasian__c +
            report.Some_Other_Race__c +
            report.Multiple_Races__c +
            report.Not_Reported__c;
          if (totalRaceTracked != report.Number_of_New_Individuals__c)
            errorMessage += 'Page 1 Q5a: Total tracked for Race/Ethnicity does not match Q4 (Number of New Individuals tracked). <br />';
        }
      }

      if (genderTracked) {
        if (
          report.Male__c == null ||
          report.Female__c == null ||
          report.Other_Gender__c == null ||
          report.Gender_Not_Reported__c == null
        ) {
          errorMessage += 'Page 1 Q5b: Please add a value for all gender identities. <br />';
        } else {
          Decimal totalGenderTracked =
            report.Male__c +
            report.Female__c +
            report.Other_Gender__c +
            report.Gender_Not_Reported__c;
          if (totalGenderTracked != report.Number_of_New_Individuals__c)
            errorMessage += 'Page 1 Q5b: Total tracked for Gender does not match Q4 (Number of New Individuals tracked). <br />';
        }
      }

      if (ageTracked) {
        if (
          report.Age_0_12__c == null ||
          report.Age_13_17__c == null ||
          report.Age_18_24__c == null ||
          report.Age_25_59__c == null ||
          report.Age_60_and_Older__c == null ||
          report.Age_Not_Reported__c == null
        ) {
          errorMessage += 'Page 1 Q5c: Please add a value for all age ranges. <br />';
        } else {
          Decimal totalAgeTracked =
            report.Age_0_12__c +
            report.Age_13_17__c +
            report.Age_18_24__c +
            report.Age_25_59__c +
            report.Age_60_and_Older__c +
            report.Age_Not_Reported__c;
          if (totalAgeTracked != report.Number_of_New_Individuals__c)
            errorMessage += 'Page 1 Q5c: Total tracked for Age does not match Q4 (Number of New Individuals tracked). <br />';
        }
      }
    }

    if (report.Victim_Compensation_Application__c == null)
      errorMessage += 'Page 3 Q7: Number of individuals assisted with a victim compensation application is required. <br />';

    // All questions for each section of Types of Services are required if the section is being tracked.
    if (infoProvided) {
      if (
        report.Number_Received_Referral_Services__c == null ||
        report.A1_Provide_Criminal_Justice_System_Info__c == null ||
        report.A2_Information_About_Victim_Rights__c == null ||
        report.A3_Referral_to_Other_Victim_Programs__c == null ||
        report.A4_Referral_to_Other_Services__c == null
      ) {
        errorMessage += 'Page 3 Q8a: Please add a value for all Information & Referral Services. <br />';
      }
    }

    if (advocacyProvided) {
      if (
        report.Number_Received_Advocacy_Services__c == null ||
        report.B1_Advocacy_to_Emergency_Medical_Care__c == null ||
        report.B2_Advocacy_to_Medical_Forensic_Exam__c == null ||
        report.B3_Law_Enforcement_Interview_Advocacy__c == null ||
        report.B4_Individual_Advocacy__c == null ||
        report.B5_Performance_of_Medical_Forensic_Exam__c == null ||
        report.B6_Immigration_Assistance__c == null ||
        report.B7_Intervention_with_Employer_or_Other__c == null ||
        report.B8_Child_or_Dependent_Care_Assistance__c == null ||
        report.B9_Transportation_Assistance__c == null ||
        report.B10_Interpreter_Services__c == null
      ) {
        errorMessage += 'Page 3 Q8b: Please add a value for all Personal Advocacy Services. <br />';
      }
    }

    if (supportProvided) {
      if (
        report.Number_Received_Support_Services__c == null ||
        report.C1_Crisis_Intervention__c == null ||
        report.C2_HotlineCrisis_Line_counseling__c == null ||
        report.C3_On_Scene_Crisis_Response__c == null ||
        report.C4_Individual_Counseling__c == null ||
        report.C5_Support_Groups__c == null ||
        report.C6_Other_Therapy__c == null ||
        report.C7_Emergency_Financial_Assistance__c == null
      ) {
        errorMessage += 'Page 3 Q8c: Please add a value for all Emotional Support Services. <br />';
      }
    }

    if (housingProvided) {
      if (
        report.Number_Received_Housing_Services__c == null ||
        report.D1_Emergency_Shelter_or_Safe_House__c == null ||
        report.D2_Transitional_Housing__c == null ||
        report.D3_Relocation_Assistance__c == null
      ) {
        errorMessage += 'Page 3 Q8d: Please add a value for all Shelter/Housing Services. <br />';
      }
    }

    if (justiceProvided) {
      if (
        report.Number_Received_Justice_System_Services__c == null ||
        report.E1_Notified_of_Criminal_Justice_Events__c == null ||
        report.E2_Victim_Impact_Statement_Assistance__c == null ||
        report.E3_Assistance_with_Restitution__c == null ||
        report.E4_Legal_Assist_with_Restraining_Order__c == null ||
        report.E5_Legal_Assist_with_Family_Law__c == null ||
        report.E6_Emergency_Justice_Related_Assist__c == null ||
        report.E7_Immigration_Assistance__c == null ||
        report.E8_Prosecution_Interview_Advocacy__c == null ||
        report.E9_Law_Enforcement_Interview__c == null ||
        report.E10_Criminal_Advocacy_or_Accompaniment__c == null ||
        report.E11_Other_Legal_Advice__c == null
      ) {
        errorMessage += 'Page 3 Q8e: Please add a value for all Justice System Services. <br />';
      }
    }

    // All text questions are required
    if (
      report.Ongoing_Successes__c == null ||
      report.Ongoing_Successes__c == ''
    )
      errorMessage += 'Page 4 Q9: Ongoing Successes is required.<br/>';
    if (
      !isFinalReport &&
      (report.Challenges_or_Barriers__c == null ||
      report.Challenges_or_Barriers__c == '')
    )
      errorMessage += 'Page 4 Q9b: Challenges or Barriers is required.<br/>';
    if (
      report.Training_and_Technical_Assistance__c == null ||
      report.Training_and_Technical_Assistance__c == ''
    )
      errorMessage += 'Page 4 Q10a: Training and Technical Assistance is required.<br/>';
    if (
      report.Preferred_Method_of_T_TA_Delivery__c == null ||
      report.Preferred_Method_of_T_TA_Delivery__c == ''
    )
      errorMessage += 'Page 4 Q10b: Preferred Method of T/TA Delivery is required.<br/>';
    if (
      !report.On_Track_Fiscally__c &&
      (report.Fiscally_on_Track__c == null ||
      report.Fiscally_on_Track__c == '')
    )
      errorMessage += 'Page 4 Q11: If not Fiscally On Track, please explain is required.<br/>';

    if (isFinalReport) {
      if (report.Number_of_Unmet_Requests__c == null)
        errorMessage += 'Page 4 Q14: Number of Unmet Requests is required.<br/>';
      if (
        report.Number_of_Unmet_Requests__c > 0 &&
        (report.Unmet_Requests_Explanation__c == null ||
        report.Unmet_Requests_Explanation__c == '')
      )
        errorMessage += 'Page 4: Please explain is required. <br/>';
      if (
        report.Services_Not_Provided__c == null ||
        report.Services_Not_Provided__c == ''
      )
        errorMessage += 'Page 4 Q15: Services Not Provided is required.<br/>';
      if (
        report.Clients_Surveyed_for_Feedback__c &&
        report.Number_of_Surveys_Distributed__c == null
      )
        errorMessage += 'Page 4 Q17: Number of Surveys Distributed is required.<br/>';
      if (
        report.Clients_Surveyed_for_Feedback__c &&
        report.Number_of_Surveys_Completed__c == null
      )
        errorMessage += 'Page 4 Q18: Number of Surveys Completed is required.<br/>';
      if (
        report.Challenges_During_Fiscal_Year__c == null ||
        report.Challenges_During_Fiscal_Year__c == ''
      )
        errorMessage += 'Page 4 Q19: Challenges During Fiscal Year is required.<br/>';
      if (
        report.Project_Description__c == null ||
        report.Project_Description__c == ''
      )
        errorMessage += 'Page 4 Q20: Project Description is required.<br/>';
      if (
        report.Changes_in_Community__c == null ||
        report.Changes_in_Community__c == ''
      )
        errorMessage += 'Page 4 Q21: Changes in Community is required.<br/>';
    }

    if (errorMessage != '')
      errorMessage =
        '<strong>The following errors must be corrected before submitting this program report. Use the "previous" button to navigate to the appropriate page. Please click “submit” again after reconciling all errors.</strong><br/><br/>' +
        errorMessage;
  }

  public void showValidationPopup() {
    displayValidationPopup = true;
  }

  public void hideValidationPopup() {
    displayValidationPopup = false;
  }

  public void hideValidationPopupAndContinue() {
    displayValidationPopup = false;
    if (pageTwoErrorMessage == '') {
      currentPage = currentPage + 1;
    }
  }

  public void showSendBackPopup() {
    displaySendBackPopup = true;
  }

  public void cancelSendBackPopup() {
    displaySendBackPopup = false;
  }

  public void pageOne() {
    currentPage = 1;
  }

  public void pageTwo() {
    currentPage = 2;
  }

  public void pageThree() {
    currentPage = 3;
  }

  public void pageFour() {
    currentPage = 4;
  }

  public void exportXLS() {
    report = vsrc.getReport(reportId);
  }
}
