global class UpdateCasesBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        UpdateCasesBatch batchInstance = new UpdateCasesBatch();
        Database.executeBatch(batchInstance, 1);
    }
}