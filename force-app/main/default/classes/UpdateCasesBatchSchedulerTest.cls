@isTest
public class UpdateCasesBatchSchedulerTest {
    static testMethod void scheduleTest() {
        SchedulableContext sc = null;
        UpdateCasesBatchScheduler cbc = new UpdateCasesBatchScheduler();
        cbc.execute(sc);
    }
}