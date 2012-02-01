@isTest
private class BoxAPITest {

    static testMethod void testAPIKey() {
        //set up data so the test doesn't fail   
        BoxDefaults__c boxDefault = BoxDefaults__c.getOrgDefaults();
        if (boxDefault == null) {
            boxDefault = new BoxDefaults__c(APIKey__c = '1234567890');
        } else {
            boxDefault.APIKey__c = '1234567890';
        }
        upsert boxDefault;
        
        System.assertEquals(BoxAPI.apiKey, '1234567890');        
    }
    
    static testMethod void testSystemAuthToken() {
        //set up data so the test doesn't fail   
        BoxDefaults__c boxDefault = BoxDefaults__c.getOrgDefaults();
        if (boxDefault == null) {
            boxDefault = new BoxDefaults__c(AuthToken__c = '1234567890');
        } else {
            boxDefault.AuthToken__c = '1234567890';
        }
        upsert boxDefault;
        
        System.assertEquals(BoxAPI.systemAuthToken, '1234567890');
    }
    
    static testMethod void testGetTicket() {
        System.assert(BoxAPI.getTicket() != null);
    }
    
    static testMethod void testLogout() {
        BoxObject.BoxResponse br = BoxAPI.logout();
        System.assertEquals('logout_ok', br.status);
    }
    
    static testMethod void testInviteCollaborator() {
        String[] emailAddress = new String[]{};
        emailAddress.add('test@test.com');
        BoxObject.BoxResponse br = BoxAPI.inviteCollaborator('1234', emailAddress);
        System.assertEquals('s_invite_collaborators', br.status);
    }
    
    static testMethod void testFutureInviteCollaborator() {
        String[] emailAddress = new String[]{};
        emailAddress.add('test@test.com');
        BoxAPI.futureInviteCollaborator('1234', emailAddress);
    }
    
    static testMethod void testGetCollaborations() {
        BoxObject.BoxResponse br = BoxAPI.getCollaborations('1234');
        System.assertEquals('s_get_collaborations', br.status);
    }
    
    static testMethod void testRemoveCollaboration() {
        BoxObject.BoxResponse br = BoxAPI.removeCollaboration('1234', '123456');
        System.assertEquals('s_remove_collaboration', br.status);
    }
    
    static testMethod void testRemoveCollaborator() {
        BoxAPI.removeCollaborator('196645552', 'dhoechst@gmail.com');
    }
    
    static testMethod void testGetAccountTree() {
        BoxObject.BoxResponse br = BoxAPI.GetAccountTree('0');
        System.assertEquals('listing_ok', br.status);
    }
    
    static testMethod void testMove() {
        BoxObject.BoxResponse br = BoxAPI.move('file', '12345678', '245789');
        System.assertEquals('s_move_node', br.status);
    }
    
    static testMethod void testCopy() {
        BoxObject.BoxResponse br = BoxAPI.copy('file', '12345678', '245789');
        System.assertEquals('s_copy_node', br.status);
    }
    
    static testMethod void testRename() {
        BoxObject.BoxResponse br = BoxAPI.rename('file', '12345678', 'New Name');
        System.assertEquals('s_rename_node', br.status);
    }
    
    static testMethod void testDelete() {
        BoxObject.BoxResponse br = BoxAPI.del('file', '12345678');
        System.assertEquals('s_delete_node', br.status);
    }
    
    static testMethod void testSetDescription() {
        BoxObject.BoxResponse br = BoxAPI.setDescription('file', '12345678', 'New Description');
        System.assertEquals('s_set_description', br.status);
    }
    
    static testMethod void testCreateFolder() {
        BoxObject.BoxResponse br = BoxAPI.createFolder('12345678', 'New Folder', false);
        System.assertEquals('create_ok', br.status);
    }
    
    static testMethod void testGetUserID() {
        BoxObject.BoxResponse br = BoxAPI.getUserId('test@test.com');
        System.assertEquals('s_get_user_id', br.status);
    }
    
    static testMethod void testGetUserInfo() {
        BoxObject.BoxResponse br = BoxAPI.getUserInfo('1234567890');
        System.assertEquals('s_get_user_info', br.status);
    }
}