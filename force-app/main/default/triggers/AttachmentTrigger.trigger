trigger AttachmentTrigger on Attachment(after insert, after delete) {
  UserClass userClass = new UserClass();
  DocumentClass dc = new DocumentClass();
  Map<Id, Id> parent_contact_ids = new Map<Id, Id>();
  Map<Id, String> modHist = new Map<Id, String>();
  Date dt = date.today();
  String fdt = dt.format();

  if (Trigger.isDelete) {
    for (Attachment a : Trigger.old) {
      parent_contact_ids.put(a.ParentId, null);
      String m =
        fdt +
        ': Attachment (' +
        a.Name +
        ') Deleted by ' +
        userClass.currentUser.Contact.Name +
        ' (' +
        userClass.currentUser.Id +
        ')';
      modHist.put(a.ParentId, m);
    }
  } else {
    for (Attachment a : Trigger.new) {
      parent_contact_ids.put(a.ParentId, a.CreatedById);
      String m =
        fdt +
        ': Attachment (' +
        a.Name +
        ') Uploaded by ' +
        userClass.currentUser.Contact.Name +
        ' (' +
        userClass.currentUser.Id +
        ')';
      modHist.put(a.ParentId, m);
    }
  }
  dc.getHasAtts(parent_contact_ids, modHist);
}
