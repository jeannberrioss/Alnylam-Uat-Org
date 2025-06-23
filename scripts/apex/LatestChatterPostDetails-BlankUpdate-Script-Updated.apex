// 1. Identify the target Case records
Set<Id> caseIdsToRecalculate = new Set<Id>();
List<Case> casesToCheck = [SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case LIMIT 1000];

for (Case c : casesToCheck) {
    if (!String.isBlank(c.Latest_Chatter_Post__c) && String.isBlank(c.Latest_Chatter_Post_Details__c)) {
        caseIdsToRecalculate.add(c.Id);
    }
}

System.debug('Identified ' + caseIdsToRecalculate.size() + ' Case records for recalculation.');

if (!caseIdsToRecalculate.isEmpty()) {
    try {
        List<Case> casesToUpdate = new List<Case>();
        Map<Id, Case> existingCasesMap = new Map<Id, Case>([SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id IN :caseIdsToRecalculate]);

        // 2. Find the latest FeedItem for each targeted Case
        //    Crucially, removed 'Type = TextPost' filter to capture all post types
        Map<Id, FeedItem> latestFeedItems = new Map<Id, FeedItem>();
        for (FeedItem fi : [
            SELECT ParentId, Body, CreatedDate, CreatedBy.Name
            FROM FeedItem
            WHERE ParentId IN :caseIdsToRecalculate
            ORDER BY CreatedDate DESC, Id DESC // Ensures truly latest post
        ]) {
            if (!latestFeedItems.containsKey(fi.ParentId)) {
                latestFeedItems.put(fi.ParentId, fi);
            }
        }
        System.debug('Found ' + latestFeedItems.size() + ' latest FeedItems for the identified cases.');

        // 3. Process and prepare Case records for update
        for (Id caseId : caseIdsToRecalculate) {
            Case currentCase = existingCasesMap.get(caseId);
            if (currentCase == null) continue; // Skip if case not found (shouldn't happen)

            FeedItem latestFi = latestFeedItems.get(caseId);

            String newChatterPost = null;
            String newChatterDetails = null;

            if (latestFi != null) {
                newChatterPost = stripHtml(latestFi.Body); // Use the helper method defined below
                String postedByUserName = (latestFi.CreatedBy != null && latestFi.CreatedBy.Name != null)
                                            ? latestFi.CreatedBy.Name
                                            : 'Unknown User';
                String postedDate = latestFi.CreatedDate.format('MM/dd/yy');
                newChatterDetails = postedByUserName + ' ' + postedDate;
            }

            // Always add to update list if the field is currently blank and we found a new value
            // OR if it's currently populated and should be cleared (no latest post found).
            // This condition is simplified for backfill purposes.
            if (String.isBlank(currentCase.Latest_Chatter_Post_Details__c) || (newChatterDetails == null && !String.isBlank(currentCase.Latest_Chatter_Post_Details__c))) {
                 casesToUpdate.add(new Case(
                    Id = currentCase.Id,
                    Latest_Chatter_Post__c = newChatterPost, // Update both fields
                    Latest_Chatter_Post_Details__c = newChatterDetails
                ));
                System.debug('Case ' + currentCase.Id + ' prepared for update. New Details: ' + newChatterDetails);
            }
        }

        // 4. Perform the DML update
        if (!casesToUpdate.isEmpty()) {
            System.debug('Attempting to update ' + casesToUpdate.size() + ' Case records.');
            update casesToUpdate;
            System.debug('Update operation completed.');
        } else {
            System.debug('No Case records required update after processing.');
        }

    } catch (Exception e) {
        System.debug('Error during recalculation: ' + e.getMessage() + ' at line ' + e.getLineNumber());
    }
} else {
    System.debug('No Case records found matching the specific criteria for Chatter details recalculation.');
}

// Helper method from your original handler (must be included in Anonymous Apex)
public static String stripHtml(String html) {
    if (String.isBlank(html)) return '';
    return html.replaceAll('<[^>]+>', '');
}