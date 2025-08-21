class Article < ApplicationRecord
  belongs_to :feed
  belongs_to :filter, optional: true 
  
  scope :read, -> { where(read: true) }
  scope :unread, -> { where(read: false) }
  scope :starred, -> { where(starred: true) }
  scope :filtered, -> { where(filtered: true) }

  def self.sanitize_content(content)
    return content unless content
  
    doc = Nokogiri::HTML::DocumentFragment.parse(content)

    # Remove iframes and embeddings (looking at you slashdot!)
    doc.css('iframe, embed, object, applet, script').remove
    doc.to_html
  end

  # Essentially a duplicate method, using it for readability while working on it
  def sanitized_description
    self.class.sanitize_content(description)
  end
end
