# frozen_string_literal: true

# It is submitted that Rails 6.0.5.1 is unable to switch back to writing mode for
# ActiveRecord::Persistence::ClassMethods.instance_methods
# This hotfix is supposed to help rails to switch back to writing mode for update/create/delete methods called
# on any active record objects.

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
    def execute_and_clear(sql, name, binds, prepare: false)
      Rails.logger.info "#{sql.inspect} ?? #{__FILE__}"
  
      Rails.logger.info "¬¬¬connection #{ActiveRecord::Base.connection_config.inspect}"
      result = if write_query? sql
                 Rails.logger.info "¬¬¬ was a write query"
                #  Rails.logger.info "¬¬¬ #{sql}"
                #  Rails.logger.info "¬¬¬ #{name}"
                #  Rails.logger.info "¬¬¬ #{binds}"
                #  Rails.logger.info "¬¬¬ #{prepare}"
                 Rails.logger.info "¬¬¬ sql #{sql}"
                 Rails.logger.error "¬¬¬¬¬¬1 connection_specification_name() #{ActiveRecord::Base.connection_specification_name()}"
                 # Specifying the database spawns an additional connection
                 ActiveRecord::Base.connected_to(role: :writing) do
                   Rails.logger.info "¬¬¬ con config#2 #{ActiveRecord::Base.connection_config.inspect}"
                   Rails.logger.error "¬¬¬¬¬¬2 connection_specification_name() #{ActiveRecord::Base.connection_specification_name()}"
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
  