class Category < ApplicationRecord
    has_many :feeds


    validates :name, presence: true, uniqueness: true
    # validate color is a 6-digit valid hex color
    validates :color, presence: true
    validate :color_must_be_hex
    
    def self.uncategorized
        find_or_create_by(name: "Uncategorized") do |category|
            category.color = "#ffffff"
        end
    end
    private
    def color_must_be_hex
        return unless color.present?
        
        hex_regex = /\A#[A-Fa-f0-9]{6}\z/
        unless color.match?(hex_regex)
            errors.add(:color, "must be a valid six digit hex code")
        end
    end
end
