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
		# Generates a .strings file for the Interface Builder file at the given path.
		# The output only contains elements where localization has been enabled.
		#
		def generate_localizable_strings(file)
			localizable_strings_entries(file)
				.sort_by! { |e| e.node.vc_name }
				.map(&:formatted_strings_file_entry)
				.join("\n\n")
		end

		private

		#
		# Generates ibtool output in plist format
		#
		def ibtool(file)
			# 	<dict>
			# 		<key>6lc-A3-0nG</key>
			# 		<dict>
			# 			<key>text</key>
			# 			<string>Empty localization ID</string>
			# 		</dict>
			# 		...
			# 	</dict>
			output = `xcrun ibtool #{file} --localizable-strings --localizable-stringarrays`
			plist = Plist::parse_xml(output)
			strings = plist['com.apple.ibtool.document.localizable-strings']
			string_arrays = plist['com.apple.ibtool.document.localizable-stringarrays']

			[strings, string_arrays]
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

		#
		# Returns the localizable strings entries for a given
		# Interface Builder file.
		#
		def localizable_strings_entries(file)
			# Generate ibtool output
			strings, string_arrays = ibtool(file)

			# Get nodes for current file
			nodes = nodes(file)

			# Generate new strings file
			entries = []
			nodes.each do |node|
				next unless node.i18n_enabled
				unless element = strings[node.original_id] || string_arrays[node.original_id]
					puts "  ✘ #{node.original_id} (#{node.element_name}): #{node.original_id} not found in ibtool output".red
					next
				end

				# A localization may contain more than one element.
				# e.g. a UITextField has a `text` and a `placeholdertext` localization
				element.each do |property, value|
					next if property == "ibExternalUserDefinedRuntimeAttributesLocalizableStrings"

					if value.is_a?(Array)
						# The localization contains an array of values, e.g. when localizing a UISegmentedControl
						value.each_with_index do |v, index|
							p = "#{property}[#{index}]"
							entry = LocalizableStringsEntry.new(node, p, v)
							entries << entry

							puts "  ✔︎ #{entry.formatted_info}".green
						end
					else
						# The localization only contains a single value
						entry = LocalizableStringsEntry.new(node, property, value)
						entries << entry

						puts "  ✔︎ #{entry.formatted_info}".green
					end

				end
			end

			entries
		end

	end
end
