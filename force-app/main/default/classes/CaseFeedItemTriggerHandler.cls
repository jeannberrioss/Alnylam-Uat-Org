public class CaseFeedItemTriggerHandler {

    private static Map<Id, String> previousLatestChatterPosts = new Map<Id, String>(); // Map to store previous values

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
                SELECT Id, Latest_Chatter_Post__c
                FROM Case
                WHERE Id IN :parentIds
            ];

            Map<Id, FeedItem> latestPosts = new Map<Id, FeedItem>();
            for (FeedItem fi : [
                SELECT ParentId, Body, CreatedDate
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
                    String latestBody = latestPosts.get(cs.Id).Body;
                    String plainText = stripHtml(latestBody); // Stripping HTML
                    if (cs.Latest_Chatter_Post__c != plainText) {
                        updates.add(new Case(
                            Id = cs.Id,
                            Latest_Chatter_Post__c = plainText
                        ));
                    }
                } else if (cs.Latest_Chatter_Post__c != null) {
                    updates.add(new Case(
                        Id = cs.Id,
                        Latest_Chatter_Post__c = null
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
                SELECT Id, Latest_Chatter_Post__c
                FROM Case
                WHERE Id IN :parentIds
            ];

            for (Case cs : cases) {
                previousLatestChatterPosts.put(cs.Id, cs.Latest_Chatter_Post__c);
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
            Map<Id, FeedItem> latestPostsAfterDelete = new Map<Id, FeedItem>();
            List<Case> CasesToUpdate = new List<Case>();

            for (FeedItem fi : [
                SELECT ParentId, Body, CreatedDate
                FROM FeedItem
                WHERE ParentId IN :parentIds AND Type = 'TextPost'
                ORDER BY CreatedDate DESC
            ]) {
                if (!latestPostsAfterDelete.containsKey(fi.ParentId)) {
                    latestPostsAfterDelete.put(fi.ParentId, fi);
                }
            }

            List<Case> cases = [
                SELECT Id, Latest_Chatter_Post__c
                FROM Case
                WHERE Id IN :parentIds
            ];

            for (Case cs : cases) {
                String previousPost = previousPostsMap.get(cs.Id);

                if (latestPostsAfterDelete.containsKey(cs.Id)) {
                    String latestBody = latestPostsAfterDelete.get(cs.Id).Body;
                    String plainText = stripHtml(latestBody); // Stripping HTML
                    if (cs.Latest_Chatter_Post__c != plainText) {
                        CasesToUpdate.add(new Case(
                            Id = cs.Id,
                            Latest_Chatter_Post__c = plainText
                        ));
                    }
                } else {
                    CasesToUpdate.add(new Case(
                        Id = cs.Id,
                        Latest_Chatter_Post__c = null
                    ));
                }
            }

            if (!CasesToUpdate.isEmpty()) {
                update CasesToUpdate;
            }
        }
        previousLatestChatterPosts.clear(); // Clear the map after processing
    }

    // --- Utility method to strip HTML tags ---
    private static String stripHtml(String html) {
        if (String.isBlank(html)) return '';
        return html.replaceAll('<[^>]+>', '');
    }
    


}