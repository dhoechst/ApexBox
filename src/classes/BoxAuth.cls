public with sharing class BoxAuth {

	public static oAuthSettings__c oAuthSetting {
		get {
			if (oAuthSetting == null) {
				oAuthSetting = oAuthSettings__c.getInstance('Box');
				if (oAuthSetting == null) {
					throw new BoxAuthException('No Box OAuth Settings Found');
				}
			}
			return oAuthSetting;
		} 
		private set;
	}

	private static Box_OAuth__c boxOAuth {
		get {
			if (boxOAuth == null) {
				boxOAuth = Box_OAuth__c.getValues(UserInfo.getUserId());
			}
			return boxOAuth;
		}
		set;
	}

	public static Box_OAuth__c authInfo {
		get {
			authInfo = boxOAuth;
			if (authInfo == null) {
				throw new BoxAuthException('No Box Auth Token Set');
			}
			if (authInfo.AuthTokenExpires__c < Datetime.now()) {
				if (authInfo.RefreshTokenExpires__c > Datetime.now()) {
					refreshToken();
				} else {
					delete authInfo;
					throw new BoxAuthException('Box refresh token has expired. Reauthorize with Box.');
				}
			}
			return authInfo;
		}
	}

	// The Code is passed back from Box after the user approves the connection.
	// It will be used to get the auth and refresh tokens.
	private String code {
		get {
			code = System.currentPagereference().getParameters().get('code');
			return code;
		} 
		set;
	}

	// The User ID to set the authorization token on.
	private Id userId {
		get {
			if (userId == null) {
				try {
					userId = System.currentPagereference().getParameters().get('state');
				} catch (Exception e) {}
				if (userId == null) {
					userId = UserInfo.getUserId();
				}
			}
			return userId;
		}
		set;
	}
	
	public PageReference checkCode() {
		if (code != null) {
			getToken(code);
			PageReference pr = Page.boxauth;
			pr.setRedirect(true);
			return pr;
		}
		return null;
	}

	public Boolean isAuthorized {
		get {
			if (boxOAuth == null) {
				return false;
			}
			return (boxOAuth.Auth_Token__c != null);
		}
		set;
	}

	public BoxObject2.User currentUser {
		get {
			if (currentUser == null) {
				currentUser = BoxAPIv2.getCurrentUser();
			}
			return currentUser;
		}
		set;
	}

	public PageReference requestToken() {
		PageReference boxRequest = new PageReference(oAuthSetting.AuthEndpoint__c + 'authorize');
		boxRequest.getParameters().put('response_type', 'code');
		boxRequest.getParameters().put('client_id', oAuthSetting.ClientId__c);
		boxRequest.getParameters().put('state', userId);
		return boxRequest;
	}

	public static void refreshToken() {
		boxAuthRequest('token', 'grant_type=refresh_token&refresh_token=' + boxOAuth.Refresh_Token__c);
	}

	private void getToken(String code) {
		boxAuthRequest('token', 'grant_type=authorization_code&code=' + code);
		if (boxOAuth != null) {
			upsert boxOAuth;
		}
	}

	public PageReference revokeToken() {
		boxAuthRequest('revoke', 'token=' + boxOAuth.Auth_Token__c);
		delete boxOAuth;
		boxOAuth = null;
		return null;
	}

	private static void boxAuthRequest(String requestType, String payload) {
		Http http = new Http();
		HttpRequest req = new HttpRequest();

		req.setMethod('POST');
		req.setEndpoint(oAuthSetting.AuthEndpoint__c + requestType);
		req.setBody(payload + '&client_id=' + oAuthSetting.ClientId__c + '&client_secret=' + oAuthSetting.ClientSecret__c);

		HttpResponse res = http.send(req);
		String jsonString = res.getBody();
		if (res.getStatusCode() > 299) {
			BoxAuthError err = (BoxAuthError)JSON.deserialize(jsonString, BoxAuthError.class);
			if (boxOAuth != null) {
				delete boxOAuth;
				boxOAuth = null;
			}
			throw new BoxAuthException(err.error_description);
		}

		if (jsonString.length() > 0) {
			BoxAuthResponse boxAuthRes = (BoxAuthResponse) System.JSON.deserialize(jsonString, BoxAuthResponse.class);
			if (boxOAuth == null) {
				boxOAuth = new Box_OAuth__c(SetupOwnerId = UserInfo.getUserId());
			}
			boxOAuth.Auth_Token__c = boxAuthRes.access_token;
			boxOAuth.Refresh_Token__c = boxAuthRes.refresh_token;
			boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(boxAuthRes.expires_in);
			boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
		}
	}

	public class BoxAuthException extends Exception {}

	private class BoxAuthResponse {
		private String access_token {get;set;}
		private Integer expires_in {get;set;}
		private List<String> restricted_to {get;set;}
		private String refresh_token {get;set;}
		private String token_type {get;set;}
	}

	private class BoxAuthError {
		private String error {get;set;}
		private String error_description {get;set;}
	}
}