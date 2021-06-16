public class Parameters {

    private static Map<String,String> stringParams;
    
    public static String getString (String name) {
        if (stringParams == null) setParams();
            
        return stringParams.get(name);
    }    
    
     private static void setParams() {
        stringParams = new Map<String,String>();
         
        Addinsoft_settings__mdt[] params = [SELECT DeveloperName,Value__c FROM Addinsoft_settings__mdt];
        
        for (Addinsoft_settings__mdt param :params) {
            if (param.Value__c != null) {
                stringParams.put(param.DeveloperName,param.Value__c);
            }
        } 
       	System.debug('[Parameters] params :' + stringParams);
    }
    
}