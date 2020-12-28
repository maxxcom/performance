class ItemEvaluation < ApplicationRecord
 belongs_to :target, polymorphic: true, required: false

end
