class Chat < ActiveRecord::Base
		has_many :attachments ,:as => :attachable, :dependent=>:destroy
		belongs_to :project
		belongs_to :user
		belongs_to :project
  
end
