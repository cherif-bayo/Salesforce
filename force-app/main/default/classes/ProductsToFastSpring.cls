public class ProductsToFastSpring{
            public class TextWithTranslations{
                public String en;
                public String es;
                public String ja;
                public String fr;
                public String de;
            }

            public class PriceWithCurrencies{
                public Decimal USD;
                public Decimal EUR;
                public Decimal JPY;
                public Decimal GBP;
            }

            public class Description{
                public TextWithTranslations summary;
        //public TextWithTranslations action;
                public TextWithTranslations full;                
            }

            public class QuantityDiscounts{
                public PriceWithCurrencies two = new PriceWithCurrencies();
                public PriceWithCurrencies three = new PriceWithCurrencies();
                public PriceWithCurrencies four = new PriceWithCurrencies();
                public PriceWithCurrencies five = new PriceWithCurrencies();
                public PriceWithCurrencies six = new PriceWithCurrencies();
                public PriceWithCurrencies seven = new PriceWithCurrencies();
                public PriceWithCurrencies eight = new PriceWithCurrencies();
                public PriceWithCurrencies nine = new PriceWithCurrencies();
                public PriceWithCurrencies ten = new PriceWithCurrencies();
                public PriceWithCurrencies eleven = new PriceWithCurrencies();
                public PriceWithCurrencies twelve = new PriceWithCurrencies();
                public PriceWithCurrencies thirteen = new PriceWithCurrencies();
                public PriceWithCurrencies fourteen = new PriceWithCurrencies();
                public PriceWithCurrencies fifteen = new PriceWithCurrencies();
                public PriceWithCurrencies sixteen = new PriceWithCurrencies();
                public PriceWithCurrencies seventeen = new PriceWithCurrencies();                                                                                      
                public PriceWithCurrencies eighteen = new PriceWithCurrencies();
                public PriceWithCurrencies nineteen = new PriceWithCurrencies();
                public PriceWithCurrencies twenty = new PriceWithCurrencies();
                public PriceWithCurrencies twentyOne = new PriceWithCurrencies();
                public PriceWithCurrencies twentyTwo = new PriceWithCurrencies();
                public PriceWithCurrencies twentyThree = new PriceWithCurrencies();
                public PriceWithCurrencies twentyFour = new PriceWithCurrencies();
                public PriceWithCurrencies twentyFive = new PriceWithCurrencies();
                public PriceWithCurrencies twentySix = new PriceWithCurrencies();
                public PriceWithCurrencies twentySeven = new PriceWithCurrencies();
                public PriceWithCurrencies twentyEight = new PriceWithCurrencies();
                public PriceWithCurrencies twentyNine = new PriceWithCurrencies();
                public PriceWithCurrencies thirty = new PriceWithCurrencies();                                                                
            }

        /*public class Fulfillment{
        public TextWithTranslations instructions;
    }*/
    
    public class Pricing{
        public String renew;
        public String interval;
        public Integer intervalLength;
        public String quantityBehavior;
        public Integer quantityDefault;
        public PriceWithCurrencies price;
        public QuantityDiscounts quantityDiscounts;
        //public Integer discountDuration;
    }
    
    public class Item{
        public String product;
        public TextWithTranslations display;
        public Description description;
        //public Fulfillment fulfillment;
        //public String image;
        //public String format;
        public Pricing pricing;
    }
    
    public class Items{
        public List<Item> items = new List<Item>();
    }
    
    private static String NEW_SOLUTIONS_CODE_PRODUCT_START = 'S_';
    
    /* DEV ID's */
    /*private static String PRICEBOOK_EUR_ID = '01s2400000248WS';
    private static String PRICEBOOK_USD_ID = '01s2400000335Su';
    private static String PRICEBOOK_GBP_ID = '01s2400000335Sz';
    private static String PRICEBOOK_JPY_ID = '01s2400000335Sp';   */
    
    /* PROD ID's */
    private static String PRICEBOOK_EUR_ID = '01s2400000248WS';
    private static String PRICEBOOK_USD_ID = '01s2400000335Su';
    private static String PRICEBOOK_GBP_ID = '01s2400000335Sz';
    private static String PRICEBOOK_JPY_ID = '01s2400000335Sp';     
    
    public String FastSpringJSON {get; set;}      
    
    public void Export(String domaine){
        String searchQueryProductCode = NEW_SOLUTIONS_CODE_PRODUCT_START + '%';
        Product2[] products = [SELECT Id, ProductCode, Name, Description_courte_us__c, Description_courte_es__c, Description_courte_jp__c, Description_courte_de__c, Description_courte_fr__c, Description_longue_us__c, Description_longue_fr__c, Description_longue_es__c, Description_longue_de__c, Description_longue_jp__c, Automatic_renewal__c FROM Product2 WHERE ProductCode LIKE :searchQueryProductCode];
        Map<Id, Product2> productsByIds = new Map<Id, Product2>(products);

        /*AyPrice__DiscountDetail__c[] discountDetails = [SELECT AyPrice__Row_Counter__c, AyPrice__Price_Book_Id__c, Price_After_Discount__c, AyPrice__Product_Id__c FROM AyPrice__DiscountDetail__c WHERE AyPrice__Product_Id__c IN :productsByIds.keySet() ORDER BY AyPrice__Price_Book_Id__c, AyPrice__Product_Id__c, AyPrice__Row_Counter__c];
        Map<Id, Map<Id, List<AyPrice__DiscountDetail__c>>> discountDetailsByProductId = new Map<Id, Map<Id, List<AyPrice__DiscountDetail__c>>>();
        for(AyPrice__DiscountDetail__c discountDetail : discountDetails){
            if(discountDetailsByProductId.get(discountDetail.AyPrice__Product_Id__c) == null){
                Map<Id, List<AyPrice__DiscountDetail__c>> discountDetailsByPricebookId = new Map<Id, List<AyPrice__DiscountDetail__c>>();
                discountDetailsByPricebookId.put(discountDetail.AyPrice__Price_Book_Id__c, new List<AyPrice__DiscountDetail__c>{discountDetail});
                discountDetailsByProductId.put(discountDetail.AyPrice__Product_Id__c, discountDetailsByPricebookId);
            }else{
                Map<Id, List<AyPrice__DiscountDetail__c>> discountDetailsByPricebookId = discountDetailsByProductId.get(discountDetail.AyPrice__Product_Id__c);
                if(discountDetailsByPricebookId.get(discountDetail.AyPrice__Price_Book_Id__c) == null){
                    discountDetailsByPricebookId.put(discountDetail.AyPrice__Price_Book_Id__c, new List<AyPrice__DiscountDetail__c>{discountDetail});
                }else{
                    discountDetailsByPricebookId.get(discountDetail.AyPrice__Price_Book_Id__c).add(discountDetail);
                }
            }
        }*/
        
        PricebookEntry[] pes = [SELECT UnitPrice, Product2.Id, Pricebook2.Id, CurrencyIsoCode FROM PricebookEntry WHERE Product2.Id in :productsByIds.keySet() AND (Pricebook2.Id = :PRICEBOOK_EUR_ID OR Pricebook2.Id = :PRICEBOOK_USD_ID OR Pricebook2.Id = :PRICEBOOK_GBP_ID OR Pricebook2.Id = :PRICEBOOK_JPY_ID)];
        Map<Id, List<PricebookEntry>> peByProductId = new Map<Id, List<PricebookEntry>>();
        for(PricebookEntry pe : pes){
            if(peByProductId.get(pe.Product2.Id) == null){
                peByProductId.put(pe.Product2.Id, new List<PricebookEntry>{pe});
            }else{
                peByProductId.get(pe.Product2.Id).add(pe);
            }
        }        

        Items items = new Items();
        for(Product2 product : products){
            /*Map<Id, List<AyPrice__DiscountDetail__c>> dd = discountDetailsByProductId.get(product.Id);
            if(dd == null){*/
                /*AyPrice__DiscountDetail__c[] discountDetailsEUR = dd.get(PRICEBOOK_EUR_ID);
                AyPrice__DiscountDetail__c[] discountDetailsUSD = dd.get(PRICEBOOK_USD_ID);
                AyPrice__DiscountDetail__c[] discountDetailsGBP = dd.get(PRICEBOOK_GBP_ID);
                AyPrice__DiscountDetail__c[] discountDetailsJPY = dd.get(PRICEBOOK_JPY_ID);*/     

                Item item = new Item();
                String productCode = product.ProductCode;
                item.product = productCode.replace('_', '-');
                item.display = new TextWithTranslations();
                item.display.en = product.Name;
                item.display.es = product.Name;
                item.display.ja = product.Name;
                item.display.de = product.Name;
                item.display.fr = product.Name;
                item.description = new Description();
                item.description.summary = new TextWithTranslations();
                item.description.summary.en = product.Description_courte_us__c;
                item.description.summary.es = product.Description_courte_es__c;
                item.description.summary.ja = product.Description_courte_jp__c;
                item.description.summary.de = product.Description_courte_de__c;
                item.description.summary.fr = product.Description_courte_fr__c;  
                item.description.full = new TextWithTranslations();
                item.description.full.en = product.Description_longue_us__c;
                item.description.full.es = product.Description_longue_es__c;
                item.description.full.ja = product.Description_longue_jp__c;
                item.description.full.de = product.Description_longue_de__c;
                item.description.full.fr = product.Description_longue_fr__c;  
                item.pricing = new Pricing();
                if(product.Automatic_renewal__c){
                    item.pricing.renew = 'auto';      
                    item.pricing.interval = 'year';
                    item.pricing.intervalLength = 1;
                }                                   
                item.pricing.quantityBehavior = 'allow';
                item.pricing.quantityDefault = 0;
                item.pricing.price = new PriceWithCurrencies();
                List<PricebookEntry> pesProduct = peByProductId.get(product.Id);
                if(pesProduct != null){
                    for(PricebookEntry pe : pesProduct){
                        if(pe.CurrencyIsoCode == 'USD'){
                            item.pricing.price.USD = pe.UnitPrice;
                        }else if(pe.CurrencyIsoCode == 'EUR'){
                            item.pricing.price.EUR = pe.UnitPrice;
                        }else if(pe.CurrencyIsoCode == 'GBP'){
                            item.pricing.price.GBP = pe.UnitPrice;
                        }else if(pe.CurrencyIsoCode == 'JPY'){
                            item.pricing.price.JPY = pe.UnitPrice;
                        }
                    }
                }
                /*if(discountDetailsUSD != null){
                    item.pricing.price.USD = discountDetailsUSD[0].Price_After_Discount__c;
                }
                if(discountDetailsEUR != null){
                    item.pricing.price.EUR = discountDetailsEUR[0].Price_After_Discount__c;
                }
                if(discountDetailsGBP != null){
                    item.pricing.price.GBP = discountDetailsGBP[0].Price_After_Discount__c;
                }
                if(discountDetailsJPY != null){
                    item.pricing.price.JPY = discountDetailsJPY[0].Price_After_Discount__c;
                }*/

                /*item.pricing.quantityDiscounts = new QuantityDiscounts();
                if(discountDetailsUSD != null){
                    if(1 < discountDetailsUSD.size()){
                        item.pricing.quantityDiscounts.two.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[1].Price_After_Discount__c;
                        if(2 < discountDetailsUSD.size()){
                            item.pricing.quantityDiscounts.three.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[2].Price_After_Discount__c;
                            if(3 < discountDetailsUSD.size()){
                                item.pricing.quantityDiscounts.four.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[3].Price_After_Discount__c;
                                if(4 < discountDetailsUSD.size()){
                                    item.pricing.quantityDiscounts.five.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[4].Price_After_Discount__c;
                                    if(5 < discountDetailsUSD.size()){
                                        item.pricing.quantityDiscounts.six.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[5].Price_After_Discount__c;
                                        if(6 < discountDetailsUSD.size()){
                                            item.pricing.quantityDiscounts.seven.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[6].Price_After_Discount__c;
                                            if(7 < discountDetailsUSD.size()){
                                                item.pricing.quantityDiscounts.eight.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[7].Price_After_Discount__c;
                                                if(8 < discountDetailsUSD.size()){
                                                    item.pricing.quantityDiscounts.nine.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[8].Price_After_Discount__c;
                                                    if(9 < discountDetailsUSD.size()){
                                                        item.pricing.quantityDiscounts.ten.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[9].Price_After_Discount__c;
                                                        if(10 < discountDetailsUSD.size()){
                                                            item.pricing.quantityDiscounts.eleven.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[10].Price_After_Discount__c;
                                                            if(11 < discountDetailsUSD.size()){
                                                                item.pricing.quantityDiscounts.twelve.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[11].Price_After_Discount__c;
                                                                if(12 < discountDetailsUSD.size()){
                                                                    item.pricing.quantityDiscounts.thirteen.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[12].Price_After_Discount__c;
                                                                    if(13 < discountDetailsUSD.size()){
                                                                        item.pricing.quantityDiscounts.fourteen.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[13].Price_After_Discount__c;
                                                                        if(14 < discountDetailsUSD.size()){
                                                                            item.pricing.quantityDiscounts.fifteen.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[14].Price_After_Discount__c;
                                                                            if(15 < discountDetailsUSD.size()){
                                                                                item.pricing.quantityDiscounts.sixteen.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[15].Price_After_Discount__c;
                                                                                if(16 < discountDetailsUSD.size()){
                                                                                    item.pricing.quantityDiscounts.seventeen.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[16].Price_After_Discount__c;                                                                                                               
                                                                                    if(17 < discountDetailsUSD.size()){
                                                                                        item.pricing.quantityDiscounts.eighteen.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[17].Price_After_Discount__c;
                                                                                        if(18 < discountDetailsUSD.size()){
                                                                                            item.pricing.quantityDiscounts.nineteen.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[18].Price_After_Discount__c;
                                                                                            if(19 < discountDetailsUSD.size()){
                                                                                                item.pricing.quantityDiscounts.twenty.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[19].Price_After_Discount__c;
                                                                                                if(20 < discountDetailsUSD.size()){
                                                                                                    item.pricing.quantityDiscounts.twentyOne.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[20].Price_After_Discount__c;
                                                                                                    if(21 < discountDetailsUSD.size()){
                                                                                                        item.pricing.quantityDiscounts.twentyTwo.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[21].Price_After_Discount__c;
                                                                                                        if(22 < discountDetailsUSD.size()){
                                                                                                            item.pricing.quantityDiscounts.twentyThree.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[22].Price_After_Discount__c;
                                                                                                            if(23 < discountDetailsUSD.size()){
                                                                                                                item.pricing.quantityDiscounts.twentyFour.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[23].Price_After_Discount__c;
                                                                                                                if(24 < discountDetailsUSD.size()){
                                                                                                                    item.pricing.quantityDiscounts.twentyFive.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[24].Price_After_Discount__c;
                                                                                                                    if(25 < discountDetailsUSD.size()){
                                                                                                                        item.pricing.quantityDiscounts.twentySix.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[25].Price_After_Discount__c;
                                                                                                                        if(26 < discountDetailsUSD.size()){
                                                                                                                            item.pricing.quantityDiscounts.twentySeven.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[26].Price_After_Discount__c;
                                                                                                                            if(27 < discountDetailsUSD.size()){
                                                                                                                                item.pricing.quantityDiscounts.twentyEight.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[27].Price_After_Discount__c;
                                                                                                                                if(28 < discountDetailsUSD.size()){
                                                                                                                                    item.pricing.quantityDiscounts.twentyNine.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[28].Price_After_Discount__c;
                                                                                                                                    if(29 < discountDetailsUSD.size()){
                                                                                                                                        item.pricing.quantityDiscounts.thirty.USD = discountDetailsUSD[0].Price_After_Discount__c - discountDetailsUSD[29].Price_After_Discount__c;
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(discountDetailsEUR != null){
                    if(1 < discountDetailsEUR.size()){
                        item.pricing.quantityDiscounts.two.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[1].Price_After_Discount__c;
                        if(2 < discountDetailsEUR.size()){
                            item.pricing.quantityDiscounts.three.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[2].Price_After_Discount__c;
                            if(3 < discountDetailsEUR.size()){
                                item.pricing.quantityDiscounts.four.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[3].Price_After_Discount__c;
                                if(4 < discountDetailsEUR.size()){
                                    item.pricing.quantityDiscounts.five.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[4].Price_After_Discount__c;
                                    if(5 < discountDetailsEUR.size()){
                                        item.pricing.quantityDiscounts.six.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[5].Price_After_Discount__c;
                                        if(6 < discountDetailsEUR.size()){
                                            item.pricing.quantityDiscounts.seven.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[6].Price_After_Discount__c;
                                            if(7 < discountDetailsEUR.size()){
                                                item.pricing.quantityDiscounts.eight.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[7].Price_After_Discount__c;
                                                if(8 < discountDetailsEUR.size()){
                                                    item.pricing.quantityDiscounts.nine.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[8].Price_After_Discount__c;
                                                    if(9 < discountDetailsEUR.size()){
                                                        item.pricing.quantityDiscounts.ten.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[9].Price_After_Discount__c;
                                                        if(10 < discountDetailsEUR.size()){
                                                            item.pricing.quantityDiscounts.eleven.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[10].Price_After_Discount__c;
                                                            if(11 < discountDetailsEUR.size()){
                                                                item.pricing.quantityDiscounts.twelve.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[11].Price_After_Discount__c;
                                                                if(12 < discountDetailsEUR.size()){
                                                                    item.pricing.quantityDiscounts.thirteen.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[12].Price_After_Discount__c;
                                                                    if(13 < discountDetailsEUR.size()){
                                                                        item.pricing.quantityDiscounts.fourteen.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[13].Price_After_Discount__c;
                                                                        if(14 < discountDetailsEUR.size()){
                                                                            item.pricing.quantityDiscounts.fifteen.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[14].Price_After_Discount__c;
                                                                            if(15 < discountDetailsEUR.size()){
                                                                                item.pricing.quantityDiscounts.sixteen.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[15].Price_After_Discount__c;
                                                                                if(16 < discountDetailsEUR.size()){
                                                                                    item.pricing.quantityDiscounts.seventeen.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[16].Price_After_Discount__c;                                                                                                               
                                                                                    if(17 < discountDetailsEUR.size()){
                                                                                        item.pricing.quantityDiscounts.eighteen.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[17].Price_After_Discount__c;
                                                                                        if(18 < discountDetailsEUR.size()){
                                                                                            item.pricing.quantityDiscounts.nineteen.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[18].Price_After_Discount__c;
                                                                                            if(19 < discountDetailsEUR.size()){
                                                                                                item.pricing.quantityDiscounts.twenty.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[19].Price_After_Discount__c;
                                                                                                if(20 < discountDetailsEUR.size()){
                                                                                                    item.pricing.quantityDiscounts.twentyOne.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[20].Price_After_Discount__c;
                                                                                                    if(21 < discountDetailsEUR.size()){
                                                                                                        item.pricing.quantityDiscounts.twentyTwo.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[21].Price_After_Discount__c;
                                                                                                        if(22 < discountDetailsEUR.size()){
                                                                                                            item.pricing.quantityDiscounts.twentyThree.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[22].Price_After_Discount__c;
                                                                                                            if(23 < discountDetailsEUR.size()){
                                                                                                                item.pricing.quantityDiscounts.twentyFour.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[23].Price_After_Discount__c;
                                                                                                                if(24 < discountDetailsEUR.size()){
                                                                                                                    item.pricing.quantityDiscounts.twentyFive.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[24].Price_After_Discount__c;
                                                                                                                    if(25 < discountDetailsEUR.size()){
                                                                                                                        item.pricing.quantityDiscounts.twentySix.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[25].Price_After_Discount__c;
                                                                                                                        if(26 < discountDetailsEUR.size()){
                                                                                                                            item.pricing.quantityDiscounts.twentySeven.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[26].Price_After_Discount__c;
                                                                                                                            if(27 < discountDetailsEUR.size()){
                                                                                                                                item.pricing.quantityDiscounts.twentyEight.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[27].Price_After_Discount__c;
                                                                                                                                if(28 < discountDetailsEUR.size()){
                                                                                                                                    item.pricing.quantityDiscounts.twentyNine.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[28].Price_After_Discount__c;
                                                                                                                                    if(29 < discountDetailsEUR.size()){
                                                                                                                                        item.pricing.quantityDiscounts.thirty.EUR = discountDetailsEUR[0].Price_After_Discount__c - discountDetailsEUR[29].Price_After_Discount__c;
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(discountDetailsGBP != null){
                    if(1 < discountDetailsGBP.size()){
                        item.pricing.quantityDiscounts.two.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[1].Price_After_Discount__c;
                        if(2 < discountDetailsGBP.size()){
                            item.pricing.quantityDiscounts.three.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[2].Price_After_Discount__c;
                            if(3 < discountDetailsGBP.size()){
                                item.pricing.quantityDiscounts.four.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[3].Price_After_Discount__c;
                                if(4 < discountDetailsGBP.size()){
                                    item.pricing.quantityDiscounts.five.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[4].Price_After_Discount__c;
                                    if(5 < discountDetailsGBP.size()){
                                        item.pricing.quantityDiscounts.six.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[5].Price_After_Discount__c;
                                        if(6 < discountDetailsGBP.size()){
                                            item.pricing.quantityDiscounts.seven.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[6].Price_After_Discount__c;
                                            if(7 < discountDetailsGBP.size()){
                                                item.pricing.quantityDiscounts.eight.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[7].Price_After_Discount__c;
                                                if(8 < discountDetailsGBP.size()){
                                                    item.pricing.quantityDiscounts.nine.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[8].Price_After_Discount__c;
                                                    if(9 < discountDetailsGBP.size()){
                                                        item.pricing.quantityDiscounts.ten.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[9].Price_After_Discount__c;
                                                        if(10 < discountDetailsGBP.size()){
                                                            item.pricing.quantityDiscounts.eleven.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[10].Price_After_Discount__c;
                                                            if(11 < discountDetailsGBP.size()){
                                                                item.pricing.quantityDiscounts.twelve.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[11].Price_After_Discount__c;
                                                                if(12 < discountDetailsGBP.size()){
                                                                    item.pricing.quantityDiscounts.thirteen.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[12].Price_After_Discount__c;
                                                                    if(13 < discountDetailsGBP.size()){
                                                                        item.pricing.quantityDiscounts.fourteen.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[13].Price_After_Discount__c;
                                                                        if(14 < discountDetailsGBP.size()){
                                                                            item.pricing.quantityDiscounts.fifteen.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[14].Price_After_Discount__c;
                                                                            if(15 < discountDetailsGBP.size()){
                                                                                item.pricing.quantityDiscounts.sixteen.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[15].Price_After_Discount__c;
                                                                                if(16 < discountDetailsGBP.size()){
                                                                                    item.pricing.quantityDiscounts.seventeen.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[16].Price_After_Discount__c;                                                                                                               
                                                                                    if(17 < discountDetailsGBP.size()){
                                                                                        item.pricing.quantityDiscounts.eighteen.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[17].Price_After_Discount__c;
                                                                                        if(18 < discountDetailsGBP.size()){
                                                                                            item.pricing.quantityDiscounts.nineteen.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[18].Price_After_Discount__c;
                                                                                            if(19 < discountDetailsGBP.size()){
                                                                                                item.pricing.quantityDiscounts.twenty.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[19].Price_After_Discount__c;
                                                                                                if(20 < discountDetailsGBP.size()){
                                                                                                    item.pricing.quantityDiscounts.twentyOne.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[20].Price_After_Discount__c;
                                                                                                    if(21 < discountDetailsGBP.size()){
                                                                                                        item.pricing.quantityDiscounts.twentyTwo.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[21].Price_After_Discount__c;
                                                                                                        if(22 < discountDetailsGBP.size()){
                                                                                                            item.pricing.quantityDiscounts.twentyThree.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[22].Price_After_Discount__c;
                                                                                                            if(23 < discountDetailsGBP.size()){
                                                                                                                item.pricing.quantityDiscounts.twentyFour.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[23].Price_After_Discount__c;
                                                                                                                if(24 < discountDetailsGBP.size()){
                                                                                                                    item.pricing.quantityDiscounts.twentyFive.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[24].Price_After_Discount__c;
                                                                                                                    if(25 < discountDetailsGBP.size()){
                                                                                                                        item.pricing.quantityDiscounts.twentySix.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[25].Price_After_Discount__c;
                                                                                                                        if(26 < discountDetailsGBP.size()){
                                                                                                                            item.pricing.quantityDiscounts.twentySeven.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[26].Price_After_Discount__c;
                                                                                                                            if(27 < discountDetailsGBP.size()){
                                                                                                                                item.pricing.quantityDiscounts.twentyEight.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[27].Price_After_Discount__c;
                                                                                                                                if(28 < discountDetailsGBP.size()){
                                                                                                                                    item.pricing.quantityDiscounts.twentyNine.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[28].Price_After_Discount__c;
                                                                                                                                    if(29 < discountDetailsGBP.size()){
                                                                                                                                        item.pricing.quantityDiscounts.thirty.GBP = discountDetailsGBP[0].Price_After_Discount__c - discountDetailsGBP[29].Price_After_Discount__c;
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(discountDetailsJPY != null){
                    if(1 < discountDetailsJPY.size()){
                        item.pricing.quantityDiscounts.two.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[1].Price_After_Discount__c;
                        if(2 < discountDetailsJPY.size()){
                            item.pricing.quantityDiscounts.three.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[2].Price_After_Discount__c;
                            if(3 < discountDetailsJPY.size()){
                                item.pricing.quantityDiscounts.four.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[3].Price_After_Discount__c;
                                if(4 < discountDetailsJPY.size()){
                                    item.pricing.quantityDiscounts.five.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[4].Price_After_Discount__c;
                                    if(5 < discountDetailsJPY.size()){
                                        item.pricing.quantityDiscounts.six.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[5].Price_After_Discount__c;
                                        if(6 < discountDetailsJPY.size()){
                                            item.pricing.quantityDiscounts.seven.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[6].Price_After_Discount__c;
                                            if(7 < discountDetailsJPY.size()){
                                                item.pricing.quantityDiscounts.eight.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[7].Price_After_Discount__c;
                                                if(8 < discountDetailsJPY.size()){
                                                    item.pricing.quantityDiscounts.nine.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[8].Price_After_Discount__c;
                                                    if(9 < discountDetailsJPY.size()){
                                                        item.pricing.quantityDiscounts.ten.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[9].Price_After_Discount__c;
                                                        if(10 < discountDetailsJPY.size()){
                                                            item.pricing.quantityDiscounts.eleven.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[10].Price_After_Discount__c;
                                                            if(11 < discountDetailsJPY.size()){
                                                                item.pricing.quantityDiscounts.twelve.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[11].Price_After_Discount__c;
                                                                if(12 < discountDetailsJPY.size()){
                                                                    item.pricing.quantityDiscounts.thirteen.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[12].Price_After_Discount__c;
                                                                    if(13 < discountDetailsJPY.size()){
                                                                        item.pricing.quantityDiscounts.fourteen.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[13].Price_After_Discount__c;
                                                                        if(14 < discountDetailsJPY.size()){
                                                                            item.pricing.quantityDiscounts.fifteen.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[14].Price_After_Discount__c;
                                                                            if(15 < discountDetailsJPY.size()){
                                                                                item.pricing.quantityDiscounts.sixteen.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[15].Price_After_Discount__c;
                                                                                if(16 < discountDetailsJPY.size()){
                                                                                    item.pricing.quantityDiscounts.seventeen.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[16].Price_After_Discount__c;                                                                                                               
                                                                                    if(17 < discountDetailsJPY.size()){
                                                                                        item.pricing.quantityDiscounts.eighteen.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[17].Price_After_Discount__c;
                                                                                        if(18 < discountDetailsJPY.size()){
                                                                                            item.pricing.quantityDiscounts.nineteen.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[18].Price_After_Discount__c;
                                                                                            if(19 < discountDetailsJPY.size()){
                                                                                                item.pricing.quantityDiscounts.twenty.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[19].Price_After_Discount__c;
                                                                                                if(20 < discountDetailsJPY.size()){
                                                                                                    item.pricing.quantityDiscounts.twentyOne.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[20].Price_After_Discount__c;
                                                                                                    if(21 < discountDetailsJPY.size()){
                                                                                                        item.pricing.quantityDiscounts.twentyTwo.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[21].Price_After_Discount__c;
                                                                                                        if(22 < discountDetailsJPY.size()){
                                                                                                            item.pricing.quantityDiscounts.twentyThree.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[22].Price_After_Discount__c;
                                                                                                            if(23 < discountDetailsJPY.size()){
                                                                                                                item.pricing.quantityDiscounts.twentyFour.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[23].Price_After_Discount__c;
                                                                                                                if(24 < discountDetailsJPY.size()){
                                                                                                                    item.pricing.quantityDiscounts.twentyFive.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[24].Price_After_Discount__c;
                                                                                                                    if(25 < discountDetailsJPY.size()){
                                                                                                                        item.pricing.quantityDiscounts.twentySix.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[25].Price_After_Discount__c;
                                                                                                                        if(26 < discountDetailsJPY.size()){
                                                                                                                            item.pricing.quantityDiscounts.twentySeven.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[26].Price_After_Discount__c;
                                                                                                                            if(27 < discountDetailsJPY.size()){
                                                                                                                                item.pricing.quantityDiscounts.twentyEight.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[27].Price_After_Discount__c;
                                                                                                                                if(28 < discountDetailsJPY.size()){
                                                                                                                                    item.pricing.quantityDiscounts.twentyNine.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[28].Price_After_Discount__c;
                                                                                                                                    if(29 < discountDetailsJPY.size()){
                                                                                                                                        item.pricing.quantityDiscounts.thirty.JPY = discountDetailsJPY[0].Price_After_Discount__c - discountDetailsJPY[29].Price_After_Discount__c;
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }*/
                
                String[] productCodeSplited = productCode.split('_');
                if(productCodeSplited.size() > 2){
                    if(productCodeSplited[2] == 'CMP' && domaine == 'CMP'){
                        items.items.add(item);
                    }else if(productCodeSplited[2] == 'EDU' && domaine == 'EDU'){
                        items.items.add(item);
                    }else if(productCodeSplited[2] == 'STU' && domaine == 'STU'){
                        items.items.add(item);
                    }else if(productCodeSplited[2] == 'CAM' && domaine == 'CAM'){
                        items.items.add(item);
                    }
                }
            }

            FastSpringJSON = JSON.serializePretty(items);
        //}
    }
    
    public void ExportEDU(){
        this.Export('EDU');
    }
    public void ExportCMP(){
        this.Export('CMP');
    }
    public void ExportSTU(){
        this.Export('STU');
    }
    public void ExportCAM(){
        this.Export('CAM');
    }
}