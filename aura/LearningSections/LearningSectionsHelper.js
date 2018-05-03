({
	doInit: function(cmp) {
		this.getLearningSections(cmp); 
	}, 

	getLearningSections: function(cmp) {
		console.log("getlearningSections");
		this.startProcess(cmp);

		let action = cmp.get("c.getlearningSections"); 
		let curUserId = cmp.get("v.selectedUser");
		if (curUserId) {
			action.setParams({ 
				"userId": curUserId
			});	
		}

		action.setCallback(this, function(response) {
			this.setResponse(cmp, response);
		}); 
 
		$A.enqueueAction(action); 
	}, 

	setResponse: function(cmp, response) {
		let result = response.getReturnValue();
		let state = response.getState();
		
		if (state === "SUCCESS") {  
			console.log(result);
			cmp.set("v.learningSections", result.learningSections);
			
			if (result.isAdmin) {
				cmp.set("v.isAdmin", result.isAdmin);
				cmp.set("v.users", result.users);
			}
		} else if (state === "ERROR") {
			let errors = response.getError();
			this.handleErrors(errors);
		}
		this.endProcess(cmp);
	},

	handleErrors : function(errors) {
		let toastParams = {
			title: "Error",
			message: "Unknown error",
			type: "error"
		};

		if (errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		console.error(toastParams);

		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},

	startProcess: function(cmp) {
		let countProcess = cmp.get("v.countProcess");
		countProcess++;
		cmp.set("v.countProcess", countProcess);
	},
	 
	endProcess: function(cmp) {
		let countProcess = cmp.get("v.countProcess");
		countProcess--;
		cmp.set("v.countProcess", countProcess);
	}
})