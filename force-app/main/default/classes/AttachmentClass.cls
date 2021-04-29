public without sharing class AttachmentClass {
  public List<Attachment> getAttachments(Id parentId, Set<Id> ids) {
    String qry = 'SELECT Id, Name, ParentId, Description, CreatedDate FROM Attachment';
    if (parentId != null) {
      qry += ' WHERE ParentId = \'' + parentId + '\'';
    } else if (ids != null && ids.size() > 0) {
      String idIn = '(\'';
      for (Id i : ids) {
        if (i != null)
          idIn += i + '\',\'';
      }
      idIn = idIn.substring(0, idIn.length() - 2);
      idIn += ')';
      if (idIn != null)
        qry += ' WHERE ParentId IN ' + idIn;
    }
    qry += ' ORDER BY CreatedDate desc';
    system.debug('AttachmentClass getAttachments qry = ' + qry);
    List<Attachment> atts = database.query(qry);
    return atts;
  }

  public void insertAttachment(Attachment a) {
    try {
      insert a;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }

  public void deleteAttachment(Attachment a) {
    try {
      delete a;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }
}
