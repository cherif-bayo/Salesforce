trigger updateLeadNbTelechargement on Telechargement__c (after insert) {

    List<String> leadsIds = new List<String>();
    List<String> contactsIds = new List<String>();
    Map<String, String> telechargementOSByContactId = new Map<String, String>();
    for(Telechargement__c telechargement : Trigger.new){
        if(telechargement.Lead__c != null){
            leadsIds.add(telechargement.Lead__c);
        }
        if(telechargement.Contact__c != null){
            contactsIds.add(telechargement.Contact__c);
            telechargementOSByContactId.put(telechargement.Contact__c, telechargement.Systeme__c);
        }
    }
    
    Lead[] leads = [SELECT Nombre_de_telechargements__c FROM Lead WHERE Id in :leadsIds];
    for(Lead lead : leads){
        if(lead.Nombre_de_telechargements__c == null){
            lead.Nombre_de_telechargements__c = 0;
        }
        lead.Nombre_de_telechargements__c = lead.Nombre_de_telechargements__c + 1;
    }
    update leads;
    
    Contact[] contacts = [SELECT Id, Piste_nombre_de_t_l_chargements__c, Systeme_d_exploitation__c FROM Contact WHERE Id in :contactsIds];
    for(Contact contact : contacts){
        if(contact.Piste_nombre_de_t_l_chargements__c  == null){
            contact.Piste_nombre_de_t_l_chargements__c  = 0;
        }
        contact.Piste_nombre_de_t_l_chargements__c  = contact.Piste_nombre_de_t_l_chargements__c + 1;
        contact.Systeme_d_exploitation__c = telechargementOSByContactId.get(contact.Id);
    }
    update contacts;
}