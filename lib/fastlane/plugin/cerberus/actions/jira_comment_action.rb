require 'fastlane/action'
require_relative '../helper/cerberus_helper'

module Fastlane
 module Actions

  class JiraCommentAction < Action

   def self.run(params)
    issues = params[:issues]
    return if issues.to_a.empty?

    client = Helper::CerberusHelper.jira_client(
      host: params[:host], 
      username: params[:username],
      password: params[:password], 
      context_path: params[:context_path], 
      disable_ssl_verification: (params[:disable_ssl_verification].to_s.downcase || 'false') == 'true'
    )
    issues = client.get(issues: issues)

    comment = "Jenkins: [Build ##{params[:build_number]}|#{params[:build_url]}]"
    comment << "\n"
    comment << "HockeyApp: [Version #{params[:app_version]} (#{params[:build_number]})|#{params[:hockey_url]}]"

    client.add_comment(
     comment: comment, 
     issues: issues
    )
   end

   def self.details
    "This action adds comments on Jira issues with the current build numnber and url of that build"
   end

   def self.is_supported?(platform)
    platform == :ios
   end

   def self.available_options
    [
     FastlaneCore::ConfigItem.new(
      key: :issues,
      env_name: "FL_JIRA_COMMENT_ISSUES",
      description:  "jira issue keys",
      optional: false,
      default_value: [],
      type: Array
     ),
     FastlaneCore::ConfigItem.new(
      key: :build_number,
      env_name: "FL_JIRA_COMMENT_BUILD_NUMBER",
      description:  "CI build number",
      optional: false,
      default_value: ENV["BUILD_NUMBER"]
     ),
     FastlaneCore::ConfigItem.new(
      key: :build_url,
      env_name: "FL_JIRA_COMMENT_BUILD_URL",
      description:  "CI build URL",
      optional: false,
      default_value: ENV["BUILD_URL"]
     ),
     FastlaneCore::ConfigItem.new(
      key: :app_version,
      env_name: "FL_JIRA_COMMENT_APP_VERSION",
      description:  "App version",
      optional: false
     ),
     FastlaneCore::ConfigItem.new(
      key: :hockey_url,
      env_name: "FL_JIRA_COMMENT_HOCKEY_URL",
      description:  "Hockey build url",
      optional: false,
      default_value: Actions.lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK]
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
  end
 end
end