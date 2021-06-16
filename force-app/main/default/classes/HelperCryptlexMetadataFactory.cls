/**
 * Created by LBEA on 06/10/2020.
 */

public with sharing class HelperCryptlexMetadataFactory {


    public static HelperCryptlexMetaData getHelperCryptlexMetadata(Software__c software) {
        System.debug('>>>> HelperCryptlexMetadataFactory  - getHelperCryptlexMetadata - software = '+software);
        if (String.isNotBlank(software.AccessType__c)) {
            return software.AccessType__c == 'Simple' ? (HelperCryptlexMetaData) new HelperCryptlexMetadataSimpleAccess(software) : (HelperCryptlexMetaData) new HelperCryptlexMetadataXlstat();
        }
        return null;
    }
}