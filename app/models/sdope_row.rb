class SdopeRow < ApplicationRecord

def self.import(file)
 
 
 csv_text = File.read(file.path, liberal_parsing: true)
 # csv_text = File.read('D:\DATI\Segreteria\Produttivita\csvMiei\SDOPE.csv', liberal_parsing: true)
 
 csv = CSV.parse(csv_text, :headers => true, :col_sep => ';', encoding:'iso-8859-1:utf-8')
  csv.each do |row|
    ls = SdopeRow.where(matricola: row[1])
	if ls.length > 0
	then
	 l = ls.first
	 #l.codsdope = row[0]
	 l.nominativo = row[2].upcase
	 l.livello = row[3]
	 l.figuracod = row[4]
	 l.figurades = row[5]
	 l.ruolo = row[6]
	 #l.assenza = row[7]
	 #l.assegnazione = row[8]
	 l.titolo1 = row[9]
	 l.titolo2 = row[10]
	 l.titolo3 = row[11]
	 l.titolo4 = row[12]
	 l.save
	
    else
    SdopeRow.create!(
	                 :matricola => row[1],
							  :nominativo => row[2],
							  :livello => row[3],
							  :figuracod => row[4],
							  :figurades => row[5],
							  :ruolo => row[6],
							  #:assenza => row[7],
							  #:assegnazione => row[8],
							  :titolo1 => row[9],
							  :titolo2 => row[10],
							  :titolo3 => row[11],
							  :titolo4 => row[12])
  end
end
end


end
