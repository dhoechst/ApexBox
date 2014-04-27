public class BoxAuthController {

    public static String authToken= System.currentPagereference().getParameters().get('auth_token');
    
    public boxAuthController () {
    }
    
    public PageReference updateBoxAuth() {
        if (authToken != null) { 
            
            BoxDefaults__c s = BoxDefaults__c.getValues(UserInfo.getUserId());
            if (s == null) {
                s = new BoxDefaults__c(setupownerid = UserInfo.getUserId(), authtoken__c = authToken);
            } else {
                s.authtoken__c = authToken;
            }
            
            try {
                Database.UpsertResult result = Database.upsert(s);
            } catch (System.DMLException e) {
                System.Debug(e);
            }
        }
        return null;
    }

}