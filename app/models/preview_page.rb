class PreviewPage  < Page
  def resolve_part part_name
      self.page_parts.each { |part| return part.current_page_part_revision.body if part.name == part_name }
      super(part_name)
    end
end