class Filter < ApplicationRecord
  # Returns a regex for this filter's term, treating * as wildcard
  def regex
    escaped = Regexp.escape(term).gsub("\\*", ".*")
    /#{escaped}/i
  end
end
