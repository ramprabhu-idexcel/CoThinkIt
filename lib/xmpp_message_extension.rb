module Jabber
  class Message < XMPPStanza

    def message_type=( b )
      replace_element_text( 'message_type', b )
    end
    def file_path=( b )
      replace_element_text( 'file_path', b )
    end
    def file_title=( b )
      replace_element_text( 'file_title', b )
    end
    def uploaded_by=( b )
      replace_element_text( 'uploaded_by', b )
    end
    def uploaded_by_xpmm_user=( b )
      replace_element_text( 'uploaded_by_xpmm_user', b )
    end
    def ipaper_id=( b )
      replace_element_text( 'ipaper_id', b )
    end
    def ipaper_access_key=( b )
      replace_element_text( 'ipaper_access_key', b )
    end
		def attach_id=( b )
      replace_element_text( 'attach_id', b )
    end    
  end
end