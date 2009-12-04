class PagePartLock < ActiveRecord::Base
  belongs_to :user
  belongs_to :page_part

  def self.create_lock(part_id, user)
    page_lock = self.find_by_part_id_and_user_id(part_id, user.id)
    if page_lock.nil? then 
      page_lock = self.create(:user_id => user.id, :part_id => part_id)
    else
      page_lock.updated_at = Time.now
    end
    page_lock.save!
  end
  
  def self.delete_lock(part_id, user)
    self.delete_all(["part_id = ? and user_id = ?", part_id, user.id])
  end

  def self.delete_old_locks
    self.delete_all(["updated_at < ?", (Time.zone.now - APP_CONFIG['lock_timeout'].to_i)])
  end
   
  def self.check_lock?(part_id, user)
    delete_old_locks
    count = self.count(:conditions => ["part_id = ? and user_id <> ?", part_id, user.id])
    return (count>0)
  end

  private 
  def self.delete_old_user_locks(part_id, user)
    self.delete_all(["part_id <> ? and user_id = ?", part_id, user.id])
  end 
end


