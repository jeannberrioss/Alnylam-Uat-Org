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

        Case fetchedCase = [SELECT Latest_Chatter_Post__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('This is the first post', fetchedCase.Latest_Chatter_Post__c);
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
        FeedItem fi2 = new FeedItem(
            ParentId = case1.Id,
            Body = '<i>This is the latest post</i>',
            Type = 'TextPost'
        );
        insert new List<FeedItem>{fi1, fi2};

       
        Test.startTest();
        delete fi2;
        Test.stopTest();

        Case fallbackCase = [SELECT Latest_Chatter_Post__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('This is the first post', fallbackCase.Latest_Chatter_Post__c);
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

        Case emptyCase = [SELECT Latest_Chatter_Post__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(null, emptyCase.Latest_Chatter_Post__c, 'Latest_Chatter_Post__c should be null after deletion.');
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

        fi.Body = '<p>Updated post</p>';
        Test.startTest();
        update fi;
        Test.stopTest();

        Case updatedCase = [SELECT Latest_Chatter_Post__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('Updated post', updatedCase.Latest_Chatter_Post__c);
    }
    
    
}