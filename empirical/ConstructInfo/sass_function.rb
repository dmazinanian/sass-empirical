require_relative 'sass_construct'

class SassFunction < SassConstruct

  attr_reader :function_node

  def initialize(function_node, style_sheet, style_sheet_path)
    super(function_node, style_sheet, style_sheet_path)
    @function_node = function_node
  end

  def name
    @function_node.name
  end

  def to_s
    "@#{name}"
  end

  def hash
    31 * super.hash + name.hash
  end

end