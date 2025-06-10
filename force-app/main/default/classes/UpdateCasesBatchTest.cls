@isTest
private class UpdateCasesBatchTest {
    @isTest
    static void testUpdateCasesBatch() {
        // Create a Trial record with LPFV__c in the past
        Trials__c trial = new Trials__c(
            Name = 'Test Trial',
            LPFV__c = Date.today().addDays(-1),
            Protocol_ID__c ='ALN-AGT01-002'
        );
        insert trial;

        Case caseRecord = new Case(
            Trial_Selected__c = trial.Id,
            Status = 'Open' // Set initial status
        );
        insert caseRecord;

        Case referredCase = new Case(
            Trial_Selected__c = trial.Id,
            Status = 'Referred' 
        );
        insert referredCase;

        // Execute the batch
        Test.startTest();
        UpdateCasesBatch batch = new UpdateCasesBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        Case updatedCase = [SELECT Status FROM Case WHERE Id = :caseRecord.Id];
        Case referredCaseCheck = [SELECT Status FROM Case WHERE Id = :referredCase.Id];

        System.assertEquals('Closed', updatedCase.Status, 'The case status should be updated to Closed.');
      
        System.assertEquals('Referred', referredCaseCheck.Status, 'The referred case status should remain Referred.');
    }
}