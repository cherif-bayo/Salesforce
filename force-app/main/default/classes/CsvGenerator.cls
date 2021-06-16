public class CsvGenerator {
    private String csv;

    public CsvGenerator (){
        this.csv = '';
    }
    
    public Boolean SendTo(String emailAdress){
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(this.csv);
        string csvname= 'nalpeiron_keys_to_import.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {emailAdress};
        String subject ='Clés Nalpeiron CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(subject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        if(r.size() == 1){
            return r[0].getErrors().size() == 0;
        }else{
            return false;
        }
    }
    
    public void AddLine(String[] cells) {
        this.csv += String.join(cells, ';') + '\n';
    }
    public String Format(String s) {
        return s != null ? s.escapeCsv() : '';
    }
    public String Format(Decimal d, Integer scale) {
        return d != null ? String.valueOf(d.setScale(scale)) : '';
    }
}