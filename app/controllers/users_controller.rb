class UsersController < ApplicationController
  before_action(:signup_in_session, only: :new)
  before_action(:logged_in_user, only: [:index, :edit, :update])
  before_action(:correct_user, only: [:edit, :update])

  def index
    @users = User.order(:name).page(params[:page]).per(15)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      flash[:success] = "🙋‍♀️ Welcome to TinyTweety"
      redirect_to @user #GET /users/:id
    else
      render :new, status: 403
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit, status: 403
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      store_location #save current url
      flash[:danger] = "Please log in"
      redirect_to login_url, status: 302
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

  def signup_in_session
    if logged_in?
      flash[:danger] = "Log out to register a new account"
      redirect_to root_url, status: 302
    end
  end
end
