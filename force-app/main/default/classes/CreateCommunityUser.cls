public without sharing class CreateCommunityUser {
  //    @future
  public void createUser(
    Id contactId,
    String email,
    String userName,
    String firstName,
    String lastName,
    Id profileId
  ) {
    User u = new User(
      Alias = (lastName + firstName).abbreviate(8),
      CommunityNickname = (lastName + firstName + contactId).abbreviate(30),
      Email = email,
      EmailEncodingKey = 'UTF-8',
      FirstName = firstName,
      LastName = lastName,
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      ProfileId = profileId,
      UserName = userName,
      ContactId = contactId
    );

    system.debug('u = ' + u);
    try {
      insert u;
      system.debug('u.Id = ' + u.Id);
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }
}
