require 'fastlane/action'
require_relative '../helper/cerberus_helper'

module Fastlane
 module Actions

  class ReleaseNotesAction < Action

   def self.run(params)
    @client = Helper::CerberusHelper.jira_client(
      host: params[:host], 
      username: params[:username],
      password: params[:password], 
      context_path: params[:context_path], 
      disable_ssl_verification: (params[:disable_ssl_verification].to_s.downcase || 'false') == 'true'
    )
    issues = @client.get(issues: params[:issues])
    Actions.lane_context[SharedValues::FL_CHANGELOG] = comment(issues: issues, url: params[:buildURL])
    return Actions.lane_context[SharedValues::FL_CHANGELOG]
   end

   def self.details
    "Creates a markdown friendly change log from the Jira issues and the Jenkins build url"
   end

   def self.is_supported?(platform)
    platform == :ios
   end

   def self.output
    String
   end

   def self.available_options
    [
     FastlaneCore::ConfigItem.new(
      key: :issues,
      env_name: "FL_HOCKEY_COMMENT_ISSUES",
      description:  "Jira issues",
      optional: false,
      default_value: [],
      type: Array
     ),
     FastlaneCore::ConfigItem.new(
      key: :buildURL,
      env_name: "FL_HOCKEY_COMMENT_BUILD_URL",
      description:  "Link to the ci build",
      optional: false,
      default_value: ENV["BUILD_URL"],
     ),
     FastlaneCore::ConfigItem.new(
      key: :username,
      env_name: "FL_JIRA_CLIENT_USERNAME",
      description:  "Jira user",
      optional: false,
      default_value: ENV["CI_USER_JIRA_CREDENTIALS_USR"]
     ),
     FastlaneCore::ConfigItem.new(
      key: :password,
      env_name: "FL_JIRA_CLIENT_PASSWORD",
      description:  "Jira user",
      optional: false,
      default_value: ENV["CI_USER_JIRA_CREDENTIALS_PSW"]
     ),
     FastlaneCore::ConfigItem.new(
      key: :host,
      env_name: "FL_JIRA_CLIENT_HOST",
      description:  "Jira location",
      optional: false,
      default_value: ENV["CI_JIRA_HOST"]
     ),
     FastlaneCore::ConfigItem.new(
      key: :context_path,
      env_name: "FL_JIRA_CLIENT_CONTEXT_PATH",
      description:  "Jira context path",
      optional: false,
      default_value: ENV["CI_JIRA_CONTEXT_PATH"] || ''
     ),
     FastlaneCore::ConfigItem.new(
      key: :disable_ssl_verification,
      env_name: "FL_JIRA_CLIENT_DISABLE_SSL_VERIFICATION",
      description:  "Jira SSL Verification mode",
      optional: false,
      default_value: 'false'
     )
    ]
   end

   def self.author
    "Harry Singh <harry.singh@outware.com.au>"
   end

   private

   def self.format(issue:)
    "- [#{issue.key}](#{@client.url(issue: issue)}) - #{issue.summary}"
   end

   def self.comment(issues:, url:)
    changes = issues.map { |issue| format(issue: issue) }.join("\n")
    changes = "No changes included." if changes.to_s.empty?

    changelog = """
    ### ChangeLog

    #{changes}

    Built by [Jenkins](#{url})
    """.each_line.map(&:strip).join("\n")

    UI.important changelog
    return changelog
   end
  end
 end
end