class ActivitiesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  def index()
    if params[:city]
      @activities = Activity.where(city: params[:city])
      @param = params[:city]
    elsif params[:category_id]
      @activities = Category.find(params[:category_id]).activities
      @param = Category.find(params[:category_id]).name
    else
      @activities = Activity.where(user: current_user)
    end
  end

  def show
    @booking = Booking.new
  end

  def new
    @activity = Activity.new
  end

  def create
    @user = current_user
    @photo = activity_params[:photo]
    @name = activity_params[:name]
    @description = activity_params[:description]
    @city = activity_params[:city]
    @street = activity_params[:street]
    
    @activity = Activity.new({ name: @name, description: @description, city: @city, street: @street })
    @activity.user = @user
    if @activity.save
      @activity.photo.attach(@photo)
      Group.create({name: @activity.name, activity: @activity})
      Membership.create({user: @user, group: @activity.group})
      redirect_to activity_path(@activity)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @activity.update(activity_params)
    @photo = activity_params[:photo]
    if @activity.save
      @activity.photo.attach(@photo) unless @photo.nil?
      redirect_to activity_path(@activity)
    else
      render :edit
    end
  end

  def destroy
    @activity.destroy

    redirect_to activities_path
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit(:name, :description, :photo, :city, :street)
  end
end
