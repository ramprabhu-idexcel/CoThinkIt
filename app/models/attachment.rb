require "rubygems"
require 'RMagick'
require 'aws/s3'
class Attachment < ActiveRecord::Base
	  include AWS::S3

	if RAILS_ENV=="development"  
		has_attachment :storage => :file_system, :size => 1.kilobytes..60.megabytes, :content_type => ['application/vnd.ms-excel',"application/x-zip-compressed","application/zip","application/x-rar",:image,'text/plain','application/pdf', 'application/msword','application/rtf'], :path_prefix => 'public/attachments',:thumbnails => {:big => "461x461>", :small => "75x75",:profile=>"91x91",:post=>"51x51"}
	else
		has_attachment :storage => :s3, :size => 1.kilobytes..60.megabytes, :content_type => ['application/vnd.ms-excel',"application/x-zip-compressed","application/zip","application/x-rar",:image,'text/plain','application/pdf', 'application/msword','application/rtf'], :path_prefix => 'public/attachments' ,:thumbnails => {:big => "461x461>", :small => "75x75",:profile=>"91x91",:post=>"51x51"}
	end
	belongs_to :project
  belongs_to :attachable, :polymorphic => true	
	has_many :events ,:as => :resource, :dependent=>:destroy	
	after_create :create_event	


  after_attachment_saved do |record|    
    if record.content_type.split('/')[0]=="image"	
      if record.thumbnail.nil?
        record.thumbnails.each do |file|
          fixed_width=200
          unless file.thumbnail=="big"
            width=file.parent.width
            height=file.parent.height
            if RAILS_ENV=="development"
              full_path = File.join(RAILS_ROOT, 'public/', file.parent.public_filename)
              save_path = File.join(RAILS_ROOT, 'public/', file.public_filename)
            else
              full_path = file.parent.public_filename
              save_path = file.public_filename
            end
            size= height<width ? height : width
            img = Magick::Image.read(full_path).first
            if fixed_width>size
              white_bg = Magick::Image.new(fixed_width, fixed_width)
              img_part=white_bg.composite(img,Magick::CenterGravity,0,0,Magick::OverCompositeOp)
            else
              logger.info(img_part)
              img_part = img.crop(Magick::CenterGravity,size,size)
            end
            img_part=img_part.resize(file.image_width,file.image_width)
            if RAILS_ENV=="development"
              img_part.write(save_path)
            else
              file_path="#{RAILS_ROOT}/public/#{file.filename}"
              img_part.write(file_path)
              #~ f=File.open(file_path)
              #~ Base.establish_connection!(:access_key_id => S3_CONFIG[:access_key_id],:secret_access_key => S3_CONFIG[:secret_access_key])
              #~ logger.info("public/attachments/#{file.parent_id}/#{file.filename}")
              #~ S3Object.store("public/attachments/#{file.parent_id}/#{file.filename}",f.read,S3_CONFIG[:bucket_name])
              #~ File.delete(file_path)
              
              
              ActionController::UploadedTempfile.open("tmp_#{file.parent_id}_#{file.filename}") do |temp|
                temp.write(File.open(file_path).read)
                temp.original_path = file_path
                d=Attachment.find_by_id(file.id)
                if !d.nil?
                  d.uploaded_data = temp
                  d.save
                  File.delete(file_path)
                end
              end
              
              
            end
          end 
        end 
      end
    end
  end
  
	def create_event
		if self.project_id
			Event.create_event(self,self.project_id,nil) 
		end
	end	

  def image_width
    case self.thumbnail
      when "small"
        75
      when "post"
        51
      when "profile"
        91
    end    
  end
  
  def self.project_files(project_id) 
    find_all_by_project_id(project_id,:conditions=>['DATE(created_at)<=?',Date.today],:order=>"created_at DESC")
  end
	 
	def find_thumbnail(name)
    image=Attachment.find_by_parent_id_and_thumbnail(id,name)
  end

  def thumbnail_width(name)
    case name
      when "small"
        75
      when "post"
        51
      when "profile"
        91
      when "big"
        641
    end    
  end 
 
  def self.thumbnail_name(*args)
    args.each do |arg|
      define_method arg do
        name = arg.split('_')[0]
        image=find_thumbnail(name)
        image ? image.public_filename : self.public_filename
      end
    end
  end
  
  thumbnail_name "post_thumbnail","big_thumbnail","small_thumbnail","profile_thumbnail"
  
end
