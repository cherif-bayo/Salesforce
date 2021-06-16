public class WrapperProduct {
    public boolean checked {get; set;}
    public Product2 p {get; set;}
    public WrapperProduct(Product2 p) {
        this.p = p;
        this.checked = false; 
    }
}