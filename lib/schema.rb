require 'active_record'

class Schema < ActiveRecord::Migration

  def self.up
    create_table :blogs do |t|
      t.string :title
      t.timestamps
    end unless ActiveRecord::Base.connection.tables.include?('blogs')
    
    create_table :entries do |t|
      t.integer :blog_id
      t.string  :title, :null => false, :default => ''
      t.string  :url, :null => false, :default => ''
      t.string  :slug, :null => false, :default => ''
      t.text    :text, :null => false, :default => ''
      t.boolean :is_live, :null => true, :default => false
      t.timestamps
    end unless ActiveRecord::Base.connection.tables.include?('entries')
  end

  def self.down
    drop_table :blogs if ActiveRecord::Base.connection.tables.include?('blogs')
    drop_table :entries if ActiveRecord::Base.connection.tables.include?('entries')
  end
  
end
