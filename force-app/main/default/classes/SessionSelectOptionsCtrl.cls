public with sharing class SessionSelectOptionsCtrl {
  public UserClass userClass = new UserClass();
  public String userAcctType = userClass.userAcctType;
  public List<SelectOption> options { get; set; }
  public String sessionId { get; set; }

  public SessionSelectOptionsCtrl() {
    options = new List<SelectOption>();
    //Date dt = date.today();
    String soql = 'SELECT Id, Name, Season__r.Name FROM Session__c';

    if (userAcctType != null && userAcctType.contains('National')) {
      options.add(new SelectOption('', 'Select a Season'));
      soql += ' WHERE RecordType.Name = \'Season\'';
      soql += ' ORDER BY LastModifiedDate desc';
      for (Session__c s : database.query(soql)) {
        options.add(new SelectOption(s.Id, s.Name));
      }
    } else {
      options.add(new SelectOption('', 'Select a Session'));
      soql += ' WHERE RecordType.Name = \'Session\'';
      soql += ' AND Site__r.Id = \'' + userClass.userAcct.Id + '\'';
      soql += ' ORDER BY LastModifiedDate desc';
      for (Session__c s : database.query(soql)) {
        options.add(new SelectOption(s.Id, s.Season__r.Name + ': ' + s.Name));
      }

      //soql += ' AND Season__r.Season_Start_Date__c <= ' + string.valueOf(dt);
      //soql += ' AND Season__r.Season_End_Date__c >= ' + string.valueOf(dt);
    }

    system.debug('SessionSelectOptionsCtrl options = ' + options);
    if (options.size() > 1) {
      String i = options[1].getValue();
      SessionId = Id.valueOf(i);
    }
  }
}
