public class UpdateLastOrder{    
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public UpdateLastOrder(){
        CurrencyType[] currOrders = [SELECT IsoCode,ConversionRate FROM CurrencyType];
        Map<String, CurrencyType> currOrdersByIsoCode = new Map<String, CurrencyType>();
        for(CurrencyType currType : currOrders){
            currOrdersByIsoCode.put(currType.IsoCode, currType);
        }
        
        Date dateLastOrders = Date.newInstance(2015, 10, 15);
        this.orders = [select Id, CurrencyIsoCode, NbOrderItems__c, TotalAmountAfterDiscount__c from Order where EffectiveDate >= :dateLastOrders and Provenance__c = 'ShareIt'];
        for(Order order : this.orders){
            Decimal priceFraisShareIt = (0.75 * currOrdersByIsoCode.get(order.CurrencyIsoCode).ConversionRate) / currOrdersByIsoCode.get('EUR').ConversionRate;
            
            Integer nbOrderProducts = Integer.valueof(order.NbOrderItems__c);
            
            order.Frais_ShareIt__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscount__c;
        }
    }
    
    public void UpdateOrders(){
        List<List<Order>> ordersToUpdate = new List<List<Order>>();
        
        List<Order> os = new List<Order>();
        Integer max = this.orders.size() >= 2000 ? 2000 : this.orders.size();
        for(Integer i = 0; i < max; i++){
            Order order = this.orders[i];     
            
            os.add(order);
        }
        
        for(Integer i = 0; i < max; i++){
            this.orders.remove(0);
        }
        
        ordersToUpdate.add(os);
        
        for(List<Order> o : ordersToUpdate){
            update o;
        }
    }
}