public without sharing class GetIdFromString {
  public Id getId(String stringId) {
    Id validId;
    if (stringId != '' && stringId != null) {
      if (
        Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
          .matcher(stringId)
          .matches()
      ) {
        validId = Id.valueOf(stringId);
      }
    }
    system.debug('GetIdFromString result = ' + validId);
    return validId;
  }
}
