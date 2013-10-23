class AnswerAttributesController < ApplicationController
  before_action :set_attribute, only: [:show, :edit, :update, :destroy]

  # GET /attributes
  # GET /attributes.json
  def index
    @attributes = AnswerAttribute.all
  end

  # GET /attributes/1
  # GET /attributes/1.json
  def show
  end

  # GET /attributes/new
  def new
    @attribute = AnswerAttribute.new 
  end

  # GET /attributes/1/edit
  def edit
  end

  # POST /attributes
  # POST /attributes.json
  def create
    @attribute = AnswerAttribute.new(attribute_params)
    @attribute.question_id =  params[:question_id]
    @question = Question.find(params[:question_id])
    respond_to do |format|
      if @attribute.save
        format.html { redirect_to @question, notice: 'Attribute was successfully created.' }
        format.json { render action: 'show', status: :created, location: @attribute }
      else
        format.html { render action: 'new' }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attributes/1
  # PATCH/PUT /attributes/1.json
  def update
    respond_to do |format|
      if @attribute.update(attribute_params)
        format.html { redirect_to @question, notice: 'Attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attributes/1
  # DELETE /attributes/1.json
  def destroy
    @attribute.destroy
    respond_to do |format|
      format.html { redirect_to @question }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attribute
      @attribute = AnswerAttribute.find(params[:id])
      @attribute.question_id= params[:question_id]
      @question = Question.find(params[:question_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attribute_params
      params.require(:answer_attribute).permit(:is_correct, :score, :question_id, :created_at, :updated_at, :description)
    end
end
