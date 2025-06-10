trigger CaseFeedItemTrigger on FeedItem (after insert, after update, after delete, before delete, before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        CaseFeedItemTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseFeedItemTriggerHandler.afterInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        CaseFeedItemTriggerHandler.beforeUpdate(Trigger.old, Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseFeedItemTriggerHandler.afterUpdate(Trigger.old, Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isDelete) {
        CaseFeedItemTriggerHandler.beforeDelete(Trigger.old);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        CaseFeedItemTriggerHandler.afterDelete(Trigger.old);
    }
}