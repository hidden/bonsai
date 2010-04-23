class User < ActiveRecord::Base
  cattr_reader :per_page #TODO wtf?
  @@per_page = (APP_CONFIG['administrators'].nil? or APP_CONFIG['administrators']['per_page'].nil?) ? 10 : APP_CONFIG['administrators']['per_page'] #TODO wtf?


  has_many :group_permissions, :dependent => :destroy
  has_many :groups, :through => :group_permissions
  has_many :page_part_locks, :dependent => :destroy

  has_many :visible_groups, :through => :group_permissions, :class_name => 'Group', :source => :group, :conditions => ['group_permissions.can_view = ?', true]

  has_many :favorites
  has_many :favorite_pages, :through => :favorites, :class_name => 'Page', :source => :page

  has_many :group_permissions_histories, :dependent => :destroy
  has_many :editor_group_histories, :class_name => 'GroupPermissionsHistory', :foreign_key => 'editor_id'
  
  attr_accessor :password, :password_confirmation
  attr_accessible :username, :name, :password, :password_confirmation
                                                                                                                         before_create { |user| user.generate_unique_token }
  after_create { |user| user.create_user_group }
  after_destroy { |user| user.private_group.destroy }
  before_save :encrypt_password

  validates_uniqueness_of :username
  validates_presence_of :name
  validates_confirmation_of :password

#majzunova administracia
  def change_active active
    self.active=active
    self.save
  end

  def verify_admin_right
    # read id of admin group
    group_id = APP_CONFIG['administrators'].nil? ? nil:APP_CONFIG['administrators']['admin_group']
    # control user
    if self.logged? and !group_id.nil?
      group=GroupPermission.find_by_sql("SELECT * FROM group_permissions g
                                            WHERE g.group_id = '#{group_id}'
                                            AND g.user_id = '#{self.id}'")
      return group.blank? ? false : true
    else
      return false
    end
  end


  def user_group
    Group.find_by_name_and_usergroup(self.username, true)  
  end

  def find_all_accessible_pages
    group_accessible = Page.find :all,
                                 :select => "DISTINCT pages.id",
                                 :joins => "JOIN pages p2 ON pages.lft >= p2.lft AND pages.rgt <= p2.rgt JOIN page_permissions pp ON p2.id = pp.page_id AND (pp.can_view = 1 OR pp.can_edit = 1 OR pp.can_manage = 1)",
                                 :conditions => ["pp.group_id IN (?)", self.groups]
    public_accessible = Page.find_all_public
    return (group_accessible+public_accessible)
  end

  def full_name
    "#{username} (#{name})"
  end

  def generate_unique_token
    self.token = ActiveSupport::SecureRandom.hex(16)
    generate_unique_token unless User.find_by_token(self.token).nil?
  end

  def private_group
    Group.find_by_name(self.username)
  end

  def can_edit_group? group
    group.is_editable? ? true : GroupPermission.exists?(:group_id => group, :user_id => self, :can_edit => true)
  end

  def can_view_page? page
    return true if page.is_public?
    return !PagePermission.first(:joins => [:page, :group_permissions], :conditions => ["(? BETWEEN pages.lft AND pages.rgt) AND group_permissions.user_id = ? AND (page_permissions.can_view = ? OR page_permissions.can_edit = ? OR page_permissions.can_manage = ?)", page.lft, self.id, true, true, true]).nil?
  end

  def can_edit_page? page
    return true if page.is_editable?
    return !PagePermission.first(:joins => [:page, :group_permissions], :conditions => ["(? BETWEEN pages.lft AND pages.rgt) AND group_permissions.user_id = ? AND (page_permissions.can_edit = ? OR page_permissions.can_manage = ?)", page.lft, self.id, true, true]).nil?
  end

  def can_manage_page? page
    return !PagePermission.first(:joins => [:page, :group_permissions], :conditions => ["(? BETWEEN pages.lft AND pages.rgt) AND group_permissions.user_id = ? AND page_permissions.can_manage = ?", page.lft, self.id, true]).nil?
  end

  def logged?
    true
  end

  def facebook_user?
  return !fb_id.nil? && fb_id > 0
end

  def create_user_group
    tmp_group = Group.find_by_name(self.username)
    tmp_group.rename unless tmp_group.nil?
    Group.create(:name => self.username, :usergroup => true).add_as_non_viewer(self)
  end

  #password authetication - from restful_authentication 
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end

  def password_digest(password, salt)
    digest = APP_CONFIG['auth_site_key']
    APP_CONFIG['digest_streches'].times do
      digest = secure_digest(digest, salt, password, APP_CONFIG['auth_site_key'])
    end
    digest
  end

  def encrypt(password)
    self.password_digest(password, salt)
  end

  def encrypt_password
    return if password.blank?
    self.salt = self.make_token if salt.nil?
    self.crypted_password = encrypt(password)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

end
