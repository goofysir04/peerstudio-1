class Ckeditor::Asset < ActiveRecord::Base
  include Ckeditor::Orm::ActiveRecord::AssetBase
  include Ckeditor::Backend::Paperclip


  #define the getter/setter because rails will think assetable_id is a foreign key
  def assetable_id
  	return self.assetable_id_
  end

  def assetable_id=(val)
  	self.assetable_id_ = val
  end

  def assetable
  	return User.find(self.assetable_id_)
  end

  def assetable=(val)
  	self.assetable_id_ = val.id
  end
end
