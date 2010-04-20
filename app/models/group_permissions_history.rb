class GroupPermissionsHistory < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  belongs_to :editor, :class_name => 'User'

  def is_newer?(date)
    return self.created_at >= date ? true : false unless date.nil?
    true
  end
end
