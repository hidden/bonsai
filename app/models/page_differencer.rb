class PageDifferencer
  def self.get_differences_by_revision page, first_revision, second_revision
    if (first_revision.to_i < second_revision.to_i)
      first = second_revision
      second = first_revision
    else
      second = second_revision
      first = first_revision
    end

    revision1 = page.page_parts_revisions[first.to_i].id
    old_revision = ""
    for part in page.page_parts
      revision = part.page_part_revisions.first(:conditions => ["id <= ?", revision1])
      unless revision.nil? or revision.was_deleted?
        old_revision << revision.body << "\n"
      end
    end
    new_revision = ""
    revision2 = page.page_parts_revisions[second.to_i].id
    for part in page.page_parts
      revision = part.page_part_revisions.first(:conditions => ["id <= ?", revision2])
      unless revision.nil? or revision.was_deleted?
        new_revision << revision.body << "\n"
      end
    end
    render = compare(old_revision, new_revision)
    return render
  end

  def self.compare old, new
    output = []
    data_old = old.split(/\n/)
    data_new = new.split(/\n/)
    diffs = Diff::LCS.sdiff(data_old, data_new)

    for diff in diffs
      data_old_parse = ""
      data_new_parse = ""
      act_sign = ""
      act_str = ""
      temp = []
      if ((diff.action == '=')||(diff.action == '-')||(diff.action == '+'))
        begin
          if (diff.action == '-')
            output << [diff.action, diff.old_element]
          else
            output << [diff.action, diff.new_element]
          end
        end
      else
        begin
          data_old_parse = diff.old_element.split("")
          data_new_parse = diff.new_element.split("")
          diffs_parsed = Diff::LCS.sdiff(data_old_parse, data_new_parse)
          for parsed_diff in diffs_parsed
            if (act_sign == "")
              act_sign = parsed_diff.action
            end
            case parsed_diff.action
              when '=' then
                if (act_sign == "=")
                  act_str << parsed_diff.old_element
                else
                  begin
                    temp << [act_sign, act_str]
                    act_sign = parsed_diff.action
                    if (act_sign=="-")
                      act_str = parsed_diff.old_element
                    else
                      act_str = parsed_diff.new_element
                    end
                  end
                end
              when '-' then
                if (act_sign == "-")
                  act_str << parsed_diff.old_element
                else
                  begin
                    temp << [act_sign, act_str]
                    act_sign = parsed_diff.action
                    if (act_sign=="-")
                      act_str = parsed_diff.old_element
                    else
                      act_str = parsed_diff.new_element
                    end
                  end
                end
              when '+' then
                if (act_sign == "+")
                  act_str << parsed_diff.new_element
                else
                  begin
                    temp << [act_sign, act_str]
                    act_sign = parsed_diff.action
                    if (act_sign=="-")
                      act_str = parsed_diff.old_element
                    else
                      act_str = parsed_diff.new_element
                    end
                  end
                end
            end
          end
          temp << [act_sign, act_str]
          output << ['*', temp]
        end
      end
    end
    return output
  end

end