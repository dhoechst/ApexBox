@isTest
global class BoxMockHttpResponse implements HttpCalloutMock {
	
	global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		// Depending on the request, return a different response

		// oauth token
		if (req.getMethod() == 'POST' && req.getEndpoint().endsWith('token')) {
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(200);
			res.setBody('{"access_token": "T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl","expires_in": 3600,"restricted_to": [],"token_type": "bearer","refresh_token": "J7rxTiWOHMoSC1isKZKBZWizoRXjkQzig5C6jFgCVJ9bUnsUfGMinKBDLZWP9BgR"}');
		}

		// revoke token
		if (req.getMethod() == 'POST' && req.getEndpoint().endsWith('revoke')) {
			res.setStatusCode(200);
		}

		// get or create folder
		if (req.getEndpoint().contains('folders') && req.getMethod() != 'DELETE') {
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"type": "folder","id": "11446498","sequence_id": "1","etag": "1","name": "Pictures","created_at": "2012-12-12T10:53:43-08:00","modified_at": "2012-12-12T11:15:04-08:00","description": "Some pictures I took","size": 629644,"path_collection": {"total_count": 1,"entries": [{"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"}]},"created_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"modified_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"owned_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"shared_link": {"url": "https://www.box.com/s/vspke7y05sb214wjokpk","download_url": "https://www.box.com/shared/static/vspke7y05sb214wjokpk","vanity_url": null,"is_password_enabled": false,"unshared_at": null,"download_count": 0,"preview_count": 0,"access": "open","permissions": {"can_download": true,"can_preview": true}},"folder_upload_email": {"access": "open","email": "upload.Picture.k13sdz1@u.box.com"},"parent": {"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"},"item_status": "active","item_collection": {"total_count": 1,"entries": [{"type": "file","id": "5000948880","sequence_id": "3","etag": "3","sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc","name": "tigers.jpeg"}],"offset": 0,"limit": 100},"tags": ["approved","ready to publish"]}');
		}

		// get trashed folder
		if (req.getEndpoint().contains('folders') && req.getEndpoint().contains('trash') && req.getMethod() != 'DELETE') {
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"type": "folder","id": "588970022","sequence_id": "1","etag": "1","name": "heloo world","created_at": "2013-01-15T16:15:27-08:00","modified_at": "2013-01-17T13:48:23-08:00","description": "","size": 0,"path_collection": {"total_count": 1,"entries": [{"type": "folder","id": "1","sequence_id": null,"etag": null,"name": "Trash"}]},"created_by": {"type": "user","id": "181757341","name": "sean test","login": "sean+test@box.com"},"modified_by": {"type": "user","id": "181757341","name": "sean test","login": "sean+test@box.com"},"trashed_at": "2013-02-07T12:53:32-08:00","purged_at": "2013-03-09T12:53:32-08:00","content_created_at": "2013-01-15T16:15:27-08:00","content_modified_at": "2013-01-17T13:48:23-08:00","owned_by": {"type": "user","id": "181757341","name": "sean test","login": "sean+test@box.com"},"shared_link": null,"folder_upload_email": null,"parent": {"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"},"item_status": "trashed"}');
		}

		// get or create file
		if (req.getEndpoint().contains('file') && req.getMethod() != 'DELETE') {
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"type": "file","id": "5000948880","sequence_id": "3","etag": "3","sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc","name": "tigers.jpeg","description": "a picture of tigers","size": 629644,"path_collection": {"total_count": 2,"entries": [{"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"},{"type": "folder","id": "11446498","sequence_id": "1","etag": "1","name": "Pictures"}]},"created_at": "2012-12-12T10:55:30-08:00","modified_at": "2012-12-12T11:04:26-08:00","created_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"modified_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"owned_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"shared_link": {"url": "https://www.box.com/s/rh935iit6ewrmw0unyul","download_url": "https://www.box.com/shared/static/rh935iit6ewrmw0unyul.jpeg","vanity_url": null,"is_password_enabled": false,"unshared_at": null,"download_count": 0,"preview_count": 0,"access": "open","permissions": {"can_download": true,"can_preview": true}},"parent": {"type": "folder","id": "11446498","sequence_id": "1","etag": "1","name": "Pictures"},"item_status": "active"}');
		}

		// get user
		if (req.getEndpoint().contains('users') && req.getMethod() != 'DELETE') {
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"type": "user","id": "181216415","name": "sean rose","login": "sean+awesome@box.com","created_at": "2012-05-03T21:39:11-07:00","modified_at": "2012-11-14T11:21:32-08:00","role": "admin","language": "en","space_amount": 11345156112,"space_used": 1237009912,"max_upload_size": 2147483648,"tracking_codes": [],"can_see_managed_users": true,"is_sync_enabled": true,"status": "active","job_title": "api genius","phone": "6509241374","address": "","avatar_url": "https://www.box.com/api/avatar/large/181216415","is_exempt_from_device_limits": false,"is_exempt_from_login_verification": false,"enterprise": {"type": "enterprise","id": "17077211","name": "seanrose enterprise"},"my_tags": ["important","needs review"]}');
		}

		// add collaboration
		if (req.getEndpoint().contains('collaborations') && req.getMethod() != 'DELETE') {
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"type": "collaboration","id": "791293","created_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"created_at": "2012-12-12T10:54:37-08:00","modified_at": "2012-12-12T11:30:43-08:00","expires_at": null,"status": "accepted","accessible_by": {"type": "user","id": "18203124","name": "sean","login": "sean+test@box.com"},"role": "editor","acknowledged_at": "2012-12-12T11:30:43-08:00","item": {"type": "folder","id": "11446500","sequence_id": "0","etag": "0","name": "Shared Pictures"}}');
		}

		// get folder collaborations
		if (req.getEndpoint().contains('collaborations') && req.getEndpoint().contains('folders') && req.getMethod() != 'DELETE') {
			res.setHeader('Content-Type', 'application/json');
    	res.setBody('{"total_count": 1,"entries": [{"type": "collaboration","id": "14176246","created_by": {"type": "user","id": "4276790","name": "David Lee","login": "david@box.com"},"created_at": "2011-11-29T12:56:35-08:00","modified_at": "2012-09-11T15:12:32-07:00","expires_at": null,"status": "accepted","accessible_by": {"type": "user","id": "755492","name": "Simon Tan","login": "simon@box.net"},"role": "editor","acknowledged_at": "2011-11-29T12:59:40-08:00","item": null}]}');
  	}

		if (req.getMethod() == 'GET') {
			res.setStatusCode(200);
		}
		if (req.getMethod() == 'POST') {
			res.setStatusCode(201);
		}
		if (req.getMethod() == 'DELETE') {
			res.setStatusCode(204);
		}

		// error handling
		if (req.getEndpoint().contains('file/error')) {
			res.setHeader('Content-Type', 'application/json');
    	res.setBody('{"type": "error","status": 403,"code": "storage_limit_exceeded","help_url": "","message": "Account storage limit reached","request_id": "7522414694f97d171b6aea"}');
    	res.setStatusCode(403);
		}

		// file download link
		if (req.getEndpoint().contains('files') && req.getEndpoint().contains('content')) {
			res.setStatusCode(302);
			res.setHeader('Location', 'https://linktofile');
		}

		return res;
	}
}