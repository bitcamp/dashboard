class EmailsController < ApplicationController
  before_action :set_email, only: [:show, :edit, :update, :destroy]
  before_action :check_permissions
  def index
    @emails = Email.all
  end


  def show
  end


  def new
    @email = Email.new
  end


  def edit
  end


  def create
    @email = Email.new(email_params)
    @email.sent_by = current_user.full_name
    @email.status = 'Not Sent'

    if @email.save
        redirect_to @email, notice: 'Email was successfully created.'
    else
        render :new
    end
  end

  def update
    if @email.update(email_params)
        redirect_to @email, notice: 'Email was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @email.destroy
      redirect_to emails_url, notice: 'Email was successfully destroyed.'
  end

  def send_email
    # TODO: Perform all of this on a background thread and show a loading bar on UI
    @email = Email.find(params[:email_id])

    if @email.nil?
      redirect_to emails_path, error: 'Error! No email found'
    end

    user_list = set_mailing_list(@email.mailing_list).to_a

    Thread.new do
      user_list.each do |user|
        UserMailer.reminder_email(user, @email.subject, @email.message).deliver_now
      end
      ActiveRecord::Base.connection.close
    end

    @email.status = 'Sent'
    @email.save!
    redirect_to @email, notice: "Success! The email has been delivered to #{apps_list.count} people!"
  end

  # Returns a list of applications whose users we should sent emails to
  def set_mailing_list(list)
    if list == 'Send Test Email to Myself'
      User.where(:user => current_user)
    elsif list == 'Send Email To Those Who Have Not Applied'
      User.where(:event_application => nil)
    elsif list == 'Accepted Applicants'
      User.joins(:event_application).where(:status => 'accepted')
    elsif list == 'Waitlisted Applicants'
      User.joins(:event_application).where(:status => 'waitlisted')
    elsif list == 'Undecided Applicants'
      User.joins(:event_application).where(:status => 'undecided')
    elsif list == 'Denied Applicants'
      User.joins(:event_application).where(:status => 'denied')
    elsif list == 'All Applicants'
      User.joins(:event_application).where.not(:event_application => nil)
    elsif list == 'All Users'
      Users.all
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email
      @email = Email.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.require(:email).permit(:subject, :message, :mailing_list, :status, :sent_by)
    end

    # Only admins and organizers have the ability to create, update, edit, show, and destroy hardware items
    def check_permissions
      unless current_user.is_admin?
        redirect_to hardware_items_path, alert: 'You do not have the permissions to visit this section of hardware'
      end
    end


end
