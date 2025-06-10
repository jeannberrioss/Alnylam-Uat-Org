global class UpdateCasesBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Status FROM Case WHERE Trial_Selected__c IN (SELECT Id FROM Trials__c WHERE LPFV__c < TODAY )';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> cases) {
        
        List<Case> casesToUpdate = new List<Case>();

        for (Case c : cases) {
            if (c.Status != 'Referred') {
                c.Status = 'Closed'; 
                casesToUpdate.add(c);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}