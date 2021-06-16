public class ExportOrderImportController{
    
    public String TextToUpload{get; set;}

    public void export(){
        this.TextToUpload = System.currentPagereference().getParameters().get('textToExport');
    }
    
}