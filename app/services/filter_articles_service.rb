class FilterArticlesService
    def self.call
        filters = Filter.all.to_a
        
        Article.find_each do |article|
            process_article(article, filters)
        end
    end

    def self.process_article(article, filters)
        matching_filter = matching_filter(article, filters)
        if article.filtered != matching_filter.present? || article.filter != matching_filter
            article.update!(
                filtered: matching_filter.present?,
                filter: matching_filter
            )
            if matching_filter
                puts "Filtered: #{article.feed.name} - #{article.title} - Filter: #{matching_filter.name}"
            else
               puts "Unfiltered: #{article.feed.name} - #{article.title}"
            end
        else
          # Optionally log unchanged articles
          # puts "No change: #{article.feed.name} - #{article.title}"
        end

        # Reuse the same matching logic from FetchFeedsService

    end

    def self.matching_filter(article, filters)
        filters.find do |filter|
            title_match = filter.title && article.title.to_s.match?(filter.regex)
            description_match = filter.description && article.description.to_s.match?(filter.regex)
            title_match || description_match
        end
    end
end
