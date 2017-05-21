require 'slack-ruby-bot'
require 'octokit'

class PullRequestBot < SlackRubyBot::Bot

  command 'ping' do |client, data, match|
    client.say(text: 'prbot', channel: data.channel)
  end

  # Match Github.com Pull Request URLs
  match /(?:https?:\/\/)?(?:w{3}\.)?github\.com\/(.*)\/pull\/(\d+)/ do |client, data, matched|
    if !matched[1].nil? and !matched[2].nil?
      repo_full_name = matched[1]
      pull_request_id = matched[2]
      repo = Octokit.repo(repo_full_name)
      pull_request = Octokit.pull(repo_full_name, pull_request_id)
      pr_reviews = octokit.repo
      attachment = [{
        fallback: 'This is a summary',
        color: '#24292e',
        title: pull_request.title + " ##{matched[2]}",
        title_link: matched,
        fields: [
          {
            'title': 'Comments',
            'value': pull_request.comments
            'short': true
          },
          {
            'title': 'Approved',
            'value': pull_request.comments
            'short': true
          }
        ],
        text: pull_request.body,
        footer: 'PR Bot',
      }]
      client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        text: "",
        attachments: attachment
      )
    else
      client.say(channel: data.channel, text: "Problem parsing that pull request, check the URL.")
    end
  end
end

PullRequestBot.run
