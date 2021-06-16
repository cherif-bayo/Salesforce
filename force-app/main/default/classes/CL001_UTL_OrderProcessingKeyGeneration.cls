public  without sharing class CL001_UTL_OrderProcessingKeyGeneration {

	public static List<FlexeraController.ResultGenerateKey> generateKey(Order order, Account account, Contact contactLie, Boolean isAnnual) {
		List<FlexeraController.ResultGenerateKey> resultsFlexeraGeneratedKey = new List<FlexeraController.ResultGenerateKey> (); //retour de la methode
		List<OrderItem> orderItems = [SELECT Quantity, Product2.Name, Product2.Family FROM OrderItem WHERE OrderId = :order.Id];
		
		// Recuperation de la liste des options
		Map<String, Integer> optionsQuantitiesByOptionsFullNames = new Map<String, Integer> ();
		for (OrderItem orderItem : orderItems) {
			if (orderItem.Product2.Family == ParametersForOrders.PRODUCT_FAMILY_OPTION) {
				optionsQuantitiesByOptionsFullNames.put(orderItem.Product2.Name, Integer.valueOf(orderItem.Quantity));
			}
		}

		// Creation des nouvelles cles pour les solutions (pas pour les options)
		for (OrderItem orderItem : orderItems) {
			if (orderItem.Product2.Family == ParametersForOrders.PRODUCT_FAMILY_SOLUTION) {
				Flexera_Key__c flexeraKey = new Flexera_Key__c();
				System.debug('>>>> orderItem.Product2.Name = '+orderItem.Product2.Name);
				flexeraKey.SoftwareCode__c = new SoftwareService().getSoftwareCodeFromName(orderItem.Product2.Name);
				flexeraKey.Software__c = new SoftwareService().getSoftwareNameFromCode(flexeraKey.SoftwareCode__c);
				System.debug('>>>> flexeraKey.SoftwareCode__c = '+flexeraKey.SoftwareCode__c);
				flexeraKey.Quantity__c = orderItem.Quantity;
				flexeraKey.Domaine_utilisateur__c = order.Domaine_utilisateur__c;
				flexeraKey.Type_licence__c = order.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_3 ? ParametersForOrders.SEND_KEY_LICENSE_TYPE_2 : order.Type_licence__c;

				flexeraKey.Nb_activations_allowed__c = ActivationHelper.getNbActivationsAllowedFromQuantityBought(
						flexeraKey.Domaine_utilisateur__c,
						flexeraKey.Type_licence__c,
						flexeraKey.Quantity__c);

				if (isAnnual || '0'.equals(Parameters.getString('Cle_Temporaire_Etudiant'))) {
					flexeraKey.Date_limite__c = Date.today().addYears(1);
				} // Si on ne veut pas de cle 3J pour les etudiants
				else {
					flexeraKey.Date_limite__c = Date.today().addDays(ParametersForOrders.NB_OF_DAYS_FREE_FOR_STUDENT);
				}
				flexeraKey.Expiration__c = flexeraKey.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_2 ? FlexeraController.EXPIRATION_PERMANENT : FlexeraController.EXPIRATION_EXPIRING;
				flexeraKey.Type_client__c = order.Account.Type;
				flexeraKey.Order__c = order.Id;
				if (account.IsPersonAccount) {
					flexeraKey.Contact__c = account.PersonContactId;
				} else {
					flexeraKey.Contact__c = contactLie.Id;			
				}
				flexeraKey.XLSTAT_Solution__c = orderItem.Product2.Name;
                
				flexeraKey.XLSTAT_Options__c = '';
				if (!new SoftwareService().isOptionsAvailableForProduct(orderItem.Product2.Name)) {
					// Ajout des options sur la licence flexera
					for (String optionName : optionsQuantitiesByOptionsFullNames.keySet()) {
						flexeraKey.XLSTAT_Options__c += optionName + ';';
					}
				}
				flexeraKey.Is_Network__c = flexeraKey.Type_licence__c == 'Réseau';

				// Generation des cles dans le SI Flexera
				if (account.IsPersonAccount) {
					Contact contact = [SELECT Id, FirstName FROM Contact WHERE Id = :account.PersonContactId];
					resultsFlexeraGeneratedKey.add(FlexeraController.Generate(1, flexeraKey, account.FirstName, account.LastName, account.PersonEmail, account.PersonMailingCountryCode, account, false, null, contact));
				} else {
					resultsFlexeraGeneratedKey.add(FlexeraController.Generate(1, flexeraKey, contactLie.FirstName, contactLie.LastName, contactLie.Email, contactLie.MailingCountryCode, account, false, null, contactLie));
				}
			}
            
		}

		// Enregistrement dans SF des cles flexera qui ont bien été généré dans le SI flexera (on laisse tombé pour les autres :-())
		List<Flexera_Key__c> flexeraKeysToInsert = new List<Flexera_Key__c> ();
		for (FlexeraController.ResultGenerateKey resultFlexeraGeneratedKey : resultsFlexeraGeneratedKey) {
			if (resultFlexeraGeneratedKey.Status == true) {
				Flexera_Key__c[] resultKeys = resultFlexeraGeneratedKey.GeneratedKeys;
				for (Flexera_Key__c generatedKey : resultKeys) {
					flexeraKeysToInsert.add(generatedKey);
				}
			}
		}
		insert flexeraKeysToInsert;

		// Clone le Sobject Cle flexera d'un revendeur pour attacher le clone au client final
		if (order.Client_final__c != null) {
			List<Flexera_Key__c> flexeraKeysDelivering = new List<Flexera_Key__c> ();
			for (Flexera_Key__c key : flexeraKeysToInsert) {
				Flexera_Key__c keyCloned = key.clone(false, true);
				keyCloned.Contact__c = order.Client_final__c;

				flexeraKeysDelivering.add(keyCloned);
			}
			insert flexeraKeysDelivering;
		}

		return resultsFlexeraGeneratedKey;
	}
}