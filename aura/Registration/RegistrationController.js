({
    handleInitCmp: function(cmp, event, helper) {
        const initContact = {
            'FirstName'         : '',
            'LastName'          : '',
            'Email'             : '',
            'Phone'             : '',
            'Skype__c'          : '',
            'HowDidYouKnow__c'  : '',
            'Referrer__c'       : ''
        };
        cmp.set("v.contact", initContact);

        helper.isRegistered(cmp);
        helper.getHowDidYouKnow(cmp);
    },

    handleClickRegister: function(cmp, event, helper) {
        helper.clickRegister(cmp, helper);
    }
})