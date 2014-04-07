@isTest
private class BoxAuthTest {
	
	static {
		oAuthSettings__c oAuthSetting = new oAuthSettings__c(
			Name = 'Box',
			AuthEndPoint__c = 'https://www.box.com/api/2.0/',
			ClientId__c = '123456',
			ClientSecret__c = '123456');
		insert oAuthSetting;
	}
	
	@isTest static void testOAuthFlow() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		Test.setCurrentPage(Page.boxauth);
		BoxAuth ba = new BoxAuth();
		PageReference authPage = ba.requestToken();
		URL authURL = new URL(authPage.getUrl());
		System.assertEquals('/api/2.0/authorize', authURL.getPath());
		System.assertEquals('code', authPage.getParameters().get('response_type'));

		Test.setCurrentPage(Page.boxauth);
		System.assertEquals(null, ba.checkCode(), 'Null should have been returned because no code was passed to the page');
		System.currentPagereference().getParameters().put('code', '123456');
		
		ba.checkCode();
		System.assertEquals('T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl', BoxAuth.authInfo.Auth_Token__c);

		System.assert(ba.isAuthorized, 'The user should be authorized to Box.');

		Test.stopTest();
	}

	@isTest static void testCurrentUser() {
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		Box_OAuth__c boxOAuth = new Box_OAuth__c(SetupOwnerId = UserInfo.getUserId());
		boxOAuth.Auth_Token__c = '1234567890';
		boxOAuth.Refresh_Token__c = '1234567890';
		boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(3600);
		boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
		insert boxOAuth;

		Test.startTest();
		BoxAuth ba = new BoxAuth();
		BoxObject2.User boxUser = ba.currentUser;
		System.assertEquals('sean+awesome@box.com', boxUser.login);
		Test.stopTest();
	}

	@isTest static void testRefreshToken() {
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		Box_OAuth__c boxOAuth = new Box_OAuth__c(SetupOwnerId = UserInfo.getUserId());
		boxOAuth.Auth_Token__c = '1234567890';
		boxOAuth.Refresh_Token__c = '1234567890';
		boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(-3600);
		boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
		insert boxOAuth;

		Test.startTest();
		System.assertEquals('T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl', BoxAuth.authInfo.Auth_Token__c);
		Test.stopTest();
	}

	@isTest static void testExpireRefreshToken() {
		Box_OAuth__c boxOAuth = new Box_OAuth__c(SetupOwnerId = UserInfo.getUserId());
		boxOAuth.Auth_Token__c = '1234567890';
		boxOAuth.Refresh_Token__c = '1234567890';
		boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(-3600);
		boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(-60);
		insert boxOAuth;

		Test.startTest();
		try {
			Box_OAuth__c oauth = BoxAuth.authInfo;
		} catch (BoxAuth.BoxAuthException e) {
			return;
		}
		Test.stopTest();
		System.assert(false, 'An exception wasn\'t thrown because the refresh token was not valid');
	}

	@isTest static void testNoAuthInfo() {
		BoxAuth ba = new BoxAuth();
		System.assert(!ba.isAuthorized, 'The user should not be authorized since no token has been set.');
		try {
			Box_OAuth__c oauth = BoxAuth.authInfo;
		} catch (BoxAuth.BoxAuthException e) {
			return;
		}
		Test.stopTest();
		System.assert(false, 'An exception wasn\'t thrown even though no auth token was set');
	}

	@isTest static void testRevokeToken() {
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		Box_OAuth__c boxOAuth = new Box_OAuth__c(SetupOwnerId = UserInfo.getUserId());
		boxOAuth.Auth_Token__c = '1234567890';
		boxOAuth.Refresh_Token__c = '1234567890';
		boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(3600);
		boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
		insert boxOAuth;

		Test.startTest();
			BoxAuth ba = new BoxAuth();
			ba.revokeToken();
		Test.stopTest();

		System.assert(!ba.isAuthorized, 'There should be no token stored since it has been revoked.');
	}
}