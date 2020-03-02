class EventApplicationsController < ApplicationController
  # imports helper methods to the controller
  include EventApplicationsHelper

  before_action -> { is_feature_enabled($Applications) }
  before_action :set_event_application, only: %i[show edit update destroy]
  before_action :check_permissions, only: %i[index destroy status_updated]
  autocomplete :university, :name, full: true
  autocomplete :major, :name, full: true

  def index
    @all_apps_count = EventApplication.all.count
    @accepted_count = EventApplication.where(status: 'accepted').count
    @waitlisted_count = EventApplication.where(status: 'waitlisted').count
    @undecided_count = EventApplication.where(status: 'undecided').count
    @denied_count = EventApplication.where(status: 'denied').count
    @flagged_count = EventApplication.where(flag: true).count
    @rsvp_count = EventApplication.joins(:user).where(users: {rsvp: true}).count

    @flagged = params[:flagged]
    @status = params[:status]
    if ['undecided', 'accepted', 'denied', 'waitlisted'].include?(@status)
      @applications = EventApplication.where({status: @status})
    elsif params[:flagged].present?
      @applications = EventApplication.where(flag: true)
    elsif params[:rsvp].present?
      @applications = EventApplication.joins(:user).where(users: {rsvp: true})
    else
      @applications = EventApplication.all
    end
    @applications = @applications.order(created_at: :asc)
    @posts = @applications.paginate(page: params[:page], per_page: 20)

    @appsCSV = EventApplication.all

    if Rails.env.development?
      @check_in_chart = User.where(:check_in => true).group_by_day(:updated_at).count
      total = 0
      @check_in_chart.keys.each do |k|
        total += @check_in_chart[k]
        @check_in_chart[k] = total
      end

      @reg_chart = User.all.group_by_day(:created_at).count
      total = 0
      @reg_chart.keys.each do |k|
        total += @reg_chart[k]
        @reg_chart[k] = total
      end

      @app_chart = EventApplication.all.group_by_day(:created_at).count
      total = 0
      @app_chart.keys.each do |k|
        total += @app_chart[k]
        @app_chart[k] = total
      end

      @rsvp_chart = User.where(:rsvp => true).group_by_day(:updated_at).count
      total = 0
      @rsvp_chart.keys.each do |k|
        total += @rsvp_chart[k]
        @rsvp_chart[k] = total
      end
    end


    respond_to do |format|
      format.html
      format.csv { send_data @appsCSV.to_csv, filename: "event_applications.csv" }
    end

  end


  def show
    # variable used in erb file
    @applicant = @application
    @status = @application.status
    @user = @application.user

    unless current_user.is_organizer?
      if @user != current_user
        redirect_to index_path, alert: lack_permission_msg if !admin_or_organizer? && @user != current_user
      end
    end
  end

  def new
    @application = EventApplication.new

    if current_user.has_applied?
        redirect_to index_path
        flash[:error] = "You have already created an application."
    end

  end


  def edit
  end


  def create
    puts "params: #{event_application_params}"
    puts "cfields params: #{event_application_params['custom_fields']}"
    @application = EventApplication.new(event_application_params)
    @application.user = current_user
    if HackumassWeb::Application::APPLICATIONS_MODE == 'open'
      @application.status = 'undecided'
    elsif HackumassWeb::Application::APPLICATIONS_MODE == 'waitlist'
      @application.status = 'waitlisted'
    else
      @application.status = 'denied'
    end

    if @application.save
      redirect_to index_path, notice: 'Thank you for submitting your application!'
    else
      render :new
    end
  end

  def update
    @application = @application
    if @application.update(event_application_params)
      redirect_to @application, notice: 'Event application was successfully updated.'
    else
      render :edit
    end
  end


  def destroy
    @application.destroy
    redirect_to event_applications_url, notice: 'Event application was successfully destroyed.'
  end

  def search
    @all_apps_count = EventApplication.all.count
    @accepted_count = EventApplication.where(status: 'accepted').count
    @waitlisted_count = EventApplication.where(status: 'waitlisted').count
    @undecided_count = EventApplication.where(status: 'undecided').count
    @denied_count = EventApplication.where(status: 'denied').count
    @flagged_count = EventApplication.where(flag: true).count

    @flagged = params[:flagged]
    @status = params[:status]
    if ['undecided', 'accepted', 'denied', 'waitlisted'].include?(@status)
      @applications = EventApplication.where({status: @status})
    elsif params[:flagged].present?
      @applications = EventApplication.where(flag: true)
    elsif params[:rsvp].present?
      @applications = EventApplication.joins(:user).where(users: {rsvp: true})
    else
      @applications = EventApplication.all
    end

    if params[:search].present?
      @applications = @applications.joins(:user).where("lower(users.first_name) LIKE lower(?) OR
                                                    lower(users.last_name) LIKE lower(?) OR
                                                    lower(users.email) LIKE lower(?) OR
                                                    lower(major) LIKE lower(?) OR
                                                    lower(name) LIKE lower(?) OR
                                                    lower(university) LIKE lower(?) OR
                                                    lower(status) LIKE lower(?) OR
                                                    lower(education_lvl) LIKE lower(?)",
                                              "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%",
                                              "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%",
                                              "%#{params[:search]}%", "%#{params[:search]}%")
      @posts = @applications.paginate(page: params[:page], per_page: 20)
    else
      redirect_to event_applications_path
    end
  end

  # updates the application status of the applicants.
  def status_updated
    new_status = params[:new_status]
    id = params[:id]
    application = EventApplication.find_by(user_id: id)
    application.status = new_status
    application.save(:validate => false)
    flash[:success] = "Status successfully updated."

    redirect_to event_application_path(application)



    # Send email when status changes.
    if new_status == 'accepted'
      UserMailer.accepted_email(application.user).deliver_now
    elsif new_status == 'denied'
      UserMailer.denied_email(application.user).deliver_now
    else
      UserMailer.waitlisted_email(application.user).deliver_now
    end
  end

  def flag_application
    app_id = params[:application]
    app = EventApplication.find(app_id)
    app.flag = true
    app.save(:validate => false)

    flash[:success] = "Application successfully flagged"

    redirect_to event_application_path(app)
  end

  def unflag_application
    app_id = params[:application]
    app = EventApplication.find(app_id)
    app.flag = false
    app.save(:validate => false)
    flash[:success] = "Flag successfully removed"

    redirect_to event_application_path(app)
  end

   private
  # Use callbacks to share common setup or constraints between actions.
  def set_event_application
    begin
      @application = EventApplication.find(params[:id])
    rescue
      flash[:warning] = 'Upppps looks like you went backwards or forward too much.'
      redirect_to event_applications_path
      return
    end
  end

  def event_application_params
    custom_fields_items = []
    HackumassWeb::Application::EVENT_APPLICATION_CUSTOM_FIELDS.each do |c|
      if c['type'] == 'multiselect'
        custom_fields_items << {c['name'].to_sym => []}
      else
        custom_fields_items << c['name'].to_sym
      end
    end
    params.require(:event_application).permit(:name, :phone, :age, :gender, :pronoun, :university, :major, :grad_year,
                   :food_restrictions, :food_restrictions_info, :t_shirt_size,
                   :resume, :education_lvl,
                   :waiver_liability_agreement, :mlh_agreement,
                   custom_fields: custom_fields_items)
  end

  # Only admins and organizers have the ability to all permission except delete.
  def check_permissions
    redirect_to index_path, alert: lack_permission_msg unless admin_or_organizer?
  end
end
