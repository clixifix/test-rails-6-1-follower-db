# frozen_string_literal: true

# .nodoc
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  FOLLOWER_URL = ENV.fetch('FOLLOWERUSER_URL', nil)

  Rails.logger.error "¬¬ #{Rails.application.config.database_configuration[Rails.env]}"
  connects_to database: { writing: :primary, reading: :follower } if FOLLOWER_URL.present?
end
