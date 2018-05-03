public with sharing class LearningSectionsCtrl {

    static final String ADMIN_PROFILE_NAME = 'System Administrator';
    static final String ERROR_MESSAGE_EMPTY_SECTIONS = 'Learning sections is empty!';
    static final String STATUS_NOT_STARTED = 'Not started';
    static final String DOCUMENT_URL_WITHOUT_ID = '/servlet/servlet.FileDownload?file=';

    @AuraEnabled
    public static DataResponse getlearningSections(Id userId) {
        DataResponse            response            = new DataResponse();
        List<SectionWrapper>    learningSections    = new List<SectionWrapper>();
        
        if (String.isBlank(userId)) {                 
            if (isAdmin()) {
                learningSections = getAllWrapperSections();
                response.users = getUsers();
                response.isAdmin = true;
            } else {
                learningSections = getSectionsForSelectedUser(UserInfo.getUserId());
            }
        } else {
            learningSections = getSectionsForSelectedUser(userId);
        }

        response.learningSections = learningSections;

        if (response.learningSections == null) {
            throw new AuraHandledException(ERROR_MESSAGE_EMPTY_SECTIONS);
        }
        
        return response;
    }

    public static List<SectionWrapper> getAllWrapperSections() {
        List<Section__c> sectionsList = [
            SELECT Name, Title__c, Sequence__c, Description__c, 
                    Document_Id__c, Document_Title__c,
            (
                SELECT Id, trailheadapp__Badge_Icon__c, Name, 
                    trailheadapp__Description__c, trailheadapp__URL__c
                FROM Badges__r
            )
            FROM Section__c
            ORDER BY Sequence__c
            LIMIT 50000
        ];

        List<SectionWrapper> sectionsWrapper = new List<SectionWrapper>();

        for (Section__c sectionItem :sectionsList) {
            sectionsWrapper.add(new SectionWrapper(sectionItem));
        }

        return sectionsWrapper;
    }

    public static List<SectionWrapper> getSectionsForSelectedUser(Id userId) {
        return getSectionsForSelectedUsers(new Id[]{userId}).get(userId);
    }

/**
* Give sections for selected users
*
* @param userIds users ids, for whom the sections are received
* @return Map<Id, List<SectionWrapper>> returns Map where Id - userIds, List<SectionWrapper> - selected sections
*/

    public static Map<Id, List<SectionWrapper>> getSectionsForSelectedUsers(Id[] userIds) {
        List<SectionWrapper>                        allWrapperSections          = getAllWrapperSections();
        Map<Id, List<SectionWrapper>>               allWrapperSectionsMap       = new Map<Id, List<SectionWrapper>>();
        Map<Id, String>                             userBadgeStatusesMap        = new Map<Id, String>();
        Map<Id, Map<Id, String>>                    bulkUserBadgeStatusesMap    = new Map<Id, Map<Id, String>>();
        Map<Id, List<trailheadapp__User_Badge__c>>  userBadgesMap               = new Map<Id, List<trailheadapp__User_Badge__c>>();

        List<trailheadapp__User_Badge__c> userBadges = [
            SELECT trailheadapp__Badge__c,
                trailheadapp__Status__c, 
                trailheadapp__User__c
            FROM trailheadapp__User_Badge__c
            WHERE trailheadapp__User__c IN :userIds
            LIMIT 50000
        ];

        for (Id userIdItem :userIds) {
            List<trailheadapp__User_Badge__c> userBadgesForCurrentUser = new List<trailheadapp__User_Badge__c>();
            for (trailheadapp__User_Badge__c userBadgeItem :userBadges) {
                if (userBadgeItem.trailheadapp__User__c == userIdItem) {
                    userBadgesForCurrentUser.add(userBadgeItem);
                }
            }
            userBadgesMap.put(userIdItem, userBadgesForCurrentUser);
        }

        Boolean isEmpty = true;
        for (Id userIdItem :userIds) {
            if ((userBadgesMap.get(userIdItem).isEmpty()) == false) {
                isEmpty = false;
            }
        }
        if (isEmpty) {
            allWrapperSectionsMap.put(userIds[0],allWrapperSections);
            return allWrapperSectionsMap;
        }

        for (Id userIdItem :userIds) {
            allWrapperSectionsMap.put (
                userIdItem,
                allWrapperSections
            );
        }

        for (Id userIdItem :userIds) {
            if (userBadgesMap.containsKey(userIdItem)) {
                for (trailheadapp__User_Badge__c userBadgeItem :userBadgesMap.get(userIdItem)) {
                    userBadgeStatusesMap.put
                    (
                        userBadgeItem.trailheadapp__Badge__c, 
                        userBadgeItem.trailheadapp__Status__c
                    );

                    bulkUserBadgeStatusesMap.put
                    (
                        userIdItem,
                        userBadgeStatusesMap
                    );
                }
            }
        }

        for (Id userIdItem :userIds) {
            for (SectionWrapper sectionItem :allWrapperSectionsMap.get(userIdItem)) {
                for (BadgeWrapper badgeItem :sectionItem.badges) {
                    if (bulkUserBadgeStatusesMap.get(userIdItem).containsKey(badgeItem.id)) {
                        badgeItem.status = bulkUserBadgeStatusesMap.get(userIdItem).get(badgeItem.Id);
                    }
                }
            }
        }

        return allWrapperSectionsMap;
    }

    public static Boolean isAdmin() {
        Id profileId = UserInfo.getProfileId();
        
        String profileName = [
            SELECT Id, Name 
            FROM Profile 
            WHERE Id = :profileId
            LIMIT 50000
        ].Name;

        Boolean isAdmin = (profileName == ADMIN_PROFILE_NAME);

        return isAdmin;
    }

    public static List<User> getUsers() {
        List<User> users = [
            SELECT Name
            FROM User
            WHERE Contact.Id != null
        ];

        return users;
    }

    class SectionWrapper {
                     public String  name;
                     public Decimal sequence;
        @AuraEnabled public String  title;
        @AuraEnabled public String  description;
        @AuraEnabled public String  documentTitle;
        @AuraEnabled public String  documentURL;
        @AuraEnabled public List<BadgeWrapper>  badges = new List<BadgeWrapper>();

        public SectionWrapper(Section__c s) {
            name = s.Name;
            title = s.Title__c;
            sequence = s.Sequence__c;
            description = s.Description__c;
            documentTitle = s.Document_Title__c;
            documentURL = DOCUMENT_URL_WITHOUT_ID + s.Document_Id__c;
            for (trailheadapp__Badge__c badgeItem :s.Badges__r) {
                badges.add(new BadgeWrapper(badgeItem));
            }
        }
    }

    class BadgeWrapper {
                     public String  id;
        @AuraEnabled public String  icon;
        @AuraEnabled public String  name;
        @AuraEnabled public String  description;
        @AuraEnabled public String  url;
        @AuraEnabled public String  status; 

        public BadgeWrapper(trailheadapp__Badge__c b) {
            id = b.Id;
            icon = b.trailheadapp__Badge_Icon__c;
            name = b.Name;
            description = b.trailheadapp__Description__c;
            url = b.trailheadapp__URL__c;
            status = STATUS_NOT_STARTED;
        }
    }

    public class DataResponse {        
        @AuraEnabled public List<SectionWrapper> learningSections;
        @AuraEnabled public List<User> users;
        @AuraEnabled public Boolean isAdmin;
    }
}