require 'colorize'    # colorful console output
require 'open3'       # capture stdout, stderr for commandline calls
require_relative 'xcode_project'


module Fame
  # Handles import and export of .xliff files
  class XliffImport
    # All accepted XLIFF file types
    ACCEPTED_FILE_TYPES = [".xliff"].freeze

    #
    # Initializer
    # @param xcode_proj_path A path to a .xcodeproj file whose contents should be localized.
    #
    def initialize(xcode_proj_path)
      @xcode_proj = XcodeProject.new(xcode_proj_path)
    end

    #
    # Imports all .xliff files at the given path into the current Xcode project
    # @param path A folder of .xliff files that should be imported into the current Xcode project.
    #
    def import(path)
      xliffs = determine_xliff_files!(path)
      puts "Found #{xliffs.count} xliff file(s) -> #{xliffs.map { |x| File.basename(x, '.*') }}".light_black

      errors = []
      xliffs.each_with_index do |xliff, index|
        language =  File.basename(xliff, '.*')
        puts "\n(#{index+1}/#{xliffs.count}) [#{language}] Importing #{xliff}".blue

        # may result in the following error:
        # xcodebuild: error: Importing localizations from en.xliff will make changes to Example. Import with xcodebuild can only modify existing strings files.
        command = "xcodebuild -importLocalizations -localizationPath \"#{xliff}\" -project \"#{@xcode_proj.xcode_proj_path}\""
        _, stdout, stderr = Open3.capture3(command)

        puts stdout.light_black
        if stderr
          puts "✘ Failed to import #{language}".red
          # grep the error specific to the initial import issue of xcodebuild
          error = stdout.split("\n").grep(/^xcodebuild: error: Importing localizations/i)
          errors << error
        else
          puts "✔︎ Successfully imported #{language}".green
        end
      end

      report_result(errors)
    end

    private

    #
    # Searches the given path for .xliff files and returns their paths.
    # @param path The path that should be searched for .xliff files.
    # @return [Array<String>] An array of paths to .xliff files.
    #
    def determine_xliff_files!(path)
      raise "[XliffImport] The provided file or folder does not exist" unless File.exist? path

      if File.directory?(path)
        files = Dir.glob(path + "/**/*{#{ACCEPTED_FILE_TYPES.join(',')}}")
        raise "[XliffImport] The provided folder did not contain any XLIFF files (#{ACCEPTED_FILE_TYPES.join(', ')})" unless files.count > 0
        return files
      else
        raise "[XliffImport] The provided file is not an XLIFF (#{ACCEPTED_FILE_TYPES.join(', ')})" unless ACCEPTED_FILE_TYPES.include? File.extname(path)
        return [path]
      end
    end

    #
    # Prints the result of the import
    #
    def report_result(errors)
      # handle errors
      if errors.count > 0
        help = "\nOoops! xcodebuild cannot import one or more of the provided .xliff file(s) because the necessary .strings files do not exist yet.\n\n" +
              "Here's how to fix it:\n" +
              "  1. Open Xcode, select the project root (blue icon)\n" +
              "  2. Choose Editor > Import Localizations...\n" +
              "  3. Repeat steps 1 and 2 for every localization\n\n" +
              "Don't worry, you only have to do this manually once.\n" +
              "After the initial Xcode import, this command will be able to import your xliff files."
        puts help.blue
      else
        puts "\n✔︎ Done importing XLIFFs\n".green
      end
    end

  end
end
