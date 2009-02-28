class GroupPermission < ActiveRecord::Base  
  belongs_to :user
  belongs_to :group

  def switch
    if can_edit?
      self.can_edit = false
    else
      self.can_edit = true
    end
  end
end
