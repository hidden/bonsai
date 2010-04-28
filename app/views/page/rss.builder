xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @recent_revisions[0].pg_name + " changes"
    xml.description "Recent changes for wiki page " + @recent_revisions[0].pg_name
    xml.link root_url.chomp('/') + '/' + @recent_revisions[0].pg_path
    
    @recent_revisions.each do |revision|
      if (revision.prev_rev_count.to_i > 0)
        xml.item do
          summary = revision.summary.empty? ? "" : "(#{revision.summary})"
          xml.title "#{revision.user.full_name} edited #{revision.page_part.name} #{summary}"
          xml.pubDate revision.created_at.to_s(:rfc822)
         xml.link root_url.chomp('/') + '/' + revision.pg_path + ';diff?first_revision=' + (revision.prev_rev_count).to_s + '&second_revision=' + (revision.prev_rev_count.to_i + 1).to_s()
        end
      end
    end
  end
end