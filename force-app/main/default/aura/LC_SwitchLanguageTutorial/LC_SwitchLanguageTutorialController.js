({
	doInit : function(component, event, helper) { 
		console.info("v.recordId = "+component.get("v.recordId"));
		var action = component.get("c.getLocalisedArticles"); 
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.localisedArticles", response.getReturnValue());

                var arrayOfMapKeys = [];                
                var StoreResponse = response.getReturnValue();
                console.log('StoreResponse' + StoreResponse);
                component.set('v.localisedArticles', StoreResponse);
 
                for (var key in StoreResponse) arrayOfMapKeys.push(key);
                component.set('v.keys', arrayOfMapKeys);
            } else if (state === "INCOMPLETE") {
				console.log("Errreur in getSummary : INCOMPLETE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) console.log("Error message testGetFilesForeignLanguage: " + errors[0].message);
                } else {
                    console.log("Errreur in urlsTutoByLanguage");
                }
            }
        });
        $A.enqueueAction(action);
	},
	onChange : function(component, event, helper) {
		var selectedUrl = component.find("localisedArticles").get("v.value");
		var localisedArticles = component.get("v.localisedArticles");
		var langs = Object.keys(localisedArticles);

		// find selected language in selectbox
		var selectedLang;
		langs.forEach(function(lang) {
			if (localisedArticles[lang] == selectedUrl) selectedLang = lang;
		});
        
		console.log('selectedUrl=' + selectedUrl);
		console.log('selectedLang=' + selectedLang);
		
		var codeLang = selectedLang.replace('English','en_US').replace('French','fr').replace('German','de').replace('Japanese','ja').replace('Spanish','es');

		location.href = selectedUrl+'?language='+codeLang;
	}
})