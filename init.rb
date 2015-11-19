require_relative 'empirical/empirical'
require 'find'
require 'fileutils'

begin

  outputDir = ARGV[0]
  if !outputDir.end_with?('/')
    outputDir = outputDir + '/'
  end
  if !Dir.exist?(outputDir)
    FileUtils::mkdir_p(outputDir) # if the nested dirs don't exists, FileUtils handles this case
  end


  sassFilesDirectory = ARGV[1]
  if !sassFilesDirectory.end_with?('/')
    sassFilesDirectory = sassFilesDirectory + '/'
  end

  main_file_paths = []
  Find.find(sassFilesDirectory) do |path|
    main_file_paths << path if path =~ /.*mainfiles.txt$/
  end

  header = true
  main_file_paths.each do |main_file|

    main_file_file_dirname = File.dirname(main_file)
    website = File.basename(main_file_file_dirname)

    files_to_consider = []
    
    file = File.open(main_file)
    file.each do |main_file_relative_path|
      main_file_relative_path = main_file_relative_path.gsub(/[\r\n]/,'')
      abs_path_to_main_sass_file = File.expand_path(main_file_relative_path, main_file_file_dirname)
      files_to_consider  << abs_path_to_main_sass_file
    end

    if files_to_consider.length > 0

      extension = File.extname(files_to_consider[0]).to_s.gsub('.', '')

      puts("We are doing #{main_file}, main files to consider: #{files_to_consider}")
      empirical = EmpiricalStudy.new(website, files_to_consider)
      empirical.write_selectors_info_to_file("#{outputDir}#{extension}-selectorsInfo.txt", header)
      empirical.write_mixin_calls_info_to_file("#{outputDir}#{extension}-mixinCallsInfo.txt", header)
      empirical.write_mixin_declarations_info_to_file("#{outputDir}#{extension}-mixinDeclarationInfo.txt", header)
      empirical.write_extend_info_to_file("#{outputDir}#{extension}-extendInfo.txt", header)
      empirical.write_file_size_info_to_file("#{outputDir}#{extension}-fileSizes.txt", header)
      empirical.write_variable_declarations_to_file("#{outputDir}#{extension}-variableDeclarationsInfo.txt", header)
      empirical.write_declared_script_functions_info("#{outputDir}#{extension}-declaredScriptFunctionsInfo.txt", header)
      empirical.write_interpolations_info_to_file("#{outputDir}#{extension}-interpolationsInfo.txt", header)

      if header
        header = false
      end

    end
    #rescue Sass::SyntaxError
    #  
    #end
  end
  
end