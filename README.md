# RSS Reader (Rails 8.0.2)

This is my first real rails project. Still very much a work in progress.

### To-Do List:
 - Allow OPML imports
 - A lot more work on css (Styling)
 - Add Categories filtering on articles view
 - Settings page
 - User Login


## Requirements
- **Ruby version**: 3.4.5
- **Rails version**: 8.0.2+
- **Database**: SQLite3


## Getting Started

### Installation & Setup

1. **Install dependencies**:
   ```bash
   bundle install
   ```

2. **Database setup**:
   ```bash
   rails db:setup
   ```
3. **Import Sample Feeds/Categories/Filters**
   ```bash
   rails db:seed
   ```
4. **Start the server**:
   ```bash
   rails server
   ```
5. **Automation**:
   Work in progress, for time being im using a crontab that calls the following everything 30 minutes
   ```bash
   rails feeds:fetch
   ```


## RSS Feed Management

### Fetching Feeds

```bash
# Fetch all RSS feeds and create articles
rails feeds:fetch
```

This command runs the `FetchFeedsService` which:
- Fetches content from all configured RSS feeds
- Parses articles and creates database records
- Applies filtering rules to remove unwanted content

## Content Filtering

The application includes a filtering system with pre-configured rules to remove promotional content, deals, and spam. Filters can target article titles and/or descriptions.

Example filters:
- "promo", "coupon", "discount" - removes promotional content
- "best deals", "save off" - removes deal-focused articles
- "#shorts" - removes YouTube shorts

## Models

- **Feed** - RSS feed sources
- **Article** - Individual feed articles
- **Filter** - Content filtering rules
- **Category** - Article categorization

## Testing

```bash
# Run RSpec tests
rspec

# The application includes validations testing
# Note: Currently needs more comprehensive test coverage
```

