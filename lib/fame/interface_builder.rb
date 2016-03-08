require 'nokogiri' 		# to rewrite the storyboard
require 'plist'				# to parse the localizable.plist file
require 'colorize'		# colorful console output
require_relative 'models'

module Fame

	class InterfaceBuilder
		# Keypaths to custom runtime attributes (provided by iOS Extenstion, see Fame.swift)
		LOCALIZATION_ENABLED_KEYPATH = "i18n_enabled".freeze
		LOCALIZATION_COMMENT_KEYPATH = "i18n_comment".freeze

		# All accepted Interface Builder file types
		ACCEPTED_FILE_TYPES = [".storyboard", ".xib"].freeze

		#
		# Initialization
		#
		def self.determine_ib_files!(path = ".")
			raise "The provided file or folder does not exist" unless File.exist? path

			if File.directory?(path)
				files = Dir.glob(path + "/**/*{#{ACCEPTED_FILE_TYPES.join(',')}}")
				raise "The provided folder did not contain any interface files (#{ACCEPTED_FILE_TYPES.join(', ')})" unless files.count > 0
				return files
			else
				raise "The provided file is not an interface file (#{ACCEPTED_FILE_TYPES.join(', ')})" unless ACCEPTED_FILE_TYPES.include? File.extname(path)
				return [path]
			end
		end

		#
		# Returns all XML nodes with a custom localization ID
		#
		def nodes(file)
			storyboard = File.open(file)
			doc = Nokogiri::XML(storyboard)

			# Grab raw nokogiri nodes that have a localization keypath
			raw_nodes = doc.xpath("//userDefinedRuntimeAttribute[@keyPath='#{LOCALIZATION_ENABLED_KEYPATH}']")

			# Map raw nodes info to instances of LocalizedNode
			raw_nodes.map do |node|
				parent = node.parent.parent 													# i.e. UILabel, UISwitch, etc.
				vc = parent.xpath("ancestor::viewController")					# the view controller of the element (only available in .storyboard files)
				element_name = parent.name														# i.e. label, switch
				original_id = parent['id'] 														# ugly Xcode ID, e.g. F4z-Kg-ni6
				vc_name = vc.attr('customClass').value rescue nil			# name of custom view controller class

				i18n_enabled = node.parent.xpath("userDefinedRuntimeAttribute[@keyPath='#{LOCALIZATION_ENABLED_KEYPATH}']").attr('value').value == "YES" rescue false
				i18n_comment = node.parent.xpath("userDefinedRuntimeAttribute[@keyPath='#{LOCALIZATION_COMMENT_KEYPATH}']").attr('value').value rescue nil

				LocalizedNode.new(node, original_id, vc_name, element_name, i18n_enabled, i18n_comment)
			end
		end

	end
end
