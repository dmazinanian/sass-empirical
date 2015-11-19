require_relative 'sass_construct'

class SassMixinCall < SassConstruct

  attr_accessor :mixin_declaration
  attr_reader :number_of_multi_valued_arguments
  attr_reader :original_mixin_reference

  def initialize(mixin_reference, number_of_multivalued_args, sass_style_sheet, sass_style_sheet_path)
    super(mixin_reference, sass_style_sheet, sass_style_sheet_path)
    @original_mixin_reference = mixin_reference
    @number_of_multi_valued_arguments = number_of_multivalued_args
  end

  def mixin_name
    @original_mixin_reference.name
  end

  def number_of_arguments
     @original_mixin_reference.args.length
  end

  def mixin_call_hash_string
    "#{mixin_name}(#{number_of_arguments})"
  end

  def to_s
    mixin_call_hash_string
  end

  def hash
    prime = 31
    result = prime * super.hash + mixin_call_hash_string.hash
    result
  end

end