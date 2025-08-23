class Feed < ApplicationRecord
    has_many :articles, dependent: :destroy

    belongs_to :category

    validates :url, presence: true, uniqueness: true
    validates :name, presence: true

    # Set default category before validation if none is assigned to it
    before_validation :set_default_category, if: -> { category.nil? }

    def unread_count
        @unread_count || 0
    end

    private
    def set_default_category 
        self.category = Category.uncategorized
    end

end
