public class OrderLineItemTaxes implements Queueable, Database.AllowsCallouts {
    Order order;
    Boolean isArchived;

    public OrderLineItemTaxes(Id orderId, Boolean isArchived) {

        // Filtrage des bons de commande vendus par Addinsoft Inc.
        this.order = [
                select AddinSoftCompany__c, BillingAddress, BillingStateCode, BillingPostalCode, BillingStreet,
                        BillingCity, BillingCountry, BillingCountryCode, CurrencyIsoCode, us_tax_exemption_certificate_id__c, Discount_Manuel_Activated__c, Discount_Client_Activated__c
                from Order
                where Id = :orderId					
        ];
        this.isArchived = isArchived;

        System.debug('[OrderLineItemTaxes] creation du job pour la commande :' + order.Id);
    }


    public void execute(QueueableContext context) {
        System.debug('[OrderLineItemTaxes] lancement du job pour la commande :' + order.Id);

        // Récupération des lignes des bons de commandes
        List<OrderItem> orderItems = [
                select OrderItemNumber, ProductCode__c, ProductType__c, UnitPrice, Percent_Discount_Total__c, Quantity, Description
                From OrderItem
                where OrderId = :order.Id
        ];

        // traitement des lignes de commandes
        Map<String, OrderItem> lineItemByCustomId = new Map<String, OrderItem> ();
        List<TaxamoFacade.TaxamoProductLineItem> taxamoItems = new List<TaxamoFacade.TaxamoProductLineItem> ();
        for (OrderItem item : orderItems) {
            TaxamoFacade.TaxamoProductLineItem taxamoItem = new TaxamoFacade.TaxamoProductLineItem();
            taxamoItem.custom_id = item.OrderItemNumber;
            taxamoItem.product_code = item.ProductCode__c;
            taxamoItem.product_type = item.ProductType__c;
            taxamoItem.product_tax_code = '210116';
            if (order.Discount_Manuel_Activated__c && item.Percent_Discount_Total__c != null && item.Percent_Discount_Total__c > 0) {
                taxamoItem.unit_price = item.UnitPrice - (item.UnitPrice * (item.Percent_Discount_Total__c / 100));
            }
            else if(order.Discount_Client_Activated__c && item.Percent_Discount_Total__c != null && item.Percent_Discount_Total__c > 0){
                taxamoItem.unit_price = item.UnitPrice - (item.UnitPrice * (item.Percent_Discount_Total__c / 100)); // Prix Unitaire après discount
            }
            else {
                taxamoItem.unit_price = item.UnitPrice;
            }


            taxamoItem.quantity = Math.round(item.Quantity);
            taxamoItem.Description = item.Description;
            taxamoItems.add(taxamoItem);
            lineItemByCustomId.put(item.OrderItemNumber, item);
        }

        // Récuperation de l'adresse du compte
        TaxamoFacade.TaxamoInvoiceAddress taxamoAdress = new TaxamoFacade.TaxamoInvoiceAddress();
        if (order.BillingAddress != null) {
            taxamoAdress.building_number = order.BillingAddress.getCity();
        }
        taxamoAdress.city = order.BillingCity;
        taxamoAdress.country = order.BillingCountryCode;
        taxamoAdress.postal_code = order.BillingPostalCode;
        taxamoAdress.region = order.BillingStateCode;
        taxamoAdress.street_name = order.BillingStreet;

        // Parametres du service Taxamo
        TaxamoFacade.TaxamoServiceParams taxamoParams = new TaxamoFacade.TaxamoServiceParams();
        taxamoParams.currency_code = order.CurrencyIsoCode;
        taxamoParams.billing_country_code = order.BillingCountryCode;
        taxamoParams.invoice_address = taxamoAdress;

        // Ajout du taxe exemption
        if (order.us_tax_exemption_certificate_id__c != null) {
            TaxamoFacade.Certificate c = new TaxamoFacade.Certificate();
            c.certificate_id = order.us_tax_exemption_certificate_id__c;
            TaxamoFacade.TaxamoTaxData td = new TaxamoFacade.TaxamoTaxData();
            td.certificat = c;
            taxamoParams.tax_data = td;
        }

        // Ajout des lignes de commandes
        taxamoParams.transaction_lines = taxamoItems;
        if (order.BillingPostalCode != null) {
            String taxamoResponse = TaxamoFacade.getTaxamoJsonResponse(taxamoParams, isArchived); // Enregistre le paiement dans Taxamo
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(taxamoResponse);
            Map<String, Object> t = (Map<String, Object>) m.get('transaction');
            List<Object> transactions = (List<Object>) t.get('transaction_lines');
            for (Object o : transactions) {
                Map<String, Object> item = (Map<String, Object>) o;
                lineItemByCustomId.get((String) item.get('custom_id')).TaxamoAmount__c = (Decimal) item.get('amount');
                lineItemByCustomId.get((String) item.get('custom_id')).TaxamoTaxeAmount__c = (Decimal) item.get('tax_amount');
                lineItemByCustomId.get((String) item.get('custom_id')).TaxamoTaxeRate__c = (Decimal) item.get('tax_rate');
                lineItemByCustomId.get((String) item.get('custom_id')).TaxamoTotalAmount__c = (Decimal) item.get('total_amount');
                System.debug('[OrderLineItemTaxes] Transaction Line' + item);
            }

            // Ajout du total des taxes Taxamo sur le devis
            order.TaxamoAmount__c = (Decimal) t.get('amount');
            order.TaxamoTaxeAmount__c = (Decimal) t.get('tax_amount');
            order.TaxamoTotalAmount__c = (Decimal) t.get('total_amount');


            update orderItems;
            update order;
        }

    }
}