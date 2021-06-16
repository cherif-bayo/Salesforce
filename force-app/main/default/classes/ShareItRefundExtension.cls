public class ShareItRefundExtension{
    private static String SHAREIT_SOAP_URL = 'https://secure.element5.com/soap/purservice.php';
    private static String SHAREIT_PUBLISHER_ID = '200251940';
    private static String SHAREIT_PASSWORD = 'xz58dzg7v76w1kqz';
    
    private static String FAULT_NODE = '<faultcode>';
    private static String FAULT_NODE_END = '</faultcode>';    
    private static String FAULT_CODE_SUCCESS = '000';

    private final Order order;
    
    public Boolean CanRefund {get; set;}

    public ShareItRefundExtension(ApexPages.StandardController standardController){
        this.order = [select Id, Provenance__c, Ref_ShareIt__c, Is_Refund__c, Status, Remarques__c from Order where Id = :standardController.getId() limit 1];
        this.CanRefund = false;
        
        if(this.order.Provenance__c == 'ShareIt'){
            if(this.order.Ref_ShareIt__c != null){
                if(this.order.Status == 'Payée' || Test.isRunningTest()){
                    this.CanRefund = true;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'La commande n\'est pas en statut payée.'));
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'La commande ne contient pas de référence ShareIt.'));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'La commande ne provient pas de ShareIt.'));
        }
    }

    public void Refund(){  
        Boolean refundOk = false;
    
        String[] refsShareIt = this.order.Ref_ShareIt__c.split(',');
        for(String refShareIt : refsShareIt){
            refShareIt = refShareIt.trim();
            
            String request = '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pur="https://secure.element5.com/soap/purservice.php?wsdl">'
               +'<soapenv:Header/>'
               +'<soapenv:Body>'
                  +'<pur:refundPurchase soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
                     +'<authentication xsi:type="pur:AuthenticationData">'
                        +'<PublisherId xsi:type="xsd:int">'+ SHAREIT_PUBLISHER_ID +'</PublisherId>'
                        +'<Password xsi:type="xsd:string">'+ SHAREIT_PASSWORD +'</Password>'
                     +'</authentication>'
                     +'<purchase xsi:type="pur:RefundPurchaseData">'
                        +'<PurchaseId xsi:type="xsd:long">'+ this.order.Ref_ShareIt__c +'</PurchaseId>'
                     +'</purchase>'
                  +'</pur:refundPurchase>'
               +'</soapenv:Body>'
            +'</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
    
            req.setEndpoint(SHAREIT_SOAP_URL);
            req.setMethod('POST');
            req.setBody(request);
            
            try {
                res = http.send(req);
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            }
                
            String responseBody = res.getBody();
            
            String faultCode = responseBody.substringBetween(FAULT_NODE, FAULT_NODE_END);
            
            refundOk = faultCode == FAULT_CODE_SUCCESS;
            
            if(refundOk == false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Une erreur est survenue. Code d\'erreur:' + faultCode + '.\n Veuillez contacter votre collaborateur, Martin.'));
                break;
            }
        }
        
        if(refundOk){
            this.order.Is_Refund__c = true;
            this.order.Status = 'Annulée';
            Date dateToday = Date.today();
            User currentuser = [Select Alias from User where Id=:userinfo.getuserId()];
            this.Order.Remarques__c += '\nRefund le: ' + dateToday.day() + '/' + dateToday.month() + '/' + dateToday.year() + ' via SF par ' + currentuser.Alias +'.';
            
            update this.order;
            
            Flexera_Key__c[] keysOrder = [SELECT Name, Entitlement_Id__c FROM Flexera_Key__c WHERE Order__c = :this.Order.Id];
        
            for(Flexera_Key__c key : keysOrder){
                Boolean result = FlexeraController.DeactivateEntitlement(key.Entitlement_Id__c);
            
                if(result == true){
                    Flexera_Key__c[] keys = [SELECT Id, Is_Inactive__c FROM Flexera_Key__c WHERE Name = :key.Name];
                    for(Flexera_Key__c k : keys){
                        k.Is_Inactive__c = true;
                    }
                    
                    update keys;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Une erreur est survenue pendant la désactivation des clefs liées à la commande remboursée. Veuillez contacter votre super collaborateur Martin.'));
                }
            }
        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Commande remboursée avec succés.'));
        }
        this.CanRefund = false;
    }
}