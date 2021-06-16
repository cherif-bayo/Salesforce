public class WrapperPricebookEntry {
    public boolean checked {get; set;}
    public PricebookEntry pe {get; set;}
    public WrapperPricebookEntry(PricebookEntry pe) {
        this.pe = pe;
        this.checked = false; 
    }
}