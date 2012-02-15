public class BoxAPI {

    private static string endpoint = 'https://www.box.net/api/1.0/rest';
    
    public static String apiKey {
        get {
            BoxDefaults__c c = BoxDefaults__c.getOrgDefaults();
            if (c == null) {
                throw new BoxException('API Key hasn\'t been configured yet');
            } else {
                return c.APIKey__c;
            }
        }
        set;
    }
    
    public static String userAuthToken {
        get {    
            BoxDefaults__c c = BoxDefaults__c.getInstance(userinfo.getuserid());
            return c.AuthToken__c;
        }
        set;
    }
    
    public static String systemAuthToken {
        get {
            BoxDefaults__c c = BoxDefaults__c.getOrgDefaults();
            return c.AuthToken__c;
        }
        set;
    }
    
    public static Boolean isAuthorized {
        get {
            return userAuthToken != null;
        }
        set;
    }
    
    private static Dom.Document boxCallout(string request) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(request);
        req.setMethod('GET');
        
        HttpResponse res = h.send(req); 
        System.debug(res.getBody());   
        if (res.getStatusCode() != 200) {
            throw new BoxException('HTTP Callout Failed ' + res.toString());
        }   
        return res.getBodyDocument();        
    }
    
    private static BoxObject.BoxResponse parseResponse(Dom.Document doc) {
        BoxObject.BoxResponse br = new BoxObject.BoxResponse();
        //try {
            Dom.XMLNode response = doc.getRootElement();
        //} catch (Exception e) {
            // do something
        //}
        
        br.status = getXMLText(response, 'status');
        br.ticket = getXMLText(response, 'ticket');
        
        Dom.XMLNode user = response.getChildElement('user', null);
        if (user != null) {
            br.user.login = getXMLText(user, 'login');
            br.user.email = getXMLText(user, 'email');
        }
        
        Dom.XMLNode collaborations = response.getChildElement('collaborations', null);
        if (collaborations != null) {
            BoxObject.BoxCollaboration[] bcs = new List <BoxObject.BoxCollaboration> ();
            for (Dom.XMLNode collaboration : collaborations.getChildElements()) {
                BoxObject.BoxCollaboration bc = new BoxObject.BoxCollaboration();
                bc.id = getXMLText(collaboration, 'id');
                bc.item_role_name = getXMLText(collaboration, 'item_role_name');
                bc.status = getXMLText(collaboration, 'status');
                bc.item_type = getXMLText(collaboration, 'item_type');
                bc.item_id = getXMLText(collaboration, 'item_id');
                bc.item_name = getXMLText(collaboration, 'item_name');
                bc.item_user_id = getXMLText(collaboration, 'item_user_id');
                bc.item_user_name = getXMLText(collaboration, 'item_user_name');
                bc.user_id = getXMLText(collaboration, 'user_id');
                bc.name = getXMLText(collaboration, 'name');
                bc.email = getXMLText(collaboration, 'email');
                bcs.add(bc);
            }
            br.collaborations = bcs;
        }
        
        Dom.XMLNode tree = response.getChildElement('tree', null);
        if (tree != null) {
            br.folders = getFolderElements(tree);
        }
        
        return br;   
    }
    
    private static BoxObject.BoxFolder[] getFolderElements(Dom.XMLNode tree) {
        BoxObject.BoxFolder[] folders = new BoxObject.BoxFolder[] {};
        for (Dom.XMLNode folder : tree.getChildElements()) {
            BoxObject.BoxFolder bf = new BoxObject.BoxFolder();
            
            bf.id = folder.getAttributeValue('id', null);
            bf.name = folder.getAttributeValue('name', null);
            bf.description = folder.getAttributeValue('description', null);
            bf.user_id = folder.getAttributeValue('user_id', null);
            bf.shared = folder.getAttributeValue('shared', null) == '1';
            bf.shared_link = folder.getAttributeValue('shared_link', null);
            bf.permissions = folder.getAttributeValue('permissions', null);
            bf.size = Integer.valueOf(folder.getAttributeValue('size', null));
            //bf.file_count = Integer.valueOf(folder.getAttributeValue('file_count', null));
            bf.name = folder.getAttributeValue('name', null);
            //bf.created = DateTime.newInstance(Long.valueOf(folder.getAttribute('created', null))*1000L);
            //bf.updated= DateTime.newInstance(Long.valueOf(folder.getAttribute('updated', null))*1000L);
            
            Dom.XMLNode subfolder = folder.getChildElement('folders', null);
            if (subfolder != null) bf.folders = getFolderElements(subfolder);                       
            
            Dom.XMLNode files = folder.getChildElement('files', null);
            if (files != null) bf.files = getFileElements(files);
            
            Dom.XMLNode tags = folder.getChildElement('tags', null);
            if (tags!= null) bf.tags= getTagElements(tags);
            
            folders.add(bf);
            
        }
        return folders;
    }
    
    private static BoxObject.BoxFile[] getFileElements(Dom.XMLNode tree) {
        BoxObject.BoxFile[] files = new BoxObject.BoxFile[] {};
        for (Dom.XMLNode file : tree.getChildElements()) {
            BoxObject.BoxFile bf = new BoxObject.BoxFile();
            
            bf.id = file.getAttributeValue('id', null);
            bf.file_name = file.getAttributeValue('file_name', null);
            bf.shared = file.getAttributeValue('shared', null) == '1';
            bf.created = DateTime.newInstance(Long.valueOf(file.getAttribute('created', null))*1000L);
            bf.updated= DateTime.newInstance(Long.valueOf(file.getAttribute('updated', null))*1000L);
            bf.size = Integer.valueOf(file.getAttributeValue('size', null));
            bf.description= file.getAttributeValue('description', null);
            bf.user_id = file.getAttributeValue('user_id', null);
            bf.shared_link = file.getAttributeValue('shared_link', null);
            bf.thumbnail = file.getAttributeValue('thumbnail', null);
            bf.small_thumbnail = file.getAttributeValue('small_thumbnail', null);
            bf.large_thumbnail = file.getAttributeValue('large_thumbnail', null);
            bf.larger_thumbnail = file.getAttributeValue('larger_thumbnail', null);
            bf.preview_thumbnail = file.getAttributeValue('preview_thumbnail', null);
            bf.permissions = file.getAttributeValue('permissions', null);
            
            Dom.XMLNode tags = file.getChildElement('tags', null);
            if (tags!= null) bf.tags= getTagElements(tags);
             
            files.add(bf);
        }
        return files;
    }
    
    private static BoxObject.BoxTag[] getTagElements(Dom.XMLNode tree) {
        BoxObject.BoxTag[] tags = new BoxObject.BoxTag[] {};
        for (Dom.XMLNode tag : tree.getChildElements()) {
            BoxObject.BoxTag bt= new BoxObject.BoxTag();
            bt.id = tag.getAttributeValue('id', null);
        }
        return tags;
    }
    
    private static string getXMLText(Dom.XMLNode xml, string ele) {
        Dom.XMLNode xmln = xml.getChildElement(ele, null);
        return xmln != null ? xmln.getText() : null;
    }
    
    public static String getTicket() {
        
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            // Make a real callout since we are not running a test
            doc = boxCallout(endpoint + '?action=get_ticket&api_key=' + apiKey);       
        } else {
            // A test is running
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>get_ticket_ok</status><ticket>bxquuv025arztljze2n438md9zef95e8</ticket></response>'); 
        }

        BoxObject.BoxResponse br = parseResponse(doc);
        if (br.status == 'get_ticket_ok') {
            return br.ticket;
        } else {
            throw new boxException(br.status);
        }
    }
    
    public static BoxObject.BoxResponse logout() {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            // Make a real callout since we are not running a test
            doc = boxCallout(endpoint + '?action=logout&api_key=' + apiKey + '&auth_token=' + systemAuthToken);       
        } else {
            // A test is running
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>logout_ok</status></response>'); 
        }

        BoxObject.BoxResponse br = parseResponse(doc);
        if (br.status == 'logout_ok') {
            return br;
        } else {
            throw new boxException(br.status);
        }
    }
    
    public static BoxObject.BoxResponse inviteCollaborator(String targetId, String[] emailAddress) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            String ep = endpoint + '?action=invite_collaborators&api_key=' + apiKey + 
                        '&auth_token=' + systemAuthToken + '&target=folder&target_id=' + targetId + 
                        '&user_ids=' + '&item_role_name=viewer&resend_invite=0&no_email=0';
            for (String email : emailAddress) {
                ep += '&emails[]=' + email;
            }
            doc = boxcallout(ep);
        } else {
            // A test is running
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_invite_collaborators</status>' +
                    '<invited_collaborators><item>user@email.com</item></invited_collaborators><unsuccessful_invitations/>' +
                    '<collaborations><collaboration><id>136080</id><item_role_name>editor</item_role_name><status>accepted</status><item_type>folder</item_type>' +
                    '<item_id>7050508</item_id><item_name>A rest folder</item_name><item_user_id>13841164</item_user_id>' +
                    '<item_user_name>user@email.com</item_user_name><user_id>13250566</user_id><name>username</name><email>user@email.com</email></collaboration>' +
                    '</collaborations></response>');          
        }
        
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status == 'user_already_collaborator' || br.status == 's_invite_collaborators') {
            return br;
        } else {
            throw new boxException(br.status);
        }       
    } 
    
    @future (callout=true)
    public static void futureInviteCollaborator (String targetId, String[] emailAddress) {
        inviteCollaborator(targetId, emailAddress);    
    }
    
    public static BoxObject.BoxResponse removeCollaboration(String targetId, String collaborationId) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxcallout(endpoint + '?action=remove_collaboration&api_key=' + apiKey + 
                        '&auth_token=' + systemAuthToken + '&target=folder&target_id=' + targetId + 
                        '&collaboration_id=' + collaborationId);
        } else {
            // A test is running
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_remove_collaboration</status>' +
                      '<collaborations/></response>');          
        }
        
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status == 's_remove_collaboration') {
            return br;
        } else {
            throw new boxException(br.status);
        }       
    } 
    
    public static BoxObject.BoxResponse getCollaborations(String targetId) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxcallout(endpoint + '?action=get_collaborations&api_key=' + apiKey + 
                        '&auth_token=' + systemAuthToken + '&target=folder&target_id=' + targetId);
        } else {
            // A test is running
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_get_collaborations</status>'+
                     '<collaborations><collaboration><id>15777887</id><item_role_name>viewer</item_role_name>'+
                     '<status>accepted</status><item_type>folder</item_type><item_id>196645552</item_id>'+
                     '<item_name>OSByPetzl</item_name><item_user_id>16901066</item_user_id>' +
                     '<item_user_name>Petzl Admin</item_user_name><user_id>12045828</user_id><name>Daniel Hoechst</name>'+
                     '<email>dhoechst@gmail.com</email></collaboration></collaborations></response>');          
        }
        
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status == 's_get_collaborations') {
            return br;
        } else {
            throw new boxException(br.status);
        }       
    } 
    
    @future (callout=true)
    public static void removeCollaborator(String folderId, String emailAddress) {
        BoxObject.BoxResponse br = getCollaborations(folderId);
        // loop through collaborations to find the right one
        for (BoxObject.BoxCollaboration bc : br.collaborations) {
            if (bc.email == emailAddress) {
               removeCollaboration(folderId, bc.id);
               break;
            }    
        }
    }
    
    public static BoxObject.BoxResponse getAccountTree(String folderId) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxcallout(endpoint + '?action=get_account_tree&api_key=' + apiKey + 
                            '&auth_token=' + systemAuthToken + '&folder_id=' + folderId + '&params[]=nozip&params[]=onelevel');
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>listing_ok</status><tree>' +
                    '<folder id="0" name="" description="" user_id="1234567" shared="" shared_link="" permissions="douv" size="13840" file_count="" created="" updated="">' +
                    '<tags/><folders><folder id="12345678" name="Folder1" description="" user_id="1234567" shared="0" shared_link="" permissions="dpstvf" size="5635170" file_count="1" created="1321649973" updated="1322778043">' +
                    '<tags><tag id="1234567"/></tags></folder>' +
                    '<folder id="1234567" name="Folder 2" description="" user_id="1234567" shared="1" shared_link="https://www.box.net/s/blah" permissions="dpstvf" size="1443427617" file_count="568" created="1322592092" updated="1323723645"><tags/></folder>' +
                    '<folder id="1234567" name="Folder 3" description="" user_id="1234567" shared="1" shared_link="https://www.box.net/s/blah" permissions="dpstvf" size="8170977" file_count="2" created="1322592069" updated="1322776759"><tags/></folder>' +
                    '</folders><files><file id="745978318" file_name="File1.docx" shared="1" sha1="f2b000f1089a6d1bc142442a279eadd1a086349d" created="1305815563" updated="1320790113" size="13840" description="" user_id="1234567"' +
                    'shared_link="https://www.box.net/s/blah" thumbnail="https://www.box.net/api/thumbs/27x30/application/docx.gif" small_thumbnail="https://www.box.net/api/thumbs/27x30/application/docx.gif" large_thumbnail="https://www.box.net/api/thumbs/43x51/application/docx.gif" larger_thumbnail="https://www.box.net/api/thumbs/43x51/application/docx.gif" preview_thumbnail="https://www.box.net/api/thumbs/242x286/application/docx.png" permissions="gdcenopstuv">'+
                    '<tags/></file></files></folder></tree></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 'listing_ok') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
    public static BoxObject.BoxResponse move(String target, String targetId, String destinationId) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=move&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&target=' + target + '&target_id=' + targetId + 
                            'destination_id=' + destinationId);
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_move_node</status></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 's_move_node') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
     public static BoxObject.BoxResponse copy(String target, String targetId, String destinationId) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=copy&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&target=' + target + '&target_id=' + targetId + 
                            'destination_id=' + destinationId);
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_copy_node</status></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 's_copy_node') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
     public static BoxObject.BoxResponse rename(String target, String targetId, String newName) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=rename&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&target=' + target + '&target_id=' + targetId + 
                            '&new_name=' + newName);
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_rename_node</status></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 's_rename_node') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
    public static BoxObject.BoxResponse del(String target, String targetId) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=delete&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&target=' + target + '&target_id=' + targetId);
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_delete_node</status></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 's_delete_node') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
    public static BoxObject.BoxResponse setDescription(String target, String targetId, String description) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=set_description&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&target=' + target + '&target_id=' + targetId + 
                            'description=' + description);
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_set_description</status></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 's_set_description') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
    public static BoxObject.BoxResponse createFolder (String parentId, String name, Boolean share) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=create_folder&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&parent_id=' + parentId+ '&name=' + name + 
                            '&share=0' );
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>create_ok</status>' +
                    '<folder><folder_id>738</folder_id><folder_name>New Folder</folder_name><folder_type_id>0</folder_type_id>' +
                    '<user_id>453</user_id><path></path><shared>1</shared><public_name>gh23ghjj</public_name><show_comments></show_comments>' +
                    '<parent_folder_id>0</parent_folder_id><password></password></folder></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 'create_ok') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
    public static BoxObject.BoxResponse getUserId (String login) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=get_user_id&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&login=' + login); 
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_get_user_id</status><id>12045828</id></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 's_get_user_id') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
    public static BoxObject.BoxResponse getUserInfo (String userId) {
        Dom.Document doc = new Dom.Document();
        if (!Test.isRunningTest()) {
            doc = boxCallout(endpoint + '?action=get_user_info&api_key=' + apiKey +
                            '&auth_token=' + systemAuthToken + '&user_id=' + userId); 
        } else {
            doc.load('<?xml version=\'1.0\' encoding=\'UTF-8\'?><response><status>s_get_user_info</status>' +
                     '<status>s_get_user_info</status><folders><folder><name>test_folder1</name><id>45225454</id>' +
                     '<status>accepted</status></folder></folders><files><file><name>test1.doc</name>' +
                     '<id>12325454</id><status>pending</status></file></files></response>');
        }
        BoxObject.BoxResponse br = parseResponse(doc);        
        if (br.status != 's_get_user_info') {
            throw new BoxException(br.status);
        } else {
            return br;
        }           
    }
    
}