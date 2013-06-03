class CompaniesController < ApplicationController
	before_filter :signed_in_user, only: [:index,:show,:edit,:update,:destroy]
    #before_filter :correct_user, only: []
  before_filter :admin_user, only: [:edit,:update,:destroy,:new]
  def new
  	@company=Company.new
  end
  def create
  	@company = Company.new (params[:company])
  	if @company.save
      #sign_in @user
  		flash[:success] = "Welcome to the Sample App!"
      
  		  redirect_to @company
      
  	else
  		render 'new'
  	end
  end
  def show
    @company=Company.find(params[:id])
  end
  def edit
    @company=Company.find(params[:id])
  end
  def destroy
  end
  def index
    @counterstart=1;
    if current_user.admin?
      @companies=Company.all
    end
    
  end
  def update
    @company=Company.find(params[:id])
    if @company.update_attributes(params[:company])
        flash[:success]="Profile updated"
        #sign_in @user
        redirect_to @company
    else
      render 'edit'
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
