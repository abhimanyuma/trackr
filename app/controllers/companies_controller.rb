class CompaniesController < ApplicationController
	before_filter :signed_in_user
  before_filter :power_user

    #before_filter :correct_user, only: []
  before_filter :admin_user, only: [:destroy]
  
  autocomplete :user, :name, :full => true 
  def new
  	@company=Company.new
  end
  def create
  	@company = Company.new (params[:company])
    @company.teams << current_user.teams.first
  	if @company.save
      #sign_in @user
  		flash[:success] = "Company created"
      
  		  redirect_to @company
      
  	else
  		render 'new'
  	end
  end
  def show
    @company=Company.find(params[:id])
    can_view_else_redirect (@company)
    @contacts=@company.contacts
    @default=@company.default_contact
    @logs=@company.logs.order("created_at DESC").paginate(page: params[:page])
    @newlog=@company.logs.build
  end
  def edit
    @company=Company.find(params[:id])
    @contacts=@company.contacts.where(:active => true)
    can_view_else_redirect (@company)
  end
  def destroy
    Company.find(params[:id]).destroy
    flash[:success]="Company Profile Deleted."
    redirect_to companies_url
  end
  def index
    @counterstart=1;
    if params[:team_id]
      @source=Team.find(params[:team_id]).companies.all(:include => [:default_contact,:logs,:teams,:pointofcontact])
    elsif params[:user_id]
      @company_ids=[]
      @source=[]
      @user=User.find(params[:user_id])
      @user.teams.each do |team|
        team.companies.each do |company|
          @company_ids << company.id
        end
      end
      @user.contacted_companies.each do |company|
        @company_ids << company.id
      end
      #@company_ids.uniq!
      @source = Company.find_all_by_id(@company_ids,:include => [:default_contact,:logs,:teams,:pointofcontact])
    else
      @source=Company.all(:include => [:default_contact,:logs,:teams,:pointofcontact])
    end
    if current_user.superadmin?
      @companies=@source
    elsif current_user.admin?
      @companies=@source.select{|c| c.active?}
    else
      @companies=[]
      @allcompanies=@source.select{|c| c.active?}
      @allcompanies.each do |company|
        if ((company.teams & current_user.teams).any?) || (company.poc_id == current_user.id)
            @companies << company
        end
      end
      
    end
    @companies=Company.all
    respond_to do |format|
        format.html # /
        format.json { render json: @companies}
        format.csv { render text: Company.to_csv() }
        format.xlsx
    end
  end
  def update
    @company=Company.find(params[:id])
    can_view_else_redirect (@company)
    if @company.update_attributes(params[:company])
        flash[:success]="Profile updated"
        #sign_in @user
        redirect_to @company
    else
      render 'edit'
    end
  end
  def updatestatus
    @company=Company.find(params[:id])
    can_view_else_redirect (@company)
    @log = @company.logs.build(params[:log])
    @prev_status=@company.status_text
    @company.status=params[:status]
    @log.content = "Status changed from #{@prev_status} to #{@company.status_text}"
    @log.user_id=current_user.id
    begin
      @log.save
    rescue Exception => e

    end
    @company.status=params[:status]
    @company.save
    redirect_to @company
  end
  def activity
    @company=Company.find(params[:id])
    can_view_else_redirect (@company)
    @company.active=params[:active] if params[:active]
    @company.save
    redirect_to @company
  end
  def Company.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |company|
        csv << company.attributes.values_at(*column_names)
      end
    end
  end
  private
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end  
    end

    def correct_user
      @user=User.find(params[:id])

      redirect_to root_path, error:"Access Denied" unless current_user?(@user)
    end

     def admin_user
      redirect_to(root_path) unless current_user.admin?
    end


end
