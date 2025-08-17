# spec/seeds/seeds_spec.rb
require "rails_helper"

RSpec.describe "db:seeds" do
  before do
    # clean slate to avoid duplicates messing with the test
    Feed.delete_all
    Filter.delete_all
    Category.delete_all
  end

  it "loads without error" do
    expect {
      load Rails.root.join("db/seeds.rb")
    }.not_to raise_error
  end

  it "creates the expected feeds" do
    load Rails.root.join("db/seeds.rb")
    expect(Feed.count).to eq(3) # update if you add/remove feeds

    expect(Feed.pluck(:name)).to include("Slashdot", "TechCrunch", "Anime News Network")
    expect(Feed.find_by(name: "Slashdot").url).to eq("https://rss.slashdot.org/Slashdot/slashdot")
  end

  it "creates the expected filters" do
    load Rails.root.join("db/seeds.rb")
    expect(Filter.count).to eq(27) # adjust if you add/remove

    expect(Filter.pluck(:term)).to include("promo", "discount", "#shorts")
  end

  it "creates the expected categories" do
    load Rails.root.join("db/seeds.rb")
    expect(Category.count).to eq(9)

    anime = Category.find_by(name: "Anime")
    expect(anime.color).to eq("#8ff0a4")
  end
end
