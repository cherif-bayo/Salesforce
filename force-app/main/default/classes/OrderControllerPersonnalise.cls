public class OrderControllerPersonnalise{

//Déclaration des variables

	private Pricebook2 pricebook;
	
	//Instance Commande
	public Order MyOrder{get; set;}
	
	public Decimal DiscountCoupon{get; set;}
	
	//Instance Account
	public Account PersonAccount{get;set;}
	
	public Account ExistantAccount{get;set;}
	
	public Account ProAccount{get;set;}
	
	public Account ExistantProAccount{get;set;}
	
	//Instance Contact
	public Contact ExistantContact{get; set;}
	
	public Contact NewContact{get; set;}
	
	public Account ClientFinalAccount{get;set;}
	
	public Contact ClientFinalContact{get;set;}
	
	public Boolean RenderClientFinalFields{get;set;}
	
	
	public Product2 NewProduct{get;set;}
	
	public List<WrapProductOrderItem> ProductsOrderItems {get; set;}
	
	 public Integer removepos{get;set;}
	 
	public Boolean Ceciestuntest{get;set;}
	public Boolean Ceciestuntest2{get;set;}
	public Boolean Ceciestuntest3{get;set;}
	public Boolean Ceciestuntest4{get;set;}
	public Boolean IsOldProductSelected{get;set;}
	
	
	public String Reference{get; set;}
	
	public String SelectedDomaine{get;set;}
	
	public String SelectedDomain{get; set;}
	public String SelectedProvenance{get; set;}
	public String SelectedDevice{get; set;}
	public String SelectedStatutClient{get; set;}
	public String SelectedStatutContact{get; set;}
	public String SelectedStatutClientFinal{get; set;}

	public String SelectedSalutationPerso{get;set;}
	public String SelectedSalutationPro{get;set;}
	public String SelectedStatePro{get;set;}
	public String SelectedStatePerso{get;set;}
	public String SelectedStateProShipping{get;set;}
	public String SelectedStatePersoShipping{get;set;}
	
	
	
	public String SelectedStatutCompteClientFinal{get; set;}
	public String SelectedSalutationClientFinalPerso{get;set;}
	public String SelectedSalutationClientFinalPro{get;set;}
	public String SelectedStateClientFinalPerso{get;set;}
	public String SelectedStateClientFinalPro{get;set;}
	
	public String SelectedLicence{get; set;}
	public String LicenceSelected {get;set{
		this.LicenceSelected = value;
		if(value != null && value != ''){
			this.SelectedLicence = LicenceSelected;
			this.RenderLicenceSelection = false;
			this.NoRenderListProducts = true;
			this.NoRenderListProductsParam = true;
			
			this.Refresh();
		}
	}}
	public Map<ID, Product2> CodeProducts{get; set;}
	public Map<String, String> TableProducts{get; set;}
	public String SelectedSolution{get; set;}
	
	public List<wrapProduct> wrapProductList {get;set;}
	public List<Product2> prodToDel {get;set;}
	public List<Integer> rowNumberList {get;set;}
	
	   
	public Set<String> sIdProduct {get;set;}
	public Map<ID, String> TestIdProduct {get;set;}
	
	
	public Boolean SelectedOptRevendeur{get; set;}
	public Boolean SelectedRow{get; set;}
	
	public ID rowId {get; set;}
	public Integer rowNumber{get;set;}
	public Integer increm {get;set;}
	
	public Integer Quantite{get;set;}
	
	public String ReferencePayment{get; set;}
	
	public Boolean RenderAll{get;set;}
	public Boolean RenderLicence{get;set;}
	public Boolean RenderReferenceFieldBDC{get; set;}
	public Boolean RenderReferenceFieldShareIt{get; set;}
	public Boolean RenderReferenceFieldFormation{get; set;}
	public Boolean RenderClientFields{get; set;}
	public Boolean RenderClientSearch{get; set;}
	public Boolean RenderContactFields{get; set;}
	public Boolean RenderContactSearch{get; set;}
	public Boolean RenderClientFinalSearch{get;set;}
	public Boolean RenderCompteClientFinalFields{get;set;}
	public Boolean RenderComptePersoClientFinalFields{get;set;}
	public Boolean RenderProvenance {get; set;}
	public Boolean RenderClient {get; set;}
	public Boolean RenderClientFinal {get; set;}
	public Boolean RenderDiscountAndProducts {get; set;}
	public Boolean RenderLicenceSelection{get; set;}
	public Boolean NoRenderListProducts {get; set;}
	public Boolean NoRenderListProductsParam {get; set;}    
	public Boolean RenderLangue {get; set;}
	
	public String Tentative{get; set;}
	public String RechercheContactActive{get;set;}
	public String RecherchCouponActive{get;set;}
	
	public Decimal CompteurTotal{get;set;}
	
	
	public String CurrencyIsoCode{get; set{
		this.CurrencyIsoCode = value;
		if(value != null && value != ''){
			this.MyOrder.CurrencyIsoCode = value;
			this.UpdatePricebook();
		}
	}}
	
	private static Map<String, String> productDomainToOrderDomain = new Map<String, String>{'Entreprise/Privé' => 'Company', 'Education' => 'Academic', 'Etudiant' => 'Student', 'N.A.' => 'N.A.'};
	private static Map<String, String> orderDomainToProductDomain = new Map<String, String>{'Company' => 'Entreprise/Privé',  'Academic' => 'Education',  'Student' => 'Etudiant', 'N.A.' => 'N.A.'}; 
	
	public OrderControllerPersonnalise(ApexPages.StandardController stdController){
		this.init();    
	}   

//Constructeur de la classe    
	public OrderControllerPersonnalise(){
		this.init();
	} 
	
	private void init(){
		this.MyOrder= new Order();
		this.NewProduct = new Product2();
		this.RenderAll= true;
		this.CodeProducts= new Map<ID, Product2>();
		this.TableProducts= new Map<String, String>();
		this.Quantite=1;
		this.wrapProductList = new List<wrapProduct>();
		this.sIdProduct = new Set<String>();
		this.prodToDel = new List<Product2>();
		this.rowNumberList = new List<Integer>();
		this.TestIdProduct = new Map<Id, String>();
		this.RenderLicenceSelection = true;
		this.RenderLangue = true;
		
		this.ProductsOrderItems = new List<WrapProductOrderItem>();
		
		this.MyOrder.CurrencyIsoCode = 'USD';
		
		String campaignID = ApexPages.currentPage().getParameters().get('Campaign');
		if(campaignID != null){
			this.MyOrder.Formations__c = campaignID;
			this.MyOrder.Provenance__c = 'Formation';
			this.RenderReferenceFieldFormation = true;
		}

		String contactId = ApexPages.currentPage().getParameters().get('contact_id');
		if(contactId != null){
			Contact contact = [SELECT Domaine_Utilisateur__c FROM Contact WHERE Id = :contactId];
		
			String selectedOrderDomain = orderDomainToProductDomain.containsKey(contact.Domaine_Utilisateur__c) ? orderDomainToProductDomain.get(contact.Domaine_Utilisateur__c) : contact.Domaine_Utilisateur__c;
			this.SelectedDomaine = selectedOrderDomain;
			this.RenderLangue = false;        
			this.RenderClient = true;
			this.RenderProvenance = true;
			this.MyOrder.Contact_Lie__c = contactId;
			this.SelectedStatutClient = 'Existant';
			this.AppearClientFields();
			this.RefreshLicences();
			
			Order[] lastOrderClient = [SELECT CurrencyIsoCode FROM Order WHERE Contact_Lie__c = :contactId OR Client_Final__c = :contactId ORDER BY CreatedDate DESC LIMIT 1];
			if(lastOrderClient.size() > 0){
				this.MyOrder.CurrencyIsoCode = lastOrderClient[0].CurrencyIsoCode;
			}
		}
		
		this.UpdatePricebook();
	}
	
	public void AddProduct(){
		this.NoRenderListProducts = false;
		this.LicenceSelected  = null;
		this.Refresh();
	}

//méthode permetant de calculer le prix Total de la commande dans le Tableau   
	public Decimal getTotalPriceOrder(){
		this.CompteurTotal=0;

		for(WrapProductOrderItem priceorder : ProductsOrderItems)
		{
			this.CompteurTotal = this.CompteurTotal + priceorder.GetTotalPriceAfterDiscount();
		}
		
		return this.CompteurTotal.setScale(2);
	}
	
//méthode retournant la Liste des Provenances (Bon de commande ou ShareIt)    
	 public List<SelectOption> getProvenance() {

		List<SelectOption> options = new List<SelectOption>();

		options.add(new SelectOption('Bon de commande','Bon de commande'));
		options.add(new SelectOption('ShareIt','ShareIt'));
		options.add(new SelectOption('Formation','Formation'));
	   
		return options;
		

	}

//méthode qui permet de gérer l'affichage des champs en fonction de la selection de la Provenance    
	public void AppearReferenceField(){
		if(SelectedProvenance == 'Bon de Commande')
		{
			this.Reference ='Référence Bon de Commande : ';
			this.RenderReferenceFieldBDC=true;
			this.RenderReferenceFieldShareIt=false;
			this.RenderReferenceFieldFormation=false;
		}
		else if(SelectedProvenance == 'ShareIt')
		{
			this.Reference ='Référence ShareIt : ';
			this.RenderReferenceFieldShareIt=true;
			this.RenderReferenceFieldBDC=false;
			this.RenderReferenceFieldFormation=false;
		}
		else if(SelectedProvenance == 'Formation')
        {
            this.Reference ='Référence Formation : ';
            this.RenderReferenceFieldFormation=true;
            this.RenderReferenceFieldBDC=false;
            this.RenderReferenceFieldShareIt=false;
        }
		
		this.RenderClient = true;
	}

//méthode retournant la Liste des différents Statuts du Client (Existant, Nouveau Compte Pro ou Perso)    
	 public List<SelectOption> getStatutClient() {

		List<SelectOption> options = new List<SelectOption>();

		options.add(new SelectOption('Existant','Existant'));

		options.add(new SelectOption('Nouveau Compte Pro','Nouveau Compte Pro'));
		
		options.add(new SelectOption('Nouveau Compte Perso','Nouveau Compte Perso'));
	   
		return options;

	}

//méthode retournant la Liste des différents Statuts du Client Final(Existant, Nouveau ou Aucun)    
	public List<SelectOption> getStatutClientFinal() {

		List<SelectOption> EtatClientFinal = new List<SelectOption>();

		EtatClientFinal .add(new SelectOption('Client Final Existant','Client Final Existant'));

		EtatClientFinal .add(new SelectOption('Nouveau Client Final','Nouveau Client Final'));
		
		EtatClientFinal .add(new SelectOption('Aucun','Aucun'));
	   
		return EtatClientFinal ;

	}
//méthode retournant la Liste des différents Statuts du nouveau Client Final (Pro ou Perso)    
	public List<SelectOption> getStatutCompteClientFinal() {

		List<SelectOption> StatutCompteClientFinal = new List<SelectOption>();

		StatutCompteClientFinal.add(new SelectOption('Client Final Pro','Client Final Pro'));

		StatutCompteClientFinal.add(new SelectOption('Client Final Perso','Client Final Perso'));
	   
		return StatutCompteClientFinal ;

	}

//méthode permettant de gérer l'affichage des formulaires et des champs en fonction du Statut du Client selectionné    
	public void AppearClientFields(){
		this.RenderDiscountAndProducts = true;

		if(SelectedStatutClient == 'Nouveau Compte Perso')
		{
			this.RenderClientFields=false;
			this.RenderClientSearch=false;
			this.Ceciestuntest=true;
			this.Ceciestuntest3=true;
			this.Ceciestuntest4=false;
			this.PersonAccount = new Account();
			this.RechercheContactActive=null;
			this.MyOrder.Contact_lie__c=null;
			this.MyOrder.AccountID=null;
			ExistantContact=null;
			ExistantAccount=null;
		}
		else if(SelectedStatutClient == 'Existant')
		{
			this.PersonAccount = new Account();
			this.RechercheContactActive=this.MyOrder.Contact_lie__c;
			this.Tentative=this.MyOrder.AccountID;
			this.Ceciestuntest=false;
			this.Ceciestuntest3=false;
			this.Ceciestuntest4=false;
			this.RenderClientFields=true;
			this.RenderClientSearch=true;
			
			//Condition permettant de vérifier que la recherche concernant le Contact lié au compte n'est pas nulle. Depuis ce contact on récupère ainsi l'ID de l'Account
			if(this.RechercheContactActive!=null)
			{
				this.Ceciestuntest=true;
				this.Ceciestuntest2=false;
				this.PersonAccount = new Account();
				ExistantContact=[SELECT AccountId FROM Contact WHERE Id=:this.RechercheContactActive];
				ExistantAccount=[SELECT Id, Name, IsPersonAccount, Domaine_utilisateur__c, Discount_global__c, Type, (SELECT Domaine_Utilisateur__c, Status FROM Orders), Selection_impaye__c, Selection_importance__c FROM Account WHERE Id=:ExistantContact.AccountId]; 
				
				this.PersonAccount.Id=ExistantAccount.Id;
				this.MyOrder.AccountId=this.PersonAccount.Id;
				this.PersonAccount.Name=ExistantAccount.Name;
				this.PersonAccount.Domaine_utilisateur__c=ExistantAccount.Domaine_utilisateur__c;
				this.PersonAccount.Discount_global__c=ExistantAccount.Discount_global__c;
				RefreshDiscountClient();
				
				this.RenderClientFinal = ExistantAccount.Type == 'Distributeur' || ExistantAccount.Type == 'Revendeur';
				
				String selectedOrderDomain = productDomainToOrderDomain.containsKey(this.SelectedDOmaine) ? productDomainToOrderDomain.get(this.SelectedDOmaine) : this.SelectedDOmaine;
				
				if(ExistantAccount.Domaine_Utilisateur__c != selectedOrderDomain){
						System.debug(selectedOrderDomain);
					 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention. Le domaine utilisateur du compte sélectionné est différent de celui entré dans la commande.'));
				}else{
					Boolean oldOrdersDomainDifferentFromThis = false;
					Boolean oldOrdersStatusDifferentFromPaid = false;
					for(Order order : ExistantAccount.Orders){
						if(order.Domaine_Utilisateur__c != selectedOrderDomain){
							oldOrdersDomainDifferentFromThis = true;
						}
						if(order.Status != 'Payée' && order.Status != 'Validée'){
							oldOrdersStatusDifferentFromPaid = true;
						}
						if(oldOrdersDomainDifferentFromThis && oldOrdersStatusDifferentFromPaid){
							break;
						}
					}
					if(oldOrdersDomainDifferentFromThis == true){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention. Le compte choisi a déjà passé des commandes avec des domaines utilisateurs différents de celui sélectionné.'));
					}
					if(oldOrdersStatusDifferentFromPaid== true){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention. Le compte choisi a passé des commandes qui n\'ont pas encore été payées.'));
					}
				}
				
				if(ExistantAccount.Domaine_Utilisateur__c == 'Student'){                    
					if(ExistantAccount.Orders.size() == 2){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention. Le compte choisi est un étudiant et il a déjà passé au moins deux commandes.'));
					}
				}
				
				if(ExistantAccount.Selection_importance__c == '0 - A éviter' || ExistantAccount.Selection_importance__c == '1 - A vérifier'){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention. Le compte choisi est marqué comme à éviter ou à vérifier.'));
				}
				
				if(ExistantAccount.Selection_impaye__c== 'Impayé'){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention. Le compte choisi a passé des commandes impayées.'));
				}
			}else{
				this.RenderDiscountAndProducts = false;
			}
			
		}
		else if(SelectedStatutClient == 'Nouveau Compte Pro')
		{
			this.PersonAccount= new Account();
			this.RenderClientFields=false;
			this.RenderClientSearch=false;
			this.Ceciestuntest=true;
			this.Ceciestuntest3=false;
			this.Ceciestuntest4=true;
			this.NewContact= new Contact();
			
		}
		
	}

