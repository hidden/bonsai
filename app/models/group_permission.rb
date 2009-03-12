class GroupPermission < ActiveRecord::Base  
  belongs_to :user
  belongs_to :group

  def switch_view
    if can_view?
      self.can_view = false
      unless self.can_edit?
        self.destroy
      end
    else
      self.group.add_viewer self.user
    end
  end

  def switch_edit
    if can_edit?
      self.can_edit = false
      unless self.can_view?
        self.destroy
      end
    else
      self.group.add_editor self.user
    end
  end
end
