@isTest
private class PropertyControllerTest {

    @isTest
    static void testGetProperties_Page2() {
        List<Property__c> testProperty = new List<property__c>();        
        testProperty.add(new Property__c(Name = 'Test Property',
        Address__c = '123 Main St',
        City__c = 'TestCity',
        State__c = 'TestState',
        Postal_Code__c = '12345',
        Country__c = 'TestCountry',
        Type__c = 'Residential',
        Furnishing_Status__c = 'Furnished',
        Status__c = 'Available',
        Rent__c = 1000,
        Description__c = 'A test property'));

        insert testProperty;

        Test.startTest();
        List<Property__c> result = PropertyController.getProperties(2, null, null, null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Expected return should be 0');
    }

    @isTest
    static void testGetProperties_FurnishingMismatch() {
        List<Property__c> testProperty = new List<property__c>();

        testProperty.add(new Property__c(Name = 'Test Property',
        Address__c = '123 Main St',
        City__c = 'TestCity',
        State__c = 'TestState',
        Postal_Code__c = '12345',
        Country__c = 'TestCountry',
        Type__c = 'Residential',
        Furnishing_Status__c = 'Furnished',
        Status__c = 'Available',
        Rent__c = 1000,
        Description__c = 'A test property'));
    
        insert testProperty;

        Test.startTest();
        List<Property__c> result = PropertyController.getProperties(1, null, null, 'Unfurnished');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'This filter should return 0 rows');
    }

    @isTest
    static void testGetProperties_OccupiedFiltered() {
        List<Property__c> testProperty = new List<property__c>();        
        testProperty.add(new Property__c(Name = 'Test Property',
        Address__c = '123 Main St',
        City__c = 'TestCity',
        State__c = 'TestState',
        Postal_Code__c = '12345',
        Country__c = 'TestCountry',
        Type__c = 'Residential',
        Furnishing_Status__c = 'Furnished',
        Status__c = 'Available',
        Rent__c = 1000,
        Description__c = 'A test property'));

        insert testProperty;

        Test.startTest();
        List<Property__c> result = PropertyController.getProperties(1, null, 'Occupied', null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Expected return should be 0');
    }

    @isTest
    static void testGetProperties_MaxRent500() {
        List<Property__c> testProperty = new List<property__c>();

        testProperty.add(new Property__c(Name = 'Test Property',
        Address__c = '123 Main St',
        City__c = 'TestCity',
        State__c = 'TestState',
        Postal_Code__c = '12345',
        Country__c = 'TestCountry',
        Type__c = 'Residential',
        Furnishing_Status__c = 'Furnished',
        Status__c = 'Available',
        Rent__c = 1000,
        Description__c = 'A test property'));
    
        insert testProperty;

        Test.startTest();
        List<Property__c> result = PropertyController.getProperties(1, 500, null, null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'This filter should return 0 rows');
    }

    @isTest
    static void testGetProperties_MaxRent1000() {
        List<Property__c> testProperty = new List<property__c>();        
        testProperty.add(new Property__c(Name = 'Test Property',
        Address__c = '123 Main St',
        City__c = 'TestCity',
        State__c = 'TestState',
        Postal_Code__c = '12345',
        Country__c = 'TestCountry',
        Type__c = 'Residential',
        Furnishing_Status__c = 'Furnished',
        Status__c = 'Available',
        Rent__c = 1000,
        Description__c = 'A test property'));

        insert testProperty;

        Test.startTest();
        List<Property__c> result = PropertyController.getProperties(1, 1000, null, null);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected return should be 1 property');
    }

    @isTest
    static void testGetProperties_UnfilteredPage() {
        List<Property__c> testProperty = new List<property__c>();

        testProperty.add(new Property__c(Name = 'Test Property',
        Address__c = '123 Main St',
        City__c = 'TestCity',
        State__c = 'TestState',
        Postal_Code__c = '12345',
        Country__c = 'TestCountry',
        Type__c = 'Residential',
        Furnishing_Status__c = 'Furnished',
        Status__c = 'Available',
        Rent__c = 1000,
        Description__c = 'A test property'));
    
        insert testProperty;

        Test.startTest();
        List<Property__c> result = PropertyController.getProperties(1, null, null, null);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'This filter should return 1 Available row');
    }

    @isTest
    static void testCreateProperty_noFiles_throwsError() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            PropertyController.createProperty(
                'Test Property', 1000, 'Address', 'City', 'State', '12345', 'Country', 'Residential', 
                'Furnished', 'Available', 'Description', new List<String>(), new List<String>()
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected createProperty to throw when no files are provided');

        Integer propertyCount = [SELECT COUNT() FROM Property__c];
        System.assertEquals(0, propertyCount,'No Property should have been created');
    }

    @isTest
    static void testCreateProperty_withFile_createsPropertyAndFile() {

        Test.startTest();
        Id newPropertyId = PropertyController.createProperty(
            'Test Property', 1000, 'Address', 'City', 'State', '12345', 'Country',
            'Residential', 'Furnished', 'Available', 'Description',
            new List<String>{ 'photo.png' },
            new List<String>{ EncodingUtil.base64Encode(Blob.valueOf('x')) }
        );
        Test.stopTest();

        System.assert(newPropertyId != null, 'Expected a new Property Id to be returned');

        Property__c insertedProperty = [SELECT Id, Name FROM Property__c WHERE Id = :newPropertyId];
        System.assertEquals('Test Property', insertedProperty.Name, 'Property Name should match what was submitted');

        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :newPropertyId];
        System.assert(links.size() > 0, 'Expected at least one file to be linked to the new Property');
    }
} 