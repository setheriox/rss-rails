# RSS Reader Application

A Ruby on Rails RSS Reader application.
This is my first attempt at a full scale web application in Rails...

## Overview

This Rails application collects articles from various RSS feeds, applies filtering rules, and organizes content into categories. It includes features for content filtering, pagination, and automated feed fetching.

## Requirements

- **Ruby version**: 3.4.5
- **Database**: PostgreSQL
- **Rails version**: 8.0.2+

## Database Setup

The application uses PostgreSQL with the following configuration:
- **Host**: postgres
- **Username**: dev  
- **Password**: <%= ENV["DB_PASSWORD"] %>
- **Development DB**: rss_dev
- **Test DB**: rss_test
- **Production DB**: rss_prod

### Database Commands

```bash
# Create and setup databases
rails db:create
rails db:migrate

# Load seed data (creates default feeds and filters)
rails db:seed

# Reset database (drop, create, migrate, seed)
rails db:reset
```

## Installation & Setup

1. **Install dependencies**:
   ```bash
   bundle install
   ```

2. **Database setup**:
   ```bash
   rails db:setup
   ```

3. **Start the server**:
   ```bash
   rails server
   ```

## Key Gems

- **feedjira** - RSS/Atom feed parsing
- **httparty** - HTTP requests for feed fetching
- **nokogiri** - XML/HTML parsing
- **kaminari** - Pagination
- **whenever** - Cron job scheduling
- **turbo-rails** & **stimulus-rails** - Hotwire for modern Rails UI
- **solid_cache**, **solid_queue**, **solid_cable** - Rails 8 solid adapters

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

### Default Feeds

The application comes with 39 pre-configured feeds including:
- Tech news (TechCrunch, ArsTechnica, Wired, The Verge)
- Gaming (IGN, Gematsu, Limited Run Games)
- Development (Slashdot, Hackster.io, Changelog)
- Reddit feeds (r/sysadmin, r/programminghumor, r/anime)
- YouTube channels
- And more

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
# Note: Currently needs more comprehensive test coverage beyond hex color validations
```

## Development Tools

- **RSpec** - Testing framework
- **Rubocop** - Code style enforcement (Rails Omakase style)
- **Brakeman** - Security vulnerability scanning
- **Debug** - Debugging tools

## Deployment

The application is configured for deployment with:
- **Kamal** - Docker-based deployment
- **Thruster** - HTTP asset caching and compression for Puma

## Automation

Use the **whenever** gem to schedule automatic feed fetching:

```bash
# Example cron job (configure in config/schedule.rb)
every 30.minutes do
  runner "FetchFeedsService.call"
end
```

## Architecture Notes

- Uses Rails 8 with modern Hotwire (Turbo/Stimulus) for enhanced UX
- PostgreSQL for data persistence with multiple database support for production
- Service-oriented architecture with `FetchFeedsService` for feed processing
- Content filtering system to maintain feed quality