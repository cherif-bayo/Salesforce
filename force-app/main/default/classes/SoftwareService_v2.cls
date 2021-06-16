/**
 * Created by RCOR on 16/10/2020.
 */

public without sharing class SoftwareService_v2 {

   /* static Map<String, Software__c> softwareByCode;


    public void populateSoftwareByCode() {
        softwareByCode = new Map<String, Software__c>();
        for (Software__c software : [SELECT Id, Code__c, Name, ProductId__c, AccessType__c, CurrencyIsoCode FROM Software__c]) {
            softwareByCode.put(software.Code__c, software);
        }
    }

    public Map<String, Software__c> getSoftwareByCode() {
        if (softwareByCode == null || softwareByCode.isEmpty()) {
            populateSoftwareByCode();
        }
        return softwareByCode;
    }*/
}