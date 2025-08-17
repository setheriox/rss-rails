# Check out app/services/fetch_Feeds_job.rb to get feeds services!
# rails feeds:fetch 
# will retreive all feed

class FetchFeedsJob < ApplicationJob
  queue_as :default
  def perform
    FetchFeedsService.call
  end
end