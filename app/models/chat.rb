class Chat < ApplicationRecord
  belongs_to :plan
  has_many :messages, dependent: :destroy
end
