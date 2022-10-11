# frozen_string_literal: true
# .nodoc
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  FOLLOWER_URL = ENV.fetch('FOLLOWERUSER_URL', nil)
end
