public with sharing class MaintenanceRequestTriggerHandler {
    public static void beforeInsertHandler(List<Maintenance_Request__c> newRecords) {
        
        List<Vendor__c> vendorRecords = [SELECT Id, Name FROM Vendor__c];
        List<AggregateResult> results = [
            SELECT Vendor__c, COUNT(Id) totalRequests FROM Maintenance_Request__c
            WHERE Status__c IN ('Open','In Progress')
            GROUP BY Vendor__c
            ];

        Map<Id, Integer> vendorWorkLoad = new Map<Id, Integer>();
        Map<Id, String> vendorNames = new Map<Id, String>();

        for (Vendor__c vendor : vendorRecords) {
            vendorWorkLoad.put(vendor.Id, 0);
            vendorNames.put(vendor.Id, vendor.Name);
        }

        for (AggregateResult result : results) {
            Id vid = (Id) result.get('Vendor__c');

            if (vid == null) {
                continue;
            }

            Integer countOfWorkItems = (Integer) result.get('totalRequests');
            vendorWorkLoad.put(vid, countOfWorkItems);
        }
        
        for (Maintenance_Request__c maintenanceRequest : newRecords) {
            Id bestVendorId = null;
            Integer lowestCount = null;
            String bestVendorName = null;

            for (Id vendorIdKey : vendorWorkLoad.keySet()) {
                Integer currentCount = vendorWorkLoad.get(vendorIdKey);
                String currentVendorName = vendorNames.get(vendorIdKey);
        
                if (lowestCount == null || currentCount < lowestCount) {
                    lowestCount = currentCount;
                    bestVendorId = vendorIdKey;
                    bestVendorName = currentVendorName;
                } else if (currentCount == lowestCount && currentVendorName != null && bestVendorName != null 
                && currentVendorName.compareTo(bestVendorName) < 0) {
                    if (String.isBlank(currentVendorName)) {
                        continue;
                    }
                    bestVendorId = vendorIdKey;
                    bestVendorName = currentVendorName;
                }
            }
            
            if (bestVendorId != null) {
                maintenanceRequest.Vendor__c = bestVendorId;
                vendorWorkLoad.put(bestVendorId, lowestCount + 1);
            }
        }
    }
}