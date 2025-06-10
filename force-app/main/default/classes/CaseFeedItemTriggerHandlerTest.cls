@isTest
private class CaseFeedItemTriggerHandlerTest {

    @isTest
    static void testInsertNewTextPost() {
        
        Case case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
       
        Trial_Participant_Request__c Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;
        
        FeedItem fi1 = new FeedItem(
            ParentId = case1.Id,
            Body = '<b>This is the first post</b>',
            Type = 'TextPost'
        );

        Test.startTest();
        insert fi1;
        Test.stopTest();

        Case fetchedCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('This is the first post', fetchedCase.Latest_Chatter_Post__c);

        String currentUserName = UserInfo.getName(); // Get the current user's name as they are the one 'posting' in the test
        String formattedDate = System.now().format('dd/MM/yy'); // Get today's date and format it to DD/MM/YY
        String expectedPostDetails = currentUserName + ' ' + formattedDate; // Expected concatenated string

    System.assertEquals(expectedPostDetails, fetchedCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should show current user and todays date.'); // Assert that the new field is populated correctly

    }

    @isTest
    static void testDeleteLatestPost() {

        Case case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
        
        Trial_Participant_Request__c Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;
        
       
        FeedItem fi1 = new FeedItem(
            ParentId = case1.Id,
            Body = '<b>This is the first post</b>',
            Type = 'TextPost'
        );

        insert fi1;

        FeedItem fi2 = new FeedItem(
            ParentId = case1.Id,
            Body = '<i>This is the latest post</i>',
            Type = 'TextPost'
        );

        insert fi2;
       
        Test.startTest();
        delete fi2;
        Test.stopTest();

        Case fallbackCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('This is the first post', fallbackCase.Latest_Chatter_Post__c);

    /* The latest remaining post is fi1, so we expect its details */

        String currentUserName = UserInfo.getName(); 
        String formattedDate = fi1.CreatedDate.format('dd/MM/yy'); // Use fi1's CreatedDate
        String expectedPostDetails = currentUserName + ' ' + formattedDate; 
        
        System.assertEquals(expectedPostDetails, fallbackCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should show details of the new latest post after deletion.');
    }

    @isTest
    static void testDeleteAllPosts() {

        Case case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
        
        Trial_Participant_Request__c Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;
        
        FeedItem fi = new FeedItem(
            ParentId = case1.Id,
            Body = 'Only post',
            Type = 'TextPost'
        );
        insert fi;

        
        Test.startTest();
        delete fi;
        Test.stopTest();

        Case emptyCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(null, emptyCase.Latest_Chatter_Post__c, 'Latest_Chatter_Post__c should be null after deletion.');
        System.assertEquals(null, emptyCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should be null after all posts are deleted.');
    }
 @isTest
    static void testAfterUpdate() {
          

        Case case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
        
        Trial_Participant_Request__c Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;

        FeedItem fi = new FeedItem(ParentId = case1.Id,
                                   Body = '<p>Initial post</p>', 
                                   Type = 'TextPost');
        
        insert fi;

        DateTime originalCreatedDate = fi.CreatedDate; // Store the original CreatedDate for later comparison

        fi.Body = '<p>Updated post</p>';
        Test.startTest();
        update fi;
        Test.stopTest();

        Case updatedCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('Updated post', updatedCase.Latest_Chatter_Post__c);

        String currentUserName = UserInfo.getName(); 
        String formattedDate = originalCreatedDate.format('dd/MM/yy'); // The CreatedDate of the FeedItem does NOT change on update, so use its original CreatedDate
        String expectedPostDetails = currentUserName + ' ' + formattedDate; 
        
        System.assertEquals(expectedPostDetails, updatedCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should show current user and original post date after update.');
    }
    
    
}