trigger removeEmailAuto on EmailMessage (after insert)  { 

    List<EmailMessage> emDelList = new List<EmailMessage> ();
    if (Trigger.new.size() > 0) {
        for (EmailMessage em : Trigger.new) {
            System.debug('>>>> ------------------------------------------------ ');
            System.debug('>>>> TRIGGER removeEmailAuto  - em.Id = '+em.Id);
            System.debug('>>>> TRIGGER removeEmailAuto  - em.Subject = '+em.Subject);
            System.debug('>>>> TRIGGER removeEmailAuto  - em.Incoming = '+em.Incoming);
            if (!em.Incoming && em.Subject.contains(System.Label.AutoReplyEmailSubject)) {
                emDelList.add(new EmailMessage(Id = em.Id));
            }
        }
    }
    delete emDelList;
}