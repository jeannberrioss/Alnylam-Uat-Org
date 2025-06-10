trigger FormAccCoordinatesTrigger on Trial_Participant_Request__c (After insert,After Update) {
 if(Trigger.isAfter) {
        if(Trigger.isUpdate || Trigger.isInsert) {
            TrialSiteTriggerHandler.processFormPostalCode(Trigger.new);
        }
    }
}