require 'fastlane_core/ui/ui'
require 'jira-ruby'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CerberusHelper
      class Jira
       def initialize(host, username, password, context_path, disable_ssl_verification)
        @host = host
        @context_path = context_path
        create_client(host: host, username: username, password: password, context_path: context_path, disable_ssl_verification: disable_ssl_verification)
       end

       def get(issues:)
        return [] if issues.to_a.empty?

        begin
         @client.Issue.jql("KEY IN (#{issues.join(",")})", fields: [:key, :summary], validate_query: false)
        rescue => e
         UI.important "Jira Client: Failed to get issues."
         UI.important "Jira Client: Reason - #{e.message}"
         []
        end
       end

       def add_comment(comment:, issues:)
        return if issues.to_a.empty?

        issues.each do |issue|
          begin
            issue.comments.build.save({ 'body' => comment })
          rescue => e
            UI.important "Jira Client: Failed to comment on issues - #{issue.key}"
            UI.important "Jira Client: Reason - #{e.message}"
          end
        end
       end

       def url(issue:)
        return "#{@host}/#{@context_path}/browse/#{issue.key}" unless @context_path.to_s.empty?
        
        "#{@host}/browse/#{issue.key}"
       end

       private
       
       def create_client(host:, username:, password:, context_path:, disable_ssl_verification:)
        options = {
         site: host,
         context_path: context_path,
         auth_type: :basic,
         username: username,
         password: password,
         ssl_verify_mode: disable_ssl_verification ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
        }

        @client = JIRA::Client.new(options)
       end
      end

      # class methods that you define here become available in your action
      # as `Helper::CerberusHelper.your_method`
      #
      def self.jira_client(host:, username:, password:, context_path:, disable_ssl_verification:)
        return Jira.new(host, username, password, context_path, disable_ssl_verification)
      end
    end
  end
end
