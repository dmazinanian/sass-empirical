require_relative 'sass_construct'
require_relative '../../empirical/sass_ast_query_handler'

class SassMixinDeclaration < SassConstruct

  attr_reader :original_mixin_declaration_node
  attr_reader :number_of_declarations
  attr_reader :number_of_declarations_using_parameters
  attr_reader :number_of_non_cross_browser_declarations
  attr_reader :number_of_unique_cross_browser_declarations
  attr_reader :number_of_unique_parameter_used_in_more_than_one_kind_of_declaration
  attr_reader :number_of_declarations_having_only_hard_coded_values
  attr_reader :number_of_unique_parameters_used_in_vendor_specific
  attr_reader :number_of_vendor_specific_sharing_parameter
  attr_reader :number_of_global_variables_accessed

  def initialize(original_mixin_node, style_sheet, style_sheet_path)
    super(original_mixin_node, style_sheet, style_sheet_path)
    @original_mixin_declaration_node = original_mixin_node
    @number_of_declarations = 0
    @number_of_declarations_using_parameters = 0
    @number_of_non_cross_browser_declarations = 0
    @number_of_unique_cross_browser_declarations = 0
    @number_of_unique_parameter_used_in_more_than_one_kind_of_declaration = 0
    @number_of_declarations_having_only_hard_coded_values = 0
    @number_of_unique_parameters_used_in_vendor_specific = 0
    @number_of_vendor_specific_sharing_parameter = 0
    @number_of_global_variables_accessed = 0
  end

  def mixin_name
    SassASTQueryHandler.remove_illegal_chars(@original_mixin_declaration_node.name)
  end

  def number_of_parameters
    @original_mixin_declaration_node.args.length
  end

  def increase_number_of_unique_cross_browser_declarations(i)
    @number_of_unique_cross_browser_declarations += i
  end

  def increase_number_of_non_cross_browser_declarations(i)
    @number_of_non_cross_browser_declarations += i
  end

  def increase_number_of_declarations(i)
    @number_of_declarations += i
  end

  def increase_number_of_declarations_using_parameters(i)
    @number_of_declarations_using_parameters += i
  end

  def increase_number_of_declarations_having_only_hard_coded_values(i)
    @number_of_declarations_having_only_hard_coded_values += i
  end

  def increase_number_of_unique_parameter_used_in_more_than_one_kind_of_declaration(i)
    @number_of_unique_parameter_used_in_more_than_one_kind_of_declaration += i
  end

  def increase_number_of_unique_parameters_used_in_vendor_specific(i)
    @number_of_unique_parameters_used_in_vendor_specific += i
  end

  def increase_number_of_vendor_specific_sharing_parameter(i)
    @number_of_vendor_specific_sharing_parameter += i
  end

  def increase_number_of_global_variables_accessed(i)
    @number_of_global_variables_accessed += i
  end

  def declarations
    SassASTQueryHandler.get_all_declarations(@original_mixin_declaration_node);
  end

  def get_mixin_hash_string
    "#{mixin_name}(#{number_of_parameters})"
  end

  def to_s
    get_mixin_hash_string
  end

  def hash
    prime = 31
    result = prime * super.hash + get_mixin_hash_string.hash
    result
  end

end