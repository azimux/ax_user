module RolesHelper
  def print_role(role)
    ret = "<p>#{h role.name}</p>\n"
    if !(children = role.children).blank?
      ret << "<ul>\n"
      children.each do |child| 
        ret << "<li>\n#{print_role(child)}\n</li>\n"
      end 
      ret << "</ul>\n"
    end
    ret
  end 
end
