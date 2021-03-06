# Ensure the agent is started using Unicorn.
# This is needed when using Unicorn and preload_app is not set to true.
# See https://docs.newrelic.com/docs/ruby/no-data-with-unicorn
if defined?(Unicorn) && defined?(NewRelic)
  ::NewRelic::Agent.manual_start()
  ::NewRelic::Agent.after_fork(:force_reconnect => true)
end
