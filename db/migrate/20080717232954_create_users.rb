class CreateUsers < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :users do |t|
        t.timestamps
      end
      add_column :users, :username, :string, :null => false, 
        :unique => true, :limit => 32
      add_column :users, :password_hash, :string
      add_column :users, :email, :string, :limit => 64
      add_column :users, :verify_code, :string, :limit => 16
      add_column :users, :password_salt, :string, :limit => 8
      add_column :users, :verified, :boolean, :default => false
        
      create_table :forgot_password_codes do |t|
        t.integer :user_id, :null => false, 
          :references => :users, :unique => true
        t.string :code, :null => false, :limit => 16
        t.datetime :created_at, :null => false
        t.timestamps
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(
        "SET CONSTRAINTS ALL DEFERRED"
      )
   
      remove_column :users, :username
      remove_column :users, :password_hash
      remove_column :users, :email
      remove_column :users, :verify_code
      remove_column :users, :password_salt
      remove_column :users, :verified
        

      drop_table :forgot_password_codes
      drop_table :users
    end
  end
end
