public class SCH001_SendEmailConfirmationStudent implements Schedulable {

	private Order order;	
	private List<FlexeraController.ResultGenerateKey> resultsFlexeraGeneratedKey;

	public SCH001_SendEmailConfirmationStudent(Order order, List<FlexeraController.ResultGenerateKey> resultsFlexeraGeneratedKey) {
		this.order = order;
		this.resultsFlexeraGeneratedKey = resultsFlexeraGeneratedKey;
	}

	public void execute(SchedulableContext ctx) {
		ApexPages.StandardController sc = new ApexPages.StandardController(order);
		SendEmailStuExtension ext = new SendEmailStuExtension(sc);
		String generatedKeys = '';
		for (FlexeraController.ResultGenerateKey resultFlexeraGeneratedKey : resultsFlexeraGeneratedKey) for (Flexera_Key__c flexeraKey : resultFlexeraGeneratedKey.GeneratedKeys) generatedKeys += flexeraKey.Name + ' ';
		ext.Free3DaysKey = generatedKeys;
		ext.SendEmail();
		if (!ext.Status) insert new WS_Error__c(WebserviceName__c = 'Email', Request__c = 'Echec de l\'envoi de l\'email STU/ACAD pour la commande : ' + Order.orderNumber);
	}
}