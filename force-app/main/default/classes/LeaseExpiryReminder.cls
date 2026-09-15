public class LeaseExpiryReminder implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<Lease_Agreement__c> leaseExpiry = [
            SELECT Id, End_Date__c, Property__r.Tenant__r.Email__c, Property__r.Tenant__r.Name FROM Lease_Agreement__c 
            WHERE End_Date__c = :Date.today().addDays(30) AND Property__r.Tenant__r.Email__c != null
        ];

        System.debug(leaseExpiry.size());

        List<Messaging.SingleEmailMessage> messagesToSend = new List<Messaging.SingleEmailMessage>();

        for (Lease_Agreement__c lease : leaseExpiry) {
            String tenantEmail = lease.Property__r.Tenant__r.Email__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] {tenantEmail});
            mail.setSubject('Lease Expiration Notice');
            mail.setPlainTextBody('Dear '+ lease.Property__r.Tenant__r.Name + ', your lease expires on ' + lease.End_Date__c.format() + '.');
        
            //Add to the collection instead of sending immediately
            messagesToSend.add(mail);
        }

        if (!messagesToSend.isEmpty()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messagesToSend);

            } catch (Exception e) {
                System.debug('Error Sending bulk Messages: ' + e.getMessage());
            }   
        }
    }
}