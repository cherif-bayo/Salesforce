@isTest
public class HelperTestDataWebServiceOrder {

    public static WebServiceOrder.Customer createBaseCustomerPlanByEmail(String email){     
        WebServiceOrder.Customer customer = new  WebServiceOrder.Customer();
        customer.FirstName 	= 'firstnametest';
        customer.LastName 	= 'Lastnametest';
        customer.Email 		= email;
        customer.company 	= 'Companytest';        
        customer.street1	='street1test';
        customer.street2	='street2test';
        customer.postalCode	='33000';
        customer.city		='CITY_TEST';
        customer.language 	= 'FR';
        customer.countryCode= 'FR';
        
        return customer;
    }
    
    public static WebServiceOrder.PlanProduct createBasePlanProductByCodeNameAndCurrency(String code,String name,String currencyCode){
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode 	= code;
        orderProduct.Quantity 		= 3;
        orderProduct.UnitPrice 		= 295;
        orderProduct.productName 	= name;
        orderProduct.currencyISOCode= currencyCode;
        
        return orderProduct;
    }
    
    public static WebServiceOrder.Plan createBasePlanByContactBillingPlanProductsAndCurrency(WebServiceOrder.Customer customer,List<WebServiceOrder.PlanProduct> products,
                                                                                             String currencyCode) {
        WebServiceOrder.Plan order 	= new  WebServiceOrder.Plan();
        order.planProducts 			= products;
        order.customerBilling 		= customer;
        order.currencyISOCode 		= currencyCode;
        
        return order;
    }
}