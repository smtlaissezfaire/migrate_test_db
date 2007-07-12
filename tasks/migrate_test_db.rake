# STOLEN FROM rcov plugin. This File Uses Magic
# ====================
# Here's an example of how this file works. As an example, let's say you typed
# this into your terminal:
# 
#   $ rake --tasks
# 
# The rake executable goes through all the various places .rake files can be,
# accumulates them all, and then runs them. When this file is loaded by Rake,
# it iterates through all the tasks, and for each task named 'test:blah' adds
# test:blah:rcov and test:blah:rcov_clobber.
# 
# So you've seen all the tasks, and you type this into your terminal:
# 
#   $ rake test:units:rcov
# 
# Rake does the same thing as above, but it runs the test:units:rcov task, which
# pretty much just does this:
# 
#   $ ruby [this file] [the test you want to run] [some options]
# 
# Now this file is run via the Ruby interpreter, and after glomming up the
# options, it acts just like the Rake executable, with a slight difference: it
# passes all the arguments to rcov, not ruby, so all your unit tests get some
# rcov sweet loving.

namespace :db do
  desc "Overwritten standard prepare to include parsing of :migrate schema dump type."
  task :prepare => :environment do
  Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:clone" }[ActiveRecord::Base.schema_format]].invoke
  schema_format = ActiveRecord::Base.schema_format
  case schema_format
    when :sql
      Rake::Task["db:test:clone_structure"].invoke
    when :ruby
      Rake::Task["db:test:clone"].invoke
    when :migrate
      # Use a migration to ready the test database
      # Useful when :sql or :ruby are failing which occurs universally when
      # views are present.
      Rake::Task["db:test:purge"].invoke
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      ActiveRecord::Schema.verbose = false
      Rake::Task["db:migrate"].invoke
    else # This could also default to :ruby... DHH thoughts on this?
      raise "Task not supported by '#{schema_format}'"
    end
  end
end
