class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user
  
    if @document.save
      flash[:notice] = "Documento salvo com sucesso."
      redirect_to documents_path
    else
      flash[:alert] = "Falha ao salvar o documento."
      render :new
    end
  end
  

  def index
    @documents = current_user.documents
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
