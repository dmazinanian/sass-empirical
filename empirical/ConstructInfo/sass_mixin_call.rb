require_relative 'sass_construct'

class SassMixinCall < SassConstruct

  attr_accessor :mixin_declaration
  attr_reader :number_of_multi_valued_arguments
  attr_reader :original_mixin_reference
  attr_reader :parents_to_root

  def initialize(mixin_reference, parents_ro_root, number_of_multivalued_args, sass_style_sheet, sass_style_sheet_path)
    super(mixin_reference, sass_style_sheet, sass_style_sheet_path)
    @original_mixin_reference = mixin_reference
    @number_of_multi_valued_arguments = number_of_multivalued_args
    @parents_to_root = parents_ro_root
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

  def get_parent_rules
    @parents_to_root
  end

  def get_callers(all_mixin_calls)

    callers = []

    @parents_to_root.each do |parent|
      if parent.kind_of?(Sass::Tree::RuleNode)
        rule_name = SassASTQueryHandler.remove_illegal_chars(parent.rule.join)
        if callers.empty?
          callers << rule_name
        else
          callers.each_with_index do |caller, index|
            callers[index] = rule_name + " " + caller
          end
        end
      elsif parent.kind_of?(Sass::Tree::MixinDefNode)
        callers_for_mixin = []
        all_mixin_calls.each do |other_mixin_call|
          if other_mixin_call.mixin_declaration.nil?
            puts "No mixin declaration was found for #{other_mixin_call.mixin_name} in #{@path_to_style_sheet}."
          else
            if other_mixin_call.mixin_declaration.mixin_name.eql?(SassASTQueryHandler.remove_illegal_chars(parent.name))
              callers_for_mixin.concat(other_mixin_call.get_callers(all_mixin_calls))
            end
          end
        end
        callers_for_mixin.each_with_index do |caller, index|
          callers.each do |caller_up_to_now|
            callers_for_mixin[index] = caller + " " + caller_up_to_now
          end
        end
        callers = callers_for_mixin
      #elsif parent.kind_of?(Sass::Tree::MediaNode)
      else
        puts "The mixin is called in #{parent.class}, I don't know what to do with it."
      end
    end

    callers

  end

end