public without sharing class UserClassWithoutSharing {
  public User getUser(String soqlWHERE) {
    User u = new User();
    String soql = 'SELECT Id, Name, Profile.Name, Email, UserName, FirstName, LastName FROM User';
    if (soqlWHERE != null && soqlWHERE != '')
      soql += soqlWHERE;
    system.debug('UserClassWithoutSharing soql = ' + soql);
    User[] users = database.query(soql);
    if (users.size() > 0) {
      u = users[0];
    }
    return u;
    ///if(u.size() > 0) return u[0];
    ///return null;
  }

  public List<User> getUserList(String soqlWHERE) {
    String soql = 'SELECT Id, Name, FirstName, LastName, Email, Profile.Name, IsActive FROM User';
    if (soqlWHERE != null && soqlWHERE != '')
      soql += soqlWHERE;
    system.debug('UserClassWithoutSharing soql = ' + soql);
    List<User> users = database.query(soql);
    return users;
  }

  public void updateUser(User u) {
    try {
      update u;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
      ApexPages.addMessage(
        new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }
}
