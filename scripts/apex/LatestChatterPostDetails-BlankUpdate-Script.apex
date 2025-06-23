// Use a Set<Id> to match the method signature
Set<Id> caseIdsToRecalculate = new Set<Id>();

/* Query all relevant Case records -- We still cannot filter by Latest_Chatter_Post_Details__c directly in SOQL. */
List<Case> allRelevantCases = [SELECT Id, Latest_Chatter_Post_Details__c FROM Case LIMIT 1000];

// Manually filter the records in Apex for blank/null values
for (Case c : allRelevantCases) {
    if (String.isBlank(c.Latest_Chatter_Post_Details__c)) {
        caseIdsToRecalculate.add(c.Id); // Add to the Set
    }
}

if (!caseIdsToRecalculate.isEmpty()) {
    try {
        // Call the method with the correct Set<Id> signature
        CaseFeedItemTriggerHandler.recalculateCaseChatterDetailsForIds(caseIdsToRecalculate);
        System.debug('Successfully initiated recalculation for ' + caseIdsToRecalculate.size() + ' Case records.');
    } catch (Exception e) {
        System.debug('Error during recalculation: ' + e.getMessage() + ' at line ' + e.getLineNumber());
    }
} else {
    System.debug('No Case records found needing Chatter details recalculation.');
}