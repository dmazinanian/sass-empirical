require File.join(File.dirname(__FILE__), '../../../Sass/lib', 'sass')
require_relative 'sass_construct'

class SassImport < SassConstruct

  attr_reader :imported_file_absolute_path
  attr_reader :original_import_node

  def initialize(import_node, style_sheet, style_sheet_path)
    super( import_node, style_sheet, style_sheet_path)
    @original_import_node = import_node
    @imported_file_absolute_path = import_node.imported_file.options[:filename]
  end

  def could_find_url
    File.exist?(@imported_file_absolute_path)
  end

  def imported_styleSheet
    Sass::Engine.for_file(@imported_file_absolute_path, {:cache => false}).to_tree
  end

  def to_s
    "@import #{@imported_file_absolute_path}"
  end

  def hash
    prime = 31;
    result = prime * super.hash + imported_file_absolute_path.hash
    result
  end

end