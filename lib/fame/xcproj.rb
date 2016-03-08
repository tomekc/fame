require 'pbxplorer'   # grab localization languages from .xcproj file

module Fame
	# Handles the Xcode Project that is subject to localization
	class XCProj

		#
		# Initializer
		# @param xcproj_path A path to a .xcproj file whose contents should be localized.
		#
		def initialize(xcproj_path)
			# TODO: Check if xcproj_path is valid
			@xcproj_path = xcproj_path
		end

		#
		# Determines all languages that are used in the current Xcode project.
		# @return [Array<String>] An array of language codes, representing all languages used in the current Xcode project.
		#
		def all_languages
			project_file = XCProjectFile.new(@xcproj_path)
			project_file.project["knownRegions"].select { |r| r != "Base" }
		end

		# TODO
		# def self.determine_xcproj_files!(path = ".")
		# 	raise "The provided file or folder does not exist" unless File.exist? path
		# end

	end
end
