require_relative '../empirical/ConstructInfo/sass_import'
require_relative '../empirical/ConstructInfo/sass_mixin_call'
require_relative '../empirical/ConstructInfo/sass_mixin_declaration'
require_relative '../empirical/ConstructInfo/sass_extend'
require_relative '../empirical/ConstructInfo/sass_selector'
require_relative '../empirical/ConstructInfo/sass_variable'
require_relative '../empirical/ConstructInfo/sass_interpolation'
require_relative '../empirical/ConstructInfo/sass_function'

class SassASTQueryHandler

  attr_reader :imported_from

  def initialize(sass_style_sheet_path, imported_from = nil)

    @sass_style_sheet_path = sass_style_sheet_path
    @sass_style_sheet = Sass::Engine.for_file(sass_style_sheet_path, {:cache => false}).to_tree
    @imported_from = imported_from
    @colorFunctions = Set.new %w(rgb rgba mix hsl hsla
                              adjust-hue lighten darken saturate desaturate
                              grayscale complement invert alpha
                              opacity opacify fade-in
                              transparentize fade-out adjust-color scale-color
                              change-color)

    @numberFunctions = Set.new %w(red green blue hue saturation lightness str-length str-index
                                percentage round ceil floor abs min max random
                                length index)

    @stringFunctions = Set.new %w(unquote quote str-insert str-slice to-upper-case to-lower-case)

  end

  def self.remove_illegal_chars(string)
    string.gsub(/[\r\n]/, '')
  end

  def get_mixin_call_info(imports_to_skip = Set.new)

    to_return = []

    get_all_children(@sass_style_sheet).each do |m|

      if m.kind_of?(Sass::Tree::MixinNode)

        number_of_multivalued_args = 0
        m.args.each do |arg|
          if arg.kind_of?(Sass::Script::Tree::ListLiteral)
            number_of_multivalued_args += 1
          end
        end

        sass_mixin_call = SassMixinCall.new(m, number_of_multivalued_args, @sass_style_sheet, @sass_style_sheet_path)
        sass_mixin_declaration = get_declaration_for_mixin_call(sass_mixin_call)
        sass_mixin_call.mixin_declaration = sass_mixin_declaration
        to_return << sass_mixin_call

      end

    end


    get_all_imports.each do |import|
      if !imports_to_skip.include?(import.imported_file_absolute_path)
        imports_to_skip.add(import.imported_file_absolute_path)
        query_handler = SassASTQueryHandler.new(import.imported_file_absolute_path, self)
        to_return.concat(query_handler.get_mixin_call_info(imports_to_skip))
      end
    end

    to_return

  end

  def get_mixin_declaration_info(imports_to_skip = Set.new)

    mixin_declarations_info = []

    get_all_children(@sass_style_sheet).each do |c|

      if c.kind_of?(Sass::Tree::MixinDefNode)

        mixin_declaration = SassMixinDeclaration.new(c, @sass_style_sheet, @sass_style_sheet_path)

        property_to_count_map = Hash.new(Set.new)

        count_variables_inside(c, property_to_count_map, mixin_declaration)

        property_to_count_map.each do |parentAndProperty, countSet|
          property = parentAndProperty[1]
          if countSet.length > 1
            non_equal_found = false
            countSet.each do |p2|
              if property != p2
                non_equal_found = true
                break
              end
            end

            if non_equal_found
              mixin_declaration.increase_number_of_unique_cross_browser_declarations(1)
            else
              mixin_declaration.increase_number_of_non_cross_browser_declarations(1)
            end

          else
            if SassASTQueryHandler.get_non_vendor_property(countSet.to_a[0]) != countSet.to_a[0]
              mixin_declaration.increase_number_of_unique_cross_browser_declarations(1)
            else
              mixin_declaration.increase_number_of_non_cross_browser_declarations(1)
            end
          end

        end

        mixin_declarations_info << mixin_declaration

      end

    end

    get_all_imports.each do |import|
      if !imports_to_skip.include?(import.imported_file_absolute_path)
        imports_to_skip.add(import.imported_file_absolute_path)
        query_handler = SassASTQueryHandler.new(import.imported_file_absolute_path)
        mixin_declarations_info.concat(query_handler.get_mixin_declaration_info(imports_to_skip))
      end
    end

    mixin_declarations_info

  end

  def get_extend_usages_info(imports_to_skip = Set.new)

    extend_usages_info = []

    get_all_children(@sass_style_sheet).each do |child|
      if child.kind_of?(Sass::Tree::ExtendNode) #&& !alreadyAddedExtends.include?(child)
        extend_usages_info << SassExtend.new(child, @sass_style_sheet, @sass_style_sheet_path)
      end
    end

    get_all_imports.each do |import|
      if !imports_to_skip.include?(import.imported_file_absolute_path)
        imports_to_skip.add(import.imported_file_absolute_path)
        query_handler = SassASTQueryHandler.new(import.imported_file_absolute_path)
        extend_usages_info.concat(query_handler.get_extend_usages_info(imports_to_skip))
      end
    end

    extend_usages_info
  end

  def get_all_imports
    all_imports = []
    get_all_import_nodes(@sass_style_sheet).each do |import_node|
      all_imports << SassImport.new(import_node, @sass_style_sheet, @sass_style_sheet_path)
    end
    all_imports
  end

  def get_all_declarations(node)
    to_return = Hash.new
    node.children.each { |child|
      if child.kind_of?(Sass::Tree::PropNode)
        to_return[child] = node
      elsif child.kind_of?(Sass::Tree::RuleNode) ||
          child.kind_of?(Sass::Tree::MediaNode) ||
          child.kind_of?(Sass::Tree::MixinNode)
        self.get_all_declarations(child).each { |c, p|
          to_return[c] = p
        }
        #else
        #  puts("Child type is unknown: #{child.class.name}")
      end
    }
    to_return
  end

  def get_selectors_info(imports_to_skip = Set.new)

    selectors_info = []

    selectors_info = get_selectors_info_recursive(@sass_style_sheet)

    get_all_imports.each do |import|
      if !imports_to_skip.include?(import.imported_file_absolute_path)
        imports_to_skip.add(import.imported_file_absolute_path)
        query_handler = SassASTQueryHandler.new(import.imported_file_absolute_path)
        selectors_info.concat(query_handler.get_selectors_info(imports_to_skip))
      end
    end

    selectors_info
  end

  def get_variables_info(imports_to_skip = Set.new)

    variables_info = []

    get_all_children(@sass_style_sheet).each do |child|

      if child.kind_of?(Sass::Tree::VariableNode)

        is_global = false
        @sass_style_sheet.children.each do |c|
          if child.equal?(c)
            is_global = true
            break
          end
        end
        if is_global or child.global
          scope = 'Global'
        else
          scope = 'Local'
        end

        type = 'OTHER'
        functionName = ''

        if child.expr.kind_of?(Sass::Script::Tree::Funcall)
          functionName = child.expr.name
          if isColorFunction(functionName)
            type = 'COLOR_FUNCTION'
          elsif isNumberFunction(functionName)
            type = 'NUMBER_FUNCTION'
          elsif isStringFunction(functionName)
            type = 'STRING_FUNCTION'
          else
            type = 'OTHER_FUNCTION'
          end
        elsif child.expr.kind_of?(Sass::Script::Tree::Literal)
          value = child.expr.value
          if value.kind_of?(Sass::Script::Value::Number)
            type = 'NUMBER'
          elsif value.kind_of?(Sass::Script::Value::String)
            if value.to_sass.start_with?('url')
              type = 'OTHER_FUNCTION'
            elsif value.to_sass =~ /".*"/ or value.to_sass =~ /'.*'/
              type = 'STRING'
            else
              type = 'IDENTIFIER'
            end
          elsif value.kind_of?(Sass::Script::Value::Color)
            type = 'COLOR'
          else
            type = 'IDENTIFIER'
          end

        elsif child.expr.kind_of?(Sass::Script::Tree::Interpolation) or
            child.expr.kind_of?(Sass::Script::Tree::Variable) or
            child.expr.kind_of?(Sass::Script::Tree::Operation) or
            child.expr.kind_of?(Sass::Script::Tree::StringInterpolation) or
            child.expr.kind_of?(Sass::Script::Tree::UnaryOperation)
          type = 'EXPRESSION_OF_VARIABLE'
        elsif child.expr.kind_of?(Sass::Script::Tree::MapLiteral)
          child.expr.pairs.each do |k, v|
            if k.kind_of?(Sass::Script::Tree::Variable) or
                v.kind_of?(Sass::Script::Tree::Variable)
              type = 'EXPRESSION_OF_VARIABLE'
              break
            end
          end
          if (type.eql?('OTHER'))
            type = 'LITERAL_LIST'
          end
        elsif child.expr.kind_of?(Sass::Script::Tree::ListLiteral)
          child.expr.elements.each do |c|
            if c.kind_of?(Sass::Script::Tree::Variable)
              type = 'EXPRESSION_OF_VARIABLE'
              break
            end
          end
          if (type.eql?('OTHER'))
            type = 'LITERAL_LIST'
          end
        end

        if type.eql?('OTHER')
          functionName = child.expr.class.to_s
        end

        variable_declaration = SassVariable.new(child, scope, type, functionName, @sass_style_sheet, @sass_style_sheet_path)
        variables_info << variable_declaration

      end
    end

    get_all_imports.each do |import|
      if !imports_to_skip.include?(import.imported_file_absolute_path)
        imports_to_skip.add(import.imported_file_absolute_path)
        query_handler = SassASTQueryHandler.new(import.imported_file_absolute_path)
        variables_info.concat(query_handler.get_variables_info(imports_to_skip))
      end
    end

    variables_info
  end

  def isColorFunction(value)
    @colorFunctions.include?value
  end

  def isNumberFunction(value)
    @numberFunctions.include?value
  end

  def isStringFunction(value)
    @stringFunctions.include?value
  end

  def get_declared_script_functions_info(imports_to_skip = Set.new)

    declared_script_functions_info = []

    get_all_children(@sass_style_sheet).each do |child|

      if child.kind_of?(Sass::Tree::FunctionNode)

        declared_script_functions_info << SassFunction.new(child, @sass_style_sheet, @sass_style_sheet_path)

      end

    end

    get_all_imports.each do |import|
      if !imports_to_skip.include?(import.imported_file_absolute_path)
        imports_to_skip.add(import.imported_file_absolute_path)
        query_handler = SassASTQueryHandler.new(import.imported_file_absolute_path)
        declared_script_functions_info.concat(query_handler.get_declared_script_functions_info(imports_to_skip))
      end
    end

    declared_script_functions_info
  end

  def get_interpolations_info(imports_to_skip = Set.new)

    interpolations_info = []

    get_all_children(@sass_style_sheet).each do |child|

      if child.kind_of?(Sass::Tree::VariableNode)
        vars = [child.expr]
      elsif child.kind_of?(Sass::Tree::RuleNode)
        vars = child.rule
      elsif child.kind_of?(Sass::Tree::PropNode)
        vars = child.name + [child.value]
      elsif child.kind_of?(Sass::Tree::MixinNode)
        vars = child.args
      elsif child.kind_of?(Sass::Tree::CssImportNode)
        vars = [child.uri]
      elsif child.kind_of?(Sass::Tree::ExtendNode)
        vars = child.selector
      elsif child.kind_of?(Sass::Script::Tree::Funcall)
        vars = child.args
      end

      if !vars.nil?
        vars.each do |var|
          if var.kind_of?(Sass::Script::Tree::Interpolation) or var.kind_of?(Sass::Script::Tree::StringInterpolation)
            interpolations_info << SassInterpolation.new(var, @sass_style_sheet, @sass_style_sheet_path)
          end
        end
      end

    end

    get_all_imports.each do |import|
      if !imports_to_skip.include?(import.imported_file_absolute_path)
        imports_to_skip.add(import.imported_file_absolute_path)
        query_handler = SassASTQueryHandler.new(import.imported_file_absolute_path)
        interpolations_info.concat(query_handler.get_interpolations_info(imports_to_skip))
      end
    end

    interpolations_info

  end

  def get_all_visited_style_sheet_paths
    all_style_sheet_paths = Set.new
    all_style_sheet_paths.add(@sass_style_sheet_path)
    get_all_imports.each do |sass_import|
      query_handler = SassASTQueryHandler.new(sass_import.imported_file_absolute_path)
      all_style_sheet_paths.merge(query_handler.get_all_visited_style_sheet_paths)
    end
    all_style_sheet_paths
  end


  def self.get_non_vendor_property(property)
    to_return = property
    prefixes = Set.new
    prefixes.add('-webkit-')
    prefixes.add('-moz-')
    prefixes.add('-ms-')
    prefixes.add('-o-')

    prefixes.each do |prefix|
      if to_return.start_with?(prefix)
        to_return = to_return[prefix.length, to_return.length - prefix.length]
        break
      end
    end

    to_return
  end

  private

    def get_all_children(node)
      to_return = Set.new [node]
      node.each { |c|
        unless c.equal?(node)
          to_return.merge(get_all_children(c))
        end
      }
      to_return
    end

    def get_all_import_nodes(child)
      all_import_nodes = []
      if child.kind_of?(Sass::Tree::ImportNode)
        all_import_nodes << child
      else
        child.each do |c|
          all_import_nodes.concat(get_all_import_nodes(c)) if child != c
        end
      end
      all_import_nodes
    end

    def get_declaration_for_mixin_call(sass_mixin_call)

      root_style_sheet_query_handler = self

      if @imported_from != nil
        imported_from = @imported_from
        begin
          root_style_sheet_query_handler = imported_from
          imported_from = imported_from.imported_from
        end while imported_from != nil
      end

      mixin_declaration_info = root_style_sheet_query_handler.get_mixin_declaration_info
      mixin_declaration_info.each do |declaration|
        if declaration.mixin_name.eql? sass_mixin_call.mixin_name
          return declaration
        end
      end
      nil
    end

  # @param [Sass::Tree::MixinDefNode] mixin_declaration_node
  # @param [SassMixinDeclaration] sass_mixin_declaration
    def count_variables_inside(mixin_declaration_node, property_to_count_map, sass_mixin_declaration)

      variable_to_declaration_map = Hash.new(Set.new) #Map<String, Set<String>>

      declarations = get_all_declarations(mixin_declaration_node)
      sass_mixin_declaration.increase_number_of_declarations(declarations.size)

      all_args = Set.new
      mixin_declaration_node.args.each do |arg|
        all_args << arg[0].name
      end

      declarations.each do |child, parent|

        property = child.name.join
        non_vendor_property = SassASTQueryHandler.get_non_vendor_property(property)

        all_variables = get_all_variables(child.value)

        use_of_parameter_found = false

        all_variables.each do |v|
          if !variable_to_declaration_map.include?(v.name)
            variable_to_declaration_map[v.name] = Set.new
          end
          variable_to_declaration_map[v.name].add(property)
          if all_args.include?(v.name)
            use_of_parameter_found = true
          else
            localFound = false
            get_all_children(mixin_declaration_node).each do |kid|
              if kid.kind_of?(Sass::Tree::VariableNode)
                if kid.name.eql?(v.name)
                  localFound = true
                  break
                end
              end
            end
            if !localFound
              sass_mixin_declaration.increase_number_of_global_variables_accessed(1)
            end
          end
        end


        if use_of_parameter_found
          sass_mixin_declaration.increase_number_of_declarations_using_parameters(1)
        end

        if all_variables.length == 0
          sass_mixin_declaration.increase_number_of_declarations_having_only_hard_coded_values(1)
        end

        if !property_to_count_map.include?([parent,  non_vendor_property])
          property_to_count_map[[parent, non_vendor_property]] = Set.new
        end
        property_to_count_map[[parent, non_vendor_property]].add(property)

      end

      vendor_specific_sharing_params = Set.new
      variable_to_declaration_map.each do |v, declaration_set|
        non_vendor_set = Set.new
        declaration_set.each do |property|
          non_vendor_property = SassASTQueryHandler.get_non_vendor_property(property)
          if !non_vendor_property.eql? property
            vendor_specific_sharing_params.add(non_vendor_property);
          end
          non_vendor_set.add(non_vendor_property)
        end

        if non_vendor_set.length > 1
          sass_mixin_declaration.increase_number_of_unique_parameter_used_in_more_than_one_kind_of_declaration(1)
        end

        if vendor_specific_sharing_params.size > 1
          sass_mixin_declaration.increase_number_of_unique_parameters_used_in_vendor_specific(1)
        end

        sass_mixin_declaration.increase_number_of_vendor_specific_sharing_parameter(vendor_specific_sharing_params.size)

      end

    end

    def get_all_variables(value)
      to_return = Set.new
      if value.children.length > 0
        value.children.each do |c|
          to_return.merge(get_all_variables(c))
        end
      else
        if value.kind_of?(Sass::Script::Tree::Variable)
          to_return.add(value)
        end
      end
      to_return
    end

    def get_selectors_info_recursive(root, parents = [])

      selectors_info = []

      root.children.each do |node|
        if node.kind_of?(Sass::Tree::RuleNode) or node.kind_of?(Sass::Tree::MediaNode)
          has_nesting = false
          get_all_children(node).each do |child|
            if child != node && (child.kind_of?(Sass::Tree::RuleNode) || child.kind_of?(Sass::Tree::MediaNode))
              has_nesting = true
              break
            end
          end

          parent_name = ''
          parent_line = -1
          parent_type = ''
          if !root.equal?(@sass_style_sheet)
            if root.kind_of?(Sass::Tree::MediaNode)
              parent_name = '@media'
              parent_type = 'Media'
              parent_line = root.source_range.start_pos.line
            elsif root.kind_of?(Sass::Tree::RuleNode)
              parent_name = SassASTQueryHandler.remove_illegal_chars(root.rule.join)
              parent_type = 'RuleNode'
              parent_line = root.selector_source_range.start_pos.line
            end
          end

          number_of_base_selectors = 0
          number_of_nestable_selectors = 0
          number_of_declarations = 0
          if node.kind_of?(Sass::Tree::RuleNode)
            type = 'RuleSet'
            number_of_base_selectors, number_of_nestable_selectors = count_nestable_selectors(node)
            node.children.each do |c|
              if c.kind_of?(Sass::Tree::PropNode)
                number_of_declarations += 1
              end
            end
          elsif node.kind_of?(Sass::Tree::MediaNode)
            type = 'Media'
          end

          selector_info = SassSelector.new(node, parents, has_nesting, type, @sass_style_sheet, @sass_style_sheet_path)
          selector_info.set_parent_info(parent_name, parent_line, parent_type)
          selector_info.set_body_info(number_of_base_selectors, number_of_nestable_selectors, number_of_declarations)

          selectors_info << selector_info

          current_parents = parents + [selector_info.name]
          selectors_info.concat(get_selectors_info_recursive(node, current_parents))

        end
      end
      selectors_info
    end

    def count_nestable_selectors(node)

      count = 0
      count_nestable = 0
      if (node.rule[0].kind_of?(Sass::Script::Tree::Interpolation))
        rule_name = node.rule[0].to_sass
      else
        rule_name = node.rule[0]
      end
      rule_name.split(',').each do |base_selector|
        base_selector = base_selector.strip
        if !base_selector.nil?
          count += 1
          count_nestable += count_number_of_nestable_selectors(base_selector)
        end
      end

      return count, count_nestable

    end

  def count_number_of_nestable_selectors(selector)

    count = 0

    while selector[0] =~ /\+|~|&|>/
      selector[0] = ''
      selector = selector.strip
    end

    # Replace multi-spaces with one :)
    selector = selector.gsub(/(\s)+/, ' ')

    if selector =~ /.*\+[^=].*/ || selector =~ /.*\~[^=].*/ || selector.include?('>')
      count += 1
    elsif selector[0] != ':' and selector.include?(':')
      count += 1
    elsif selector.include?(' ')
      template = /~|\*|\+|=|\^|\$|\||\"|\'/
      for i in 1..selector.length
        if selector[i] == ' '
          if selector[i - 1] !~ template and selector[i + 1] !~ template
            count += 1
            break
          end
        end
      end
    end
    count
  end

end