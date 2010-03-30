class PreviewPage  < Page
  def resolve_part part_name
      self.page_parts.each { |part| return part.current_page_part_revision.body if part.name == part_name }
      super(part_name)
  end

  def layout_parts
    definition = "vendor/layouts/#{self.layout}/definition.yml"
    if File.exist?(definition)
      layout = YAML.load_file(definition)
      unless layout.nil?
        return layout['parts']
      end
    end
  end

  def resolve_layout
    unless self.layout.nil?
      self.layout
    else
      'application'
    end
  end
end