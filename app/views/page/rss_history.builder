xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @page.title + " changes"
    xml.description "Recent changes for wiki page " + @page.title
    xml.link root_url.chomp('/') + @page.get_path

    @recent_revisions.each_with_index do |revision, index|

      xml.item do
        summary = revision.summary.empty? ? "" : "(#{revision.summary})"
        xml.title "#{revision.user.full_name} edited #{revision.page_part.name} #{summary}"
        xml.pubDate revision.created_at.to_s(:rfc822)
        if index<1
          xml.link root_url.chomp('/') + @page.get_path
        else
          xml.link root_url.chomp('/') + '?diff&first_revision='+(@revision_count - index - 1).to_s + '&second_revision='+(@revision_count - index).to_s()
        end
        end
    end
  end
end