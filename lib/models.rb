require 'active_record'
#require 'redcloth'
#require 'syntaxi'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "lib/frog.db"
)

class Blog < ActiveRecord::Base
  has_many :entries, :order => 'created_at DESC'
end

class Entry < ActiveRecord::Base
  belongs_to :blog
  
  scope :is_live, where(:is_live => true)
  
  #Syntaxi.line_number_method = 'floating'
  #Syntaxi.wrap_at_column = 80
  
  # TODO : Add the sanitize gem (http://wonko.com/post/sanitize) to raw restrict html input
  
  def html
    return if self.text.blank?

    html = self.text
    
    # s = StringScanner.new(self.text)
    # html = ''
    # while markup = s.scan_until(/\[code/) do
    #   html += RedCloth.new(markup[0..-6]).to_html
    #   s.pos= s.pos-5
    #   code = s.scan_until(/\[\/code\]/)
    #   if code
    #     code.gsub!(/\[code\]/, '[code lang="ruby"]')
    #     html += '<div class="syntax">' + Syntaxi.new(code).process + '</div>'  
    #   else
    #     break
    #   end
    # end
    # html += RedCloth.new(s.rest).to_html
    
    html
  end
  
  def short_uri
    URI.parse(self.slug).host.gsub(/www./, '') rescue self.slug
  end
  
end