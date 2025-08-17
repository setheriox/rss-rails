class Feed < ApplicationRecord
    has_many :articles, dependent: :destroy

    belongs_to :category

    validates :url, presence: true, uniqueness: true
    validates :name, presence: true

    # Set default category before validation if none is assigned to it
    before_validation :set_default_category, if: -> { category.nil? }

    private
    def set_default_category 
        self.category = Category.uncategorized
    end

end
