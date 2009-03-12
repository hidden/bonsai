class GroupPermission < ActiveRecord::Base  
  belongs_to :user
  belongs_to :group

  def switch_view
    if can_view?
      self.group.remove_viewer self.user
    else
      self.group.add_viewer self.user
    end
  end

  def switch_edit
    if can_edit?
      self.group.remove_editor self.user
    else
      self.group.add_editor self.user
    end
  end
end
