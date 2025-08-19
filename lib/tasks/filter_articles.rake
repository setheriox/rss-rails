namespace :filter do
  desc "Run the FilterArticlesService on all articles"
  task articles: :environment do
    FilterArticlesService.call
    puts "Filtering complete."
  end
end