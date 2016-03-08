module Fame

  # nokogiri_node = original nokogiri node
  # original_id = F4z-Kg-ni6
  # vc_name = CustomViewController (optional)
  # element_name = label
  # i18n_enabled = true
  # i18n_comment = "Best label ever invented"
  LocalizedNode = Struct.new(:nokogiri_node, :original_id, :vc_name, :element_name, :i18n_enabled, :i18n_comment) do
    def formatted_info
      info = [vc_name, element_name].compact.join(" ")
      "[#{info}] #{i18n_comment}"
    end
  end

end
