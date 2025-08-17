bundle install
rspec
rails db:create
rails db:seed
rails feeds:fetch