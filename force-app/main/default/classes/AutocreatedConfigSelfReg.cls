global class AutocreatedConfigSelfReg implements Auth.ConfigurableSelfRegHandler {
	private final Long CURRENT_TIME = Datetime.now().getTime();

	// This method is called once after verification (if any was configured)
	// This method should create a user and insert it
	// Password can be null
	// Return null or throw an exception to fail creation
	global Id createUser(Id accountId, Id profileId, Map<SObjectField, String> registrationAttributes, String password) {
		User u = new User();
		u.ProfileId = profileId;
		for (SObjectField field : registrationAttributes.keySet()) {
			String value = registrationAttributes.get(field);
			u.put(field, value);
		}
        
        User[] existingUser = [SELECT Id FROM User WHERE UserName = :u.Email AND IsActive = true LIMIT 1];
        if(existingUser.isEmpty() == false){
            throw new Auth.DiscoveryCustomErrorException(Label.Community_Existing_Account);
        }

		u.Username = u.Email;
        u.Alias = generateAlias();
        u.CommunityNickname = generateCommunityNickname();
        
        if(Test.isRunningTest() == false){
			Site.validatePassword(u, password, password);
        }
        Id userId;
        try{
            userId = Site.createExternalUser(u, accountId, password);
        }catch(Exception e){
            throw new Auth.DiscoveryCustomErrorException(Label.Community_Login_Error);
        }
        return userId;
	}

	// Default implementation to try to provide uniqueness
	private String generateAlias() {
		String timeString = String.valueOf(CURRENT_TIME);
		return timeString.substring(timeString.length() - 8);
	}

	// Default implementation to try to provide uniqueness
	private String generateCommunityNickname() {
		return 'ExternalUser' + CURRENT_TIME;
	}
}