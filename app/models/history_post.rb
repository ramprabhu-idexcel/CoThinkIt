class HistoryPost < ActiveRecord::Base
	  belongs_to :resource, :polymorphic => true	
		belongs_to :user
end
