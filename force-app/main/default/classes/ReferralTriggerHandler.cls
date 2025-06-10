public class ReferralTriggerHandler {
    public static void handleAfterInsert(List<Referral__c> referrals) {
        Set<Id> caseIds = new Set<Id>();
         for (Referral__c referral : referrals) {
            if (referral.Case__c != null) {
                caseIds.add(referral.Case__c);
            }
        }
        if (caseIds.isEmpty()) {
            return;
        }
        
        List<Task> tasks = [
            SELECT Id, WhatId, Subject
            FROM Task
            WHERE WhatId IN :caseIds
            AND TaskSubtype  = 'Email'
            AND Subject = 'Email: Alnylam Clinical Trial – Study Center Identified'
        ];
        Map<Id, Case> caseToUpdateMap = new Map<Id, Case>();
        for (Task task : tasks) {
            if (task.WhatId != null) {
                Case caseRecord = caseToUpdateMap.get(task.WhatId);
                if (caseRecord == null) {
                    caseRecord = new Case(Id = task.WhatId);
                    caseRecord.Status = 'Referred'; 
                    caseToUpdateMap.put(task.WhatId, caseRecord);
                }
            }
        }
        if (!caseToUpdateMap.isEmpty()) {
            update caseToUpdateMap.values();
        }
    }
}