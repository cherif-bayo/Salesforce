global class OrderUnpaidEmailBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {
  global OrderUnpaidEmailBatchable() {
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query;
        List<String> NoRelanceDistrib = System.Label.NoRelanceDistrib.split(';');
    if (Test.isRunningTest()) {
      query = 'SELECT Retard_de_paiement__c, Commande_Lie__c, Date_de_paiement_estime__c FROM Paiement__c WHERE Retard_de_paiement__c <= 0 AND Commande_Lie__r.Account.Name NOT IN :NoRelanceDistrib AND Commande_Lie__r.Facturation_NoRelance__c = false AND Commande_Lie__r.Account.Type != \'Distributeur\' AND Commande_Lie__r.En_cours_de_paiement__c = false and Commande_Lie__r.Provenance__c=\'Bon de commande\' AND Commande_Lie__r.Status != \'Annulée\' ';
    } else {
      query = 'SELECT Retard_de_paiement__c, Commande_Lie__c, Date_de_paiement_estime__c FROM Paiement__c WHERE Retard_de_paiement__c < 0 AND Commande_Lie__r.Account.Name NOT IN :NoRelanceDistrib AND Commande_Lie__r.Facturation_NoRelance__c = false AND Commande_Lie__r.Account.Type != \'Distributeur\' AND Commande_Lie__r.En_cours_de_paiement__c = false and Commande_Lie__r.Provenance__c=\'Bon de commande\' AND Commande_Lie__r.Status != \'Annulée\' ';
    }
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Paiement__c> paiements) {
    Map<Decimal, Relance__c> relancesByNbDays = new Map<Decimal, Relance__c> ();
    List<Decimal> relancesNbDaysSorted = new List<Decimal> ();

    for (Relance__c relance :[SELECT Name, Nb_Days__c, Template_Email__c, Order_Status__c FROM Relance__c]) {
      relancesByNbDays.put(relance.Nb_Days__c, relance);
      relancesNbDaysSorted.add(relance.Nb_Days__c);
    }

    relancesNbDaysSorted.sort();

    List<Id> ordersIds = new List<Id> ();
    for (Paiement__c paiement : paiements) {
      ordersIds.add(paiement.Commande_Lie__c);
    }
    Map<Id, Order> ordersByIds = new Map<Id, Order> ([SELECT Id, Account.PersonContactId, Contact_Lie__c, Account.Type, Contact_Email__c, Contact_li_langue__c, Facturation_Statut__c, Facturation_Date_1ere_relance__c, Facturation_Date_2eme_relance__c, Facturation_Date_3eme_relance__c, Facturation_MailContact__c FROM Order WHERE Id in :ordersIds]);

    Map<Id, Facture__c> facturesByOrderId = new Map<Id, Facture__c> ();
    for (Facture__c facture :[SELECT Id, Commande_lie__c, TotalAmountAfterTVAWithCurrency__c, Date__c, Name, AddinSoftCompany2__c, US_Invoice_Code__c, FR_Invoice_Code__c FROM Facture__c WHERE Commande_lie__c IN :ordersIds ORDER BY CreatedDate DESC]) {
      if (facturesByOrderId.containsKey(facture.Commande_lie__c) == false) {
        facturesByOrderId.put(facture.Commande_lie__c, facture);
      }
    }

    for (Paiement__c paiement : paiements) {
      Decimal retardPaiement = Math.abs(paiement.Retard_de_paiement__c);

      Relance__c relanceToApply = null;
      Integer indexRelance = 1;
      for (Decimal relanceNbDay : relancesNbDaysSorted) {
        if (retardPaiement >= relanceNbDay && retardPaiement<relanceNbDay + 1) {
          relanceToApply = relancesByNbDays.get(relanceNbDay);
          break;
        } else {
          indexRelance++;
        }
      }

      if (relanceToApply != null && facturesByOrderId.containsKey(paiement.Commande_Lie__c)) {

        Order orderPaiement = ordersByIds.get(paiement.Commande_Lie__c);

        if (relanceToApply.Order_Status__c != orderPaiement.Facturation_Statut__c) {
          Boolean isFR = orderPaiement.Contact_li_langue__c == 'FR';
          String templateName = relanceToApply.Template_Email__c;

          Map<String, String> mapSubjectParams = new Map<String, String> {
          };

          Facture__c facturePaiement = facturesByOrderId.get(orderPaiement.Id);
          Converter.Locale localeDate;
          if (isFR) {
            localeDate = Converter.Locale.FR;
          } else {
            localeDate = Converter.Locale.US;
          }
          String dateFacture = Converter.DateToLocaleDate(facturePaiement.Date__c, localeDate);
          String datePaiementEstimated = Converter.DateToLocaleDate(paiement.Date_de_paiement_estime__c, localeDate);

          String subject;
          Boolean isAddinsoftInc = facturePaiement.AddinSoftCompany2__c == 'Addinsoft Inc.';
          if (isFR) {
            templateName += ' FR';
            if (isAddinsoftInc) {
                subject = 'XLSTAT – Facture impayée ' + 'n°' + facturePaiement.US_Invoice_Code__c;
            } else {
                subject = 'XLSTAT – Facture impayée ' + 'n°' + facturePaiement.FR_Invoice_Code__c;                            
            }
        } else {
            templateName += ' US';
            if (isAddinsoftInc) {
                subject = 'XLSTAT – Unpaid invoice ' + '#' + facturePaiement.US_Invoice_Code__c;
            } else {
                subject = 'XLSTAT – Unpaid invoice ' + '#' + facturePaiement.FR_Invoice_Code__c;                            
            }
        }

          Map<String, String> mapBodyParams = new Map<String, String> {
            '{!FactureDate}' => dateFacture,
            '{!FactureAmount}' => facturePaiement.TotalAmountAfterTVAWithCurrency__c,
            '{!FactureUs}' => facturePaiement.US_Invoice_Code__c,
            '{!FactureFr}' => facturePaiement.FR_Invoice_Code__c,
            '{!FactureId}' => facturePaiement.Name,
            '{!FactureDateEnd}' => datePaiementEstimated
          };

          Attachment[] att = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Parentid = :facturePaiement.Id ORDER BY CreatedDate DESC LIMIT 1];

          List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment> ();
          if (att.size() > 0) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(att[0].Name);
            efa.setBody(att[0].Body);
            efa.setContentType(att[0].ContentType);
            emailAttachments.add(efa);
          }

          // Find the right email address for the payment reminder email (reseller shoudn't receive twice this email)
          String toEmailadress;
          if (orderPaiement.Account.Type != 'Revendeur' &&
              orderPaiement.Facturation_MailContact__c != null
              && orderPaiement.Facturation_MailContact__c.length() > 4) { // at less a@b.c
            toEmailadress = orderPaiement.Facturation_MailContact__c;
          } else {
            toEmailadress = orderPaiement.Contact_Email__c;
          }

          List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper> ();
          EmailMessageWrapper emw = new EmailMessageWrapper('accounting@xlstat.com', toEmailadress, null, null, subject, mapSubjectParams, null, mapBodyParams);
          emw.EmailAttachments = emailAttachments;
          listEmailMessageWrapper.add(emw);

          if (orderPaiement.Account.Type == 'Revendeur' && orderPaiement.Facturation_MailContact__c != null) {
            EmailMessageWrapper emw2 = new EmailMessageWrapper('accounting@xlstat.com', orderPaiement.Facturation_MailContact__c, null, null, subject, mapSubjectParams, null, mapBodyParams);
            emw2.EmailAttachments = emailAttachments;
            listEmailMessageWrapper.add(emw2);
          }

          UtilityClassV2 utilityClass = new UtilityClassV2(listEmailMessageWrapper, templateName, orderPaiement.Id);
          List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
          List<Email__c> emailsToInsert = new List<Email__c> ();
          Boolean successSendEmail = true;
          for (Integer i = 0; i<results.size(); i++) {
            Messaging.SendEmailResult result = results[i];
            if (result.isSuccess() == false) {
              successSendEmail = false;
              break;
            }
          }

          if (successSendEmail == true) {
            orderPaiement.Facturation_Statut__c = relanceToApply.Order_Status__c;
            if (indexRelance == 1) {
              orderPaiement.Facturation_Date_1ere_relance__c = DateTime.now();
            } else if (indexRelance == 2) {
              orderPaiement.Facturation_Date_2eme_relance__c = DateTime.now();
            } else if (indexRelance == 3) {
              orderPaiement.Facturation_Date_3eme_relance__c = DateTime.now();
            }

            update orderPaiement;

            for (EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
              Email__c e = new Email__c();
              e.Address__c = emailMessageWrapper.ToAddress;
              e.Contact__c = orderPaiement.Contact_Lie__c == null ? orderPaiement.Account.PersonContactId : orderPaiement.Contact_Lie__c;
              e.Order__c = orderPaiement.Id;
              e.Type__c = relanceToApply.Name;
              e.Subject__c = subject;
              e.Attachment_Id__c = att.size()> 0 ? att[0].Id : null;
              emailsToInsert.add(e);
            }
            insert emailsToInsert;
          } else {
            throw new CustomException('Problem sending email for order: ' + orderPaiement.Id);
          }
        }
      }
    }
  }

  global void finish(Database.BatchableContext BC) { }

  private class CustomException extends Exception { }
}