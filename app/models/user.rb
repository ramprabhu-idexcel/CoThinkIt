require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  has_many :project_users, :dependent=>:destroy
  has_many :posts, :dependent=>:destroy
  has_many :tasks, :dependent=>:destroy
  has_many :todos, :dependent=>:destroy  
  has_many :history_posts, :dependent=>:destroy
  has_many :projects, :through=>:project_users
	has_many :comments, :dependent=>:destroy	
	has_many :todo_users, :dependent=>:destroy		
	has_one :billing_information, :dependent=>:destroy
	 has_many :attachments ,:as => :attachable, :dependent=>:destroy
  has_one :plan_limits
  has_many :billing_histories
  has_many :chats
  has_many :email_notifications, :dependent=>:destroy
  attr_accessor  :step
  validates_presence_of     :first_name,:message =>'Please enter your first name.'
  
	validates_presence_of     :last_name,:message =>'Please enter your last name.'
  #~ validates_presence_of     :company,:message =>'Please enter your company, organization, group, or school name.'
	validates_presence_of     :email,:message =>'Please enter your email address.'
	validates_presence_of     :password,:message =>'Please enter password.' ,:if => Proc.new { |user| user.step == "1" }
	#validates_presence_of     :password_confirmation,:message =>'Please enter password confirmation.' ,:if => Proc.new { |user| user.step == "1" }
	#validates_confirmation_of :password_confirmation,:message =>'Dont match.', :if => Proc.new { |user| user.step == "1" }
  validates_format_of :email,:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:message => 'please enter a valid Email address.'
  validates_uniqueness_of   :email,:message =>'Sorry! The email address you entered is already in use.'
  #~ validates_presence_of     :site_address,:message =>'Please enter a site address.'
  #~ validates_uniqueness_of   :site_address,:message =>'Sorry! The site address you entered is already in use.',:if=>:valid_name
  #~ validates_format_of :site_address, :with => /^\w+$/i, :message =>'Please only use letter and numbers. No spaces please.'

  before_create :make_activation_code 
  after_create :add_billing_history

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :first_name, :email, :name, :password,:site_address, :company, :last_name,:password_confirmation,:title,:office_phone,:mobile,:time_zone,:role,:color_code,:reset_code, :last_login_time


  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
   def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  def recently_activated?
    @activated
  end

 def create_reset_code  
   @reset = true  
      self.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
   #self.attributes = {:reset_code => Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )}  
   save(false)  
 end  
   
 def recently_reset?  
   @reset  
 end  
   
 def delete_reset_code  
	 self.reset_code = nil
   save(false)  
 end  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    #~ u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL and status=?',email,true] # need to get the salt
   # u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL and status =?',email,true] # need to get the salt
    u = find :first, :conditions => ['email = ?',email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def events
    events=[]
    events<<tasks<<todos
    events.flatten!
  end
  
  def all_events(user)
    Event.project_events(user_project_ids,user)
  end
  
  def events_in_date(date)
    Event.events_in_date(user_project_ids,date)
  end
  
  def user_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end
  
   #added for chat
  def chat_password
    
    password="#{self.id}_openfire_password"
    openfire_password=Base64.encode64(password)
    return openfire_password
  end
  
  def user_project_ids
    project_users.find_all_by_status(true,:select=>"project_id").map(&:project_id)
  end
  
  #tasks of all the project on the date
  def tasks_in_date(date) 
    Task.tasks_in_date(user_project_ids,date)
  end
  
  #todos of all the project on the date
  def todos_in_date(date)
    Todo.todos_in_date(user_project_ids,date)
  end
  
  def user_membership
    project_users.find_all_by_status(true)
  end
  
  def member_in_projects
    projects.all(:conditions=>['status=?', true])
  end
  #returns the users except the current user
  def other_members
    User.find(:all,:conditions=>['project_users.status=? AND project_users.project_id IN (?) AND users.id!=?',true,user_project_ids,self.id],:include=>:project_users)
  end
  
  #returns the active users including the current user
  def all_active_members
    User.find(:all,:conditions=>['project_users.status=? AND project_users.project_id IN (?)',true,user_project_ids],:include=>:project_users)
  end
  
  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end
  
  def valid_name
    %w{www demo cothinkit blog}.include?(self.site_address.downcase) ? errors.add(:site_address,"Sorry! The site address you entered is already in use.")  : true
  end
  
  def not_guest?(project_id)
    mem=project_users.find_by_project_id(project_id)
    mem && mem.role && mem.role.name!="Guest"
  end
  
  def user_current_time(time)
    k=[0,0]
    t=time_zone.split("GMT") if time_zone
    k=t[1].split(":") unless t.nil? || t.blank?
    Time.now.utc+k[0].to_i.hours+k[1].to_i.minutes
  end
  
  def user_time(time)
    k=[0,0]
    t=time_zone.split("GMT") if time_zone
    k=t[1].split(":") unless t.nil? || t.blank?
    time+k[0].to_i.hours+k[1].to_i.minutes
  end
  
  def allowed_to_changeplan?(plan_id)
    plan=Plan.find_by_id plan_id
    if plan_limits
      if plan_limits.download_bandwidth_in_MB.nil?
        download_transfer=0
      else
        download_transfer=plan_limits.download_bandwidth_in_MB 
      end
      transfer=download_transfer+plan_limits.bandwidth_used
    end
    plan.name=="Beta" || !plan_limits || (plan_limits && plan.storage_value > plan_limits.storage_used && plan.bandwidth_value > transfer) #unless plan.nil?
  end
  
  def owner_project_ids
    project_users.find(:all,:conditions=>['is_owner=?',true],:select=>'project_id').collect{|c| c.project_id}.uniq
  end
  
  def find_unique
    User.find(:all,:conditions=>['email = ? AND status = ?', self.email,false]).empty?
  end
  
  def add_billing_history
    BillingHistory.create(:user_id=>self.id,:plan_name=>"Trial",:amount=>0,:billing_date=>Date.today)
  end
  
  def update_billing_information(plan_id)
    if billing_information 
      billing_information.update_attribute(:plan_id,plan_id)
    else
      BillingInformation.new(:user_id=>self.id,:plan_id=>plan_id)
    end
  end

  def profile_incomplete?
    title.nil? || title.blank? || mobile.nil? || mobile.blank? || office_phone.nil? || office_phone.blank? || color_code.nil? || color_code.blank? || attachments.find_by_project_id(nil).nil?
  end
  
  def make_activation_code
    self.activation_code = self.class.make_token
  end
  
  def user_completed_projects
    projects.all(:conditions=>['status=? AND is_completed=?', true,true],:select => "distinct projects.*", :order=>"name", :limit=>3)
  end
  
  def user_projects
    projects.all(:conditions=>['status=? AND is_completed=?',true,false],:select => "distinct projects.*", :order=>"name")
  end
  
  def user_project_ids
    projects.all(:conditions=>['status=? AND is_completed=?',true,false], :order=>"name",:select=>"projects.id").map(&:id).uniq
  end
  
  def user_pending_projects
    projects.all(:conditions=>['status=? AND is_completed=?', true,false],:select => "distinct projects.*", :order=>"name")
  end
  
  def owned_projects
    projects.all(:conditions=>['project_users.is_owner=?',true],:include=>:project_users)
  end
  
  def completed_projects
    projects.find_all_by_is_completed(true)
  end
  
  def projects_in_progress
    projects.find_all_by_is_completed(false)
  end
  
  def my_tasks
    todos.find(:all,:conditions=>['tasks.project_id is NULL'],:include=>:task)
  end
  
  def my_tasks_status(status,login_time)
    todos.find(:all,:conditions=>['tasks.project_id is NULL AND todo_status=? AND todos.created_at>=?',status,login_time],:include=>:task)
  end
end
