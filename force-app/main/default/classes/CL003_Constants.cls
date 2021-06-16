public with sharing class CL003_Constants {

    //Origins of the leads depending on the web service method called
    public static final String ORIGINE_DOWNLOAD = 'Download';    
    
    //The default company to set to the leads (Company field of the Lead object in SF is required but we don't have the information)
    public static final String DEFAULT_COMPANY = '-';
    
    //in order to troncate standard salesforce field
    public static final Integer MAX_LENGTH_FIRST_NAME = 40;
    public static final Integer MAX_LENGTH_LAST_NAME = 80;
	public static final Integer MAX_LENGTH_VATNUMBER = 30;
    
    // Php -> SF locales conversion
    public static final Map<String, String> phpLocaleToSFLocale = new Map<String, String>{
        'en' => 'US', 
        'ja' => 'JP'
    };

    // website user domain classification
    public static final Map<String, String> domainCodeToDomain = new Map<String, String> {
        'stu' => 'Etudiant', 
        'edu' => 'Enseignant/chercheur', 
        'cmp' => 'Professionnel'
    };    
    
    // prospect origins
    public static final Map<String, String> ORIGIN = new Map<String, String> {
        'SE'  => 'Moteur de recherche',
        'WAD' => 'Pub sur internet',
        'PAD' => 'Pub papier',
        'FC'  => 'Ami ou collègue',
        'CG'  => 'Conference',
        'AR'  => 'Article',
        'EM'  => 'Email',
        'OT'  => 'Autre'
    };

    // Backward compatibility
    //public static final String DEFAULT_SOFTWARE = 'Xlstat';
    public static final String DEFAULT_SOFTWARE = '00';
}