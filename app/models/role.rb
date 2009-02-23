class Role < ActiveRecord::Base
  has_and_belongs_to_many :children, :join_table => :role_parent_child,
    :class_name => 'Role', :foreign_key => "parent_id",
    :association_foreign_key => "child_id"
  
  has_and_belongs_to_many :users
  
  def in_role?(role, visited = Set.new)
    if visited.include?(name)
      raise "recursive role structure!  found #{name} twice!"
    end
      
    visited << self

    if role.is_a?(Role)
      role = role.name
    else
      role = role.to_s
    end
      
    return true if role == name
      
    children.each do |child|
      return true if child.in_role?(role, visited)
    end
      
    false
  end
end

