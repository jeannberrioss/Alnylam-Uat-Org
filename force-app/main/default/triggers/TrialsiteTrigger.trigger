trigger TrialsiteTrigger on Trial_Site__c (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isUpdate || Trigger.isInsert) {
            TrialSiteTriggerHandler.processTrialSites(Trigger.new,Trigger.oldMap);
        }
    }

}