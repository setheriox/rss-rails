class Feed < ApplicationRecord
    has_many :articles, dependent: :destroy
    belongs_to :categories
    validates :url, presence: true, uniqueness: true
    validates :name, presence: true
end
