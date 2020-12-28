class OfficeTargetCollaboration < ApplicationRecord

 belongs_to :target, polymorphic: true
 belongs_to :office, class_name: 'Office', foreign_key: 'office_id'
 
end
