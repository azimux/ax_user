class CreateRoles < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :roles do |t|
        t.string :name, :null => false
        t.timestamps
      end
      
      add_index :roles, :name, :unique => true
    
      create_table :roles_users, :id => false do |t|
        t.integer :user_id, :null => false
        t.integer :role_id, :null => false
      end
      
      create_table :role_parent_child do |t|
        t.integer :parent_id, :null => false, :references => :roles
        t.integer :child_id, :null => false, :references => :roles
      end
      
      r = Role.create(:name => 'admin')
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :roles_users
      drop_table :roles
      drop_table :role_parent_child
    end
  end
end
