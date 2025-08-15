class Article < ApplicationRecord
  belongs_to :feed
  belongs_to :filter, optional: true 

end
