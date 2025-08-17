require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "validations" do
    it "requires a unique name" do
      Category.create!(name: "UniqueName", color: "#123456")
      duplicate = Category.new(name: "UniqueName", color: "#123456")
      expect(duplicate).not_to be_valid
    end
    
    it "is valid with a proper 6-digit hex color" do
      category = Category.new(name: "Valid", color: "#ABC123")
      expect(category).to be_valid
    end

    it "is invalid without a #" do
      category = Category.new(name: "NoPound", color: "ABC123")
      expect(category).not_to be_valid
      expect(category.errors[:color]).to include("must be a valid six-digit hex code with pound")
    end

    it "is invalid with too few digits" do
      category = Category.new(name: "Short", color: "#ABC12")
      expect(category).not_to be_valid
      expect(category.errors[:color]).to include("must be a valid six-digit hex code with pound")
    end

    it "is invalid with too many digits" do
      category = Category.new(name: "Long", color: "#ABC1234")
      expect(category).not_to be_valid
      expect(category.errors[:color]).to include("must be a valid six-digit hex code with pound")
    end
    
    it "is invalid with non-hex characters" do
      category = Category.new(name: "NonHex", color: "#BCDEFG")
      expect(category).not_to be_valid
      expect(category.errors[:color]).to include("must be a valid six-digit hex code with pound")
    end
    
    it "requires a unique name" do
      category = Category.create!(name: "UniqueName", color: "#ABCDEF")
      duplicate = Category.new(name: "UniqueName", color: "#123456")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end
  end
end
