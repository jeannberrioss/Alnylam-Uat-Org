trigger ReferralTrigger on Referral__c (after insert) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        ReferralTriggerHandler.handleAfterInsert(Trigger.new);
    }
}