//méthode gérant l'affichage des formulaires et champs du Client Final en fonction du Statut du Client Final selectionné  
	public void AppearClientFinalFields()
	{
		
		if(SelectedStatutClientFinal=='Client Final Existant')
		{
			this.ClientFinalAccount=new Account();
	
			this.ClientFinalContact=new Contact();
			this.RenderClientFinalSearch=true;
			this.RenderClientFinalFields=false;
			this.RenderCompteClientFinalFields=false;
			this.RenderComptePersoClientFinalFields=false;
		}
		else if(SelectedStatutClientFinal=='Nouveau Client Final')
		{
			this.ClientFinalAccount=new Account();
	
			this.ClientFinalContact=new Contact();
			this.RenderClientFinalSearch=false;
			this.RenderClientFinalFields=true;
			this.RenderCompteClientFinalFields=false;
			this.RenderComptePersoClientFinalFields=false;
			//Condition qui permet d'aficher les champs pour un Nouveau Client Final Pro ou Perso en fonction de la selection
			if(SelectedStatutCompteClientFinal=='Client Final Pro')
			{
				this.ClientFinalAccount=new Account();
	
				this.ClientFinalContact=new Contact();
				this.RenderCompteClientFinalFields=true;
				this.RenderComptePersoClientFinalFields=false;
			}
			else if(SelectedStatutCompteClientFinal=='Client Final Perso')
			{
				this.ClientFinalAccount=new Account();
	
				this.ClientFinalContact=new Contact();
				this.RenderComptePersoClientFinalFields=true;
				this.RenderCompteClientFinalFields=false;
			}
		}
		else if(SelectedStatutClientFinal=='Aucun')
		{
			this.ClientFinalAccount=new Account();
	
			this.ClientFinalContact=new Contact();
			this.RenderClientFinalSearch=false;
			this.RenderClientFinalFields=false;
			this.RenderCompteClientFinalFields=false;
			this.RenderComptePersoClientFinalFields=false;
		}
		
	}

