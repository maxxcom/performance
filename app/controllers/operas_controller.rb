class OperasController < ApplicationController
  before_action :set_opera, only: [:show, :edit, :update, :destroy]

  # GET /operas
  # GET /operas.json
  def index
    @operas = Opera.all
  end
  
  def indexfiltro
    if params[:opera] != nil
     @stringa_ricerca = params[:opera][:stringa]
	 @operas = Opera.left_joins(:responsabile).where("lower(operas.descrizione) LIKE lower(?) OR operas.numero LIKE ? OR  people.cognome LIKE ? OR people.nome LIKE ? ", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%" ).order(:id)
	else
     @operas = Opera.all
	 @stringa_ricerca = ""
	end
  end

  # GET /operas/1
  # GET /operas/1.json
  def show
  end

  # GET /operas/new
  def new
    @opera = Opera.new
  end

  # GET /operas/1/edit
  def edit 
    puts "edit"
  end

  # POST /operas
  # POST /operas.json
  def create
    @opera = Opera.new(opera_params)

    respond_to do |format|
      if @opera.save
        format.html { redirect_to @opera, notice: 'Opera was successfully created.' }
        format.json { render :show, status: :created, location: @opera }
      else
        format.html { render :new }
        format.json { render json: @opera.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /operas/1
  # PATCH/PUT /operas/1.json
  def update
    puts "update"
	puts params
	puts "controllo target"
	puts params[:opera][:target]
	new_opera_params = opera_params
	new_opera_params.delete("target")
	if params[:opera][:target] != nil 
	   if params[:opera][:target].length > 3
	    puts "modifico"
	    target_id = params[:opera][:target].split('-')[0].to_s
	    target_type = params[:opera][:target].split('-')[1].to_s
	    
	    new_opera_params.merge({"target_id" => target_id})
		new_opera_params.merge({"target_type" => target_type})
		
		puts new_opera_params
	   end
	end
	puts new_opera_params
    respond_to do |format|
      if @opera.update(new_opera_params)
        format.html { redirect_to @opera, notice: 'Opera was successfully updated.' }
        format.json { render :show, status: :ok, location: @opera }
      else
        format.html { render :edit }
        format.json { render json: @opera.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operas/1
  # DELETE /operas/1.json
  def destroy
    @opera.destroy
    respond_to do |format|
      format.html { redirect_to operas_url, notice: 'Opera was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def importazione_opere
    @dirigenti = Person.dirigenti
  end
  
  def importa_opere
    
	responsabile = Person.find(params[:person][:id])
	puts responsabile.cognome
    filename = params[:file].original_filename
	puts "FILENAME " + filename
	
	importati = Opera.importa(params[:file], responsabile) # viene lanciato il metodo del model
    @opere = importati[0]
	@opere_modificate = importati[1]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end

  def importazione_valori_opere
    @dirigenti = Person.dirigenti
  end
  
  def importa_valori_opere
    
	responsabile = Person.find(params[:person][:id])
	puts responsabile.cognome
    filename = params[:file].original_filename
	puts "FILENAME " + filename
	
	importati = Opera.importa_valori(params[:file], responsabile) # viene lanciato il metodo del model
    @opere = importati[0]
	@opere_modificate = importati[1]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_opera
      @opera = Opera.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def opera_params
      params.require(:opera).permit(:numero, :sub, :descrizione, :anno, :ente, :target_id, :target_type, :target, :responsabile_id)
    end
end
