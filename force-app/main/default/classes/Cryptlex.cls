public class Cryptlex {

	public static Integer DOMAIN_NULL = 0;
	public static Integer DOMAIN_COMPANY = 1;
	public static Integer DOMAIN_ACADEMIC = 2;
	public static Integer DOMAIN_STUDENT = 3;
	public static Integer DOMAIN_CLASSROOM = 4;
	public static Integer DOMAIN_SMALL_CAMPUS = 5;
	public static Integer DOMAIN_LARGE_CAMPUS = 6;
	public static Integer DOMAIN_EDITOR = 7;
	public static Integer DOMAIN_NALPEIRON = 8;
	public static Integer DOMAIN_TRIAL = 9;

	public static Map<Integer, String> domainByCode = new Map<Integer, String> {
		0 => 'Non Applicable',
		1 => 'Company',
		2 => 'Academic',
		3 => 'Student',
		4 => 'Campus Classroom',
		5 => 'Campus Small Campus',
		6 => 'Campus Large Campus',
		7 => 'Editeur',
		8 => 'Nalpeiron',
		9 => 'Trial'
	};

	public static Integer SOLUTION_NULL = 0;
	public static Integer SOLUTION_BASIC = 1;
	public static Integer SOLUTION_PREMIUM = 2;
	public static Integer SOLUTION_SENSORY = 3;
	public static Integer SOLUTION_MARKETING = 4;
	public static Integer SOLUTION_FORECAST = 5;
	public static Integer SOLUTION_BIOMED = 6;
	public static Integer SOLUTION_ECOLOGY = 7;
	public static Integer SOLUTION_PSY = 8;
	public static Integer SOLUTION_QUALITY = 9;
	public static Integer SOLUTION_EDITOR = 10;
	public static Integer SOLUTION_BASIC_PLUS = 11;
	public static Integer SOLUTION_DANONE = 12;
	public static Integer SOLUTION_LEGACY = 13;

	public static Integer LICENSE_TYPE_NULL = 0;
	public static Integer LICENSE_TYPE_TRIAL = 1;
	public static Integer LICENSE_TYPE_FREE = 2;
	public static Integer LICENSE_TYPE_EXPIRING = 3;
	public static Integer LICENSE_TYPE_PERPETUAL = 4;
	public static Integer LICENSE_TYPE_NETWORK = 5;

	public static Integer OPTION_NULL = 0;
	public static Integer OPTION_3DPLOT = 1;
	public static Integer OPTION_LG = 2;
	public static Integer OPTION_3DPLOT_LG = 3;
	public static Integer OPTION_CCR = 4;
	public static Integer OPTION_CCR_3DPLOT = 5;
	public static Integer OPTION_CCR_LG = 6;
	public static Integer OPTION_CCR_3DPLOT_LG = 7;

	public static Integer SCOPE_USER = 0;
	public static Integer SCOPE_STATION = 1;

	public enum ACCESS { LIFESCIENCE, MARKETING2, BASICPLUS, BASIC, QUALITY, PSY, ECOLOGY, BIOMED, FORECAST, MARKETING, SENSORY, PREMIUM, BASE, OMICS, LG, DANONE, CCR, CONJOINT, SIM, DOE, EDITOR, POWER, ADA, PLSPM, LIFE, DOSE, SPC, PIVOT, PLS, XLSTATTIME, MX, DPLOT, PRO }
	public enum ACCESSINVERSE { PRO, DPLOT, MX, XLSTATTIME, PLS, PIVOT, SPC, DOSE, LIFE, PLSPM, ADA, POWER, EDITOR, DOE, SIM, CONJOINT, CCR, DANONE, LG, OMICS, BASE, PREMIUM, SENSORY, MARKETING, FORECAST, BIOMED, ECOLOGY, PSY, QUALITY, BASIC, BASICPLUS, MARKETING2, LIFESCIENCE }

	// APEX can't use - or 1-9 in enum so we use a map to translate product's name
	public static Map<String, String> accessEnumTextFromProductName = new Map<String, String> {
		'XLSTAT-Base'			=> 'BASE',
		'XLSTAT-Biomed'			=> 'BIOMED',
		'XLSTAT-Ecology'		=> 'ECOLOGY',
		'XLSTAT-Forecast'		=> 'FORECAST',
		'XLSTAT-Marketing'		=> 'MARKETING',
		'XLSTAT-Premium'		=> 'PREMIUM',
		'XLSTAT-Psy'			=> 'PSY',
		'XLSTAT-Quality'		=> 'QUALITY',
		'XLSTAT-Sensory'		=> 'SENSORY',
		'XLSTAT-Education'		=> 'EDITOR',
		'XLSTAT-3DPlot'			=> 'DPLOT',
		'XLSTAT-LatentClass'	=> 'LG',
		'XLSTAT-CCR'			=> 'CCR',
		'XLSTAT-Basic'			=> 'BASIC',
		'XLSTAT-Basic+'			=> 'BASICPLUS',
		'XLSTAT-Marketing_2'	=> 'MARKETING2',
		'XLSTAT-LifeScience'	=> 'LIFESCIENCE'
	};

	public static Map<String, String> productNameFromAccessEnumText = new Map<String, String> {
		'BASE'			=> 'XLSTAT-Base',
		'BIOMED'		=> 'XLSTAT-Biomed',
		'ECOLOGY'		=> 'XLSTAT-Ecology',
		'FORECAST'		=> 'XLSTAT-Forecast',
		'MARKETING'		=> 'XLSTAT-Marketing',
		'PREMIUM'		=> 'XLSTAT-Premium',
		'PSY'			=> 'XLSTAT-Psy',
		'QUALITY'		=> 'XLSTAT-Quality',
		'SENSORY'		=> 'XLSTAT-Sensory',
		'EDITOR'		=> 'XLSTAT-Education',
		'DPLOT'			=> 'XLSTAT-3DPlot',
		'LG'			=> 'XLSTAT-LatentClass',
		'CCR'			=> 'XLSTAT-CCR',
		'BASIC'			=> 'XLSTAT-Basic', 
		'BASICPLUS'		=> 'XLSTAT-Basic+', 
		'MARKETING2'	=> 'XLSTAT-Marketing_2',
		'LIFESCIENCE'	=> 'XLSTAT-LifeScience'
	};

}