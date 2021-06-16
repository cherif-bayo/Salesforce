public class FlexeraKeysExtension {
	public class WrapperContact {
		public Boolean IsAdded { get; set; }
		public Contact contact { get; set; }

		public WrapperContact() {
			IsAdded = false;
		}
	}

	private final String accountId;
	private final String contactId;
	private Boolean isRead;
	private Flexera_Key__c oldKey;
	private String oldSolution;

	public final Order order { get; set; }
	public final Campaign Campaign { get; set; }
	public final Version__c Version { get; set; }

	public Flexera_Key__c Key { get; set; }
	public Order TmpOrder { get; set; }
	public WrapperContact MainContact { get; set; }
	public Map<String, WrapperContact> WpContacts { get; set; }
	public String SelectedContactId { get; set; }
	public Boolean IsUpdate { get; set; }
	public Boolean HasOrder { get; set; }
	public Boolean HasCampaign { get; set; }
	public FlexeraController.ResultGetInformations ResultInformations { get; set; }
	public Integer NbKeys { get; set; }
	public Boolean IsCampusAndNetwork { get; set; }
	public Boolean GenerateExtensionCampus { get; set; }
	public Boolean GetIsFromAccount() { return HasOrder == false && HasCampaign == false; }
	public Boolean getRenderButtonRemoveContact() { return WpContacts.values().size() > 1; }
	public Boolean getRenderCheckboxesCampus() {
		return Key.Domaine_utilisateur__c == 'Campus' && Key.Type_licence__c != 'Classroom';
	}
	public Boolean getRenderCheckboxesCampus2() { return Key.Domaine_utilisateur__c == 'Campus'; }

	private void loadContacts() {
		WpContacts = new Map<String, WrapperContact> ();
		List<String> contactsIdsKeys = new List<String> ();
		for (Flexera_Key__c keyContact :[SELECT Contact__c FROM Flexera_Key__c WHERE Name = :Key.Name]) contactsIdsKeys.add(keyContact.Contact__c);
		for (Contact contact :[SELECT Id, FirstName, LastName, Name, Email, MailingCountryCode, (SELECT Id FROM Cles_Flexera__r WHERE Name = :Key.Name) FROM Contact WHERE AccountId = :accountId]) {
			WrapperContact wpContact = new WrapperContact();
			wpContact.contact = contact;
			wpContact.IsAdded = contact.Cles_Flexera__r.size() > 0;
			WpContacts.put(contact.Id, wpContact);
		}
		for (Contact contact :[SELECT Id, FirstName, LastName, Name, Email, MailingCountryCode, (SELECT Id FROM Cles_Flexera__r WHERE Name = :Key.Name) FROM Contact WHERE Id IN :contactsIdsKeys AND Id NOT IN :WpContacts.keySet()]) {
			WrapperContact wpContact = new WrapperContact();
			wpContact.contact = contact; wpContact.IsAdded = contact.Cles_Flexera__r.size() > 0;
			WpContacts.put(contact.Id, wpContact);
		}
		if (WpContacts.keySet().contains(contactId) == false && contactId != null) {
			Contact contact = [SELECT Id, FirstName, LastName, Name, Email, MailingCountryCode FROM Contact WHERE Id = :contactId];
			WrapperContact wpContact = new WrapperContact(); wpContact.contact = contact;
			wpContact.IsAdded = true; WpContacts.put(contact.Id, wpContact);
		}
	}

	public FlexeraKeysExtension(ApexPages.StandardController stdController) {
		String keyId = stdController.getId();

		HasOrder = false;
		HasCampaign = false;
		isRead = false;
		NbKeys = 1;
		IsUpdate = keyId != null;
		TmpOrder = new Order();
		IsCampusAndNetwork = false;
		GenerateExtensionCampus = false;

		String orderId;
		if (IsUpdate) {
			Key = [SELECT Date_relance__c, Relance_manuelle__c, Is_Inactive__c, Account__r.Name, Nb_activations_allowed__c, Is_Network__c, Has_Student_Ext__c, Name, Campaign__c, Order__c, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__c, Entitlement_Id__c FROM Flexera_Key__c WHERE Id = :keyId];
			orderId = Key.Order__c;
			Version__c[] versions = [SELECT Name FROM Version__c WHERE Id = :Key.Version__c];
			if (versions.size() > 0) Version = versions[0];
			contactId = Key.Contact__c;
			IsCampusAndNetwork = Key.Is_Network__c;
		} else {
			orderId = ApexPages.currentPage().getParameters().get('order_id');
		}

		if (orderId != null) {
			order = [SELECT Id, OrderNumber, AccountId, Contact_lie__c, Contact_lie__r.AccountId, Client_final__c, Client_final__r.AccountId, Account.Type, Domaine_utilisateur__c, Type_licence__c FROM Order WHERE Id = :orderId];

			if (order.Client_final__c != null) {
				accountId = order.Client_final__r.AccountId;
				if (!IsUpdate) contactId = order.Client_final__c;
			} else if (order.Contact_lie__c != null) {
				accountId = order.Contact_lie__r.AccountId;
				if (!IsUpdate) contactId = order.Contact_lie__c;
			} else {
				accountId = order.AccountId;
			}
			HasOrder = true;
			HasCampaign = false;
		} else {
			String campaignId;
			if (IsUpdate == false) {
				campaignId = ApexPages.currentPage().getParameters().get('campaign_id');
			} else {
				campaignId = Key.Campaign__c;
			}
			System.debug('[FlexeraKeyExtension] campaignId:' + campaignId);
			if (campaignId != null) {
				List<Campaign> campaigns = [SELECT Id, Name FROM Campaign WHERE Id = :campaignId];
				if (campaigns != null && campaigns.size() > 0) {
					Campaign = campaigns[0];
					HasOrder = false;
					HasCampaign = true;
				}
			}
		}
		if (!IsUpdate) {
			Key = new Flexera_Key__c();
			Key.Version__c = [SELECT Id FROM Version__c ORDER BY Date__c DESC] [0].Id;
			Key.Date_limite__c = Date.today().addYears(1);
			Key.Quantity__c = 1;

			if (HasOrder) {
				Key.Order__c = order.Id;
				Key.Type_client__c = order.Account.Type;
				loadContacts();
				if (contactId != null) MainContact = WpContacts.get(contactId);
				else MainContact = WpContacts.values() [0];
				MainContact.IsAdded = true;
			} else {
				String contactId = ApexPages.currentPage().getParameters().get('contact_id');
				if (contactId != null) Key.Contact__c = contactId;
				if (HasCampaign) Key.Campaign__c = Campaign.Id;
			}
		} else {
			if (HasOrder) {
				loadContacts();
				if (contactId != null) MainContact = WpContacts.get(contactId);
				else MainContact = WpContacts.values() [0];
				MainContact.IsAdded = true;
			} else {
				MainContact = new WrapperContact();
				WpContacts = new Map<String, WrapperContact> ();
				if (Key.Contact__c != null) {
					MainContact.contact = [SELECT Id, FirstName, LastName, Name, Email, MailingCountryCode FROM Contact WHERE Id = :Key.Contact__c];
					MainContact.IsAdded = true;
					WpContacts.put(MainContact.contact.Id, MainContact);
				}
			}
		}
		UpdateSolutions();
	}

	public void UpdateSolutions() {
		if (HasOrder) {
			if (IsUpdate) order.Id = Key.Order__c;

			OrderItem[] orderItemsSolutions = [SELECT Quantity, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name, PricebookEntry.Product2.Type_licence__c, PricebookEntry.Product2.Domaine_Utilisateur_Order__c FROM OrderItem WHERE OrderId = :order.Id AND PricebookEntry.Product2.Family = 'Solution' AND PricebookEntry.Product2.Type_licence__c != 'Support et maintenance ( 1 an )'];

			if (orderItemsSolutions.size() > 0) {
				OrderItem[] orderItemsOptions = [SELECT Quantity, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name FROM OrderItem WHERE OrderId = :order.Id AND PricebookEntry.Product2.Family = 'Module'];

				if (!IsUpdate) {
					for (OrderItem orderItemOption : orderItemsOptions) if (isProductCodeACampusExtension(orderItemOption.PricebookEntry.Product2.ProductCode)) GenerateExtensionCampus = true;

					if (orderItemsSolutions.size() != 1) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'La commande comporte plusieurs solutions. Vous devez donc choisir la solution liée à la clef à la main.'));
					}

					Key.Quantity__c = orderItemsSolutions[0].Quantity;
					Key.XLSTAT_Solution__c = orderItemsSolutions[0].PricebookEntry.Product2.Name;
					Key.Type_licence__c = orderItemsSolutions[0].PricebookEntry.Product2.Type_licence__c;
					if (Key.Type_licence__c != order.Type_licence__c) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention ! Le type de licence de la commande et du produit ajouté sont différents.'));
					Key.Expiration__c = Key.Type_licence__c == 'Perpétuelle' ? FlexeraController.EXPIRATION_PERMANENT : FlexeraController.EXPIRATION_EXPIRING;
					Key.Domaine_utilisateur__c = orderItemsSolutions[0].PricebookEntry.Product2.Domaine_Utilisateur_Order__c;
					if (Key.Domaine_utilisateur__c != order.Domaine_utilisateur__c) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention ! Le domaine utilisateur de la commande et du produit ajouté sont différents.'));
					}
					Key.XLSTAT_Options__c = '';
					Boolean allOptionsHaveSameQuantity = true;

					for (OrderItem orderItemOption : orderItemsOptions) {
						if (orderItemOption.Quantity != orderItemsSolutions[0].Quantity) {
							allOptionsHaveSameQuantity = false;
							break;
						}
					}
					if (!allOptionsHaveSameQuantity) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'La quantité des options liées à la commande est différente du nombre de solution. Vous devez donc ajouter les options liées à la clef à la main.'));
				}
			}
		} else {
			if (!IsUpdate) {
				Key.Quantity__c = 1;
				Key.Type_licence__c = 'Annuelle';
				Key.Expiration__c = FlexeraController.EXPIRATION_EXPIRING;
				Key.XLSTAT_Options__c = '';
				Key.XLSTAT_Solution__c = '';
			}
		}

		if (IsUpdate) {
			oldKey = Key.clone();
			oldSolution = Key.XLSTAT_Solution__c;
		}
	}

	public void GetFlexeraInformations() {
		ResultInformations = FlexeraController.GetInformations(Key.Entitlement_Id__c);
		System.debug('[flexerakeyExtenion] ResultInformations :' + ResultInformations);

		ApexPages.getMessages().clear();
		if (ResultInformations.Status == false) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ResultInformations.ErrorMessage));
			return;
		}

		if (Key.Is_Inactive__c != ResultInformations.IsInactive) {
			if (ResultInformations.IsInactive) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention ! La clef est marquée comme désactivée sur Cryptlex mais ne l\'est pas sur Salesforce.'));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention ! La clef est marquée comme désactivée sur Salesforce mais ne l\'est pas sur Cryptlex.'));
			}
		}
	}

	public void AddOrRemoveContact() {
		WrapperContact selectedWpContact = WpContacts.get(SelectedContactId);
		selectedWpContact.IsAdded = !selectedWpContact.IsAdded;

		List<WrapperContact> wpContactsAdded = new List<WrapperContact> ();
		for (WrapperContact wpContact : WpContacts.values()) {
			if (wpContact.IsAdded == true) wpContactsAdded.add(wpContact);
		}
		if (wpContactsAdded.size() == 1) MainContact = wpContactsAdded[0];
	}

	public PageReference Save() {
		try {
			if (Key.XLSTAT_Solution__c != null) {

				Boolean success = false;

				if (!HasOrder && Key.Contact__c != null) {
					MainContact = new WrapperContact();
					MainContact.contact = [SELECT Id, FirstName, LastName, Name, Email, MailingCountryCode FROM Contact WHERE Id = :Key.Contact__c];
					WpContacts = new Map<String, WrapperContact> ();
					WpContacts.put(MainContact.contact.Id, MainContact);
					MainContact.IsAdded = true;
				}

				if (Key.Type_licence__c == 'Réseau' || (getRenderCheckboxesCampus() && IsCampusAndNetwork)) Key.Is_Network__c = true;

				List<Flexera_Key__c> keysToInsert = new List<Flexera_Key__c> ();
				String keyId;
				if (IsUpdate) {
					Boolean resultUpdate = FlexeraController.UpdateKey(oldKey, Key);

					if (resultUpdate) {
						update Key;

						List<Flexera_Key__c> keysToDelete = new List<Flexera_Key__c> ();
						List<Flexera_Key__c> keysToUpdate = new List<Flexera_Key__c> ();

						Map<String, Flexera_Key__c> keysByContactId = new Map<String, Flexera_Key__c> ();
						for (Flexera_Key__c oldKey :[SELECT Id, Contact__c FROM Flexera_Key__c WHERE Contact__c IN :WpContacts.keySet() AND Name = :Key.Name]) {
							keysByContactId.put(oldKey.Contact__c, oldKey);
						}

						for (WrapperContact wpContact : WpContacts.values()) {
							if (wpContact.IsAdded == false) {
								if (keysByContactId.containsKey(wpContact.contact.Id)) {
									keysToDelete.add(keysByContactId.get(wpContact.contact.Id));
								}
							} else {
								if (keysByContactId.containsKey(wpContact.contact.Id) == false) {
									Flexera_Key__c newKey = Key.clone(false, true);
									newKey.Contact__c = wpContact.contact.Id;

									keysToInsert.add(newKey);
								} else {
									Flexera_Key__c oldKey = keysByContactId.get(wpContact.contact.Id);
									Flexera_Key__c newKey = Key.clone(false, true);
									newKey.Id = oldKey.Id;
									newKey.Contact__c = oldKey.Contact__c;
									oldKey = newKey;

									keysToUpdate.add(oldKey);
								}
							}
						}

						insert keysToInsert;
						delete keysToDelete;
						update keysToUpdate;

						success = true;

						if (keysToInsert.size() > 0) {
							keyId = keysToInsert[0].Id;
						} else {
							keyId = Key.Id;
						}
					} else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur est survenue pendant la mise à jour de la clef depuis Flexera.'));
					}
				} else {
					List<Flexera_Key__c> keysToGenerate = new List<Flexera_Key__c> { Key };
					if (GenerateExtensionCampus && getRenderCheckboxesCampus2()) { // Generation de clés en plus pour les étudiants d'une campus
						Flexera_Key__c keyExtension = Key.clone(false, true);
						keyExtension.Has_Student_Ext__c = true;
						keyExtension.Is_Network__c = false;
						keysToGenerate.add(keyExtension);
					}
					Boolean generationSuccess = true;
					for (Flexera_Key__c keyToGenerate : keysToGenerate) {
						Account account = null;
						if (order != null) {
							account = [SELECT Type FROM Account WHERE Id = :accountId];
						}
						System.debug('>>>> FlexeraKeysExtension - keyToGenerate = '+keyToGenerate);
						FlexeraController.ResultGenerateKey resultGenerateKey = FlexeraController.Generate(NbKeys, keyToGenerate, '', '', '', '', account);

						if (resultGenerateKey.Status) {
							for (Flexera_Key__c generatedKey : resultGenerateKey.GeneratedKeys) {
								for (WrapperContact wpContact : WpContacts.values()) {
									if (wpContact.IsAdded == true) {
										Flexera_Key__c keyToInsert = generatedKey.clone(false, true);
										keyToInsert.Contact__c = wpContact.contact.Id;
										keysToInsert.add(keyToInsert);
									}
								}
							}
						} else {
							generationSuccess = false;
							break;
						}
					}
					if (generationSuccess) {
						insert keysToInsert;
						keyId = keysToInsert[0].Id;
						success = true;
					} else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur est survenue pendant la génération de la clef depuis Flexera.'));
					}
				}

				if (success == true) {
					if (HasOrder && IsUpdate == false) {
						PageReference pageRef = Page.FlexeraSendKeyByEmail;
						pageRef.getParameters().put('keys_id', keyId);
						pageRef.getParameters().put('is_update', 'false');
						pageRef.setRedirect(true);

						return pageRef;
					} else {
						PageReference pageRef = new PageReference('/' + keyId);
						pageRef.setRedirect(true);

						return pageRef;
					}
				} else {
					return null;
				}
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vous devez sélectionner la solution associée à la clef.'));
				return null;
			}
		} catch(Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getLineNumber());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
			return null;
		}
	}

	public void UpdateKeyLimit() {
		if (FlexeraController.UpdateKeyLimit(Key.Entitlement_Id__c, Key.Name, Key.Expiration__c) == false) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur est survenue pendant la mise à jour de la date limite de la clef.'));
		} else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'La mise à jour de la date limite a bien été effectuée.'));
	}

	public void UpdateContacts() {
		Contact contact = [SELECT Id, FirstName, LastName, Name, Email, MailingCountryCode FROM Contact WHERE Id = :TmpOrder.Contact_lie__c];

		WrapperContact wpContact = new WrapperContact();
		wpContact.contact = contact;
		wpContact.IsAdded = true;
		WpContacts.put(contact.Id, wpContact);

		TmpOrder.Contact_lie__c = null;
	}

	public void UpdateActivationsAllowed() {
		if (!isRead) Key.Nb_activations_allowed__c = ActivationHelper.getNbActivationsAllowedFromQuantityBought(Key.Domaine_utilisateur__c,
		                                                                                                        Key.Type_licence__c,
		                                                                                                        Key.Quantity__c);
	}

	public PageReference Deactivate() {
		Boolean result = FlexeraController.DeactivateEntitlement(Key.Entitlement_Id__c);

		if (result == true) {
			Flexera_Key__c[] keys = [SELECT Id, Is_Inactive__c FROM Flexera_Key__c WHERE Name = :Key.Name];
			for (Flexera_Key__c k : keys) {
				k.Is_Inactive__c = true;
			}

			update keys;
		} else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur est survenue pendant la désactivation de la clef. Veuillez contacter votre super collaborateur Martin.'));

		PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
		pageRef.setRedirect(true);
		return pageRef;
	}

	public void GetFlexeraInformationsFromRead() {
		isRead = true;

		GetFlexeraInformations();
	}

	private Boolean isProductCodeACampusExtension(String productCode) {
		return productCode.startsWith('S_EXS');
	}
}