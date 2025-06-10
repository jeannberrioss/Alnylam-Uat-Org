@isTest
private class CaseFeedItemTriggerHandlerTest {

    @isTest
    static void testInsertNewTextPost() {
        
        // --- Creating a dedicated test user ---

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'testun',
            Email = 'testuser_' + System.currentTimeMillis() + '@test.com', // Ensure unique email
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            FirstName = 'Test', // Added First Name to have a full name for concatenation
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            UserName = 'testuser_' + System.currentTimeMillis() + '@example.com' // Ensure unique username
        );
        insert testUser;
        // --- Test user created ---

        testUser = [SELECT Id, Name FROM User WHERE Id = :testUser.Id];

        Case case1; 
        Trial_Participant_Request__c Form1;
        FeedItem fi1;

        Test.startTest();

        System.RunAs(testUser) {
            
        case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
       
        Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;
        
            fi1 = new FeedItem(
            ParentId = case1.Id,
            Body = '<b>This is the first post</b>',
            Type = 'TextPost'
        );

        insert fi1;
    }
        Test.stopTest();

        Case fetchedCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('This is the first post', fetchedCase.Latest_Chatter_Post__c);

        String expectedUserName = testUser.Name; // This is correct: Using the name of the user who performed the insert (testUser)
        String formattedDate = System.now().format('MM/dd/yy'); // Use System.now() as FeedItem.CreatedDate will be current DateTime
        String expectedPostDetails = expectedUserName + ' ' + formattedDate; 
    
        System.assertEquals(expectedPostDetails, fetchedCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should show test user\'s name and the post date.');
    
    }

    @isTest
    static void testDeleteLatestPost() {

         // Created a dedicated test user ---
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'testdl',
            Email = 'testuser_delete_' + System.currentTimeMillis() + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUserDL',
            FirstName = 'TestDL',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            UserName = 'testuser_delete_' + System.currentTimeMillis() + '@example.com'
        );
        insert testUser;
        // --- Test user created ---

        testUser = [SELECT Id, Name FROM User WHERE Id = :testUser.Id];

        Case case1;
        Trial_Participant_Request__c Form1;
        FeedItem fi1;
        FeedItem fi2;

        Test.startTest();

        System.RunAs(testUser) {

        case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
        
        Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;
        
       
            fi1 = new FeedItem(
            ParentId = case1.Id,
            Body = '<b>This is the first post</b>',
            Type = 'TextPost'
        );

        insert fi1;

            fi2 = new FeedItem(
            ParentId = case1.Id,
            Body = '<i>This is the latest post</i>',
            Type = 'TextPost'
        );

        insert fi2;
        delete fi2;

        }

        Test.stopTest();

        Case fallbackCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('This is the first post', fallbackCase.Latest_Chatter_Post__c, 'Latest_Chatter_Post__c should fall back to the previous post body (fi1).');

        FeedItem reQueriedFi1 = [SELECT CreatedDate FROM FeedItem WHERE Id = :fi1.Id]; // Re-query fi1

        String expectedUserName = testUser.Name; // Use the full name of the specific testUser who created fi1
        String formattedDate = reQueriedFi1.CreatedDate.format('MM/dd/yy'); // Use fi1's CreatedDate, as it's the actual created date of the remaining latest post
        String expectedPostDetails = expectedUserName + ' ' + formattedDate; 
        System.assertEquals(expectedPostDetails, fallbackCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should show details of the new latest post (fi1) after deletion.');
    }

    @isTest
    static void testDeleteAllPosts() {

       // --- Created a dedicated test user ---
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'testda',
            Email = 'testuser_all_' + System.currentTimeMillis() + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUserDA',
            FirstName = 'TestDA',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            UserName = 'testuser_all_' + System.currentTimeMillis() + '@example.com'
        );

        insert testUser;
        // --- Test user created ---

        Case case1;
        Trial_Participant_Request__c Form1;
        FeedItem fi;
        
        Test.startTest();

        System.RunAs(testUser) {

        case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
        
        Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;
        
            fi = new FeedItem(
            ParentId = case1.Id,
            Body = 'Only post',
            Type = 'TextPost'
        );
       
        insert fi;
        delete fi;

        }

        Test.stopTest();

        Case emptyCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(null, emptyCase.Latest_Chatter_Post__c, 'Latest_Chatter_Post__c should be null after deletion.');
        System.assertEquals(null, emptyCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should be null after all posts are deleted.');
    }
 @isTest
    static void testAfterUpdate() {
          
        // --- Created a dedicated test user ---
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'testau',
            Email = 'testuser_update_' + System.currentTimeMillis() + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUserAU',
            FirstName = 'TestAU',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            UserName = 'testuser_update_' + System.currentTimeMillis() + '@example.com'
        );
        insert testUser;
        // --- Test user created ---

        testUser = [SELECT Id, Name FROM User WHERE Id = :testUser.Id];

        Case case1;
        Trial_Participant_Request__c Form1;
        FeedItem fi;
        DateTime originalCreatedDate;
        
        Test.startTest();

         System.runAs(testUser) {

        case1 = new Case(Status = 'Form Submitted', Origin = 'Web');
        insert case1;
        
        Form1 = new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c = '08/1999';
        Form1.Case__c = case1.Id;
        insert Form1;

        fi = new FeedItem(ParentId = case1.Id,
                                   Body = '<p>Initial post</p>', 
                                   Type = 'TextPost');
        
        insert fi;

        originalCreatedDate = fi.CreatedDate; // Store the original CreatedDate for later comparison

        fi.Body = '<p>Updated post</p>';
        
        update fi;

         }

        Test.stopTest();

        Case updatedCase = [SELECT Latest_Chatter_Post__c, Latest_Chatter_Post_Details__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals('Updated post', updatedCase.Latest_Chatter_Post__c,'Latest_Chatter_Post__c should reflect the updated post body');

         FeedItem reQueriedFi = [SELECT CreatedDate FROM FeedItem WHERE Id = :fi.Id]; // Re-query fi

        String expectedUserName = testUser.Name; // Use the full name of the specific testUser who created the FeedItem
        String formattedDate = reQueriedFi.CreatedDate.format('MM/dd/yy'); // Use the original CreatedDate, as it doesn't change on update
        String expectedPostDetails = expectedUserName + ' ' + formattedDate; 
        
        System.assertEquals(expectedPostDetails, updatedCase.Latest_Chatter_Post_Details__c, 'Latest_Chatter_Post_Details__c should show test user\'s name and original post date after update.');
    }
    
    
}