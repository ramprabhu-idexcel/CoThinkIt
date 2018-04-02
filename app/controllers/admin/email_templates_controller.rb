class Admin::EmailTemplatesController < AdminController
  layout "admin"
  def index
    @email_templates = Admin::EmailTemplate.all.sort_by{|template| template.key.downcase}
    @email_template=Admin::EmailTemplate.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_email_templates }
    end
  end

  def show
    @email_template = Admin::EmailTemplate.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email_template }
    end
  end

  def new
    @email_template = Admin::EmailTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_template }
    end
  end


  def edit
    @email_template = Admin::EmailTemplate.find_by_id(params[:id])
    @subject=@email_template.subject[1..-2]
    @from=@email_template.from[1..-2]
    render :layout=> false
  end

  def create
    @email_template = Admin::EmailTemplate.new(params[:admin_email_template])

    respond_to do |format|
      if @email_template.save
        format.html { redirect_to(@email_template) }
        format.xml  { render :xml => @email_template, :status => :created, :location => @email_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email_template.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @email_template = Admin::EmailTemplate.find_by_id(params[:id])
    params[:admin_email_template][:from]="\"#{params[:admin_email_template][:from]}\""
    params[:admin_email_template][:subject]="\"#{params[:admin_email_template][:subject]}\""
    @email_template.attributes=params[:admin_email_template]
    if @email_template.valid?
      @message=%Q{<div class="notification success png_bg">
  <a class="close" href="#"><img alt="close" title="Close this notification" src="/images/admin_images/icons/cross_grey_small.png"></img></a>
  <div>Success! Email template updated</div></div>}
      @email_template.update_attributes(params[:admin_email_template])
      flash[:notice]=@message
    else
      errors=[]
      @email_template.errors.each{|attr,msg| errors<<msg }
      @message=%Q{<div class="notification error png_bg">
  <a class="close" href="#"><img alt="close" title="Close this notification" src="/images/admin_images/icons/cross_grey_small.png"></img></a>
  <div>#{errors.join("<br>")}</div></div>}
    end
    render :text=> @message
  end

  def destroy
    @email_template = Admin::EmailTemplate.find_by_id(params[:id])
    @email_template.destroy

    respond_to do |format|
      format.html { redirect_to(admin_email_templates_url) }
      format.xml  { head :ok }
    end
  end
  
  def show_edit
    @email_template = Admin::EmailTemplate.find_by_id(params[:id])
  end
end
