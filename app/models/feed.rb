class Feed < ApplicationRecord
    has_many :articles, dependent: :destroy
    validates :url, presence: true, uniqueness: true
    validates :name, presence: true
end
