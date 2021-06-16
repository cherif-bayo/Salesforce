public class SolutionConverter{
    private static String PRODUCT_CODE_START = 'S_';
    
     private static Map<String, String> optionsSolutionsCodesByNames = new Map<String, String>{
        'XLSTAT-3DPlot' => '3DP',
        'XLSTAT-LatentClass'  => 'LG'
    };
    
    private static String[] ModulesLibelles = new String[]{
        'XLSTAT-Pro',
        'XLSTAT-3DPlot',
        'XLSTAT-MX',
        'XLSTAT-Time',
        'XLSTAT-PLS',
        'XLSTAT-Pivot',
        'XLSTAT-SPC',
        'XLSTAT-Dose',
        'XLSTAT-Life',
        'XLSTAT-PLSPM',
        'XLSTAT-ADA',
        'XLSTAT-Power',
        'XLSTAT-Education',
        'XLSTAT-DOE',
        'XLSTAT-Sim',
        'XLSTAT-Conjoint',
        'XLSTAT-CCR',
        'XLSTAT-Danone',
        'XLSTAT-LG',
        'XLSTAT-OMICS'
    };
    
    private Map<String, String> solutionsNamesByProducts;
    
    public SolutionConverter(){
        List<AggregateResult> solutions = [SELECT Name, ProductCode FROM Product2 WHERE Family = 'Solution' GROUP BY Name, ProductCode];
        this.solutionsNamesByProducts = new Map<String, String>();
        for(AggregateResult solution : solutions){
            String productCode = (String)(solution.get('ProductCode'));
            String[] productCodeSplitted = productCode.split('_');
            String productCodeName = productCodeSplitted[1];
            if(productCodeName == 'EDU'){
                productCodeName = 'BAS';
            }
            this.solutionsNamesByProducts.put((String)(solution.get('Name')), productCodeName);
        }
    }

    public List<String> FindFromProductsCodes(String productsStr){
        Map<String, List<String>> productsByLicense = new Map<String, List<String>>();
    
        String[] products = productsStr.split(',');
        String productCode;
        for(String product : products){
            String productTrimed = product.trim();
            if(solutionsNamesByProducts.containsKey(productTrimed)){
                productCode = this.solutionsNamesByProducts.get(productTrimed);
            }
        }            
        List<String> productsList = new List<String>{productCode};
        
        for(String product : products){
            String productTrimed = product.trim();
            if(optionsSolutionsCodesByNames.containsKey(productTrimed)){
                productsList.add(optionsSolutionsCodesByNames.get(productTrimed));
            }
        }     
        
        return productsList; 
    }
}