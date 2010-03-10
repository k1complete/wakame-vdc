module Dcmgr
  module Models
    class ImageStorageHost < Base
      set_dataset :image_storage_hosts
      def self.prefix_uuid; 'ISH'; end
  
      many_to_many :tags, :join_table=>:tag_mappings, :left_key=>:target_id, :conditions=>{:target_type=>TagMapping::TYPE_IMAGE_STORAGE_HOST}
    end
  end
end