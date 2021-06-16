@isTest
public class TEST001_SOAP_SUPPORT {

	@isTest
	public static void main() {
		WS001_SOAP_Support.Ticket ticket = new WS001_SOAP_Support.Ticket();
		ticket.email = 'toto@titi.com';
		ticket.subject = 'sujet';
		ticket.message = 'message';
		String caseNumber = WS001_SOAP_Support.createTicket(ticket);

		WS001_SOAP_Support.Attachment attachment = new WS001_SOAP_Support.Attachment();
		attachment.filename = 'test.txt';
		attachment.mimetype = 'text/plain';
		attachment.content = 'aEcd';

		WS001_SOAP_Support.createAttachmentForTicket(attachment, caseNumber);
	}
}