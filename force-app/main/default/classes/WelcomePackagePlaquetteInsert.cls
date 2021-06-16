public class WelcomePackagePlaquetteInsert{
    public static void InsertPlaquettes(){
        List<Plaquette__c> plaquettesToInsert = new List<Plaquette__c>();
    
        Schema.DescribeFieldResult fieldResultSolution = Plaquette__c.Solution__c.getDescribe();
        List<Schema.PicklistEntry> pleSolution = fieldResultSolution.getPicklistValues();
        for( Schema.PicklistEntry fSolution : pleSolution){
            Schema.DescribeFieldResult fieldResult = Plaquette__c.Domaine__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry fDomaine : ple){
                Schema.DescribeFieldResult fieldResultLangue = Plaquette__c.Langue__c.getDescribe();
                List<Schema.PicklistEntry> pleLangue = fieldResultLangue.getPicklistValues();
                for( Schema.PicklistEntry fLangue : pleLangue){
                    Plaquette__c plaquette = new Plaquette__c();
                    plaquette.Langue__c = fLangue.getLabel();
                    plaquette.Solution__c = fSolution.getLabel();
                    plaquette.Domaine__c = fDomaine.getLabel();
                    plaquette.Sujet_Email__c = 'XLSTAT Welcome Package';
                    plaquette.Nom_Fichier__c = 'US Default';
                    plaquette.Texte_Email__c = 'Dear XLSTAT user,<br>'
+'<br>'
+'Thank you for downloading XLSTAT a few weeks ago. We hope you’ve found the statistical tools you were looking for among the 200+ XLSTAT features currently available. You still have 16 days to further explore XLSTAT’s capabilities.<br>'
+'<br>'
+'For those of you interested, XLSTAT offers free face-to-face, online, general or tailored short webinars and data analysis trainings on a regular basis. Our team is also available to offer on-site trainings. To find out more about our various training opportunities, please visit: https://www.xlstat.com/en/training<br>'
+'<br>'
+'Are you already convinced XLSTAT is the right statistical software for you? Get a quote or order the most competitively priced and user-friendly data analysis software today at: https://www.xlstat.com/en/order<br>'
+'<br>'
+'Any questions, suggestions or comments? Just fill in this form https://help.xlstat.com/customer/en/portal/emails/new and we will be in touch shortly!<br>'
+'<br>'
+'If you wish to stop receiving email newsletters from XLSTAT, please fill in this form. https://www.xlstat.com/en/unsubscribe <br>'
+'<br>'
+'Again, thank you for your recent XLSTAT download.<br>'
+'<br>'
+'Statistically yours,<br>'
+'The XLSTAT team';
                    plaquette.Html_Email__c = '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" valign="top">'
+'                                                            <tbody><tr>'
+'                                                                <td colspan="5" align="center">'
+'                                                                    <div class="contentEditableContainer contentTextEditable">'
+'                                                                        <div class="contentEditable">'
+'                                                                            <h1 style="font-size:32px; color: #75B760;font-weight: normal; margin: 0;">'
+'<small>Dear XLSTAT user</small><br>'
+'                                                                                 Thank you for downloading XLSTAT a few weeks ago.'
+'                                                                            </h1>'
+'                                                                        </div>'
+'                                                                    </div>'
+'                                                                </td>'
+'                                                            </tr>'
+'                                                            <tr><td height="28"></td></tr>'
+'                                                            <tr>'
+'                                                                <td colspan="5" align="left">'
+'                                                                    <div class="contentEditableContainer contentTextEditable">'
+'                                                                        <div class="contentEditable">'
+'                                                                            <h3 style="color: #666; font-weight: normal; font-size: 22px; margin: 0;">'
+'                                                                                '
+'We hope you’ve found the statistical tools you were looking for among the 200+ XLSTAT features currently available. You still have 16 days to further explore XLSTAT’s capabilities.'
+'<br><br>For those of you interested, XLSTAT offers free face-to-face, online, general or tailored short webinars and data analysis trainings on a regular basis. Our team is also available to offer on-site trainings. To find out more about our various training opportunities, please visit: '
+'<br><br>'
+'<div align="center"> <a href="https://www.xlstat.com/en/training" style="padding:12px;font-size:13px;text-decoration:none;background:#75B760;color:#fff;border-radius:3px;-moz-border-radius:3px;-webkit-border-radius:3px;font-weight: bold;font-size: 16px; " target="_blank">XLSTAT Training</a> </div><br>'
+'                                                                            </h3>'
+'                                                                        </div>'
+'                                                                    </div>'
+'                                                                </td>'
+'                                                            </tr>'
+'                                                          <tr><td height="8"></td></tr>'
+'                                                            <tr>'
+'                                                                <td colspan="5" align="left">'
+'                                                                    <div class="contentEditableContainer contentTextEditable">'
+'                                                                        <div class="contentEditable">'
+'                                                                            <h3 style="color: #666; font-weight: normal; font-size: 22px; margin: 0;">'
+'                                                                               Are you already convinced XLSTAT is the right statistical software for you? Get a quote or order the most competitively priced and user-friendly data analysis software today at: '
+'<br><br>'
+'<div align="center"> <a href="https://www.xlstat.com/en/order" style="padding:12px;font-size:13px;text-decoration:none;background:#75B760;color:#fff;border-radius:3px;-moz-border-radius:3px;-webkit-border-radius:3px;font-weight: bold;font-size: 16px; " target="_blank"> Order XLSTAT</a> </div><br> '
+'                                                                              <br>Statistically yours, '
+'                                                                            </h3>'
+'                                                                        </div>'
+'                                                                    </div>'
+'                                                                </td>'
+'                                                            </tr>'
+'                                                          <tr><td height="28"></td></tr>'
+'                                                            <tr>'
+'                                                                <td colspan="5" align="right">'
+'                                                                    <div class="contentEditableContainer contentTextEditable">'
+'                                                                        <div class="contentEditable">'
+'                                                                            <h3 style="color: #666; font-weight: normal; font-size: 22px; margin: 0;">'
+'                                                                                The XLSTAT team'
+'                                                                            </h3>'
+'                                                                        </div>'
+'                                                                    </div>'
+'                                                                </td>'
+'                                                            </tr>'
+'                                                            <tr><td height="8"></td></tr>'
+'                                                        </tbody></table>';
                    plaquettesToInsert.add(plaquette);
                }
            }
        }
        
        insert plaquettesToInsert;
    }
}