//méthode retournant la Liste des différents Domaines Utilisateur
	public List<SelectOption> getDomaineList()
	{
		List<SelectOption> DomaineOptionList = new List<SelectOption>();

		DomaineOptionList.add(new SelectOption('NULL', '-----Select Domaine-----'));
					
		DomaineOptionList.add(new SelectOption('Etudiant', 'Student'));
		DomaineOptionList.add(new SelectOption('Education', 'Academic'));
		DomaineOptionList.add(new SelectOption('Entreprise/Privé', 'Company/Private'));
		DomaineOptionList.add(new SelectOption('Campus', 'Campus'));
		DomaineOptionList.add(new SelectOption('Editeur', 'Editeur'));
		DomaineOptionList.add(new SelectOption('N.A.', 'N.A.'));

		return DomaineOptionList;
	}

//méthode retournant la Liste des différents Type de Licences en fonction du Domaine Utilisateur selectionné
	public List<SelectOption> LicenceList {get; set;}
//méthode retournant la Liste des différents Produits en fonction du Domaine Utilisateur et du Type de Licence selectionnés    
	public List<SelectOption> getProductList()
	{
			this.SelectedDomain = this.NewProduct.Domaine_utilisateur__c;
			List<Product2> Products = [SELECT Name FROM Product2 WHERE Domaine_utilisateur__c=:this.SelectedDomaine AND Type_Licence__c=:this.SelectedLicence];

			List<SelectOption> ProductOptionList = new List<SelectOption>();
			Set<String> sNamesLicence = New Set<String>();
			ProductOptionList.add(new SelectOption('-----Select Solution-----', '-----Select Solution-----'));
			for(Product2 product : Products)
			{
			   if(sNamesLicence.Contains(product.Name) == FALSE){
				
					sNamesLicence.add(product.Name);
					
					ProductOptionList.add(new SelectOption(product.Name, product.Name));
				}
			}
			
			return ProductOptionList;
		 
	}

