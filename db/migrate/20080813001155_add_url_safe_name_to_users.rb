class AddUrlSafeNameToUsers < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :users, :url_safe_name, :string, :null => true
      add_index :users, :url_safe_name, :unique => true
    
    
      User.all.each do |user|
        user.url_safe_name = User.url_safe_name(user.username)
        user.save!
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :users, :url_safe_name
    end
  end
end
