public without sharing class CreateMOUCtrl {
  public void createMOU(
    String signer1Email,
    String signer2Email,
    Id grantId,
    String docName
  ) {
    String docTitle = 'Letter of Agreement Contract';

    if (docName == 'OVC_LOA.pdf') {
      docTitle = 'NCAI Fund Victim Services Micro-grant Program Letter of Agreement';
    }

    Sertifi2_0__TestContract__c contract = new Sertifi2_0__TestContract__c(
      Name = docTitle,
      Sertifi2_0__Message__c = docTitle,
      Sertifi2_0__Sign_Type__c = 'Electronically',
      Grant__c = grantId,
      Sertifi2_0__CustomLinkID__c = grantId,
      Sertifi2_0__Open__c = 0,
      Sertifi2_0__Settings__c = 'Settings'
    );
    try {
      insert contract;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    Sertifi2_0__EDocument__c signDoc = new Sertifi2_0__EDocument__c(
      Sertifi2_0__TestContract__c = contract.id,
      Sertifi2_0__Name__c = docTitle,
      //Sertifi2_0__Sertifi_ID__c = 'qwerty',
      Sertifi2_0__Number_Signed__c = 0,
      Sertifi2_0__Document_Type__c = 'Signing Document'
    );
    try {
      insert signDoc;
    } catch (Exception e) {
      system.debug('>>> error = ' + e.getMessage());
    }

    if (docName == '' || docName == null) {
      String n = [SELECT LOA__c FROM Grant__c WHERE Id = :grantId].LOA__c;
      if (n != null)
        docName = n;
      else
        docName = 'UA_Letter_of_Agreement.pdf';
    }
    system.debug('docName = ' + docName);
    Document[] docs = [SELECT Name, Body FROM Document WHERE Name = :docName];
    if (docs.size() > 0) {
      Attachment attachmentPDF = new Attachment();
      attachmentPdf.parentId = signDoc.id;
      attachmentPdf.name = docName;
      attachmentPdf.body = docs[0].Body;
      insert attachmentPDF;
      try {
        upsert attachmentPDF;
      } catch (Exception e) {
        system.debug('>>> error = ' + e.getMessage());
      }
    }

    Contact[] c1 = [
      SELECT Id, Name, Email
      FROM Contact
      WHERE email = :signer1Email
    ];
    if (c1.size() > 0) {
      Sertifi2_0__ContractContactJunction__c signer1 = new Sertifi2_0__ContractContactJunction__c(
        Sertifi2_0__Contact__c = c1[0].id,
        Sertifi2_0__TestContract__c = contract.id,
        Sertifi2_0__Signer_Order__c = 1,
        Sertifi2_0__Level_Name__c = '1st Signer',
        Sertifi2_0__Email__c = signer1Email
      );
      try {
        insert signer1;
      } catch (Exception e) {
        system.debug('>>> error = ' + e.getMessage());
      }
    }

    if (signer2Email != null && signer2Email != '') {
      Contact[] c2 = [
        SELECT Id, Name, Email
        FROM Contact
        WHERE email = :signer2Email
      ];
      if (c2.size() > 0) {
        Sertifi2_0__ContractContactJunction__c signer2 = new Sertifi2_0__ContractContactJunction__c(
          Sertifi2_0__Contact__c = c2[0].id,
          Sertifi2_0__TestContract__c = contract.id,
          Sertifi2_0__Signer_Order__c = 2,
          Sertifi2_0__Level_Name__c = '2nd Signer',
          Sertifi2_0__Email__c = signer2Email
        );
        try {
          insert signer2;
        } catch (Exception e) {
          system.debug('>>> error = ' + e.getMessage());
        }
      }
    }

    sendToSertifi(contract.Id);
  }

  @Future(callout=true)
  public static void sendToSertifi(Id contractId) {
    Sertifi2_0__SertifiSettings__c settings = Sertifi2_0__SertifiSettings__c.getValues(
      'Settings'
    );
    string results = Sertifi2_0.SertifiSFAPI.sendEContractToSertifi(
      contractId,
      settings
    );
    System.debug(results);
  }
}
