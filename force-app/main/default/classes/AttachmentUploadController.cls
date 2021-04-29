public without sharing class AttachmentUploadController {
  private DocumentClass dc = new DocumentClass();
  private getIdFromString gifs = new getIdFromString();

  public Attachment att {
    get {
      if (att == null)
        att = new Attachment();
      return att;
    }
    set;
  }

  public String filename { get; set; }
  public List<SelectOption> filenames { get; set; }
  public String contentType { get; set; }
  public String message { get; set; }
  public String errorMessage { get; set; }

  public AttachmentUploadController() {
    filenames = new List<SelectOption>();
    String param = ApexPages.currentPage().getParameters().get('filename');
    if (param != null) {
      List<String> names = param.split(',');
      if (names != null) {
        for (String n : names) {
          if (n != '') {
            filenames.add(new SelectOption(n.capitalize(), n.capitalize()));
          }
        }
      }
    }
  }

  public void ProcessAttachment() {
    system.debug('AttachmentUploadController att = ' + att);
    if (att.Body == null)
      message = 'Please choose a file for upload.';
    else {
      att.ownerId = UserInfo.getUserId();
      if (att.ParentId == null) {
        String urlParentId = ApexPages.currentPage()
          .getParameters()
          .get('parentId');
        att.ParentId = gifs.getId(urlParentId);
      }
      if (filename != null && filename != '') {
        att.Description = att.Name;
        att.Name = filename;
      }

      if (contentType != null && contentType.contains('pdf')) {
        att.ContentType = 'application/pdf';
        try {
          insert att;
          message = 'Attachment uploaded successfully. Click "Choose File" to upload another attachment, or "Close" if you are finished.';

          if (
            att.ParentId.getSObjectType().getDescribe().getName() ==
            'Document__c'
          ) {
            Document__c d = [
              SELECT Status__c
              FROM Document__c
              WHERE Id = :att.ParentId
            ];
            d.Status__c = 'Submitted';
            dc.upsertDoc(d);
          }
        } catch (Exception e) {
          message = 'Error uploading attachment.';
          system.debug(e);
        } finally {
          att = null;
          filename = null;
          contentType = null;
        }
      } else {
        errorMessage = 'Please upload PDF\'s ONLY.';
      }
    }
  }
}
