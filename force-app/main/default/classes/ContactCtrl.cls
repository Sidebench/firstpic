public without sharing class ContactCtrl {
  public void upsertContact(Contact cont) {
    try {
      upsert cont;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }
}
