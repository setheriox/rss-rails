class FetchFeedsJob < ApplicationJob
  queue_as :default

  def perform
    FetchFeedsService.call
  end
end