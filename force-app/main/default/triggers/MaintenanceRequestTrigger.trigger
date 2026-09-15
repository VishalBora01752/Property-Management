trigger MaintenanceRequestTrigger on Maintenance_Request__c (before insert) {
    switch on Trigger.OperationType {
        when BEFORE_INSERT {
            MaintenanceRequestTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}