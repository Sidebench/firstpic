public without sharing class AttachmentCtrl {
  public Id parentId { get; set; }
  public String fileName { get; set; }
  public Boolean filterByFileName = false;
  public List<Attachment> att_list { get; set; }
  public Id deleteAttId { get; set; }
  public Boolean displayAttPopup { get; set; }

  public void getAttList() {
    if (parentId != null) {
      String soql =
        'SELECT Id, Name, Description FROM Attachment WHERE ParentId = \'' +
        parentId +
        '\'';
      if (filterByFileName) {
        List<String> names = fileName.split(',');
        String newStr = '';
        for (String str : names) {
          newStr += '\'' + str.trim() + '\',';
          newStr = newStr.lastIndexOf(',') > 0
            ? newStr.substring(0, newStr.lastIndexOf(',')) + ','
            : newStr;
        }
        newStr = newStr.Substring(0, newStr.length() - 1);
        soql += ' AND Name IN (' + newStr + ')';
      }
      system.debug('AttachmentCtrl soql = ' + soql);
      att_list = database.query(soql);
    }
    //return att_list;
  }

  // BEGIN deleteAttById
  public void deleteAttById() {
    if (deleteAttId != null) {
      Attachment a = [SELECT Id FROM Attachment WHERE Id = :deleteAttId];
      if (a != null) {
        deleteAttachment(a);
      }
    }
    getAttList();
  }
  // END deleteAttById

  // BEGIN deleteAtt
  public void deleteAttachment(Attachment a) {
    try {
      delete a;
    } catch (Exception e) {
      system.debug('error = ' + e.getMessage());
    }
  }
  // END deleteAtt

  // BEGIN Popups
  public void showAttPopup() {
    displayAttPopup = true;
  }

  public void hideAttPopup() {
    displayAttPopup = false;
    getAttList();
  }
  // END Popups
}
