require 'pdf-reader'

module Importers
  class PdfEcad

    CATEGORIES = {"CA" => "Author", "E" => "Publisher", "V" => "Versionist", "SE" => "SubPublisher"}

    def initialize(path)
      reader = PDF::Reader.new(path)
      @raw_data = ''
      reader.pages.each do |page|
        @raw_data << clean(page.text) #removes titles, details, empty and broken lines
      end
    end

    def works
      work_array = []
      @raw_data.each_line{ |l|
        if is_work? l #check if it is a work or right holder entry
          work_array << work(l) #add a new work
        else
          work_array[-1][:right_holders] << right_holder(l) #add a new right holder into a work
        end 
      } 
      work_array
    end
  
    def right_holder(line)
      if is_work? line #match to iswc code
        nil 
      else
        right_holder = {}
        name = /([A-Z.]+\s)+([A-Z.]+)/.match(line)[0]
        nick = /([A-Z.]+\s)+([A-Z.]+)/.match(line.gsub(/#{name}/,''))
        right_holder[:name] = name
        right_holder[:pseudos] = [{:name => safe(nick), :main => true}]
        right_holder[:ipi] = format_ipi(safe(/\d{3}\.\d{2}.\d{2}.\d{2}/.match(line)))
        right_holder[:share] = /(\d*)\,(\d{2})?/.match(line)[0].gsub(/\,/, '.').gsub(/\.$/, '.00').to_f
        right_holder[:role] = CATEGORIES[/[A-Z][A-Z]?(?=\s*\d+\,)/.match(line)[0]]
        right_holder[:society_name] = safe(/(?<=\d\s)[A-Z]+(?=\s+[A-Z]{1,2}\s+\d)/.match(line))
        right_holder[:external_ids] = [{:source_name => 'Ecad', :source_id => /\d+/.match(line)[0]}]
        right_holder
      end
    end 

    def work(line)
      if is_work? line
        work = {} 
        work[:iswc] = /[A-Z]?-.+\..+-\d?/.match(line)[0] 
        work[:title] = /[A-Z][A-Z0-9\(\)\s]+[A-Z0-9\(\)](?=\s+[A-Z]{2})/.match(line)[0] 
        work[:external_ids] = [{:source_name => 'Ecad', :source_id => /\d+/.match(line)[0]}]
        work[:situation] = /[A-Z]{2}(?=\s+\d{2}\/)/.match(line)[0]
        work[:created_at] = /\d{2}\/\d+\/\d+/.match(line)[0]
        work[:right_holders] = []
        work
      else
        nil
      end
    end

    def safe(vault) if vault.nil? then nil else vault[0] end end

    def format_ipi(ipi) if ipi.nil? then nil else ipi.gsub(/\./,'') end end

    def is_work?(line) !!(line =~ /.+.-.+\..+-..+/) end

    def clean(text) text.gsub(/^$\n/, '').gsub(/\n\s+(?=.+\,)/, ' ').gsub(/^(\s.+|\D.+|\d{2}\/.+)$\n?/, '') end

  end

end
