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
    get_caller_rule_nodes(all_mixin_calls).each do |d|
      begin
        compiled = Sass.compile(d.to_scss)
        compiled_ast = Sass::Engine.new(compiled, :syntax => :scss).to_tree
        rule = compiled_ast.children[0]
        unless rule.nil?
          rule.children = []
          callers << SassASTQueryHandler.remove_illegal_chars(rule.to_sass)
        else
          raise Sass::SyntaxError.new("Failed to parse #{d.to_scss}")
        end
      rescue Sass::SyntaxError
        callers << SassASTQueryHandler.remove_illegal_chars(d.to_scss.gsub("prop: val;", "").gsub!(/{|}/, ""))
      end
    end
    puts(callers)
    callers
  end

  def get_caller_rule_nodes(all_mixin_calls)

    caller_rules = []

    @parents_to_root.each do |parent|
      if parent.kind_of?(Sass::Tree::RuleNode)
        current = parent.clone
        if caller_rules.empty?
          dummy_style_sheet = Sass::Engine.new(".dummy\n\tprop: val").to_tree
          dummy_declaration = dummy_style_sheet.children[0].children[0]
          current.children = [dummy_declaration]
          caller_rules << current
        else
          caller_rules.each_with_index do |caller_rule, index|
            new_parent = current.clone
            new_parent.children = [caller_rule]
            caller_rules[index] = new_parent
          end
        end
      elsif parent.kind_of?(Sass::Tree::MixinDefNode)
        caller_rules_for_mixin = []
        all_mixin_calls.each do |other_mixin_call|
          if other_mixin_call.mixin_declaration.nil?
            puts "No mixin declaration was found for #{other_mixin_call.mixin_name} in #{@path_to_style_sheet}."
          else
            if other_mixin_call.mixin_declaration.mixin_name.eql?(SassASTQueryHandler.remove_illegal_chars(parent.name))
              caller_rules_for_mixin.concat(other_mixin_call.get_caller_rule_nodes(all_mixin_calls))
            end
          end
        end
        new_caller_rules = []
        caller_rules_for_mixin.each do |caller_for_mixin|
          caller_rules.each do |caller_rule|
            new_parent = caller_for_mixin.clone
            leaf_node = get_leaf(new_parent)
            leaf_node.children = [caller_rule.clone]
            new_caller_rules << new_parent
          end
        end
        caller_rules = new_caller_rules
      end

    end

    caller_rules

  end

  def get_leaf(node)
    leaf = node
    previous_leaf = nil
    while leaf.children.size > 0
      previous_leaf = leaf
      leaf = leaf.children[0]
    end
    if leaf.kind_of? Sass::Tree::PropNode
      leaf = previous_leaf
    end
    leaf
  end

end