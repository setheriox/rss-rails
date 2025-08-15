class Filter < ApplicationRecord
  has_many :articles

  after_create :apply_to_existing_articles
  before_destroy :unfilter_articles  # Changed from after_destroy to before_destroy
  
  # Returns a regex for this filter's term, treating * as wildcard
  def regex
    escaped = Regexp.escape(term).gsub("\\*", ".*")
    /#{escaped}/i
  end

  def matches_article?(article)
    return false if term.blank?

    title_match = title? && article.title.to_s.match?(regex)
    description_match = description? && article.description.to_s.match?(regex)

    title_match || description_match
  end

  private

  def apply_to_existing_articles
    Article.where(filtered: false).find_each do |article|
      if matches_article?(article)
        article.update!(filtered: true, filter_id: self.id)
      end
    end
  end

  def unfilter_articles
    Article.where(filter_id: self.id).update_all(filtered: false, filter_id: nil)
  end
end