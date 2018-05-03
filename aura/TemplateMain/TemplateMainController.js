({
    doRequest: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        helper.doRequest(cmp, params.action, params.callBack, params.callBackFail);
    },
    addRequest: function (cmp, event, helper) {
        cmp.set('v.numberOfRequests', cmp.get('v.numberOfRequests') + 1);
    },
    subRequest: function (cmp, event, helper) {
        cmp.set('v.numberOfRequests', cmp.get('v.numberOfRequests') - 1);
    },
    goToDetail: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.goToDetail(params.itemId);
        }
    },
    goToURL: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.goToURL(params.path);
        }
    },
    showMessage: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.showMessage(params.title, params.message, params.type);
        }
    },
    errorMessageLog: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.errorMessageLog(params.title, params.message);
        }
    },
    slideBlock: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        helper.slideBlock(params.timer, params.element);
    }
})