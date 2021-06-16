global class WebServiceEditor{
    //Currency static variables
    private static String PRICEBOOK_USD_ID = '01s2400000335Su';
    private static String CURRENCY_ISO_CODE = 'USD';
    
    //Domain static variables
    private static String USER_DOMAIN_STUDENT = 'Student';
    private static String USER_DOMAIN_PROF = 'Academic';
    
    //Contact static variables
    private static String IMPORTANCE = '2 - Normal';
    private static String LANGUE = 'US';
    private static String INDUSTRY = 'Education';
    
    //Order static variables
    private static String ORDER_STATUS_START = 'Version préliminaire';
    private static String ORDER_STATUS_END = 'Validée';
    private static String ORDER_USER_DOMAIN = 'Editeur';
    private static String ORDER_LICENSE_TYPE = 'Annuelle';
    
    //Nalpeiron static variables
    private static Integer NALPEIRON_NB_USERS = 1;
    private static Integer NALPEIRON_PEARSON_MODULE = 12;
    private static String NALPEIRON_LICENSE_TYPE = 'Annual';
    private static String NALPEIRON_ACCOUNT_NAME = 'editor';
    private static String NALPEIRON_ACCOUNT_EMAIL = 'editor@editor.com';

    /*
        User informations sent from the editor
    */
    global class Customer{
        webservice String countryISOCode;
        webservice String email;
        webservice String firstName;
        webservice String lastName;
        webservice String institution;
        webservice Boolean isStudent;
    }
    
    /*
        Class returned on the AddOrder call
    */
    global class ResultAddOrder{
        webservice String customerId;
        webservice String message;
        webservice String orderId;
        webservice Boolean state;
    }
    
    /*
        Class returned on the GenerateLicense call
    */
    global class ResultGenerateLicense{
        webservice String message;
        webservice String nalpeironKey;
        webservice Boolean state;
    }
    
    /*
        Insert the new order in the SF Database
        Inputs:
            - editorId: The Id linked to the editor account in SF
            - productId: The Id linked to the product added to the order in SF
            - customer: Customer class with user informations
        Outputs:
            - ResultAddOrder class containing the status, a message when an error occured, the Id of the order created in SF and the contact Id created in SF
    */
    webservice static ResultAddOrder AddOrder(String editorId, String productId, Customer customer){
        ResultAddOrder result = new ResultAddOrder();
        result.state = false;
    
        //Get the editor which called the method using his editor id
        Account[] editor = [SELECT Id, EditorSiteProvenance__c, EditorProvenance__c FROM Account where Id = :editorId];
        
        //If the editor id exists in SF
        if(editor.size() > 0){
            //Get the product to add to the order using the product id sent from the editor
            Product2[] product = [SELECT Id FROM Product2 WHERE Id = :productId];
            
            //If the product id exists in SF
            if(product.size() > 0){
                Account[] existingAccount = [SELECT PersonContactId FROM Account WHERE PersonEmail = :customer.email AND Revendeur__pc = :editor[0].Id];
            
                //Creates the account in SF using the user informations sent from the editor
                Account contact;
                if(existingAccount.size() == 0){
                    customer.firstName = customer.firstName.toLowerCase();
                    customer.lastName = customer.lastName.toLowerCase();        
                    
                    customer.firstName = customer.firstName.capitalize();
                    customer.lastName = customer.lastName.capitalize();                                
                
                    contact = new Account();
                    contact.Salutation = '';
                    contact.FirstName = customer.firstName;
                    contact.LastName = customer.lastName;
                    if(String.isBlank(contact.LastName)) contact.LastName = 'inconnu';
                    contact.PersonEmail = customer.email;
                    if(String.isBlank(contact.PersonEmail)) contact.PersonEmail = 'inconnu@xlstat.com';
                    contact.BillingCountryCode = customer.countryISOCode;
                    contact.ShippingCountryCode = customer.countryISOCode;
                    contact.Website_Auto__c = true;
                    contact.Langue__pc = LANGUE;
                    contact.Selection_importance__c = IMPORTANCE;
                    contact.CurrencyIsoCode = CURRENCY_ISO_CODE;
                    contact.Industry = INDUSTRY;
                    contact.PersonDepartment = customer.institution;
                    contact.Domaine_Utilisateur__c = customer.isStudent ? USER_DOMAIN_STUDENT : USER_DOMAIN_PROF;
                    contact.Revendeur__pc = editor[0].Id;
                    
                    insert contact;
                    
                    //We need to query the new contact id generated by SF when the account is inserted
                    contact = [SELECT PersonContactId FROM Account WHERE Id = :contact.Id];
                }else{
                    contact = existingAccount[0];
                }
            
                //Creates the order in SF
                Order order = new Order();
                order.AccountId = editor[0].Id;
                order.Client_final__c = contact.PersonContactId;
                order.Status = ORDER_STATUS_START;
                order.EffectiveDate = Date.today();
                order.Pricebook2Id = PRICEBOOK_USD_ID;
                order.CurrencyISOCode = CURRENCY_ISO_CODE;
                order.Domaine_utilisateur__c = ORDER_USER_DOMAIN;
                order.Website_Auto__c = true;
                order.BillingCountryCode = customer.countryISOCode;
                order.ShippingCountryCode = customer.countryISOCode;
                order.Editor_Auto__c = true;
                order.Provenance__c = editor[0].EditorProvenance__c;
                order.Provenance_d_affiliation__c = editor[0].EditorSiteProvenance__c;
                
                insert order;
                
                //Pricebook entry linked to the product id sent from the editor
                PricebookEntry pe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2.Id = :product[0].Id AND Pricebook2.Id = :PRICEBOOK_USD_ID limit 1];
                
                //Add the order item to the order linked to product id sent from the editor
                OrderItem orderItem = new OrderItem();
                orderItem.PricebookEntryId = pe.Id;
                orderItem.Quantity = NALPEIRON_NB_USERS;
                orderItem.OrderId = order.Id;
                orderItem.UnitPrice = pe.UnitPrice;
                
                insert orderItem;
                
                order.Status = ORDER_STATUS_END;
                update order;
                
                result.state = true;
                result.customerId = contact.PersonContactId;
                result.orderId = order.Id;
            }else{
                result.message = 'Wrong product Id.';
            }
        }else{
            result.message = 'Wrong editor Id.';
        }
        
        return result;
    }
    
    /*
        Generate the license key using the Nalpeiron web service
        Inputs:
            - editorId: The Id linked to the editor account in SF
            - customerId: The Id linked to the contact added to SF from the previous call of the AddOrder method
            - orderId: The Id linked to the order added to SF from the previous call of the AddOrder method
        Outputs:
            - ResultGenerateLicense class containing the status, a message when an error occured and the nalpeiron key generated
    */
    webservice static ResultGenerateLicense GenerateLicense(String editorId, String customerId, String orderId){
        ResultGenerateLicense result = new ResultGenerateLicense();
        result.state = false; 
        
        //Generates the nalpeiron key using the informations of the order and account previously created in SF by the AddOrder call
        
        Flexera_Key__c flexeraKey = new Flexera_Key__c();
        flexeraKey.Quantity__c = NALPEIRON_NB_USERS;
        flexeraKey.Domaine_Utilisateur__c = ORDER_USER_DOMAIN;
        flexeraKey.Type_Licence__c = ORDER_LICENSE_TYPE;
		flexeraKey.Nb_Activations_allowed__c = ActivationHelper.getNbActivationsAllowedFromQuantityBought(ORDER_USER_DOMAIN,ORDER_LICENSE_TYPE,NALPEIRON_NB_USERS);
        flexeraKey.Date_Limite__c = Date.today().addYears(1);
        flexeraKey.Expiration__c = FlexeraController.EXPIRATION_EXPIRING;
        flexeraKey.Type_client__c = ORDER_USER_DOMAIN;
        flexeraKey.Order__c = orderId;
        flexeraKey.Contact__c = customerid;
        flexeraKey.XLSTAT_Solution__c = 'XLSTAT-Education';
        flexeraKey.XLSTAT_Options__c = '';
        
        FlexeraController.ResultGenerateKey resultGenerateFlexeraKey = FlexeraController.Generate(1, flexeraKey, NALPEIRON_ACCOUNT_NAME, NALPEIRON_ACCOUNT_NAME, NALPEIRON_ACCOUNT_EMAIL, null, null);
        if(resultGenerateFlexeraKey.Status == true){
            insert resultGenerateFlexeraKey.GeneratedKeys;
        }
        
        if(resultGenerateFlexeraKey.Status){
            result.nalpeironKey = resultGenerateFlexeraKey.GeneratedKeys[0].Name;
            result.state = true;
            
            try{
                Account[] accounts = [SELECT Name, PersonEmail, BillingCountryCode, Code_MyAccount__pc FROM Account WHERE PersonContactId = :customerId];
                
                if(accounts.size() > 0){
                    Account account = accounts[0];
                
                    Map<String, String> mapSubjectParams = new Map<String, String> {
                    };
                    
                    Map<String, String> mapBodyParams = new Map<String, String> {
                        '{!ContactName}' => account.Name,
                        '{!CodeMyAccount}' => account.Code_MyAccount__pc
                    };
                    
                    Boolean isFr = account.BillingCountryCode == 'fr';
                    String subject = isFr ? 'Création de votre compte XLSTAT' : 'Create a My XLSTAT account';
                    
                     List<EmailMessageWrapper> listEmailMessageWrapper = new  List<EmailMessageWrapper>();
                     listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', account.PersonEmail, null, null, subject, mapSubjectParams, null, mapBodyParams));
                         
                    String templateName;
                    if(isFr){
                        templateName = 'MyXLSTAT FR';
                    }else{
                        templateName = 'MyXLSTAT US';
                    }
                    
                    UtilityClass utilityClass = new UtilityClass(listEmailMessageWrapper, templateName);
                    List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
                    List<Email__c> emailsToInsert = new List<Email__c>();
                    Boolean successSendEmail = true;
                    for(Integer i = 0; i < results.size(); i++){
                        Messaging.SendEmailResult resultEmail = results[i];
                        if(resultEmail.isSuccess() == false){
                            successSendEmail = false;
                            break;
                        }
                    }
                    
                     if(successSendEmail == true){
                         for(EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper){
                             Email__c e = new Email__c();
                             e.Address__c = emailMessageWrapper.ToAddress;
                             e.Contact__c = customerId;
                             e.Order__c = orderId;
                             e.Nalpeiron_Key__c = result.nalpeironKey;
                             e.Type__c = 'Compte MyXLSTAT Editeur';
                             e.Subject__c = subject;
                             emailsToInsert.add(e); 
                         } 
                        insert emailsToInsert;
                     }
                }
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }else{
            result.message = 'Error while generating key.';
        }
        
        return result;
    }
}