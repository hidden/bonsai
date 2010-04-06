class GroupPermissionsHistory < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  belongs_to :editor, :class_name => 'User'
end