//méthode retournant la Liste des différentes Civilités pour un nouveau Compte Perso/Client Final Perso ou un nouveau Contact   
	public List<SelectOption> getSalutationList()
	{
		List<SelectOption> SalutationsOptionList= new List<SelectOption>();

		SalutationsOptionList.add(new SelectOption('--None--', '--None--'));
					
		SalutationsOptionList.add(new SelectOption('Monsieur', 'Monsieur'));
		SalutationsOptionList.add(new SelectOption('Melle', 'Melle'));
		SalutationsOptionList.add(new SelectOption('Madame', 'Madame'));
		SalutationsOptionList.add(new SelectOption('Mr.', 'Mr.'));
		SalutationsOptionList.add(new SelectOption('Ms.', 'Ms.'));
		SalutationsOptionList.add(new SelectOption('Mrs.', 'Mrs.'));
		SalutationsOptionList.add(new SelectOption('Pr.', 'Pr.'));
		SalutationsOptionList.add(new SelectOption('Dr.', 'Dr.'));
		SalutationsOptionList.add(new SelectOption('Pr. Dr.', 'Pr. Dr.'));  
			
		return SalutationsOptionList;
	}

//méthode permettant de retourner la Liste des différentes Provinces/Régions (States) dans les formulaires d'adresses    
	public List<SelectOption> getStateList()
	{
		List<SelectOption> StateOptionList = new List<SelectOption>();
		StateOptionList.add(new SelectOption('-----Select State-----', '-----Select State-----'));
		
		List<Schema.PicklistEntry>  fieldResult = Lead.statecode.getDescribe().getPicklistValues();
		for( Schema.PicklistEntry f : fieldResult ){
			StateOptionList.add(new SelectOption(f.getValue(), f.getLabel()));
		}
			
		return StateOptionList;
	}
	
	public void RefreshLicences(){
		if(this.SelectedDomain != 'NULL'){
			this.RenderProvenance = true;
		}
		
		List<Product2> Licences = [SELECT Type_licence__c, Type_licence_desc_EN__c FROM Product2 WHERE Domaine_utilisateur__c = :SelectedDomaine];

		List<SelectOption> LicenceOptionList = new List<SelectOption>();
		Set<String> sNamesLicence = New Set<String>();
		LicenceOptionList.add(new SelectOption('-----Select Licence-----', '-----Select Licence-----'));
		for(Product2 licence : Licences)
		{
			if(sNamesLicence.Contains(licence.Type_licence__c) == FALSE){
			
				sNamesLicence.add(licence.Type_licence__c);
				
				LicenceOptionList.add(new SelectOption(licence.Type_licence__c, licence.Type_licence_desc_EN__c));
			}
		}
		
		this.LicenceList = LicenceOptionList;
	}

