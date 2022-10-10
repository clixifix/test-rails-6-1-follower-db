# frozen_string_literal: true

require_relative '../../lib/rails/postgres_write_handler'

# .nodoc
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  FOLLOWER_URL = ENV.fetch('FOLLOWERUSER_URL', nil)

  connects_to database: { writing: :primary, reading: :follower } if FOLLOWER_URL.present?
end
