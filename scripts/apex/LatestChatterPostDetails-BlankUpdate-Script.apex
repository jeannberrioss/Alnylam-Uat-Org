Set<Id> caseIdsToRecalculate = new Set<Id>();

// Query for all Case records where Latest_Chatter_Post_Details__c is currently NULL.
// Ensure 'Case' is the correct object API Name.
for (Case c : [SELECT Id FROM Case WHERE Latest_Chatter_Post_Details__c = NULL LIMIT 1000]) {
    caseIdsToRecalculate.add(c.Id);
}

if (!caseIdsToRecalculate.isEmpty()) {
    try {
        // Call the newly added public method in your handler class.
        CaseFeedItemTriggerHandler.recalculateCaseChatterDetailsForIds(caseIdsToRecalculate);
        System.debug('Successfully initiated recalculation for ' + caseIdsToRecalculate.size() + ' Case records.');
    } catch (Exception e) {
        System.debug('Error during recalculation: ' + e.getMessage() + ' at line ' + e.getLineNumber());
    }
} else {
    System.debug('No Case records found needing Chatter details recalculation.');
}