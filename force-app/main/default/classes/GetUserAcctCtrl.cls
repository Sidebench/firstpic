public class GetUserAcctCtrl {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String portalName { get; set; }

  public GetUserAcctCtrl() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    portalName = userClass.userProfile;
  }
}
