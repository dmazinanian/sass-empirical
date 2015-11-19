require File.join(File.dirname(__FILE__), '../../sass/lib', 'sass')
require_relative 'sass_ast_query_handler'

class EmpiricalStudy

  def initialize(website, path_to_sass_files)
    @website = website
    @sass_style_sheets_paths = path_to_sass_files
  end

  def write_mixin_calls_info_to_file(path, header = true)

    if (header)
      write_line_to_file(path, "WebSite|File|MixinName|NumberOfArgumentsPassed|NumberOfMultiValuedArguments|MixinDeclarationFile|MixinDeclarationName\n")
    end

    already_visited_mixin_calls = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)

      query_handler.get_mixin_call_info().each do |mixin_call_info|
        if !already_visited_mixin_calls.include? mixin_call_info
          already_visited_mixin_calls.add(mixin_call_info)
          file_name = mixin_call_info.path_to_style_sheet
          mixin_name = mixin_call_info.mixin_name
          number_of_arguments = mixin_call_info.number_of_arguments
          number_of_multivalued_args = mixin_call_info.number_of_multi_valued_arguments
          mixin_declaration = mixin_call_info.mixin_declaration
          if mixin_declaration != nil
            mixin_declaration_style_path = mixin_declaration.path_to_style_sheet
            mixin_declaration_name = mixin_declaration.mixin_name
          end
          line = "#{@website}|#{file_name}|#{mixin_name}|#{number_of_arguments}|#{number_of_multivalued_args}|" \
                 "#{mixin_declaration_style_path}|#{mixin_declaration_name}\n"
          write_line_to_file(path, line, true)
        end
      end

    end

  end

  def write_mixin_declarations_info_to_file(path, header = true)

    if (header)
      write_line_to_file(path,
                         'WebSite|File|MixinName|Parameters|Declarations|DeclarationsUsingParams|'\
      'CrossBrowserDeclarations|NonCrossBrowserDeclarations|UniqueParametersUsedInMoreThanOneKindOfDeclaration|'\
      'DeclarationsHavingOnlyHardCoded|ParametersReusedInVendorSpecific|VendorSpecificSharingParam|GlobalVarsAccessed')
    end


    already_visited_mixin_declarations = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)

      query_handler.get_mixin_declaration_info.each do |mixin_declaration_info|
        if !already_visited_mixin_declarations.include? mixin_declaration_info
          already_visited_mixin_declarations.add(mixin_declaration_info)
          file_name = mixin_declaration_info.path_to_style_sheet
          mixin_name = mixin_declaration_info.mixin_name
          n_params = mixin_declaration_info.number_of_parameters
          n_declarations = mixin_declaration_info.number_of_declarations
          n_declarations_using_parameters = mixin_declaration_info.number_of_declarations_using_parameters
          n_unique_cross_browser_declarations = mixin_declaration_info.number_of_unique_cross_browser_declarations
          n_non_cross_browser_declarations = mixin_declaration_info.number_of_non_cross_browser_declarations
          n_unique_parameter_used_in_more_than_one_kind_of_declaration =
              mixin_declaration_info.number_of_unique_parameter_used_in_more_than_one_kind_of_declaration
          n_declarations_having_only_hard_coded_values =
              mixin_declaration_info.number_of_declarations_having_only_hard_coded_values
          n_unique_parameters_used_in_vendor_specific =
              mixin_declaration_info.number_of_unique_parameters_used_in_vendor_specific
          n_vendor_specific_sharing_parameter =
              mixin_declaration_info.number_of_vendor_specific_sharing_parameter
          n_global_vars_accessed = mixin_declaration_info.number_of_global_variables_accessed

          line = "#{@website}|#{file_name}|#{mixin_name}|#{n_params}|"\
              "#{n_declarations}|#{n_declarations_using_parameters}|"\
              "#{n_unique_cross_browser_declarations}|#{n_non_cross_browser_declarations}|"\
              "#{n_unique_parameter_used_in_more_than_one_kind_of_declaration}|"\
              "#{n_declarations_having_only_hard_coded_values}|"\
              "#{n_unique_parameters_used_in_vendor_specific}|"\
              "#{n_vendor_specific_sharing_parameter}|"\
              "#{n_global_vars_accessed}"
              "\n"
          write_line_to_file(path, line, true)
        end
      end

    end

  end

  def write_extend_info_to_file(path, header = true)
    if header
      write_line_to_file(path, "WebSite|File|Line|Target\n", false);
    end

    already_visited_extends = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)

      query_handler.get_extend_usages_info.each do |extend_info|

        if !already_visited_extends.include?(extend_info)
          already_visited_extends.add(extend_info)

          file_name = extend_info.path_to_style_sheet
          position = extend_info.start_line
          target = extend_info.target_selector_name

          write_line_to_file(path, "#{@website}|#{file_name}|#{position}|#{target}\n", true)

        end
      end

    end

  end

  def write_selectors_info_to_file(path, header)

    if header
      write_line_to_file(path, 'WebSite|File|Line|Name|NumberOfBaseSelectors|NumberOfNestableSelectors|'\
      "HasNesting|Parent|ParentLine|ParentType|NumberOfDeclarations|Type|Level\n", false);
    end

    already_visited_selectors = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)

      query_handler.get_selectors_info.each do |selector_info|

        if !already_visited_selectors.include?(selector_info)
          already_visited_selectors.add(selector_info)

          file_name = selector_info.path_to_style_sheet
          position = selector_info.start_line
          selector_name = selector_info.name
          n_base_selectors = selector_info.number_of_base_selectors
          n_nestable_selectors = selector_info.number_of_nestable_selectors
          has_nesting = selector_info.has_nesting
          parent_name = selector_info.parent_name
          parent_line = selector_info.parent_line
          parent_type = selector_info.parent_type
          n_declarations = selector_info.number_of_declarations
          type = selector_info.type
          level = selector_info.level

          line = "#{@website}|#{file_name}|#{position}|#{selector_name}|"\
              "#{n_base_selectors}|#{n_nestable_selectors}|#{has_nesting}|#{parent_name}|#{parent_line}|"\
              "#{parent_type}|#{n_declarations}|#{type}|#{level}\n"
          write_line_to_file(path, line, true);

        end

      end

    end

  end

  def write_file_size_info_to_file(path, header)

    if header
      write_line_to_file(path, "WebSite|File|Size\n", false);
    end

    already_visited_style_sheets = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)
      query_handler.get_all_visited_style_sheet_paths.each do |style_sheet_path|
        if !already_visited_style_sheets.include?(style_sheet_path)
          already_visited_style_sheets.add(style_sheet_path)
          fileSize = File.size(style_sheet_path)
          write_line_to_file(path, "#{@website}|#{style_sheet_path}|#{fileSize}\n", true)
        end
      end

    end

  end
  
  def write_variable_declarations_to_file(path, header)

    if (header)
      write_line_to_file(path, "WebSite|File|Line|Variable|Type|Scope\n", false);
    end

    already_visited_variables = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)
      query_handler.get_variables_info.each do |variable_info|

        if !already_visited_variables.include?(variable_info)

          already_visited_variables.add(variable_info)

          style_sheet_path = variable_info.path_to_style_sheet
          line = variable_info.start_line
          variable = variable_info.name.gsub('|', '{???}')
          type = variable_info.type
          scope = variable_info.scope

          line = "#{@website}|#{style_sheet_path}|#{line}|#{variable}|#{type}|#{scope}\n"
          write_line_to_file(path, line, true)

        end

      end

    end

  end

  def write_declared_script_functions_info(path, header)

    if (header)
      write_line_to_file(path, "WebSite|File|Line|FuncName\n", false);
    end

    already_visited_script_functions = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)
      query_handler.get_declared_script_functions_info.each do |script_function_info|

        if !already_visited_script_functions.include?(script_function_info)

          already_visited_script_functions.add(script_function_info)

          style_sheet_path = script_function_info.path_to_style_sheet
          line_n = script_function_info.start_line
          name = script_function_info.name

          line = "#{@website}|#{style_sheet_path}|#{line_n}|#{name}\n"
          write_line_to_file(path, line, true)

        end

      end

    end

  end

  def write_interpolations_info_to_file(path, header)

    if (header)
      write_line_to_file(path, "WebSite|File|Line|VariableUsed\n", false);
    end

    already_visited_interpolation_objects = Set.new

    @sass_style_sheets_paths.each do |path_to_main_sass_file|

      query_handler = SassASTQueryHandler.new(path_to_main_sass_file)
      query_handler.get_interpolations_info.each do |interpolation_info|

        if !already_visited_interpolation_objects.include?(interpolation_info)

          already_visited_interpolation_objects.add(interpolation_info)

          style_sheet_path = interpolation_info.path_to_style_sheet
          line = interpolation_info.start_line
          variable_used = interpolation_info.variable_name_as_string

          line = "#{@website}|#{style_sheet_path}|#{line}|#{variable_used}\n"
          write_line_to_file(path, line, true)

        end

      end

    end

  end

  def write_line_to_file(path, line, append = false)
    if append
      mode = 'a'
    else
      mode = 'w'
    end
    File.open(path, mode) do |f1|
      f1.puts(line)
    end
  end

end
