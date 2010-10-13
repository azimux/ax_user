class AddLastLoginToUsers < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :users, :last_login, :datetime
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :users, :last_login
    end
  end
end
