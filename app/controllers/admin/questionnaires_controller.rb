class Admin::QuestionnairesController < AdminAreaController
  
  def index
    @questionnaires = Questionnaire.all
  end

  def new
    @questionnaire = Questionnaire.new
  end

  def show
    if params[:version]
      @current_version = params[:version].to_i
      @questionnaire = Questionnaire.find(params[:id]).versions[@current_version].reify
    else
      @questionnaire = Questionnaire.find(params[:id])
      @current_version = @questionnaire.versions.length
    end
  end

  def edit
    @questionnaire = Questionnaire.find(params[:id])
  end

  def create
    @questionnaire = Questionnaire.new(params[:questionnaire])
    if @questionnaire.save
      redirect_to :action => :show, :id => @questionnaire.id
    else
      render :action => :new
    end
  end

  def update
    logger.info "Finding:"
    @questionnaire = Questionnaire.find(params[:id])
    logger.info "Updating attributes"
    @questionnaire.attributes = params[:questionnaire]

    logger.info "Attributes are now: " + @questionnaire.attributes.inspect
    
    logger.info "Saving"
    if @questionnaire.save
      redirect_to questionnaire_path(@questionnaire)
    else
      render :action => :edit
    end
  end

  def delete
    @questionnaire.delete(params[:id])
  end
  
end