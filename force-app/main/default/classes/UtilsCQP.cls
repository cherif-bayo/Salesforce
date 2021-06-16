public class UtilsCQP {
	private static Pricebook2 stdPriceBook; // Singleton, remember when first referenced

	//  ------------------------------------------------------
	//  getStdPricebookId : as of V31, testmethods can locate std pricebook wo seeAlldata=true
	//  ------------------------------------------------------
	public static String getStdPricebookId() {
		if (Test.isRunningTest()) return Test.getStandardPricebookId();
		return getStdPricebook().id;
	}

	//  -------------------------------------------------------
	//  getStdPriceBook: Singleton
	//  -------------------------------------------------------
	public static Pricebook2 getStdPriceBook() {
		if (stdPriceBook == null) {
			List<Pricebook2> stdPriceBooks = [select id, name from Pricebook2 where isStandard = true];
			if (stdPriceBooks.size() > 0) stdPriceBook = stdPriceBooks[0];
		}
		return stdPriceBook;
	}
}