({
    MESSAGE_INFO:           'info',
    MESSAGE_SUCCESS:        'success',
    MESSAGE_WARNING_TYPE:   'warning',
    MESSAGE_ERROR_TYPE:     'error',

    doRequest: function (cmp, action, callBack, callBackFail) {
        action.setCallback(this, function(response) {
            var state   = response.getState();
            var result  = response.getReturnValue();

            if (state === 'SUCCESS') {
                // console.log('Request result:');
                // console.dir(result);
                callBack(result);
                //cmp.set("v.answerSuccess", true);

            } else if (state === 'ERROR') {
                if (callBackFail) {
                    callBackFail(result);
                }

                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.errorMessageLog(cmp.get('v.labelErrorOccurred'), errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
                        this.errorMessageLog(
                            cmp.get('v.labelErrorOccurred'),
                            errors[0].pageErrors[0].statusCode+ '\n' + errors[0].pageErrors[0].message
                        );
                    }
                } else {
                    this.errorMessageLog(cmp.get('v.labelErrorHasNoMessage'), '');
                }

                cmp.set("v.answerSuccess", false);

            } else {
                this.errorMessageLog(cmp.get('v.labelErrorOccurred'), 'STATUS - ' + state);

                cmp.set("v.answerSuccess", false);
            }

            cmp.set('v.numberOfRequests', cmp.get('v.numberOfRequests') - 1);
        });

        setTimeout($A.getCallback(function () {
            cmp.set('v.numberOfRequests', cmp.get('v.numberOfRequests') + 1);
        }), 0);
        $A.enqueueAction(action);
    },
    goToDetail: function (itemId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId":     itemId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    goToURL: function(path) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url":          path,
            "isredirect":   true
        });
        navEvt.fire();
    },
    showMessage: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title":    title,
            "message":  message,
            "type":     $A.util.isEmpty(type) ? this.MESSAGE_INFO : type
        });
        toastEvent.fire();
    },
    errorMessageLog: function (title, message) {
        this.showMessage(title, message, this.MESSAGE_ERROR_TYPE);
        console.log('PORTAL ERROR LOG: Title - "' + title + '", Message - "' + message + '"');
    },
    slideBlock : function(timer, element) {
        var timer = component.get('v.cardTimer');
        if (timer !== null && timer !== 'null') {
            return false;
        }

        var blockId         = event.currentTarget.dataset.blockid;
        var slider          = component.find(blockId);
        var sliderElement   = slider.getElement();

        var sliderStartHeight   = $A.util.hasClass(slider, 'slider-open') ? getComputedStyle(sliderElement).height : 0;
        var sliderEndHeight     = $A.util.hasClass(slider, 'slider-open') ? 0 : getComputedStyle(sliderElement).height;

        sliderElement.style.height = sliderStartHeight;

        var animationEnd = function() {
            if (sliderEndHeight === 0) {
                $A.util.toggleClass(slider, 'slider-open');
            }
            sliderElement.style.height = '';
            component.set('v.cardTimer', null);
        }
        var animationStart = function() {
            sliderElement.style.height = sliderEndHeight;
            if (sliderStartHeight === 0) {
                $A.util.toggleClass(slider, 'slider-open');
            }

            timer = setTimeout($A.getCallback(animationEnd), 400);

            component.set('v.cardTimer', timer);
        }

        timer = setTimeout($A.getCallback(animationStart), 25);
        component.set('v.cardTimer', timer);
        return true;
    }

})