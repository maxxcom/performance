class SettingsController < ApplicationController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]
  before_action :check_login

  # GET /settings
  # GET /settings.json
  def index
    @settings = Setting.all
  end

  # GET /settings/1
  # GET /settings/1.json
  def show
  end

  # GET /settings/new
  def new
    @setting = Setting.new
  end

  # GET /settings/1/edit
  def edit
  end

  # POST /settings
  # POST /settings.json
  def create
    @setting = Setting.new(setting_params)

    respond_to do |format|
      if @setting.save
        format.html { redirect_to @setting, notice: 'Setting was successfully created.' }
        format.json { render :show, status: :created, location: @setting }
      else
        format.html { render :new }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/1
  # PATCH/PUT /settings/1.json
  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to @setting, notice: 'Setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @setting }
      else
        format.html { render :edit }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/1
  # DELETE /settings/1.json
  def destroy
    @setting.destroy
    respond_to do |format|
      format.html { redirect_to settings_url, notice: 'Setting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def importa_tabelle_base
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    
	ris = Setting.import_tabelle_base(params[:file]) #pure viene lanciato il metodo del model
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  
  end
  
  def importazione_tabelle_base
    
  end
  
  def esporta_tabelle_base
   data_organico = Time.now.strftime("%d-%m-%Y")
   ente = Setting.where(denominazione: "ente").first != nil ? Setting.where(denominazione: "ente").first.value : "_"
   anno = Setting.where(denominazione: "anno").first != nil ? Setting.where(denominazione: "anno").first.value : "_"
   nomefile = "TabelleDiBase_" + ente + "_" + anno + "_" + data_organico + ".xlsx"	
   
   exfile = WriteXLSX.new(nomefile)
   worksheet1 = exfile.add_worksheet(sheetname = 'Settings')
   worksheet2 = exfile.add_worksheet(sheetname = 'TipiUfficio')
   worksheet3 = exfile.add_worksheet(sheetname = 'CategorieDipendenti')
   worksheet_tipologie = exfile.add_worksheet(sheetname = 'TipologieDipendenti')
   worksheet4 = exfile.add_worksheet(sheetname = 'FattoriValutazione')
   worksheet5 = exfile.add_worksheet(sheetname = 'AreeValutazione')
   worksheet6 = exfile.add_worksheet(sheetname = 'PercentualiCalcolo')
   worksheet7 = exfile.add_worksheet(sheetname = 'PercentualiFTE')
   worksheet_periodi = exfile.add_worksheet(sheetname = 'Periodi')
   
   format1 = exfile.add_format # Add a format
	format1.set_font('Arial')
	format1.set_size(8)
	format1.set_align('left')
	format2 = exfile.add_format # Add a format
	format2.set_font('Arial')
	format2.set_size(8)
	format2.set_align('center')
	format3 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'yellow'})
	
	worksheet1.set_column('A:A', 20)
	worksheet1.set_column('B:B', 20)
	worksheet1.set_column('C:C', 20)
	worksheet1.set_column('D:D', 20)
	worksheet1.set_column('E:E', 20)
	
	worksheet1.write(0, 0, "denominazione", format1)
	worksheet1.write(0, 1, "value", format1)
	worksheet1.write(0, 2, "descrizione", format1)
	
	index = 1
	Setting.all.each do |s|
	 worksheet1.write(index, 0, s.denominazione, format1)
	 worksheet1.write(index, 1, s.value, format1)
	 worksheet1.write(index, 2, s.descrizione, format1)
	 
	 index = index + 1
	end
	
	worksheet2.set_column('A:A', 20)
	worksheet2.set_column('B:B', 20)
	worksheet2.set_column('C:C', 20)
	worksheet2.set_column('D:D', 20)
	worksheet2.set_column('E:E', 20)
	
	worksheet2.write(0, 0, "denominazione", format1)
	
	
	index = 1
	OfficeType.all.each do |s|
	 worksheet2.write(index, 0, s.denominazione, format1)
	 
	 index = index + 1
	end
	
	worksheet3.set_column('A:A', 20)
	worksheet3.set_column('B:B', 20)
	worksheet3.set_column('C:C', 20)
	worksheet3.set_column('D:D', 20)
	worksheet3.set_column('E:E', 20)
	
	worksheet3.write(0, 0, "denominazione", format1)
	worksheet3.write(0, 1, "descrizione", format1)
	
	index = 1
	Category.all.each do |s|
	 worksheet3.write(index, 0, s.denominazione, format1)
	 worksheet3.write(index, 1, s.descrizione, format1)
	 
	 index = index + 1
	end
	
	worksheet_tipologie.set_column('A:A', 20)
	worksheet_tipologie.set_column('B:B', 20)
	worksheet_tipologie.set_column('C:C', 20)
	worksheet_tipologie.set_column('D:D', 20)
	worksheet_tipologie.set_column('E:E', 20)
	
	worksheet_tipologie.write(0, 0, "denominazione", format1)
	worksheet_tipologie.write(0, 1, "descrizione", format1)
	
	index = 1
	QualificationType.all.each do |s|
	 worksheet_tipologie.write(index, 0, s.denominazione, format1)
	 
	 
	 index = index + 1
	end
	
	worksheet4.set_column('A:A', 20)
	worksheet4.set_column('B:B', 20)
	worksheet4.set_column('C:C', 20)
	worksheet4.set_column('D:D', 20)
	worksheet4.set_column('E:E', 20)
	
	worksheet4.write(0, 0, "denominazione", format1)
	worksheet4.write(0, 1, "descrizione", format1)
	worksheet4.write(0, 2, "peso_sg", format1)
	worksheet4.write(0, 3, "peso_dirigenti", format1)
	worksheet4.write(0, 4, "peso_po", format1)
	worksheet4.write(0, 5, "peso_preposti", format1)
	worksheet4.write(0, 6, "peso_nonpreposti", format1)
	worksheet4.write(0, 7, "max", format1)
	worksheet4.write(0, 8, "min", format1)
	worksheet4.write(0, 9, "ordine_apparizione", format1)
	
	index = 1
	Vfactor.all.each do |s|
	
	 worksheet4.write(index, 0, s.denominazione, format1)
	 worksheet4.write(index, 1, s.descrizione, format1)
	 worksheet4.write(index, 2, s.peso_sg, format1)
	 worksheet4.write(index, 3, s.peso_dirigenti, format1)
	 worksheet4.write(index, 4, s.peso_po, format1)
	 worksheet4.write(index, 5, s.peso_preposti, format1)
	 worksheet4.write(index, 6, s.peso_nonpreposti, format1)
	 worksheet4.write(index, 7, s.max, format1)
	 worksheet4.write(index, 8, s.min, format1)
	 worksheet4.write(index, 9, s.ordine_apparizione, format1)
	 
	 index = index + 1
	end
	
	worksheet5.set_column('A:A', 20)
	worksheet5.set_column('B:B', 20)
	worksheet5.set_column('C:C', 20)
	worksheet5.set_column('D:D', 20)
	worksheet5.set_column('E:E', 20)
	
	worksheet5.write(0, 0, "denominazione", format1)
	worksheet5.write(0, 1, "descrizione", format1)
	
	index = 1
	ValuationArea.all.each do |s|
	 worksheet5.write(index, 0, s.denominazione, format1)
	 worksheet5.write(index, 1, s.descrizione, format1)
	 
	 index = index + 1
	end
	
	worksheet6.set_column('A:A', 20)
	worksheet6.set_column('B:B', 20)
	worksheet6.set_column('C:C', 20)
	worksheet6.set_column('D:D', 20)
	worksheet6.set_column('E:E', 20)
	
	worksheet6.write(0, 0, "AreaValutazione", format1)
	worksheet6.write(0, 1, "TipologiaDipendenti", format1)
	worksheet6.write(0, 2, "Categoria", format1)
	worksheet6.write(0, 3, "Percentuale", format1)
	
	index = 1
	ValuationQualificationPercentage.all.each do |v|
	 valuation_area_id = v.valuation_area_id
	 qualification_type_id = v.qualification_type_id
	 category_id = v.category_id
	 
	 a = ValuationArea.find(valuation_area_id)
	 q = QualificationType.find(qualification_type_id)
	 c = Category.find(category_id)
	 worksheet6.write(index, 0, a.denominazione, format1)
	 worksheet6.write(index, 1, q.denominazione, format1)
	 worksheet6.write(index, 2, c.denominazione, format1)
	 worksheet6.write(index, 3, v.percentuale, format1)
	 
	 index = index + 1
	end
	
	worksheet7.set_column('A:A', 20)
	worksheet7.set_column('B:B', 20)
	worksheet7.set_column('C:C', 20)
	worksheet7.set_column('D:D', 20)
	worksheet7.set_column('E:E', 20)
	
	worksheet7.write(0, 0, "categoria", format1)
	worksheet7.write(0, 1, "percentuale", format1)
	
	index = 1
	FtePercentage.all.each do |f|
	 if f.category_id != nil
	   c = Category.find(f.category_id)
	   worksheet7.write(index, 0, c != nil ? c.denominazione.to_s : "-", format1)
	   worksheet7.write(index, 1, f.percentuale.to_s, format1)
	 
	   index = index + 1
	 end
	end
	
	worksheet_periodi.set_column('A:A', 20)
	worksheet_periodi.set_column('B:B', 20)
	worksheet_periodi.set_column('C:C', 20)
	worksheet_periodi.set_column('D:D', 20)
	worksheet_periodi.set_column('E:E', 20)
	
	worksheet_periodi.write(0, 0, "denominazione", format1)
	worksheet_periodi.write(0, 1, "data_inizio", format1)
	worksheet_periodi.write(0, 2, "data_fine", format1)
	worksheet_periodi.write(0, 3, "stato_aperto", format1)
	
	index = 1
	Period.all.each do |p|
	 worksheet_periodi.write(index, 0, p.denominazione, format1)
	 worksheet_periodi.write(index, 1, p.data_inizio.to_s, format1)
	 worksheet_periodi.write(index, 2, p.data_fine.to_s, format1)
	 worksheet_periodi.write(index, 3, p.stato_aperto.to_s, format1)
	 index = index + 1
	end
    
	exfile.close
	send_file nomefile
   
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_setting
      @setting = Setting.find(params[:id])
    end
	
	def check_login
	 if !logged_in? then redirect_to root_url end
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def setting_params
      params.require(:setting).permit(:denominazione, :value, :descrizione)
    end
end
