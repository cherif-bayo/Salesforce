public with sharing class OrderPaidStatusExtension
{
	private static String ORDER_STATUS_PAID = 'Payée';
	private static String PAIEMENT_TYPE_SHAREIT = 'ShareIt';
	private static String PROVENANCE_SHAREIT = 'ShareIt';
	private static String PAIEMENT_TYPE_STRIPE = 'Stripe';
	private static String PROVENANCE_STRIPE = 'Stripe';
	private static String DOMAINE_STUDENT = 'Student';

	public Order order { get; set; }
	public Paiement__c paiementInput { get; set; }
	public Boolean showMsg { get; set; }

	public OrderPaidStatusExtension(ApexPages.StandardController standardController) {
		order = [select Provenance__c, Status, Domaine_utilisateur__c from Order where Id = :standardController.getId() limit 1];

		if ([SELECT Id FROM Flexera_Key__C WHERE Order__c = :order.Id].size() == 0) {
			showMsg = true;
		} else {
			showMsg = false;
		}
	}

	private void updateOrder(Date datePaiement, String typePaiement) {
		List<Paiement__c> paiements = [select Date_de_paiement_effectif__c, Type_de_paiement__c from Paiement__c where Commande_Lie__c = :order.Id];
		Boolean hasPaiement = true;

		if (paiements.size() == 0) {
			hasPaiement = false;
			Paiement__c paiement = new Paiement__c();
			paiement.Commande_Lie__c = order.Id;
			paiement.Modalites_de_paiement__c = '+0j';
			paiements.add(paiement);
		}
		paiements[0].Date_de_paiement_effectif__c = datePaiement;
		paiements[0].Type_de_paiement__c = typePaiement;

		if (hasPaiement) {
			update paiements;
		} else {
			insert paiements;
		}

		order.Status = ORDER_STATUS_PAID;
        //  We decided to not run this method so that we can avoid checking Renouvelé field on orders for academics users 
		//setRenewal();
		update order;
        if (ParametersForOrders.US_COMPANY.equals(order.AddinSoftCompany__c)) {
            recordTrasancationInTaxamo();
            System.debug('[recordTrasancationInTaxamo] Enregistrement de la transaction dans taxamo :' + order.Id);
        }
	}

	private void sendEmailsKeys() {
		for (Flexera_Key__c key :[select Id, Contact__r.Email from Flexera_Key__C where Order__c = :order.Id]) {

			FlexeraSendKeyByEmailController controller = new FlexeraSendKeyByEmailController();
			controller.keyId = key.Id;
			controller.InstanciatePart1();
			controller.InstanciatePart2();
			controller.Preview();

			for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
                // Before wpContact.ContactsAccountEmails[0].getValue();
				wpContact.ContactEmail = key.Contact__r.Email;
			}
			controller.Send();
		}
	}

	private PageReference getRedirection() {
		this.sendEmailsKeys();

		PageReference pageRef = new PageREference('/' + order.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}

	public PageReference ChangeStatus() {
		if (order.Provenance__c == PROVENANCE_SHAREIT) {
			this.updateOrder(Date.today(), PAIEMENT_TYPE_SHAREIT);
			return this.getRedirection();
		} else if (order.Provenance__c == PROVENANCE_STRIPE) {
			this.updateOrder(Date.today(), PAIEMENT_TYPE_STRIPE);
			return this.getRedirection();
		} else {
			this.PaiementInput = new Paiement__c();
		}

		return null;
	}

	public PageReference ChangeStatusNotShareIt() {
		if (this.PaiementInput.Type_de_paiement__c == PAIEMENT_TYPE_SHAREIT) {
			order.Provenance__c = PROVENANCE_SHAREIT;
		} else if (this.PaiementInput.Type_de_paiement__c == PAIEMENT_TYPE_STRIPE) {
			order.Provenance__c = PROVENANCE_STRIPE;
		}

		this.updateOrder(this.PaiementInput.Date_de_paiement_effectif__c, this.PaiementInput.Type_de_paiement__c);
		return this.getRedirection();
	}
    
	
    /*
     We decided to not run this method so that we can avoid checking Renouvelé field on orders for academics users 
	private void setRenewal() {
		if (!DOMAINE_STUDENT.equalsIgnoreCase(this.order.Domaine_utilisateur__c)) {
			this.order.Renouvele__c = true;
		}
	}
	*/
    
	private void recordTrasancationInTaxamo() {
		System.enqueueJob(new OrderLineItemTaxes(order.Id, true)); //true => archived
	}
}