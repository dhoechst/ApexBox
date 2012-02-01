public class BoxObject {

    public class BoxResponse {
        public String status {get; set;}
        public String ticket {get; set;}
        public String auth_Token {get; set;}
        public BoxUser User;
        public BoxCollaboration[] collaborations;
        public BoxFolder[] folders;
    }
    
    public class BoxUser {
        public String login {get; set;}
        public String email {get; set;}
    }
    
    public class BoxCollaboration {
        public String id {get; set;}
        public String item_role_name {get; set;}
        public String status {get; set;}
        public String item_type {get; set;}
        public String item_id {get; set;}
        public String item_name {get; set;}
        public String item_user_id {get; set;}
        public String item_user_name {get; set;}
        public String user_id {get; set;}
        public String name {get; set;}
        public String email {get; set;}
    }
    
    public class BoxFolder {
        public String id {get; set;}
        public String name {get; set;}
        public String description {get; set;}
        public String user_id {get; set;}
        public Boolean shared {get; set;}
        public String shared_link {get; set;}
        public String permissions {get; set;}
        public Integer size {get; set;}
        public Integer file_count {get; set;}
        public DateTime created {get; set;}
        public DateTime updated {get; set;} 
        public BoxTag[] tags;
        public BoxFile[] files;
        public BoxFolder[] folders;    
    }
    
    public class BoxTag {
        public String id {get; set;}
    }
    
    public class BoxFile {
        public String id {get; set;}
        public String file_name {get; set;}
        public String keyword {get; set;}
        public Boolean shared  {get; set;}
        public Integer size {get; set;}
        public String description {get; set;}
        public String user_id {get; set;}
        public String shared_link {get; set;}
        public DateTime created {get; set;}
        public DateTime updated  {get; set;}
        public BoxTag[] tags;
        public String thumbnail {get; set;}
        public String small_thumbnail {get; set;}
        public String large_thumbnail {get; set;}
        public String larger_thumbnail {get; set;}
        public String preview_thumbnail {get; set;}
        public String permissions {get; set;}
    }
}