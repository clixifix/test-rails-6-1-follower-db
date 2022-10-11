# frozen_string_literal: true

# It is submitted that Rails 6.0.5.1 is unable to switch back to writing mode for
# ActiveRecord::Persistence::ClassMethods.instance_methods
# This hotfix is supposed to help rails to switch back to writing mode for update/create/delete methods called
# on any active record objects.

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
    def execute_and_clear(sql, name, binds, prepare: false)
      result = if write_query? sql
                 Rails.logger.info "¬¬¬ was a write query"
                 # Specifying the database spawns an additional connection
                 ActiveRecord::Base.connected_to(role: :writing) do
                   execute_the_query(sql, name, binds, prepare)
                 end
               else
                 Rails.logger.info "¬¬¬ was a read query"
                 execute_the_query(sql, name, binds, prepare)
               end

      ret = yield result
      result.clear
      ret
    end

    def execute_the_query(sql, name, binds, prepare)
      Rails.logger.info "¬¬¬ execute_the_query()"

      if without_prepared_statement?(binds)
        exec_no_cache(sql, name, [])
      elsif !prepare
        exec_no_cache(sql, name, binds)
      else
        exec_cache(sql, name, binds)
      end
    end
  end
  