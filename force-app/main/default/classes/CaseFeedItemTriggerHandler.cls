public class CaseFeedItemTriggerHandler {

    private static Map<Id, String> previousLatestChatterPosts = new Map<Id, String>(); // Map to store previous values
    private static Map<Id, String> previousLatestChatterPostDetails = new Map<Id, String>(); // Map to store previous details

    public static void beforeInsert(List<FeedItem> newList) {
        // Logic for before insert event will go here
    }

    public static void afterInsert(List<FeedItem> newList) {
        handleAfterInsertAndUpdate(newList); // Reusing logic for insert
    }

    public static void beforeUpdate(List<FeedItem> oldList, List<FeedItem> newList) {
        // Logic for before update event will go here
    }

    public static void afterUpdate(List<FeedItem> oldList, List<FeedItem> newList) {
        handleAfterInsertAndUpdate(newList); // Reusing logic for update
    }

    public static void beforeDelete(List<FeedItem> oldList) {
        storePreviousChatterPosts(oldList); // Calling helper method for beforeDelete logic
    }

    public static void afterDelete(List<FeedItem> oldList) {
        handleAfterDelete(oldList); // Calling helper method for afterDelete logic
    }

    // --- Helper Method to handle After Insert and After Update logic ---
    private static void handleAfterInsertAndUpdate(List<FeedItem> feedItems) {
        Set<Id> parentIds = new Set<Id>();
        for (FeedItem fi : feedItems) {
            if (fi.Type == 'TextPost' && fi.ParentId != null) {
                parentIds.add(fi.ParentId);
            }
        }

        if (!parentIds.isEmpty()) {
            List<Case> cases = [
                SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c
                FROM Case
                WHERE Id IN :parentIds
            ];

            Map<Id, FeedItem> latestPosts = new Map<Id, FeedItem>();
            for (FeedItem fi : [
                SELECT ParentId, Body, CreatedDate, CreatedBy.Name
                FROM FeedItem
                WHERE ParentId IN :parentIds AND Type = 'TextPost'
                ORDER BY CreatedDate DESC
            ]) {
                if (!latestPosts.containsKey(fi.ParentId)) {
                    latestPosts.put(fi.ParentId, fi);
                }
            }

            List<Case> updates = new List<Case>();
            for (Case cs : cases) {
                if (latestPosts.containsKey(cs.Id)) {
                    
                    FeedItem latestFi = latestPosts.get(cs.Id);
                    String latestBody = latestFi.Body;
                    String plainText = stripHtml(latestBody);              

                    String postedByUserName = (latestFi.CreatedBy != null && latestFi.CreatedBy.Name != null)
                                        ? latestFi.CreatedBy.Name // Get the name of the user who posted
                                        : 'Unknown User'; // Get full name, default if null
                 
                    String postedDate = latestFi.CreatedDate.format('MM/dd/yy'); // Retrieve the latest post date in 'MM/dd/yy' format
                    String newPostDetails = postedByUserName + ' ' + postedDate; // Combine user name and date as required in this new feature

                    if (cs.Latest_Chatter_Post__c != plainText || cs.Latest_Chatter_Post_Details__c != newPostDetails) {
                        updates.add(new Case(
                            Id = cs.Id,
                            Latest_Chatter_Post__c = plainText,
                            Latest_Chatter_Post_Details__c = newPostDetails
                        ));
                    }
                } else if (cs.Latest_Chatter_Post__c != null || cs.Latest_Chatter_Post_Details__c != null) {
                    updates.add(new Case(
                        Id = cs.Id,
                        Latest_Chatter_Post__c = null,
                        Latest_Chatter_Post_Details__c = null
                    ));
                }
            }

            if (!updates.isEmpty()) {
                update updates;
            }
        }
    }

    // --- Helper Method to handle Before Delete logic ---
    private static void storePreviousChatterPosts(List<FeedItem> feedItems) {
        Set<Id> parentIds = new Set<Id>();
        for (FeedItem fi : feedItems) {
            if (fi.Type == 'TextPost' && fi.ParentId != null) {
                parentIds.add(fi.ParentId);
            }
        }

        if (!parentIds.isEmpty()) {
            List<Case> cases = [
                SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c
                FROM Case
                WHERE Id IN :parentIds
            ];

            for (Case cs : cases) {
                previousLatestChatterPosts.put(cs.Id, cs.Latest_Chatter_Post__c); // Store previous Latest_Chatter_Post__c
                previousLatestChatterPostDetails.put(cs.Id, cs.Latest_Chatter_Post_Details__c); // Store previous Latest_Chatter_Post_Details__c
            }
        }
    }

    // --- Helper Method to handle After Delete logic ---
    private static void handleAfterDelete(List<FeedItem> feedItems) {
        Set<Id> parentIds = new Set<Id>();
        for (FeedItem fi : feedItems) {
            if (fi.Type == 'TextPost' && fi.ParentId != null) {
                parentIds.add(fi.ParentId);
            }
        }
    
        if (!parentIds.isEmpty()) {

            Map<Id, String> previousPostsMap = previousLatestChatterPosts;
            Map<Id, String> previousPostDetailsMap = previousLatestChatterPostDetails;
            Map<Id, FeedItem> latestPostsAfterDelete = new Map<Id, FeedItem>();
            List<Case> CasesToUpdate = new List<Case>();

            for (FeedItem fi : [
                SELECT ParentId, Body, CreatedDate, CreatedBy.Name
                FROM FeedItem
                WHERE ParentId IN :parentIds AND Type = 'TextPost'
                ORDER BY CreatedDate DESC
            ]) {
                if (!latestPostsAfterDelete.containsKey(fi.ParentId)) {
                    latestPostsAfterDelete.put(fi.ParentId, fi);
                }
            }

            List<Case> cases = [
                SELECT Id, Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c
                FROM Case
                WHERE Id IN :parentIds
            ];

            for (Case cs : cases) {

                String previousPost = previousPostsMap.get(cs.Id); // Get previous Latest_Chatter_Post__c
                String previousPostDetails = previousPostDetailsMap.get(cs.Id); // Get previous Latest_Chatter_Post_Details__c

                if (latestPostsAfterDelete.containsKey(cs.Id)) {

                    FeedItem latestFi = latestPostsAfterDelete.get(cs.Id); // Get the latest FeedItem after deletion
                    String latestBody = latestFi.Body; // Retrieve the body of the latest post
                    String plainText = stripHtml(latestBody); // Strip HTML tags from the body

                    String postedByUserName = (latestFi.CreatedBy != null && latestFi.CreatedBy.Name != null)
                                        ? latestFi.CreatedBy.Name // Get the name of the user who posted
                                        : 'Unknown User'; // If null, default to 'Unknown User'
                                        
                    String postedDate = latestFi.CreatedDate.format('MM/dd/yy'); // Retrieve the latest post date in 'MM/dd/yy' format
                    String newPostDetails = postedByUserName + ' ' + postedDate; // Combine user name and date as required in this new feature
                    
                    if (cs.Latest_Chatter_Post__c != plainText || cs.Latest_Chatter_Post_Details__c != newPostDetails) {
                        CasesToUpdate.add(new Case(
                            Id = cs.Id,
                            Latest_Chatter_Post__c = plainText,
                            Latest_Chatter_Post_Details__c = newPostDetails
                        ));
                    }

                } else {
                          if (cs.Latest_Chatter_Post__c != null || cs.Latest_Chatter_Post_Details__c != null) {
                    CasesToUpdate.add(new Case(
                        Id = cs.Id,
                        Latest_Chatter_Post__c = null,
                        Latest_Chatter_Post_Details__c = null
                    ));
                    }
                }
            }

            if (!CasesToUpdate.isEmpty()) {
                update CasesToUpdate;
            }
        }

        previousLatestChatterPosts.clear(); // Clear the map after processing so it doesn't retain old values
        previousLatestChatterPostDetails.clear(); // Clear the map after processing so it doesn't retain old values
    }

    // --- Utility method to strip HTML tags ---
    private static String stripHtml(String html) {
        if (String.isBlank(html)) return '';
        return html.replaceAll('<[^>]+>', '');
    }

/* --- New Public Static Method for One-Off Data backfill or blank update --- */

public static void recalculateCaseChatterDetailsForIds(Set<Id> caseIds) {
    if (caseIds == null || caseIds.isEmpty()) {
        return;
    }

    List<FeedItem> dummyFeedItems = new List<FeedItem>();
    for (Id caseId : caseIds) {
        dummyFeedItems.add(new FeedItem(ParentId = caseId));
    }

    handleAfterInsertAndUpdate(dummyFeedItems); // Calling my existing private method to perform the actual logic.
}

/* End of one-off method for data backfill or blank update */

}