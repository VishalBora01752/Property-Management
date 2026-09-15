@isTest
private class LeaseExpiryReminderTest {
    
    @isTest
    static void testLeaseExpiryPositive() {
        
        Tenant__c tenant1 = new Tenant__c(
                Email__c = 'dawntown49@gmail.com',
                Name = 'Shangfeng',
                Phone_Number__c = '987654321'
            );

        insert tenant1;

        Property__c property1 = new Property__c(
                Name = 'Oneshot',
                Address__c = '123 Chill St',
                City__c = 'TestCity1',
                State__c = 'TestState1',
                Postal_Code__c = '123451',
                Country__c = 'TestCountry1',
                Type__c = 'Residential',
                Furnishing_Status__c = 'Furnished',
                Status__c = 'Available',
                Rent__c = 100000,
                Description__c = 'A test property1',
                Tenant__c = tenant1.Id
            );

        insert property1;

        Lease_Agreement__c lease1 = new Lease_Agreement__c(
            Agreed_Monthly_Rent__c = 100000,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Property__c = property1.Id,
            Terms__c = '2'
            );

        insert lease1;

        Test.startTest();
        
        LeaseExpiryReminder job = new LeaseExpiryReminder();
        job.execute(null);
        
        Integer invocation = Limits.getEmailInvocations();

        Test.stopTest();
        
        System.assertEquals(1, invocation, 'Error with email scheduling for lease expiry');
        
    }

    @isTest
    static void testLeaseExpiryNegative() {
        
        Tenant__c tenant1 = new Tenant__c(
                Email__c = 'dawntown49@gmail.com',
                Name = 'Xiao',
                Phone_Number__c = '987654321'
            );

        insert tenant1;

        Property__c property1 = new Property__c(
                Name = 'Oneshot2',
                Address__c = '1232 Chill St',
                City__c = 'TestCity1',
                State__c = 'TestState1',
                Postal_Code__c = '123451',
                Country__c = 'TestCountry1',
                Type__c = 'Residential',
                Furnishing_Status__c = 'Furnished',
                Status__c = 'Available',
                Rent__c = 10000,
                Description__c = 'A test property1a',
                Tenant__c = tenant1.Id
            );

        insert property1;

        Lease_Agreement__c lease1 = new Lease_Agreement__c(
            Agreed_Monthly_Rent__c = 10000,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(31),
            Property__c = property1.Id,
            Terms__c = '2'
            );

        insert lease1;

        Test.startTest();
        
        LeaseExpiryReminder job = new LeaseExpiryReminder();
        job.execute(null);
        
        Test.stopTest();

        Integer invocation = Limits.getEmailInvocations();
        System.assertEquals(0, invocation, 'Error with email scheduling for lease expiry');
        
    }
}