class Category < ApplicationRecord
    has_many :feeds
    validates :name, presence: true, uniqueness: true
    
    # validate color is a 6-digit valid hex color
    # utilizes app/validators/hex_color_validator.rb
    validates :color, presence: true, hex_color: true
end
