require_relative 'sass_construct'
class SassExtend < SassConstruct

  attr_reader :extend_node

  def initialize(extend_node, style_sheet, path_to_style_sheet)
    super(extend_node, style_sheet, path_to_style_sheet)
    @extend_node = extend_node
  end

  def target_selector_name
    @extend_node.selector.join
  end

  def special_hash_string
    to_s
  end

  def hash
    prime = 31
    prime * super.hash + special_hash_string.hash
  end

  def to_s
    "@extend #{target_selector_name}"
  end

end