require_relative 'sass_construct'

class SassVariable < SassConstruct

  attr_reader :type
  attr_reader :scope
  attr_reader :functionName

  def initialize(sass_node, scope, type, funcname, style_sheet, style_sheet_path)

    super(sass_node, style_sheet, style_sheet_path)
    @sass_variable_node = sass_node
    @scope = scope
    @type = type
    @functionName = funcname

  end

  def name
    SassASTQueryHandler.remove_illegal_chars(@sass_variable_node.to_sass)
  end

  def to_s
    "$#{name}"
  end

  def hash
    31 * super.hash + name.hash
  end

end