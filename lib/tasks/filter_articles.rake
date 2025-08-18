namespace :feeds do
  desc "Fetch all RSS feeds and create articles"
  task fetch: :environment do
    puts "Starting feed fetch..."
    FetchFeedsService.call
    puts "Feed fetch completed!"
  end
end
