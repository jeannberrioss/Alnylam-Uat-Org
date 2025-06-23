List<Id> caseIdsToRecalculate = new List<Id>();

/* Query all relevant Case records (within a safe limit for anonymous apex).
We cannot filter by Latest_Chatter_Post_Details__c directly in SOQL */

List<Case> allRelevantCases = [SELECT Id, Latest_Chatter_Post_Details__c FROM Case LIMIT 1000]; // Adjust limit if needed for more records

// Manually filter the records in Apex
for (Case c : allRelevantCases) {
    if (String.isBlank(c.Latest_Chatter_Post_Details__c)) {
        caseIdsToRecalculate.add(c.Id);
    }
}

if (!caseIdsToRecalculate.isEmpty()) {
    try {
        CaseFeedItemTriggerHandler.recalculateCaseChatterDetailsForIds(caseIdsToRecalculate);
        System.debug('Successfully initiated recalculation for ' + caseIdsToRecalculate.size() + ' Case records.');
    } catch (Exception e) {
        System.debug('Error during recalculation: ' + e.getMessage() + ' at line ' + e.getLineNumber());
    }
} else {
    System.debug('No Case records found needing Chatter details recalculation.');
}