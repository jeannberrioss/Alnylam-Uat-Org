// Helper method (must be included in your Anonymous Apex block)
public static String stripHtml(String html) {
    if (String.isBlank(html)) return '';
    return html.replaceAll('<[^>]+>', '');
}

// 1. Identify the precise target Case records:
//    Cases where Latest_Chatter_Post__c IS BLANK
//    AND Latest_Chatter_Post_Details__c IS POPULATED.
Set<Id> caseIdsToFix = new Set<Id>();
List<Case> casesToCheck = [SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case LIMIT 1000]; // Adjust LIMIT if needed

for (Case c : casesToCheck) {
    if (String.isBlank(c.Latest_Chatter_Post__c) && !String.isBlank(c.Latest_Chatter_Post_Details__c)) {
        caseIdsToFix.add(c.Id);
    }
}

System.debug('Identified ' + caseIdsToFix.size() + ' Case records requiring specific TextPost body update.');

if (!caseIdsToFix.isEmpty()) {
    try {
        List<Case> casesToUpdate = new List<Case>();
        Map<Id, Case> existingCasesMap = new Map<Id, Case>([SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id IN :caseIdsToFix]);

        // 2. Find the LATEST FeedItem of TYPE = 'TextPost' for each identified Case.
        Map<Id, FeedItem> latestTextPosts = new Map<Id, FeedItem>();
        for (FeedItem fi : [
            SELECT ParentId, Body, CreatedDate, CreatedBy.Name // Include these for potential future debugging/flexibility
            FROM FeedItem
            WHERE ParentId IN :caseIdsToFix AND Type = 'TextPost' // Explicitly filter for TextPost
            ORDER BY CreatedDate DESC, Id DESC // Ensures truly latest TextPost
        ]) {
            if (!latestTextPosts.containsKey(fi.ParentId)) {
                latestTextPosts.put(fi.ParentId, fi);
            }
        }
        System.debug('Found ' + latestTextPosts.size() + ' latest TextPosts corresponding to target cases.');

        // 3. Process and prepare Case records for update.
        for (Id caseId : caseIdsToFix) {
            Case currentCase = existingCasesMap.get(caseId);
            if (currentCase == null) continue; // Skip if case not found (shouldn't happen)

            FeedItem latestTextFi = latestTextPosts.get(caseId);
            String newChatterPostBody = null;

            if (latestTextFi != null) {
                newChatterPostBody = stripHtml(latestTextFi.Body);
            }

            // Only update Latest_Chatter_Post__c IF it's currently blank or needs correction,
            // and we found a TextPost to fill it from.
            // IMPORTANT: We explicitly retain the current Latest_Chatter_Post_Details__c value.
            if (currentCase.Latest_Chatter_Post__c != newChatterPostBody) {
                casesToUpdate.add(new Case(
                    Id = currentCase.Id,
                    Latest_Chatter_Post__c = newChatterPostBody,
                    Latest_Chatter_Post_Details__c = currentCase.Latest_Chatter_Post_Details__c // RETAIN EXISTING VALUE
                ));
                System.debug('Case ' + currentCase.Id + ' prepared for update. Latest_Chatter_Post__c: "' + newChatterPostBody + '"');
            }
        }

        // 4. Perform the DML update.
        if (!casesToUpdate.isEmpty()) {
            System.debug('Attempting to update ' + casesToUpdate.size() + ' Case records.');
            update casesToUpdate;
            System.debug('Update operation completed successfully.');
        } else {
            System.debug('No Case records required update based on TextPost criteria, or already correct.');
        }

    } catch (Exception e) {
        System.debug('Error during specific TextPost body update: ' + e.getMessage() + ' at line ' + e.getLineNumber());
    }
} else {
    System.debug('No Case records found matching the specific criteria (blank Latest_Chatter_Post__c with populated Latest_Chatter_Post_Details__c).');
}