require 'nokogiri' 		# to rewrite the XLIFF file
require 'colorize'		# colorful console output
require_relative 'models'

module Fame

	class XLIFF

		def generate(language)
			`xcodebuild -exportLocalizations -localizationPath . -exportLanguage #{language}`
		end

		#
		# Modifies all nodes that are related to ib_nodes
		#
		def update_trans_units(language, ib_nodes)
			
			# Read XLIFF
			file = File.open("#{language}.xliff") 
			doc = Nokogiri::XML(file)
			units = doc.xpath('//xmlns:trans-unit')
			file.close

			ib_nodes.each do |ib_node|
				oid = ib_node.original_id
				formatted_info = ib_node.formatted_info

				# Select nodes connected to oid
				nodes = units.select do |unit| 
					uid = unit['id'] rescue ""
					uid.include?(oid)
				end

				# Update or remove nodes
				nodes.each do |node|
					if ib_node.i18n_enabled
						note = node.xpath('xmlns:note')
						note.children.first.content = formatted_info
					else
						node.remove
					end
				end
				if nodes.count > 0
					if ib_node.i18n_enabled
						puts "  ✔︎ ".green + "#{nodes.count} translation unit(s) ".black + "updated".green + " for #{oid} ".black + "#{formatted_info}".light_black
					else 
						puts "  ✔︎ ".green + "#{nodes.count} translation unit(s) ".black + "removed".red + " for #{oid} ".black + "#{formatted_info}".light_black
					end
				end
			end

			# Write updated XLIFF
			file = File.open("#{language}.xliff", "w") 
			doc.write_xml_to(file)
			file.close
		end

	end

end
