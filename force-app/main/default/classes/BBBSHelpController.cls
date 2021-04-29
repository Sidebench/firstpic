public class BBBSHelpController {
  public UserClass userClass = new UserClass();
  public User currentUser { get; set; }
  public Account userAcct { get; set; }
  public String approverLevel { get; set; }

  public BBBSHelpController() {
    currentUser = userClass.currentUser;
    userAcct = userClass.userAcct;
    approverLevel = userClass.approverLevel;
  }
}
