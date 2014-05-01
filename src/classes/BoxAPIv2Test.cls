@isTest
private class BoxAPIv2Test {

	static {
		Box_OAuth__c boxOAuth = new Box_OAuth__c(SetupOwnerId = UserInfo.getUserId());
		boxOAuth.Auth_Token__c = '1234567890';
		boxOAuth.Refresh_Token__c = '1234567890';
		boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(3600);
		boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
		insert boxOAuth;
	}
	
	@isTest static void testGetFolder() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxObject2.FolderFile folder = BoxAPIv2.getFolder('0');
		Test.stopTest();
		System.assertEquals('Pictures', folder.name);
		System.assertEquals('folder', folder.type);
		System.assertEquals('11446498', folder.id);
		System.assertEquals('1', folder.etag);
		System.assertEquals(Date.newInstance(2012, 12, 12), folder.created_at.date());
		System.assertEquals(Date.newInstance(2012, 12, 12), folder.modified_at.date());
		System.assertEquals('Some pictures I took', folder.description);
		System.assertEquals(629644, folder.size);
		System.assertEquals('1', folder.sequence_id);
		BoxObject2.PathCollection pathCol = folder.path_collection;
		System.assertEquals(1, pathCol.total_count);
		BoxObject2.MiniFolderFile minifolder = pathCol.entries[0];
		System.assertEquals('folder', minifolder.type);
		System.assertEquals('0', minifolder.id);
		System.assertEquals('All Files', minifolder.name);
		BoxObject2.MiniUser createdUser = folder.created_by;
		System.assertEquals('user', createdUser.type);
		System.assertEquals('17738362', createdUser.id);
		System.assertEquals('sean rose', createdUser.name);
		System.assertEquals('sean@box.com', createdUser.login);
		BoxObject2.MiniUser modifiedUser = folder.modified_by;
		System.assertEquals('sean@box.com', modifiedUser.login);
		BoxObject2.MiniUser ownedUser = folder.owned_by;
		System.assertEquals('sean@box.com', ownedUser.login);
		BoxObject2.SharedLink link = folder.shared_link;
		System.assertEquals('https://www.box.com/s/vspke7y05sb214wjokpk', link.url);
		System.assertEquals('https://www.box.com/shared/static/vspke7y05sb214wjokpk', link.download_url);
		System.assertEquals(null, link.vanity_url);
		System.assertEquals(false, link.is_password_enabled);
		System.assertEquals(null, link.unshared_at);
		System.assertEquals(0, link.download_count);
		System.assertEquals(0, link.preview_count);
		System.assertEquals('open', link.access);
		BoxObject2.Permissions perms = link.permissions;
		System.assertEquals(true, perms.can_download);
		System.assertEquals(true, perms.can_preview);
		BoxObject2.FolderUploadEmail email = folder.folder_upload_email;
		System.assertEquals('open', email.access);
		System.assertEquals('upload.Picture.k13sdz1@u.box.com', email.email);
		BoxObject2.MiniFolderFile parent = folder.parent;
		System.assertEquals('All Files', parent.name);
		System.assertEquals('active', folder.item_status);
		BoxObject2.ItemCollection itemcoll = folder.item_collection;
		System.assertEquals(1, itemcoll.total_count);
		System.assertEquals(0, itemcoll.offset);
		System.assertEquals(100, itemcoll.limit_x);
		BoxObject2.MiniFolderFile item = itemcoll.entries[0];
		System.assertEquals('file', item.type);
		System.assertEquals('5000948880', item.id);
		System.assertEquals('3', item.sequence_id);
		System.assertEquals('3', item.etag);
		System.assertEquals('134b65991ed521fcfe4724b7d814ab8ded5185dc', item.sha1);
		System.assertEquals('tigers.jpeg', item.name);
	}

	@isTest static void testGetTrashedFolder() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxObject2.FolderFile folder = BoxAPIv2.getFolder('0', true);
		Test.stopTest();
		System.assertEquals('heloo world', folder.name);
		System.assertEquals('trashed', folder.item_status);
		System.assertEquals(Date.newInstance(2013, 2, 7), folder.trashed_at.date());
		System.assertEquals(Date.newInstance(2013, 3, 9), folder.purged_at.date());
		System.assertEquals(Date.newInstance(2013, 1, 15), folder.content_created_at.date());
		System.assertEquals(Date.newInstance(2013, 1, 17), folder.content_modified_at.date());
	}
	
	@isTest static void testCreateFolder() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxObject2.FolderFile folder = BoxAPIv2.createFolder('Test Folder', '0');
		Test.stopTest();
		System.assertEquals('Pictures', folder.name);
	}

	@isTest static void testDeleteFolder() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxAPIv2.deleteFolder('0');
		Test.stopTest();
	}

	@isTest static void testGetFile() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxObject2.FolderFile file = BoxAPIv2.getFile('12345');
		Test.stopTest();
		System.assertEquals('tigers.jpeg', file.name);
		System.assertEquals('file', file.type);
	}

	@isTest static void testDeleteFile() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxAPIv2.deleteFile('12345');
		Test.stopTest();
	}

	@isTest static void testGetCurrentUser() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxObject2.User user = BoxAPIv2.getCurrentUser();
		Test.stopTest();
		System.assertEquals('sean+awesome@box.com', user.login);
		System.assertEquals('user', user.type);
		System.assertEquals('181216415', user.id);
		System.assertEquals('sean rose', user.name);
		System.assertEquals(Date.newInstance(2012, 5, 3), user.created_at.date());
		System.assertEquals(Date.newInstance(2012, 11, 14), user.modified_at.date());
		System.assertEquals('admin', user.role);
		System.assertEquals('en', user.language);
		System.assertEquals('sean rose', user.name);
		System.assertEquals(11345156112L, user.space_amount);
		System.assertEquals(1237009912L, user.space_used);
		System.assertEquals(2147483648L, user.max_upload_size);
		System.assertEquals('active', user.status);
		System.assertEquals('api genius', user.job_title);
		System.assertEquals('6509241374', user.phone);
		System.assertEquals('', user.address);
		System.assertEquals('https://www.box.com/api/avatar/large/181216415', user.avatar_url);
	}

	@isTest static void testAddCollaboration() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxObject2.Collaboration collab = BoxAPIv2.addCollaboration('12345', 'sean@box.com', 'viewer');
		Test.stopTest();
		System.assertEquals('collaboration', collab.type);
		System.assertEquals('791293', collab.id);
		System.assertEquals('sean@box.com', collab.created_by.login);
		System.assertEquals(Date.newInstance(2012, 12, 12), collab.created_at.date());
		System.assertEquals(Date.newInstance(2012, 12, 12), collab.modified_at.date());
		System.assertEquals(null, collab.expires_at);
		System.assertEquals('accepted', collab.status);
		System.assertEquals('sean+test@box.com', collab.accessible_by.login);
		System.assertEquals('editor', collab.role);
		System.assertEquals(Date.newInstance(2012, 12, 12), collab.acknowledged_at.date());
		System.assertEquals('Shared Pictures', collab.item.name);
	}

	@isTest static void testGetFolderCollaboration() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		BoxObject2.CollaborationCollection collab = BoxAPIv2.getFolderCollaboration('12345');
		Test.stopTest();
		System.assertEquals('14176246', collab.entries[0].id);
		System.assertEquals(1, collab.total_count);
	}

	@isTest static void testErrorHandling() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		try {
			BoxObject2.FolderFile file = BoxAPIv2.getFile('error');
			} catch (BoxException e) {
			}
		Test.stopTest();
		System.assertEquals('error', BoxAPIv2.error.type);
		System.assertEquals(403, BoxAPIv2.error.status);
		System.assertEquals('storage_limit_exceeded', BoxAPIv2.error.code);
		System.assertEquals('Account storage limit reached', BoxAPIv2.error.message);
		System.assertEquals('7522414694f97d171b6aea', BoxAPIv2.error.request_id);
		System.assertEquals('', BoxAPIv2.error.help_url);
	}

	@isTest static void testGetFileDownloadLink() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		PageReference pr = BoxAPIv2.getFileDownloadLink('1234');
		Test.stopTest();
		System.assertEquals('https://linktofile', pr.getUrl());
	}
	
}