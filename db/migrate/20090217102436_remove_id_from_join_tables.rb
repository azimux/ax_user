class RemoveIdFromJoinTables < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      remove_column :role_parent_child, :id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      add_column :role_parent_child, :id, :primary_key
    end
  end
end
