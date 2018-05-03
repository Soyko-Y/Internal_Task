public with sharing class RegistrationCtrl {

    @AuraEnabled
    public static String addNewContact (Contact newContact) {
    
        String  existingEmail;
        Id      recordTypeId;

        try {
            existingEmail = [ 
                SELECT Email 
                FROM Contact 
                WHERE Email = :newContact.Email 
                LIMIT 1
            ].Email;
        } catch (Exception e) {
        } 

        if (String.isNotBlank(existingEmail)) {
            throw new AuraHandledException('Ошибка. Пользователь с таким Email уже зарегистрирован');
        } else {
            recordTypeId = [ 
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Contact' AND Name = 'Candidate'
                LIMIT 1
            ].Id;
            newContact.RecordTypeId = recordTypeId;
            insert newContact;
        }
        return 'now';
    }
    
    @AuraEnabled
    public static List<WrapperPickListItem> getHowDidYouKnow() {
        return WrapperPickListItem.getPickListValuesDAO(
            Contact.getSObjectType().getDescribe().getName(),
            String.valueOf(Contact.HowDidYouKnow__c)
        );
    }
}