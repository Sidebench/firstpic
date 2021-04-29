public class test {
  public test() {
    List<Grant__c> grants = [
      SELECT Id, Account__c, CEO_Email_text__c, updated_via_script__c
      FROM Grant__c
      WHERE
        National_Grant__c = 'a011h00000238Z2'
        AND Id = 'a011h00000238Z2'
        AND updated_via_script__c = FALSE
      LIMIT 100
    ];
    List<Document__c> items = new List<Document__c>();
    Integer count = 0;
    for (Grant__c i : grants) {
      Document__c d1 = new Document__c(
        Organization__c = i.Account__c,
        CEO_Email__c = i.CEO_Email_text__c,
        Name = 'Notice to Apply Email ',
        Status_Updated_by_Admin_Only__c = true,
        Access_Mode__c = 'National Access Only'
      );

      items.add(d1);

      count++;
      i.updated_via_script__c = true;
    }
    system.debug(count);
    system.debug(grants);
    system.debug(items);
    //update grants;
    //insert items;
  }
}
