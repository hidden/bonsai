 class SimpleDiff

   def self.diff old,new
     output = []
     data_old = old.split(/\r?\n/)
     data_new = new.split(/\r?\n/)
     diffs = Diff::LCS.sdiff(data_old, data_new)

     for diff in diffs
       if(['=', '-', '+'].include?(diff.action))
         if(diff.action == '-')
           output << [diff.action, diff.old_element]
         else
           output << [diff.action, diff.new_element]
         end
       else
         temp = []
         changes = Diff::LCS.sdiff(diff.old_element.split(''), diff.new_element.split(''))
         act_sign = changes.first.action
         old_string = ""
         new_string = ""
         for change in changes
           new_sign = change.action
           if (new_sign != act_sign)
             case act_sign
               when '+', '=' then temp << [act_sign, new_string]
               when '-' then temp << [act_sign, old_string]
               when '!' then
                 temp << ['-', old_string]
                 temp << ["+", new_string]
             end
             old_string = ""
             new_string = ""
             act_sign = new_sign
           end
           old_string << change.old_element unless change.old_element.nil?
           new_string << change.new_element unless change.new_element.nil?
         end
         case act_sign
           when '+' then
             temp << [act_sign, new_string]
           when '-' then
             temp << [act_sign, old_string]
           when '=' then
             temp << [act_sign, new_string]
           when '*' then
             temp << ['-', old_string]; temp << ["+", new_string]
         end
         output << ['*', temp]
       end
     end
     output
   end
end