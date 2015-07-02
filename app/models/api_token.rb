class ApiToken < ActiveRecord::Base

  validates :hex_value, uniqueness: true

  belongs_to :store

end
