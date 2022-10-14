release: .deploy/release

web: bin/start-nginx bundle exec unicorn -c ./config/unicorn.rb

generalworker: bundle exec rails jobs:work
