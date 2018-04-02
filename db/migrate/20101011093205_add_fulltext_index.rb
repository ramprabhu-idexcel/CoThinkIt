class AddFulltextIndex < ActiveRecord::Migration
  def self.up
		
		execute 'ALTER TABLE attachments ENGINE=MyISAM;'
		execute 'ALTER TABLE billing_informations ENGINE=MyISAM;'
		execute 'ALTER TABLE chats ENGINE=MyISAM;'
		execute 'ALTER TABLE comments ENGINE=MyISAM;'
		execute 'ALTER TABLE countries ENGINE=MyISAM;'
		execute 'ALTER TABLE events ENGINE=MyISAM;'
		execute 'ALTER TABLE history_posts ENGINE=MyISAM;'
		execute 'ALTER TABLE plans ENGINE=MyISAM;'		
		execute 'ALTER TABLE plan_limits ENGINE=MyISAM;'
		execute 'ALTER TABLE posts ENGINE=MyISAM;'
		execute 'ALTER TABLE projects ENGINE=MyISAM;'
		execute 'ALTER TABLE project_users ENGINE=MyISAM;'
		execute 'ALTER TABLE roles ENGINE=MyISAM;'
		execute 'ALTER TABLE schema_migrations ENGINE=MyISAM;'
		execute 'ALTER TABLE searches ENGINE=MyISAM;'
		execute 'ALTER TABLE tasks ENGINE=MyISAM;'
		execute 'ALTER TABLE todos ENGINE=MyISAM;'
		execute 'ALTER TABLE todo_users ENGINE=MyISAM;'
		execute 'ALTER TABLE users ENGINE=MyISAM;'
		
		execute 'ALTER TABLE `posts` ADD FULLTEXT `post_title_fulltext` (`title`);'
    execute 'ALTER TABLE `posts` ADD FULLTEXT `post_content_fulltext` (`content`);'
		execute 'ALTER TABLE `posts` ADD FULLTEXT `post_status_fulltext` (`status`);'
		
		execute 'ALTER TABLE `comments` ADD FULLTEXT `comment_comment_fulltext` (`comment`);'
		execute 'ALTER TABLE `comments` ADD FULLTEXT `comment_status_fulltext` (`status`);'		
		
		execute 'ALTER TABLE `attachments` ADD FULLTEXT `attachment_filename_fulltext` (`filename`);'
  end

  def self.down
		
		execute 'ALTER TABLE `posts` DROP INDEX `post_title_fulltext`'
    execute 'ALTER TABLE `posts` DROP INDEX `post_content_fulltext`;'
		execute 'ALTER TABLE `posts` DROP INDEX `post_status_fulltext`;'
		
		execute 'ALTER TABLE `comments` DROP INDEX `comment_comment_fulltext`;'
		execute 'ALTER TABLE `comments` DROP INDEX `comment_status_fulltext`;'		
		
		execute 'ALTER TABLE `attachments` DROP INDEX `attachment_filename_fulltext`;'				
		
		execute 'ALTER TABLE attachments ENGINE=INNODB;'
		execute 'ALTER TABLE billing_informations ENGINE=INNODB;'
		execute 'ALTER TABLE chats ENGINE=INNODB;'
		execute 'ALTER TABLE comments ENGINE=INNODB;'
		execute 'ALTER TABLE countries ENGINE=INNODB;'
		execute 'ALTER TABLE events ENGINE=INNODB;'
		execute 'ALTER TABLE history_posts ENGINE=INNODB;'
		execute 'ALTER TABLE plans ENGINE=INNODB;'				
		execute 'ALTER TABLE plan_limits ENGINE=INNODB;'
		execute 'ALTER TABLE posts ENGINE=INNODB;'
		execute 'ALTER TABLE projects ENGINE=INNODB;'
		execute 'ALTER TABLE project_users ENGINE=INNODB;'
		execute 'ALTER TABLE roles ENGINE=INNODB;'
		execute 'ALTER TABLE schema_migrations ENGINE=INNODB;'
		execute 'ALTER TABLE searches ENGINE=INNODB;'
		execute 'ALTER TABLE tasks ENGINE=INNODB;'
		execute 'ALTER TABLE todos ENGINE=INNODB;'
		execute 'ALTER TABLE todo_users ENGINE=INNODB;'
		execute 'ALTER TABLE users ENGINE=INNODB;'
		

  end
end
