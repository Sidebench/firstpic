public class BBBSErrorController {
  public String subject { get; set; }
  public String body { get; set; }
  public Boolean emailSent { get; set; }

  public BBBSErrorController() {
    emailSent = false;
  }

  public PageReference send() {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    String[] toAddresses = new List<String>{ 'melaina@s4g.us' };

    // Sets the paramaters of the email
    email.setSubject(subject);
    email.setToAddresses(toAddresses);
    email.setPlainTextBody(body);

    // Sends the email
    Messaging.SendEmailResult[] r = Messaging.sendEmail(
      new List<Messaging.SingleEmailMessage>{ email }
    );

    emailSent = true;
    return null;
  }
}
