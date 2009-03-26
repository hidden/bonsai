xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @page.title + " changes"
    xml.description "Recent changes for wiki page " + @page.title
    xml.link root_url.chomp('/') + @page.get_path

    for revision in @recent_revisions
      xml.item do
        summary = revision.summary.empty? ? "" : "(#{revision.summary})"
        xml.title "#{revision.user.full_name} edited #{revision.page_part.name} #{summary}"
        xml.pubDate revision.created_at.to_s(:rfc822)
        xml.link root_url.chomp('/') + @page.get_path
      end
    end
  end
end