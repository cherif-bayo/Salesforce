public class ExportSector{
    public Map<String, String> sectors {get;set;}
    public string Filetype{get;set;}
    public string header{get;set;}

    public ExportSector(){
        sectors = new Map<String, String>();
        Filetype = '';
        header = 'sep=,\rSectors\r';  
    }
    
    public void ExportSectors(){
        for(Account account : [select Id, Sous_Secteur__c from Account]){
            sectors.put(account.Sous_Secteur__c, account.Id);            
        }
    }
}