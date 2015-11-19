require_relative 'sass_construct'

class SassSelector < SassConstruct

  attr_reader :name
  attr_reader :parent_name
  attr_reader :parent_line
  attr_reader :parent_type
  attr_reader :number_of_base_selectors
  attr_reader :number_of_nestable_selectors
  attr_reader :number_of_declarations
  attr_reader :has_nesting
  attr_reader :type


  def initialize(selector_node, parents, has_nesting, type, style_sheet, style_sheet_path)
    super(selector_node, style_sheet, style_sheet_path)
    @selector_node = selector_node
    @parents = parents
    @has_nesting = has_nesting
    @type = type
    @name = selector_node.kind_of?(Sass::Tree::MediaNode) ?
        '@media' : SassASTQueryHandler.remove_illegal_chars(selector_node.rule.join)
  end


  def set_parent_info(parent_name, parent_line, parent_type)
    @parent_name = parent_name
    @parent_line = parent_line
    @parent_type = parent_type
  end

  def set_body_info(number_of_base_selectors, number_of_nestable_selectors, number_of_declarations)

    @number_of_base_selectors = number_of_base_selectors
    @number_of_nestable_selectors = number_of_nestable_selectors
    @number_of_declarations = number_of_declarations

  end

  def level
    @parents.size
  end

  def fully_qualified_name

    f_qualified_name = ''

    @parents.each_with_index do |parent, index|
      f_qualified_name << parent
      if index < @parents.size - 2
        f_qualified_name << ' '
      end
    end

    if @parents.size > 0
      f_qualified_name << ' '
    end

    f_qualified_name << name

    f_qualified_name

  end

  def hash
    prime = 31
    prime * super.hash + fully_qualified_name.hash
  end

  def to_s
    fully_qualified_name
  end

end