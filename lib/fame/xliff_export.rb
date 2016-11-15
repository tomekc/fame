require 'nokogiri'		# to rewrite the XLIFF file
require 'colorize'		# colorful console output
require 'open3'       # to capture stdout, stderr when calling external xcodebuild
require_relative 'models'
require_relative 'xcode_project'

module Fame
  # Handles import and export of .xliff files
  class XliffExport

    #
    # Initializer
    # @param xcode_proj_path A path to a .xcodeproj file whose contents should be localized.
    #
    def initialize(xcode_proj_path)
      @xcode_proj = XcodeProject.new(xcode_proj_path)
    end

    #
    # Exports all .xliff files for the current Xcode project
    # @param path A path to a folder where exported .xliff files should be placed.
    # @param ib_nodes An array of `LocalizedNode`s, generated from `InterfaceBuilder.nodes`.
    #
    def export(path, ib_nodes)
      # export localizations
      export_xliffs(path)

      # update translation units based on the settings provided in Interface Builder
      # Localizations are only exported if explicitly enabled via the fame Interface Builder integration (see Fame.swift file).
      update_xliff_translation_units(path, ib_nodes)
    end

    private

    #
    # Exports all .xliff files for the current Xcode project to the given path.
    # @param path A path to a folder where exported .xliff files should be placed.
    #
    def export_xliffs(path)
      # get all languages that should be exported to separate .xliff files
      languages = @xcode_proj.all_languages
        .map { |l| "-exportLanguage #{l}" }
        .join(" ")

      command = "xcodebuild -exportLocalizations -localizationPath \"#{path}\" -project \"#{@xcode_proj.xcode_proj_path}\" #{languages}"
      stdout, stderr, status = Open3.capture3(command)

      puts stdout.light_black
      puts(stderr.yellow) unless status.success?
    end

    #
    # Modifies all .xliff files based on the settings extracted from Interface Builder nodes.
    #
    def update_xliff_translation_units(path, ib_nodes)
      @xcode_proj.all_languages.each do |language|
        xliff_path = File.join(path, "#{language}.xliff")
        puts "Updating translation units for #{language}".blue

        # Read XLIFF file
        raise "File #{xliff_path} does not exist" unless File.exists? xliff_path
        doc = read_xliff_file(xliff_path)

        # Remove plist files
        trans_files = doc.xpath('//xmlns:file')
        trans_files.select do |f|
          original = f["original"] rescue ""
          if original.include?(".plist") || original.include?("Tests")
            f.remove
            puts "Removed plist file #{original} from translation"
          end
        end

        # Extract all translation units from the xliff
        trans_units = doc.xpath('//xmlns:trans-unit')

        # Loop over the Interface Builder nodes and update the xliff file based on their settings
        ib_nodes.each do |ib_node|
          # Select nodes connected to original_id
          units = trans_units.select do |u|
            u_id = u["id"] rescue ""
            u_id.start_with?(ib_node.original_id)
          end

          # Update or remove nodes
          units.each do |unit|
            if ib_node.i18n_enabled
              # Update comment
              comment = unit.xpath("xmlns:note")
              comment.children.first.content = ib_node.formatted_info
            else
              # Remove translation unit, since it should not be translated
              unit.remove
            end
          end

          # Print status
          if units.count > 0
            status = ib_node.i18n_enabled ? "updated".green : "removed".red
            puts [
              "  ✔︎".green,
              "#{units.count} translation unit(s)".black,
              status,
              "for".light_black,
              "#{ib_node.original_id}".black,
              "#{ib_node.formatted_info}".light_black
            ].join(" ")
          end
        end

        # Write updated XLIFF file to disk
        write_xliff_file(doc, xliff_path)
      end
    end

    #
    # Reads the document at the given path and parses it into a `Nokogiri` XML doc.
    # @param path The path the xliff file that should be parsed
    # @return [Nokogiri::XML] A `Nokogiri` XML document representing the xliff
    #
    def read_xliff_file(path)
      xliff = File.open(path)
      doc = Nokogiri::XML(xliff)
      xliff.close

      doc
    end

    #
    # Writes the given `Nokogiri` doc to the given path
    # @param doc A Nokogiri XML document
    # @param path The path the `doc` should be written to
    #
    def write_xliff_file(doc, path)
      file = File.open(path, "w")
      doc.write_xml_to(file)
      file.close
    end

  end
end
