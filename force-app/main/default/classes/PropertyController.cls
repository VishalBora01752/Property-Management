public with sharing class PropertyController {
    @AuraEnabled
    public static String ping() {
    return 'ok';
    }
    @AuraEnabled
    public static List<Property__c> getProperties(Integer pageNumber) {
        pageNumber = (pageNumber == NULL || pageNumber < 1) ? 1 : pageNumber;
        Integer offsetValue = (pageNumber - 1) * 25;
        List<Property__c> rows = [
            SELECT Id, Name, Rent__c, Status__c, Furnishing_Status__c FROM Property__c 
            LIMIT 25 OFFSET :offsetValue
        ];
        return rows;
    }
}