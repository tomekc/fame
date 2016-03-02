
module Fame
  
  # nokogiri_node = original nokogiri node
  # original_id = F4z-Kg-ni6
  # vc_name = CustomViewController (optional)
  # element_name = label
  # i18n_enabled = true
  # i18n_comment = "Best label ever invented"
  LocalizedNode = Struct.new(:nokogiri_node, :original_id, :vc_name, :element_name, :i18n_enabled, :i18n_comment)

  # node = LocalizedNode
  # property = localizable element, e.g. text of a label
  # value = localizable strings value (i.e. the translation)
  LocalizableStringsEntry = Struct.new(:node, :property, :value) do

    # The formatted .strings file entry
    def formatted_strings_file_entry
      comment = node.i18n_comment || "No comment provided by engineer."
      key = "#{node.original_id}.#{property}"
      ["/* #{formatted_info}: #{comment} */", "\"#{key}\" = \"#{value}\";"].join("\n")
    end

    # The formatted info of this entry
    def formatted_info
      [node.vc_name, node.element_name, property].compact.join(" ")
    end
  end

end
