public class ExportIndustry{
    public Map<String, String> industries {get;set;}
    public string Filetype{get;set;}
    public string header{get;set;}

    public ExportIndustry(){
        industries = new Map<String, String>();
        Filetype = '';
        header = 'sep=,\rIndustries\r';  
    }
    
    public void ExportIndustries(){
        for(Account account : [select Id, Industry from Account]){
            industries.put(account.Industry, account.Id);            
        }
    }
}