//méthode permettant de rafraîchir le tableau des produits afin d'afficher les produits adaptés en fonction des différentes selections précédentes(Domaine Utilisateur, Type de Licence etc)    
	public void Refresh()
	{
	this.NoRenderListProductsParam  = true;
		this.wrapProductList = new List<wrapProduct>();
		Map<Id, Product2> productsByIds = new Map<Id, Product2>();
		//Condition qui permet de vérifier si l'option Old Products est cochée dans quel cas uniquement les Anciens Produits seront affichés
		if(this.IsOldProductSelected!=true)
		{  
			if(this.SelectedLicence != 'Campus' && this.SelectedLicence != 'Mixte' && this.SelectedLicence != 'N.A.'){
				productsByIds.putAll([select Id, Name, ProductCode, Type_licence_desc_EN__c, Type_licence__c, Domaine_utilisateur__c, Domaine_utilisateur_en__c FROM Product2 WHERE (Domaine_utilisateur__c= :this.SelectedDomaine AND Type_Licence__c= :this.SelectedLicence AND ProductCode LIKE 'S_%') OR Family='Shipping' ORDER BY Name, Family]);
			}else if(this.SelectedLicence == 'Campus'){
				productsByIds.putAll([select Id, Name, ProductCode, Type_licence_desc_EN__c, Type_licence__c, Domaine_utilisateur__c, Domaine_utilisateur_en__c FROM Product2 WHERE (Domaine_utilisateur__c= :this.SelectedDomaine AND ProductCode LIKE 'S_%' AND (Type_Licence__c= 'Small Campus' OR Type_Licence__c = 'Large Campus')) OR Family='Shipping' ORDER BY Name, Family]);
			}else if(this.SelectedLicence == 'Mixte'){
				productsByIds.putAll([select Id, Name, ProductCode, Type_licence_desc_EN__c, Type_licence__c, Domaine_utilisateur__c, Domaine_utilisateur_en__c FROM Product2 WHERE (Domaine_utilisateur__c= :this.SelectedDomaine AND ProductCode LIKE 'S_%' AND (Type_Licence__c= 'Annuelle' OR Type_Licence__c = 'Perpétuelle')) OR Family='Shipping' ORDER BY Name, Family]);
			}else if(this.SelectedLicence == 'N.A.'){
				productsByIds.putAll([select Id, Name, ProductCode, Type_licence_desc_EN__c, Type_licence__c, Domaine_utilisateur__c, Domaine_utilisateur_en__c FROM Product2 WHERE (Domaine_utilisateur__c= :this.SelectedDomaine AND Type_Licence__c= :this.SelectedLicence AND ProductCode LIKE 'F_%') OR Family='Formation' ORDER BY Name, Family]);
			}
		}
		else
		{
			productsByIds.putAll([select Id, Name, ProductCode, Type_licence_desc_EN__c, Domaine_utilisateur_en__c FROM Product2 WHERE (Domaine_utilisateur__c= :this.SelectedDomaine AND Type_Licence__c= :this.SelectedLicence AND ProductCode LIKE 'M_%') OR Family='Shipping' ORDER BY Name, Family]);
		}
		
		for(PricebookEntry pe : [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id in :productsByIds.keySet() AND Pricebook2Id = :this.Pricebook.Id]){
			WrapProduct wrapProduct = new WrapProduct(productsByIds.get(pe.Product2Id), pe.UnitPrice);
			this.wrapProductList.add(wrapProduct);
		}
	}
	
	public void RefreshDiscountManual()
	{
		this.MyOrder.Discount_Manuel_Activated__c = this.MyOrder.Discount_Manuel__c != 0;
	}
	
	public void RefreshDiscountClient()
	{
		this.MyOrder.Discount_Client_Activated__c = this.PersonAccount.Discount_global__c != 0 && this.PersonAccount.Discount_global__c != null;
	}

//méthode qui permet de rafraîchir la valeur du champs DiscountCoupon en fonction de la selection d'un Coupon    
	public void RefreshCoupon()
	{
		if(this.MyOrder.Ref_du_coupon__c !=null)
		{
			Coupon__c TestCoupon = [select discount_EUR__c, discount_USD__c, discount_GBP__c, discount_JPY__c FROM Coupon__c WHERE Id=:this.MyOrder.Ref_du_coupon__c];
			if(this.MyOrder.CurrencyIsoCode == 'EUR'){
				this.DiscountCoupon=TestCoupon.discount_EUR__c;
			}else if(this.MyOrder.CurrencyIsoCode == 'JPY'){
				this.DiscountCoupon=TestCoupon.discount_JPY__c ;
			}else if(this.MyOrder.CurrencyIsoCode == 'GBP'){
				this.DiscountCoupon=TestCoupon.discount_GBP__c;
			}else{
				this.DiscountCoupon=TestCoupon.discount_USD__c;
			}
			
			if(this.DiscountCoupon != null && this.DiscountCoupon != 0){
				this.MyOrder.Discount_Coupon_Activated__c = true;
			}
		}
	}

