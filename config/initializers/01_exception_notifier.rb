unless Rails.env.development? or (not ActiveRecord::Base.connection.column_exists?("settings", "target_id"))
  Quby::Application.config.middleware.use ExceptionNotifier,
   :email_prefix => "[Quby] ",
   :sender_address => %{"Exception Notifier" <noreply@roqua.nl>},
   # TODO After the 201105 release we can remove this conditional
   :exception_recipients => Settings.exception_email || "#{Settings.organization}@roqua.nl"
end