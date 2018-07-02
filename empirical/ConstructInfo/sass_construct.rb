class SassConstruct

  attr_reader :style_sheet
  attr_reader :path_to_style_sheet
  attr_reader :start_line
  attr_reader :end_line
  attr_reader :original_sass_node

  def initialize(sass_node, style_sheet, path_to_style_sheet)
    @original_sass_node = sass_node
    @style_sheet = style_sheet
    @path_to_style_sheet = path_to_style_sheet
    source_range = sass_node.source_range
    if source_range.nil?
      @start_line = sass_node.line
      @end_line = sass_node.line
    else
      @start_line = source_range.start_pos.line
      @end_line = source_range.end_pos.line
    end
  end

  def ==(o)
    self.eql?(o)
  end

  def eql?(o)
    self.hash == o.hash
  end

  def hash
    prime = 31
    result = prime + @start_line
    result = prime * result + @end_line
    result = prime * result + @path_to_style_sheet.hash
    result
  end

end