//méthode permettant de récupérer et afficher le nom du compte associé au Contact selectionné    
	public void RecupAccountName()
	{
			this.RechercheContactActive=this.MyOrder.Contact_lie__c;

			this.Ceciestuntest=false;
			this.Ceciestuntest3=false;
			this.Ceciestuntest4=false;
			this.RenderClientFields=true;
			this.RenderClientSearch=true;
			
			
			this.PersonAccount = new Account();
			if(this.RechercheContactActive!=null)
			{
				this.Ceciestuntest=true;
				this.Ceciestuntest2=false;
				this.PersonAccount = new Account();
				//On récupère d'abord l'AccountID lié à l'ID du Contact selectionné
				ExistantContact=[SELECT AccountId FROM Contact WHERE Id=:this.RechercheContactActive];
				//On récupère ensuite les différentes informations de l'Account associé à ce Contact grâce à la requête précédente
				ExistantAccount=[SELECT Id, Name, IsPersonAccount, Domaine_utilisateur__c, Discount_global__c  FROM Account WHERE Id=:ExistantContact.AccountId]; 
				
				this.PersonAccount.Id=ExistantAccount.Id;
				this.PersonAccount.Name=ExistantAccount.Name;
				this.PersonAccount.Domaine_utilisateur__c=ExistantAccount.Domaine_utilisateur__c;
				this.PersonAccount.Discount_global__c=ExistantAccount.Discount_global__c;
			}
				   
	}

//méthode associé au bouton Dupliquer "=>" (pour le formulaire Client) permettant de faire prendre aux champs de l'Adresse d'expédition(Shipping) les mêmes valeurs que celles de l'Adresse de Facturation(Billing)    
	public void DupliquerAdresse()
	{
		this.PersonAccount.ShippingCountryCode=this.PersonAccount.BillingCountryCode;
		this.PersonAccount.ShippingStreet=this.PersonAccount.BillingStreet;
		this.PersonAccount.ShippingCity=this.PersonAccount.BillingCity;
		
		this.PersonAccount.ShippingPostalCode=this.PersonAccount.BillingPostalCode;
	}
//méthode associé au bouton Dupliquer "=>" (pour le formulaire Client Final) permettant de faire prendre aux champs de l'Adresse d'expédition(Shipping) les mêmes valeurs que celles de l'Adresse de Facturation(Billing)    
	public void DupliquerAdresseClientFinal()
	{
		this.ClientFinalAccount.ShippingCountryCode=this.ClientFinalAccount.BillingCountryCode;
		this.ClientFinalAccount.ShippingStreet=this.ClientFinalAccount.BillingStreet;
		this.ClientFinalAccount.ShippingCity=this.ClientFinalAccount.BillingCity;
		
		this.ClientFinalAccount.ShippingPostalCode=this.ClientFinalAccount.BillingPostalCode;
	}
	
	public void UpdatePricebook(){
		this.pricebook = [SELECT Id FROM PriceBook2 WHERE CurrencyIsoCode__c=:MyOrder.CurrencyIsoCode AND IsStandard = false];
				   
	   this.MyOrder.PriceBook2Id=this.priceBook.Id;  
	}

//méthode associé au bouton AddLicence permettant d'ajouter les produits selectionnés issus du premier tableau dans un second tableau en récupérant les informations de ces produits   
//ce deuxième tableau contient les OrderItems (produits commandés) avec des informations tels que le prix unitaire, la quantité, le montant total etc    
	public void AddLicence()
	{
		
		Integer counter = this.ProductsOrderItems.size();
	
		List<Product2> products = new List<Product2>();
		List<OrderItem> MyOrderItems = new List<OrderItem>();
		for(wrapProduct wrap : wrapProductList){  
		   if(wrap.isSelected){
			   if(TestIdProduct.ContainsKey(wrap.prod.Id) == FALSE){
			   
				   TestIdProduct.put(wrap.prod.Id, wrap.prod.Name);      
				   
				   System.debug(MyOrder.Pricebook2Id);     
				   
				   PriceBookEntry priceBookEntry =[SELECT Id, Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id=:wrap.prod.Id AND PriceBook2Id=:MyOrder.Pricebook2Id]; 

				   OrderItem orderitem = new OrderItem();
				   orderItem.PricebookentryId=priceBookEntry.Id;
				   orderItem.Quantity = 1;
				   orderItem.UnitPrice = priceBookEntry.UnitPrice;
				   orderItem.Not_Apply_Discounts__c = true;
				   
				   MyOrderItems.add(orderitem);
				   products.add(wrap.prod);
				   
				}
				
				wrap.IsSelected = false;
			}  
		 }
		 //Appel à la fonction de Martin en passant en paramètres : nomInstanceOrder, nomListOrderItems, nomInstanceAccount
		 OrderItemDiscount.UpdateDiscountsFromCustomOrder(MyOrder, MyOrderItems, PersonAccount);
		 
		 
		 //Pour chaque produits selectionnés on appelle le Constructeur de la classe WrapProductOrderItem et on l'ajoute à la Liste ProductsOrderItems 
		 for(Integer i = 0; i < MyOrderItems.size(); i++){         
			WrapProductOrderItem wrap = new WrapProductOrderItem(products[i], MyOrderItems[i], counter);
			
			this.ProductsOrderItems.add(wrap);
			counter++;
			
			if(LicenceSelected != null && LicenceSelected != ''){
				MyOrderItems[i].OrderId = this.MyOrder.id;
			}
		 }
		 
		 if(LicenceSelected != null && LicenceSelected != ''){
			 insert MyOrderItems;
		 }
	}
	
