class Setting < ApplicationRecord

def self.import_tabelle_base(file)
 stringa_filename = file.original_filename
 extension = 'xls'
 xls = Roo::Spreadsheet.open(file.path)
 informazioni = xls.info
 
 fogli = xls.sheets
 fogli.each do |name|
        puts name
        sheet = xls.sheet(name)
		last_row = sheet.last_row
		puts "last_row: " + last_row.to_s
		case name
		when "Settings"
		  indice = 2
		  for row in indice..last_row
			denominazione  = sheet.cell('A',row)
			value = sheet.cell('B',row)
			descrizione = sheet.cell('C',row)
			if Setting.where(denominazione: denominazione).length == 0
			  Setting.create(denominazione: denominazione, value: value, descrizione: descrizione)
			  
			else
			  #eventualmente update
			end
		  end
		
		when "TipiUfficio"
			indice = 2
			for row in indice..last_row
			 denominazione  = sheet.cell('A',row)
			 if OfficeType.where(denominazione: denominazione).length == 0
			  OfficeType.create(denominazione: denominazione)
			  
			 else
			  #eventualmente update
			 end
			end
		
		when "CategorieDipendenti"
			indice = 2
			for row in indice..last_row
			 denominazione  = sheet.cell('A',row)
			 descrizione  = sheet.cell('B',row)
			 if Category.where(denominazione: denominazione).length == 0
			  Category.create(denominazione: denominazione, descrizione: descrizione)
			  
			 else
			  #eventualmente update
			 end
			end
		
		when "TipologieDipendenti"
			indice = 2
			for row in indice..last_row
			 denominazione  = sheet.cell('A',row)
			 
			 if QualificationType.where(denominazione: denominazione).length == 0
			  QualificationType.create(denominazione: denominazione)
			  
			 else
			  #eventualmente update
			 end
			end
		
		when "FattoriValutazione"
			indice = 2
			for row in indice..last_row
			 denominazione  = sheet.cell('A',row)
			 descrizione = sheet.cell('B',row)	
			 peso_sg	= sheet.cell('C',row)
			 peso_dirigenti	= sheet.cell('D',row)
			 peso_po	= sheet.cell('E',row)
			 peso_preposti	= sheet.cell('F',row)
			 peso_nonpreposti	= sheet.cell('G',row)
			 max	= sheet.cell('H',row)
			 min	= sheet.cell('I',row)
			 ordine_apparizione= sheet.cell('J',row)

			 if Vfactor.where(denominazione: denominazione).length == 0
			  Vfactor.create(denominazione: denominazione, 
				descrizione: descrizione,
				peso_sg: peso_sg,
				peso_dirigenti: peso_dirigenti,
				peso_po: peso_po,
				peso_preposti: peso_preposti,
				peso_nonpreposti: peso_nonpreposti,
				max: max,
				min: min,
				ordine_apparizione: ordine_apparizione
			  )
			  
			 else
			  #eventualmente update
			 end
			end
		
		when "AreeValutazione"
			indice = 2
			for row in indice..last_row
			 denominazione  = sheet.cell('A',row)
			 descrizione  = sheet.cell('B',row)
			 if ValuationArea.where(denominazione: denominazione).length == 0
			  ValuationArea.create(denominazione: denominazione, descrizione: descrizione)
			  
			 else
			  #eventualmente update
			 end
			end
		
		when "PercentualiCalcolo"
		    indice = 2
			for row in indice..last_row
			 area_valutazione  = sheet.cell('A',row)
			 tipologia_dipendenti  = sheet.cell('B',row)
			 categoria = sheet.cell('C',row)
			 percentuale = sheet.cell('D',row)
			 
			 a = ValuationArea.where(denominazione: area_valutazione).first
			 t = QualificationType.where(denominazione: tipologia_dipendenti).first
			 c = Category.where(denominazione: categoria).first
			 
			 if (a != nil) && (t != nil) && (c != nil)
			 
			   if ValuationQualificationPercentage.where(valuation_area_id: a.id, qualification_type_id: t.id, category_id: c.id).length == 0
			     vqp = ValuationQualificationPercentage.new
			     vqp.valuation_area = a
			     vqp.qualification_type = t
			     vqp.category = c
				 vqp.percentuale = percentuale
			     vqp.save
			   else
			     vqp = ValuationQualificationPercentage.where(valuation_area_id: a.id, qualification_type_id: t.id, category_id: c.id).first
				 
				 vqp.percentuale = percentuale
			     vqp.save
			   
			   end 
			 
			 end
			end 
		
		when "Periodi"
		    indice = 2
			for row in indice..last_row
			 denominazione  = sheet.cell('A',row)
			 data_inizio  =  Date.parse(sheet.cell('B',row))
			 data_fine =  Date.parse(sheet.cell('C',row))
			 stato_aperto = sheet.cell('D',row)
			 
			 if Period.where(denominazione: denominazione).length == 0
			   p = Period.new
			   p.denominazione = denominazione
			   p.data_inizio = data_inizio
			   p.data_fine = data_fine
			   p.stato_aperto = stato_aperto
			   p.save
			 else 
			   p = Period.where(denominazione: denominazione).first
			   
			   p.data_inizio = data_inizio
			   p.data_fine = data_fine
			   p.stato_aperto = stato_aperto
			   p.save
			   
			 end
			
			end
		
		when "PercentualiFTE"
		    indice = 2
			for row in indice..last_row
			 categoria  = sheet.cell('A',row)
			 percentuale  =  sheet.cell('B',row)
			 
			 c = Category.where(denominazione: categoria).first
			 
			 
			 if c != nil
			   if FtePercentage.where(category_id: c.id).length == 0
			     f = FtePercentage.new
			     f.category = c
			     f.percentuale = percentuale
			     f.save
			   else
			     f = FtePercentage.where(category_id: c.id).first 
			     f.percentuale = percentuale
			     f.save
			   end
			 
			 end
			 
			 
			end 
		
		
		
		end
 
 end
end

def self.disabilita_pagelle_singole
  result = false
  set = Setting.where(denominazione: "disabilita_pagelle_singole").first
  if set != nil
    if set.value.eql? "1" || set.value == "true"
	  result = true
	end
  end
  return result
end

def self.get_data_impegno
  data_impegno = ""
	setting_data_impegno = Setting.where(denominazione: "data_impegno")
	if setting_data_impegno.length > 0
		data_impegno = setting_data_impegno.first.value
	else
		anno = Setting.where(denominazione: "anno")
		if anno.length > 0
	      data_impegno = anno.first.value.to_s + "0101"
		else
		  data_impegno = "20XX0101"
		end 
	end
  return data_impegno

end 

end
