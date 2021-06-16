//Déclaration d'une autre Wrapper Class      
    public class WrapProductOrderItem{
    //Déclaration des variables de cette classe
        public Product2 Product {get; set;}
        public OrderItem OrderItem {get; set;}
        Public Integer Counter {get; set;}
        Public Decimal OrderTotalPrice {get;set;}
        
        public Boolean IsSelected {get; set;}
        
        //Constructeur de la classe
        public WrapProductOrderItem(Product2 p, OrderItem oi, Integer c) {
            this.Product = p;
            this.OrderItem = oi;
            this.IsSelected = false;
            this.Counter = c;
            this.OrderTotalPrice=0;
        }
       
       //méthode permattant de rafraîchir le prix Total de l'OrderItem en fonction de la quantité saisie
       public Decimal GetTotalPrice(){
            return (this.OrderItem.Quantity * this.OrderItem.Unit_Price_Discount_Volume__c).setScale(2);
        }
        
        //méthode permattant de rafraîchir le prix Total Après Discount de l'OrderItem en fonction de la quantité saisie et des Discounts utilisés
        public Decimal GetTotalPriceAfterDiscount(){
            return this.OrderItem.Total_Price_After_Discount__c;
        }
    }