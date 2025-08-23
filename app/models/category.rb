class Category < ApplicationRecord
    has_many :feeds
    
    # sqlite3 needs case_sensitive flag, postgres does not
    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validates :color, presence: true,
                      format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "must be a valid six-digit hex code with pound" }

    def self.uncategorized
        find_by(name: "Uncategorized")
    end

    def unread_count
        @unread_count || 0
    end
end
