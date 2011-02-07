require 'addressable/uri'

class AnswersController < ApplicationController
  before_filter :find_questionnaire, :only => [:index, :show, :edit, :create, :update]
  before_filter :find_patient
  append_before_filter :find_answer, :only => [:show, :edit, :update]

  # SECURITY CRITICAL
  before_filter :ip_check_for_api_methods, :only => [:index]
  before_filter :verify_token, :only => [:show, :edit, :update]

  before_filter :remember_token_in_session
  before_filter :remember_return_url_in_session
  before_filter :remember_display_mode_in_session
  before_filter :check_aborted, :only => [:create, :update]

  protect_from_forgery :except => [:edit, :update]  
  
  respond_to :html, :json, :xml

  def check_aborted
    if (params[:commit] == "Onderbreken" and @questionnaire.abortable) or
       (params[:commit] == "Toch opslaan" and session[:display_mode] == "bulk")
      params[:answer] ||= HashWithIndifferentAccess.new
      params[:answer][:aborted] = true
    else
      params[:answer] ||= HashWithIndifferentAccess.new
      params[:answer][:aborted] = false
    end
  end

  def index
    @answers = if @patient_id and @questionnaire
                 Answer.where(:patient_id => @patient_id, :questionnaire_id => @questionnaire.id)
               elsif @questionnaire
                 @questionnaire.answers.all
               elsif @patient_id
                 Answer.where(:patient_id => @patient_id)
               else
                 Answer.all
               end
    respond_with @answers
  end

  def show
    respond_with @answer
  end

  def edit
    render :action => "answers/#{session[:display_mode]}/edit"
  end

  def create
    @answer = @questionnaire.answers.create(params[:answer])
            
    respond_to do |format|
      format.json { render :json => @answer}
    end
  end
  
  def update
    respond_to do |format|
      #Update_attributes also validates
      if @answer.update_attributes(params[:answer])
        if session[:return_url]
          address = Addressable::URI.parse(session[:return_url])
          address.query_values = (address.query_values || {}).merge(:key => session[:return_token], :return_from => "quby")
          logger.info address.to_s
          redirect_to address.to_s and return
        else
          render :action => "completed" and return
        end
      else
        flash.now[:notice] = "De vragenlijst is nog niet volledig ingevuld." if session[:display_mode] != "bulk"
        format.html { render :action => "answers/#{session[:display_mode]}/edit" }
        format.json { render :json => @answer.errors.to_json }
      end      
    end
  end

  protected

  def find_questionnaire
    if params[:questionnaire_id]
      @questionnaire = Questionnaire.find_by_key(params[:questionnaire_id])
      
      unless @questionnaire
        render :text => "Questionnaire not found", :status => 404
        return false
      end
    end
  end

  def find_patient
    if params[:patient_id]
      @patient_id = params[:patient_id]
    end
  end

  def find_answer
    @answer = @questionnaire.answers.find(params[:id]) 
  end

  def verify_token
    return true if Rails.env.development?
    
    unless @answer.token == (params[:token] || session[:answer_token])
      render :text => "Invalid token, or no token given"
      return false
    end
  end

  def remember_token_in_session
    if params[:token]
      session[:answer_token] = params[:token]
    end
  end

  def remember_return_url_in_session
    if params[:return_url]
      session[:return_url] = CGI.unescape(params[:return_url])
      session[:return_token] = params[:return_token]
    end
  end

  def remember_display_mode_in_session
    if params[:display_mode] and ["paged", "bulk"].include?(params[:display_mode])
      session[:display_mode] = params[:display_mode] if params[:display_mode]
    end

    session[:display_mode] = "paged" if session[:display_mode].blank?
  end

end
