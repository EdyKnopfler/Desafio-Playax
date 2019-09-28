require 'pdf-reader'

class PdfEcadImporter
  CATEGORIES = { 'CA' => 'Author', 'E' => 'Publisher', 'V' => 'Versionist', 'SE' => 'SubPublisher' }
  
  def self.valid_iswc?(iswc)
    match = iswc =~ /^.-...\....\....-./
    match != nil
  end
  
  def self.valid_share?(share)
    match = share =~ /^\d{1,3},/
    match != nil
  end
  
  def initialize(pdf_file)
    @works = []
    @current_work = nil
    reader = PDF::Reader.new(pdf_file)
    reader.pages.each do |page|
      lines = page.text.split("\n")
      lines.each do |line|
        next if line == ''
        self.process_line(line)
      end
    end
    self.save_pending_work
  end
  
  def process_line(line)
      if line.length >= 27 and self.class.valid_iswc?(line[13..27])      
        self.save_pending_work
        @current_work = self.class.work(line)
        @current_work[:right_holders] = []
      elsif @current_work != nil
        holder = self.class.right_holder(line)
        @current_work[:right_holders] << holder if holder != nil
      end
  end
  
  def save_pending_work
    @works << @current_work if @current_work != nil
  end
  
  def self.right_holder(line)
    return nil if line.length < 139 
    share_field = line[110..139].strip 
    return nil if not self.valid_share?(share_field)
    ipi_field = line[77..88].strip
    {
      :name => line[13..51].strip,
      :pseudos => [{:name => line[52..76].strip, :main => true}],
      :role => CATEGORIES[line[107..111].strip],
      :society_name => line[90..106].strip,
      :ipi => if ipi_field != '' 
                ipi_field.gsub('.', '')
              else 
                nil 
              end,
      :external_ids => [{:source_name => 'Ecad', :source_id => line[0..12].strip}],
      :share => share_field.sub(',', '.').to_f
    }
  end

  def self.work(line)
    iswc_field = line[13..27]
    return nil if not self.valid_iswc?(iswc_field)
    {
      :iswc => iswc_field.strip,
      :title => line[37..96].strip,
      :external_ids => [{:source_name => 'Ecad', :source_id => line[0..12].strip}],
      :situation => line[97..111].strip,
      :created_at => line[112..121]
    }
  end

  def works
    @works
  end
end
