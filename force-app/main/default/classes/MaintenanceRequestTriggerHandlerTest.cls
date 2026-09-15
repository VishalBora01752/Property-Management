@isTest
private class MaintenanceRequestTriggerHandlerTest {

    @isTest
    static void vendorAutoAssignment() {

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
                Description__c = 'A test property1a'
            );
        
        insert property1;

        Vendor__c vendorA = new Vendor__c();
        vendorA.Name = 'Vendor A';
        vendorA.Phone_Number__c = '678912345';
        vendorA.Email__c = 'Avendor@gmail.com';

        insert vendorA;

        Vendor__c vendorB = new Vendor__c();
        vendorB.put('Name', 'Vendor B');
        vendorB.put('Email__c', 'Bvendor@gmail.com');
        vendorB.put('Phone_Number__c', '352416789');

        insert vendorB;

        List<Maintenance_Request__c> mReq = new List<Maintenance_Request__c>{
            new Maintenance_Request__c(
                Description__c = 'test1',
                Status__c = 'Open',
                Property__c = property1.Id
            )
        };

        test.startTest();
        insert mReq;   
        Maintenance_Request__c stored = [
            SELECT Vendor__c FROM Maintenance_Request__c WHERE Id = :mReq[0].Id
        ];
        System.assertEquals(vendorA.Id, stored.Vendor__c, 'Tie at 0 workload should pick Name A before B');
        System.assertNotEquals(null, stored.Vendor__c, 'Expected a Vendor to be auto-assigned');
        test.stopTest();
    }

    @isTest
    static void assignsToVendorWithLowerWorkload() {

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
                Description__c = 'A test property1a'
            );
        
        insert property1;

        Vendor__c vendorA = new Vendor__c();
        vendorA.Name = 'Vendor A';
        vendorA.Phone_Number__c = '678912345';
        vendorA.Email__c = 'Avendor@gmail.com';

        insert vendorA;

        Vendor__c vendorB = new Vendor__c();
        vendorB.put('Name', 'Vendor B');
        vendorB.put('Email__c', 'Bvendor@gmail.com');
        vendorB.put('Phone_Number__c', '352416789');

        insert vendorB;

        List<Maintenance_Request__c> mReq1 = new List<Maintenance_Request__c>{
            new Maintenance_Request__c(
                Description__c = 'test2',
                Status__c = 'Open',
                Property__c = property1.Id
            )
        };

        insert mReq1;

        List<Maintenance_Request__c> mReq = new List<Maintenance_Request__c>{
            new Maintenance_Request__c(
                Description__c = 'test1',
                Status__c = 'Open',
                Property__c = property1.Id
            )
        };

        test.startTest();
        insert mReq;   
        Maintenance_Request__c stored = [
            SELECT Vendor__c FROM Maintenance_Request__c WHERE Id = :mReq[0].Id
        ];
        
        System.assertEquals(vendorB.Id, stored.Vendor__c, 'Should assign to vendorB since A should already have 1 value');
        test.stopTest();
    }

    @isTest
    static void vendorAutoAssignmentNull() {

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
                Description__c = 'A test property1a'
            );
        
        insert property1;

        List<Maintenance_Request__c> mReq = new List<Maintenance_Request__c>{
            new Maintenance_Request__c(
                Description__c = 'test1',
                Status__c = 'Open',
                Property__c = property1.Id
            )
        };

        test.startTest();
        insert mReq;   
        Maintenance_Request__c stored = [
            SELECT Vendor__c FROM Maintenance_Request__c WHERE Id = :mReq[0].Id
        ];
        
        System.assertEquals(null, stored.Vendor__c, 'since no vendor exists it should be null');
        test.stopTest();
    }

    @isTest
    static void assignsToVendorBulkTest() {

        Property__c property1 = new Property__c(
                Name = 'BulkTest',
                Address__c = '1232 Bulk St',
                City__c = 'TestCity1',
                State__c = 'TestState1',
                Postal_Code__c = '123451',
                Country__c = 'TestCountry1',
                Type__c = 'Residential',
                Furnishing_Status__c = 'Furnished',
                Status__c = 'Available',
                Rent__c = 10000,
                Description__c = 'A test property1a'
            );
        
        insert property1;

        Vendor__c vendorA = new Vendor__c();
        vendorA.Name = 'Vendor A';
        vendorA.Phone_Number__c = '678912345';
        vendorA.Email__c = 'Avendor@gmail.com';

        Vendor__c vendorB = new Vendor__c();
        vendorB.put('Name', 'Vendor B');
        vendorB.put('Email__c', 'Bvendor@gmail.com');
        vendorB.put('Phone_Number__c', '352416789');

        insert new List<Vendor__c>{vendorA, vendorB};

        List<Maintenance_Request__c> bulkReq = new List<Maintenance_Request__c>();
        for (Integer i = 0; i < 200; i++) {
            bulkReq.add(new Maintenance_Request__c(
                Description__c = 'Bulk Request ' + i,
                Status__c = 'Open',
                Property__c = property1.Id
            ));
        }

        test.startTest();

        insert bulkReq;   
        List<Maintenance_Request__c> insertedRequests = [
            SELECT Vendor__c FROM Maintenance_Request__c WHERE Property__c = :property1.Id
        ];
        
        Map<Id, Integer> vendorCounts = new Map<Id, Integer>();
        for (Maintenance_Request__c req : insertedRequests) {
            if (!vendorCounts.containsKey(req.Vendor__c)) {
                vendorCounts.put(req.Vendor__c, 0);
            }
            vendorCounts.put(req.Vendor__c, vendorCounts.get(req.Vendor__c) + 1 );
        }

        System.assertEquals(100, vendorCounts.get(vendorA.Id), 'Expected Vendor A to have 100 requests');
        System.assertEquals(100, vendorCounts.get(vendorB.Id), 'Expected Vendor B to have 100 requests');
        
        test.stopTest();
    }
}