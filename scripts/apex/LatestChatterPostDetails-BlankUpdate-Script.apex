Set<Id> caseIdsToRecalculate = new Set<Id>();

// Query relevant Case records, including both fields for Apex-side filtering.

List<Case> casesToCheck = [SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case LIMIT 1000]; // Adjust LIMIT if you have more potential candidates

// Manually filter records based on both criteria in Apex

for (Case c : casesToCheck) {

    if (!String.isBlank(c.Latest_Chatter_Post__c) && String.isBlank(c.Latest_Chatter_Post_Details__c)) {
        caseIdsToRecalculate.add(c.Id);
    }
}

if (!caseIdsToRecalculate.isEmpty()) {
    try {
        System.debug('Identified ' + caseIdsToRecalculate.size() + ' Case records for recalculation.'); // New debug for clarity
        CaseFeedItemTriggerHandler.recalculateCaseChatterDetailsForIds(caseIdsToRecalculate);
        System.debug('Successfully initiated recalculation for ' + caseIdsToRecalculate.size() + ' Case records.');
    } catch (Exception e) {
        System.debug('Error during recalculation: ' + e.getMessage() + ' at line ' + e.getLineNumber());
    }
} else {
    System.debug('No Case records found matching the specific criteria for Chatter details recalculation.');
}