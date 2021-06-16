/**
 * Created by LBEA on 07/10/2020.
 */

public without sharing class SoftwareService {

    public Map<String, Software__c> softwareByCode;
    public Map<String, String> softwareCodeByName;
    public Map<String, String> softwareCodeByProductId;

    /** Codes des softwares avec options **/
    public final String XLSTAT_CODE = '00';
    private final List<String> softwareCodeWithOptions = new List<String>{ XLSTAT_CODE };


    public void populateSoftwareMaps() {
        System.debug('--- populateSoftwareMaps ---');
        softwareByCode = new Map<String, Software__c>();
        softwareCodeByName = new Map<String, String>();
        softwareCodeByProductId = new Map<String, String>();
        for (Software__c software : [SELECT Id, Code__c, Name, ProductId__c, AccessType__c, CurrencyIsoCode FROM Software__c]) {
            softwareByCode.put(software.Code__c, software);
            softwareCodeByName.put(software.Name, software.Code__c);
            softwareCodeByProductId.put(software.ProductId__c, software.Code__c);
        }
        System.debug('softwareByCode');
        System.debug(softwareByCode);
    }

    public Software__c getSoftwareFromCode(String softwareCode) {
        if (softwareByCode == null || softwareByCode.isEmpty()) { populateSoftwareMaps(); }
        return softwareByCode.get(softwareCode);
    }

    public Software__c getSoftwareFromName(String softwareName) {
        if (softwareName.indexOf('-') != -1) { softwareName = softwareName.split('-')[0]; }
        if (softwareByCode == null || softwareByCode.isEmpty()) { populateSoftwareMaps(); }
        String softwareCode = softwareCodeByName.get(softwareName);
        return softwareByCode.get(softwareCode);
    }

    public String getSoftwareNameFromCryptlexProductId(String productId) {
        if (softwareByCode == null || softwareByCode.isEmpty()) { populateSoftwareMaps(); }
        String softwareCode = softwareCodeByProductId.get(productId);
        System.debug('>>>> softwareCode =  '+softwareCode);
        return softwareByCode.get(softwareCode).Name;
    }


    public String getSoftwareNameFromCode(String softwareCode) {
        System.debug('--- getSoftwareNameFromCode ---');
        if (softwareByCode == null || softwareByCode.isEmpty()) { 
            populateSoftwareMaps(); 
        }
        return softwareByCode.get(softwareCode) != null ? softwareByCode.get(softwareCode).Name : '';
    }

    public String getSoftwareCodeFromName(String softwareName) {
        if (softwareName.indexOf('-') != -1) { softwareName = softwareName.split('-')[0]; }
        if (softwareByCode == null || softwareByCode.isEmpty()) { populateSoftwareMaps(); }
        return softwareCodeByName.get(softwareName);
    }

    public Boolean isOptionsAvailableForProduct(String softwareName) {
        if (softwareByCode == null || softwareByCode.isEmpty()) { populateSoftwareMaps(); }
        String softwareCode = softwareCodeByName.get(softwareName);
        return softwareCodeWithOptions.contains(softwareCode);
    }

    public Boolean isSimpleAccess(String softwareCode) {
        if (softwareByCode == null || softwareByCode.isEmpty()) { populateSoftwareMaps(); }
        return softwareByCode.get(softwareCode).AccessType__c == 'Simple';
    }

}