//méthode associé au bouton Remove permettant de retirer un Produit de la Liste d'OrderItems et donc du deuxième tableau    
	public void Remove()
	{
		
		 if(ProductsOrderItems.size()>0)
		 {
			for(Integer i=0;i<ProductsOrderItems.size();i++)
			{
				if(ProductsOrderItems.get(i).Product.Id==rowid)
				{
					removepos=i;
				}
			}
			
			if(LicenceSelected != null && LicenceSelected != ''){
				 delete ProductsOrderItems[removepos].OrderItem;
			 }
			
			ProductsOrderItems.remove(removepos);
			TestIdProduct.remove(rowid);
		   
		}
	}
	
	public void UpdateDiscount()
	{    
		Integer updateIndex = null;
		if(ProductsOrderItems.size()>0)
		 {
			for(Integer i=0;i<ProductsOrderItems.size();i++)
			{
				if(ProductsOrderItems.get(i).Product.Id==rowid)
				{
					updateIndex =i;
					break;
				}
			}
		}
		
		List<OrderItem> orderItems = new List<OrderItem>();
		orderItems.add(ProductsOrderItems.get(updateIndex).OrderItem);
		
		if(LicenceSelected != null && LicenceSelected != ''){
			List<String> pricebookEntriesIds = new List<String>();
			for(OrderItem orderItem : orderItems){
				pricebookEntriesIds.add(orderItem.PricebookEntryId);
			}
		
			OrderItemDiscount.UpdateDiscounts(false, orderItems, pricebookEntriesIds);
		
			ProductsOrderItems[updateIndex].OrderItem = orderItems[0];
		 }else{
			OrderItemDiscount.UpdateDiscountsFromCustomOrder(MyOrder, orderItems, PersonAccount);
		
			ProductsOrderItems[updateIndex].OrderItem = orderItems[0];
		 }
	}
	
