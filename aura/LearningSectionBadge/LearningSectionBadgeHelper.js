({
	navigate: function(cmp, event) {
		 
		let address = cmp.get("v.address");
		let urlEvent = $A.get("e.force:navigateToURL");

		urlEvent.setParams({
		  "url": address
		});
		
		urlEvent.fire();
	}
})