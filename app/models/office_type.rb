class OfficeType < ApplicationRecord
has_many :offices, inverse_of: 'office_type'

end