//méthode associée au bouton Valider qui permet de valider la saisie de la commande et procède aux différentes insertion des données en fonction des différentes selections précédentes(statut Client, statut Client Final etc) 
   public PageReference Valider()
   {
	   String selectedOrderDomain = productDomainToOrderDomain.containsKey(this.SelectedDOmaine) ? productDomainToOrderDomain.get(this.SelectedDOmaine) : this.SelectedDOmaine;
	   this.MyOrder.Status='Version préliminaire';
	   Date DateOrderDay=system.today();
	   this.MyOrder.EffectiveDate=DateOrderDay;
	   
	   //Si ce compte est un Nouveau Compte Perso
	   //Première étape de récupération des champs à insérer pour l'Account Client Perso
	   
	   if(this.SelectedStatutClient == 'Nouveau Compte Perso')
	   {
		   this.PersonAccount.CurrencyIsoCode=this.MyOrder.CurrencyIsoCode;
		   this.PersonAccount.Langue__pc=this.NewContact.Langue__c;
		   this.PersonAccount.Salutation=this.SelectedSalutationPerso;
		   this.PersonAccount.Domaine_Utilisateur__c = selectedOrderDomain;
		   //Insertion de l'Account du Client (PersonAccount)
		   insert this.PersonAccount;
		   
		   //On récupère l'ID de l'Account inséré pour l'associer à la commande
		   //Deuxième étape de récupération des champs de la commande (MyOrder)
		   this.MyOrder.AccountId=this.PersonAccount.Id;
		   this.MyOrder.Provenance__c=this.SelectedProvenance;
		   this.MyOrder.Provenance_du_site_web__c=this.NewContact.Langue__c;
		  
	   }
	   
	   //Si ce compte est un Nouveau Compte Pro
	   //Première étape de récupération des champs à insérer pour l'Account Client Pro
	   
	   else if(this.SelectedStatutClient == 'Nouveau Compte Pro')
	   {
		   this.PersonAccount.CurrencyIsoCode=this.MyOrder.CurrencyIsoCode;
		   this.PersonAccount.Domaine_utilisateur__c=selectedOrderDomain;
		   //Insertion de l'Account du Client (PersonAccount)
		   insert this.PersonAccount;
		   
		   //Deuxième étape : on récupère ensuite les champs du nouveau Contact
		   this.NewContact.Salutation=this.SelectedSalutationPro;
		   this.NewContact.CurrencyIsoCode=this.PersonAccount.CurrencyIsoCode;
		   this.NewContact.Domaine_utilisateur__c=this.PersonAccount.Domaine_utilisateur__c;
		   //On associe le nouveau Contact avec l'ID de l'Account précédemment inséré
		   this.NewContact.AccountId=this.PersonAccount.Id;
		   
		   //On insère ce nouveau Contact (NewContact)
		   insert this.NewContact;
		   
		   //Troisième étape de récupération des champs de la commande (MyOrder)
		   //On récupère l'ID de l'Account inséré pour l'associer à la commande
		   this.MyOrder.AccountId=this.PersonAccount.Id;
		   this.MyOrder.Contact_Lie__c=this.NewContact.Id;
		   this.MyOrder.Provenance__c=this.SelectedProvenance;
		   this.MyOrder.Provenance_du_site_web__c=this.NewContact.Langue__c;
		   
	   }
	   //Si ce compte est un Account déjà Existant
	   else if(this.SelectedStatutClient=='Existant')
	   {
		   //Condition regardant si cet Account déjà existant est un Account Pro et Perso
		   if(this.ExistantAccount.IsPersonAccount==false)
		   {
			   //Première étape de récupération des champs de la commande (MyOrder)
			   //On récupère l'ID de l'Account existant pour l'associer à la commande
			   this.MyOrder.AccountId=this.PersonAccount.Id;
			   this.MyOrder.Contact_Lie__c=this.RechercheContactActive;
			   this.MyOrder.Provenance__c=this.SelectedProvenance;

		   }
		   else if(this.ExistantAccount.IsPersonAccount==true)
		   {
			   //Première étape de récupération des champs de la commande (MyOrder)
			   //On récupère l'ID de l'Account existant pour l'associer à la commande
			   this.MyOrder.AccountId=this.PersonAccount.Id;
			   this.MyOrder.Provenance__c=this.SelectedProvenance;

		   }
	   }
	   
	   //S'il y a un Client Final est qu'il est nouveau alors
 
	   if(this.SelectedStatutClientFinal=='Nouveau Client Final')
	   {
		   //Et si c'est un Nouveau Client Final Perso
		   if(this.SelectedStatutCompteClientFinal=='Client Final Perso')
		   {   
			   //On récupère les champs de ce Client Final (ClientFinalAccount)
			   this.ClientFinalAccount.CurrencyIsoCode=this.MyOrder.CurrencyIsoCode;
			   this.ClientFinalAccount.Langue__pc=this.NewContact.Langue__c;
			   this.ClientFinalAccount.Salutation=this.SelectedSalutationClientFinalPerso;
			   this.ClientFinalAccount.Domaine_utilisateur__c=this.PersonAccount.Domaine_utilisateur__c;
			   
			   //On insère ce ClientFinalAccount
			   insert this.ClientFinalAccount;
			   
			   //On récupère l'ID du Contact associé à l'Account Id qui vient d'être inséré
			   Contact RecupIdContactFromAccountPerso=[SELECT Id FROM Contact WHERE AccountId=:this.ClientFinalAccount.Id];
			   
			   //On associe le champs Client Final de la commande à cet Id que l'on vient de récupère juste au dessus
			   this.MyOrder.Client_Final__c=RecupIdContactFromAccountPerso.Id;
		   }
		   
		   //Et si c'est un Nouveau Client Final Perso
		   else if(this.SelectedStatutCompteClientFinal=='Client Final Pro')
		   {
			   //On récupère les champs de ce Client Final (ClientFinalAccount)
			   this.ClientFinalAccount.CurrencyIsoCode=this.MyOrder.CurrencyIsoCode;
			   this.ClientFinalAccount.Domaine_utilisateur__c=this.PersonAccount.Domaine_utilisateur__c;
			   
			   //On insère ce ClientFinalAccount
			   insert this.ClientFinalAccount;
			   
			   //On récupère les champs du Conact lié à ce Client Final (ClientFinalContact)
			   this.ClientFinalContact.Salutation=this.SelectedSalutationClientFinalPro;
			   this.ClientFinalContact.CurrencyIsoCode=this.ClientFinalAccount.CurrencyIsoCode;
			   this.ClientFinalContact.Domaine_utilisateur__c=this.ClientFinalAccount.Domaine_utilisateur__c;
			   this.ClientFinalContact.Langue__c = this.NewContact.Langue__c;
			   
			   //On associe le nouveau Contact(ClientFinalContact) avec l'ID de l'Account(ClientFinalAccount) précédemment inséré
			   this.ClientFinalContact.AccountId=this.ClientFinalAccount.Id;
			   
			   //On insère ce nouveau Contact "Final" (ClientFinalContact)
			   insert this.ClientFinalContact;
			   
			   //On associe les Id du Client Final et de son Contact à la commande
			   this.MyOrder.AccountPro__c=this.ClientFinalAccount.Id;
			   this.MyOrder.Client_Final__c=this.ClientFinalContact.Id;
		   }
		   
		   //Et si c'est un Client Final déjà existant, toutes les informations sont déjà récupérées grâce aux champs sur la page VisualForce
	   }
	   
	   this.MyOrder.Domaine_Utilisateur__c = selectedOrderDomain;
	   
	   //Etape commune : On insère la commande
	   insert this.MyOrder;
	   
	   //Dernière Etape commune : on récupère les OrderItems
	   //Ces OrderItems sont associés à l'ID de la commande précédemment insérée
	   List<OrderItem> OrderItemToAddInOrder = new List<OrderItem>();
		   for(WrapProductOrderItem wrap : this.ProductsOrderItems)
		   {
			   wrap.OrderItem.OrderId=this.MyOrder.Id;
			   OrderItemToAddInOrder.add(wrap.OrderItem);
			   
		   }
		   //On insère les OrderItems
		   insert OrderItemToAddInOrder;
   
	   PageReference pageRef = new PageReference('/' + this.MyOrder.Id);
	   pageRef.setRedirect(true);
	   return pageRef;
   } 
	
//Déclaration d'une Wrapper Class    
	public class wrapProduct {
	//Déclaration des variables de cette classe
		public Product2 prod {get; set;}
		public Boolean isSelected {get; set;}
		public Decimal UnitPrice {get; set;}
		
		//Constructeur de la classe
		public wrapProduct(Product2 p, Decimal unitPrice) {
			this.prod = p;
			this.isSelected = false;
			this.UnitPrice = unitPrice;
		}
	}
}