module RedmineIssuesHook
  class Hooks < Redmine::Hook::Listener
    require "net/https"
    require "uri"
    require "json"

    def controller_issues_new_after_save(context)
      webhook_url = load_webhook_url(context[:issue].project_id)
      return if webhook_url.blank?

      issue_url = context[:controller].issue_url(context[:issue])

      execute(false, webhook_url, context[:issue], issue_url)
    end

    def controller_issues_edit_after_save(context)
      webhook_url = load_webhook_url(context[:issue].project_id)
      return if webhook_url.blank?

      issue_url = context[:controller].issue_url(context[:issue])

      execute(false, webhook_url, context[:issue], issue_url)
    end

    private

    def load_webhook_url(project_id)
      Webhook.find_by(project_id: project_id)&.url
    end

    def execute(is_new, webhook_url, issue, issue_url)
      uri = URI.parse(webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json"
      req.body = build_teams_json(is_new, issue, issue_url).to_json

      begin
        res = http.request(req)
        results = JSON.parse(res.body)
      rescue => e
        p e.message
      end

    end

    CONTENT_BASE = {
      "@type": "MessageCard",
      "@context": "http://schema.org/extensions",
      "themeColor": "0076D7",
      "summary": "Teams Notification",
      "sections": [],
      "potentialAction": []
    }

    def build_teams_json(is_new, issue, issue_url)
      result = CONTENT_BASE
      result[:sections] = build_section(is_new, issue)
      result[:potentialAction] = build_potentialAction(issue_url)
      result
    end

    def build_section(is_new, issue)
      [{
        activityTitle: issue.subject,
        activitySubtitle: is_new ? "チケットが新規作成されました" : "チケットが更新されました",
        facts: build_facts(issue),
        markdown: true
      }]
    end

    def build_facts(issue)
      [
        {
          name: "プロジェクト",
          value: issue.project.name
        },
        {
          name: "チケットID",
          value: "#{issue.tracker.name}##{issue.id.to_s}"
        },
        {
          name: "担当者",
          value: (issue.assigned_to ? issue.assigned_to.name : "担当者が割り当てられていません")
        },
        {
          name: "優先度",
          value: issue.priority.name
        },
        {
          name: "ステータス",
          value: issue.status.name
        }
      ]
    end

    def build_potentialAction(issue_url)
      [
        {
          "@type": "OpenUri",
          name: "チケットを確認する",
          targets: [
            {
              os: "default",
              uri: issue_url
            }
          ]
        }
      ]
    end
  end
end