@isTest
public class ReferralTriggerHandlerTest {
    
    @isTest
    public static void testHandleAfterInsert() {
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        Referral__c referral = new Referral__c(
            Case__c = testCase.Id,
            Person_Account__c = testAccount.Id
        );
        insert referral;
        
        Task testTask = new Task(
            WhatId = testCase.Id, // Relating the Task to the Case
            TaskSubtype = 'Email',
            Subject = 'Email: Alnylam Clinical Trial – Study Center Identified'
        );
        insert testTask;
        Test.startTest();
        List<Referral__c> referrals = [SELECT Id, Case__c FROM Referral__c WHERE Case__c = :testCase.Id];
        ReferralTriggerHandler.handleAfterInsert(referrals);
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Referred', updatedCase.Status, 'The Case status updated to Referred.');
    }
    
    @isTest
    public static void testHandleAfterInsert_NoRelatedTask() {
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        Referral__c referral = new Referral__c(
            Case__c = testCase.Id,
            Person_Account__c = testAccount.Id
        );
        insert referral;
        
        Test.startTest();
        List<Referral__c> referrals = [SELECT Id, Case__c FROM Referral__c WHERE Case__c = :testCase.Id];
        ReferralTriggerHandler.handleAfterInsert(referrals);
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('New', updatedCase.Status, 'The Case status should not be updated if no related email Task is found.');
    }
    
    @isTest
    public static void testHandleAfterInsert_NoReferrals() {
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;
        
        Task testTask = new Task(
            WhatId = testCase.Id,
            TaskSubtype = 'Email',
            Subject = 'Email: Alnylam Clinical Trial – Study Center Identified'
        );
        insert testTask;
        
        Test.startTest();
        List<Referral__c> referrals = [SELECT Id, Case__c FROM Referral__c WHERE Case__c = :testCase.Id];
        ReferralTriggerHandler.handleAfterInsert(referrals);
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('New', updatedCase.Status, 'The Case status should remain unchanged when no Referral__c record is related.');
    }
}