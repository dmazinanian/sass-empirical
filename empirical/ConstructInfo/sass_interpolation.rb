require_relative 'sass_construct'

class SassInterpolation < SassConstruct

  def initialize(interpolation_node, style_sheet, path_to_style_sheet)
    super(interpolation_node, style_sheet, path_to_style_sheet)
    @interpolation_node = interpolation_node
  end

  def variable_name_as_string
    @interpolation_node.to_sass
  end

  def to_s
    variable_name_as_string
  end

  def hash
    31 * super.hash + variable_name_as_string.hash
  end

end