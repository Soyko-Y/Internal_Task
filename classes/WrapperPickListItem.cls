public with sharing class WrapperPickListItem {

    @AuraEnabled public String  label;
    @AuraEnabled public String  value;
    @AuraEnabled public Boolean isDefault;

    public WrapperPickListItem(PicklistEntry picklistEntry) {
        this.label      = picklistEntry.label;
        this.value      = picklistEntry.value;
        this.isDefault  = picklistEntry.defaultValue;
    }

    public WrapperPickListItem(String label, String value, Boolean isDefault){
        this.label      = label;
        this.value      = value;
        this.isDefault  = isDefault;
    }

    public static List<WrapperPickListItem> getPickListValuesDAO (String objectName, String fieldName) {
        SObjectDescriber    objectDescriber = SObjectDescriber.getObjectDescriber(objectName);
        DescribeFieldResult fieldDescribe   = objectDescriber.getFieldDescribe(fieldName);
        if (objectDescriber.getDescribe().isAccessible()) {
            if (fieldDescribe != null && fieldDescribe.isAccessible()) {
                return getActivePicklistItems(fieldDescribe.getPicklistValues());
            }
        }

        return new List<WrapperPickListItem>();
    }
    public static List<WrapperPickListItem> getPickListValues (String objectName, String fieldName) {
        if (SObjectDescriber.getObjectDescriber(objectName).getFieldDescribe(fieldName) != null) {
            return getActivePicklistItems(SObjectDescriber.getObjectDescriber(objectName).getFieldDescribe(fieldName).getPicklistValues());
        }

        return new List<WrapperPickListItem>();
    }


    private static List<WrapperPickListItem> getActivePicklistItems (List<PicklistEntry> picklistEntries) {
        List<WrapperPickListItem> picklistItems = new List<WrapperPickListItem>();
        for (PicklistEntry plItem : picklistEntries) {
            if (plItem.active) {
                picklistItems.add(new WrapperPickListItem(plItem));
            }
        }

        return picklistItems;
    }

}