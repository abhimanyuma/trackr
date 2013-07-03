class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index,:show,:edit,:update,:destroy]
  before_filter :correct_user, only: [:edit,:update]
  before_filter :admin_user, only: [:destroy,:editlevel]
  def index

    @counterstart=1;
    if current_user.superadmin?
      @users=User.all
    else
      @users=User.where(level: Global.level[:superadmin] .. Global.level[:disabled])
    end
    @pagenum= params[:page]? params[:page].to_i : 1
    @counterstart=(User.per_page*(@pagenum-1))+1
    respond_to do |format|
      format.html
      format.json do 
        @allusers = User.where(level: Global.level[:superadmin] .. Global.level[:disabled]).where("name like ?", "%#{params[:q]}%") 
        render :json => @allusers 
        
      end
      @usr=User.all
      format.csv { render text: User.to_csv() }
      #format.xlsx { send_data @usr.to_csv(col_sep: "\t") }
      format.xlsx
    end
    
  end
  def show
  	@user=User.find(params[:id])
  end

  def new
  	@user= User.new
  end

  def create
  	@user = User.new (params[:user])
  	if @user.save
      @team=Team.new
      @team.name=@user.name
      @team.user_tokens="#{@user.id}"
      @team.set_single
      @team.save
      sign_in @user
  		flash[:success] = "Welcome to the Sample App!"
      
  		redirect_to @user
      
  	else
  		render 'new'
  	end
  end

  def editlevel
    @user=User.find(params[:id])
    level=params[:level]
    if level
      @user.level = level
    else
      @user.level = 127
    end
    @user.save
    redirect_to users_path
  end
  def User.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |user|
        csv << user.attributes.values_at(*column_names)
      end
    end
  end
  def edit
    @user=User.find(params[:id])
  end

  def update
    @user=User.find(params[:id])
    if @user.update_attributes(params[:user])
        flash[:success]="Profile updated"
        sign_in @user
        redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success]="User Removed"
    redirect_to users_url
  end

  private
    def correct_user
      @user=User.find(params[:id])

      redirect_to root_path, error:"Access Denied" unless current_user?(@user)
    end

end
