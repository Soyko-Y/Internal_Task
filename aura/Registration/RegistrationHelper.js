({
    isRegistered: function(cmp) {
        this.setCookie('isRegistered', true, { expires: -1 });
        if (this.getCookie('isRegistered') !== undefined) {
            cmp.set('v.registeredStatus', 'already');
        }

        if (document.referrer) {
            cmp.set('v.contact.Referrer__c', document.referrer);
        } else {
            cmp.set('v.contact.Referrer__c', 'Direct link');
        }
    },
    
    getHowDidYouKnow: function(cmp) {
        let action = cmp.get('c.getHowDidYouKnow');
        console.log(cmp.find('templateMain'));
        cmp.find('templateMain').doRequest(action, function(response) {
            cmp.set('v.howDidYouKnowPicklists', response);
        });
    },

    clickRegister: function(cmp, helper) {
        let newContact = cmp.get('v.contact');
        let action = cmp.get('c.addNewContact');
        
        let allValid = cmp.find('input').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        if (allValid) {
            action.setParams({
                'newContact': newContact
            });
            
            cmp.find('templateMain').doRequest(action, function(response) {
                cmp.set('v.registeredStatus', response);
                const MONTH_IN_SECOND = 2592000;
                helper.setCookie('isRegistered', true, { expires: MONTH_IN_SECOND });
            });
        }       
    },

    getCookie: function (name) {
        var matches = document.cookie.match(new RegExp(
          '(?:^|; )' + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + '=([^;]*)'
        ));
        return matches ? decodeURIComponent(matches[1]) : undefined;
    },
    
    setCookie: function (name, value, options) {
        options = options || {};

        var expires = options.expires;

        if (typeof expires == 'number' && expires) {
          var d = new Date();
          d.setTime(d.getTime() + expires * 1000);
          expires = options.expires = d;
        }
        if (expires && expires.toUTCString) {
          options.expires = expires.toUTCString();
        }

        value = encodeURIComponent(value);

        var updatedCookie = name + '=' + value;

        for (var propName in options) {
          updatedCookie += '; ' + propName;
          var propValue = options[propName];
          if (propValue !== true) {
            updatedCookie += '=' + propValue;
          }
        }

        document.cookie = updatedCookie;
    }
})