public with sharing class PropertyController {

    @AuraEnabled
    public static List<Property__c> getProperties(Integer pageNumber, Integer maxRent, String status, String furnishing) {
        
        pageNumber = (pageNumber == null || pageNumber < 1) ? 1 : pageNumber;
        Integer offsetValue = (pageNumber - 1) * 25;
        
        List<Property__c> rows;

        Boolean noRent = (maxRent == null || maxRent < 1);
        Boolean noStatus = String.isBlank(status);
        Boolean noFurnishing = String.isBlank(furnishing);

        String query = 'SELECT Id, Name, Rent__c, Status__c, Furnishing_Status__c from Property__c';
        List<String> condition = new List<String>();
        
        if (!noRent) {
            condition.add('Rent__c <= :maxRent');
        }

        if (!noStatus) {
            condition.add('Status__c = :status');
        }

        if (!noFurnishing) {
            condition.add('Furnishing_Status__c = :furnishing');
        }
        
        if (!condition.isEmpty()) {
            query += ' WHERE ' + String.join(condition, ' AND ');    
        }

        query += ' ORDER BY Name LIMIT 25 OFFSET :offsetValue';

        rows = Database.query(query);

        return rows;
    }

    @AuraEnabled
    public static Id createProperty(String name, Integer rent, String address, String city, String state, String postalCode,
        String country, String type, String furnishingStatus, String status, String description, List<String> fileNames, List<String> fileBodies) {  
        
        if (fileNames == null || fileNames.isEmpty() || fileBodies == null || fileBodies.isEmpty()) {
            throw new AuraHandledException('Please upload at least one image.');                
        }
        
        Property__c p = new Property__c(
            Name = name,
            Address__c = address,
            City__c = city,
            State__c = state,
            Postal_Code__c = postalCode,
            Country__c = country,
            Type__c = type,
            Furnishing_Status__c = furnishingStatus,
            Status__c = status,
            Rent__c = rent,
            Description__c = description
            );
        insert p;

        List<ContentVersion> versions = new List<ContentVersion>();
        for (Integer i = 0; i < fileNames.size(); i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = fileNames[i];
            cv.PathOnClient = fileNames[i];
            cv.VersionData = EncodingUtil.base64Decode(fileBodies[i]);
            cv.FirstPublishLocationId = p.Id;
            versions.add(cv);
        }

        insert versions;
        return p.Id;
    }
}