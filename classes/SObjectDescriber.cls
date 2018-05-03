public with sharing class SObjectDescriber {

    private static Map<String, Schema.SObjectType>  schemaGlobalDescribe = Schema.getGlobalDescribe();
    private static Map<String, SObjectDescriber>    objectsDescribersMap = new Map<String, SObjectDescriber>();

    private String                           sObjectName;
    private Schema.DescribeSObjectResult     sObjectDescribe;

    // Map<FieldName, Describe>
    private Map<String, DescribeFieldResult> fieldNameToFieldDescribeMap;
    // Map<RelatedFieldName, Describe>
    private Map<String, DescribeFieldResult> relationFieldNameToFieldDescribeMap;
    // Map<RelatedFieldName, RelatedObjectName>
    private Map<String, String>              childRelationNameToObjectNameMap;


    public static SObjectDescriber getObjectDescriber(String sObjectName) {
        if (!objectsDescribersMap.containsKey(sObjectName) || Test.isRunningTest()) {
            objectsDescribersMap.put(sObjectName, new SObjectDescriber(sObjectName));
        }

        return objectsDescribersMap.get(sObjectName);
    }
    public static Schema.SObjectType getSObjectType(String objectName) {

        return schemaGlobalDescribe.get(objectName);
    }

    public Schema.DescribeSObjectResult getDescribe() {

        return sObjectDescribe;
    }

    public Boolean containsField(String fieldName) {

        return fieldNameToFieldDescribeMap.containsKey(fieldName);
    }
    public Boolean containsRelatedField(String fieldName) {

        return relationFieldNameToFieldDescribeMap.containsKey(fieldName);
    }

    public DescribeFieldResult getFieldDescribe(String fieldName) {

        return fieldNameToFieldDescribeMap.get(fieldName);
    }
    public DescribeFieldResult getRelatedFieldDescribe(String fieldName) {

        return relationFieldNameToFieldDescribeMap.get(fieldName);
    }


    private SObjectDescriber(String sObjectName) {
        this.sObjectName        = sObjectName;
        this.sObjectDescribe    = schemaGlobalDescribe.get(this.sObjectName).getDescribe();

        // Init fieldNameToFieldDescribeMap and relationFieldNameToFieldDescribeMap
        this.fieldNameToFieldDescribeMap            = new Map<String, DescribeFieldResult>();
        this.relationFieldNameToFieldDescribeMap    = new Map<String, DescribeFieldResult>();
        for (SObjectField fieldItem : this.sObjectDescribe.fields.getMap().values()) {
            DescribeFieldResult describedField = fieldItem.getDescribe();
            this.fieldNameToFieldDescribeMap.put(describedField.name, describedField);
            if (describedField.relationshipName != null) {
                this.relationFieldNameToFieldDescribeMap.put(describedField.relationshipName, describedField);
            }
        }

        // Init childRelationNameToObjectNameMap
        this.childRelationNameToObjectNameMap = new Map<String, String>();
        for (Schema.ChildRelationship relationItem : this.sObjectDescribe.getChildRelationships()) {
            if (relationItem.relationshipName != null) {
                this.childRelationNameToObjectNameMap.put(relationItem.relationshipName, relationItem.childSObject.getDescribe().name);
            }
        }
    }

}