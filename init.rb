require_dependency 'redmine_issue_hook'

Redmine::Plugin.register :redmine_webhook_notificator do
  name 'Redmine Webhook Notificator plugin'
  author 'tasogarei'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url ''
  author_url ''

  permission :hook, { webhook: :index }, public: true
  menu :project_menu, :hook, { controller: 'webhook', action: 'index' }, caption: 'Webhook', param: :project_id
end
