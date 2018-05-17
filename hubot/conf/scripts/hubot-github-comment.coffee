# Description:
#   hubot monitoring git comments mention and slack DM
#
# Dependencies:
#   "hubot-slack": "^4.4.0"
#   "hubot-slack-attachement": "^1.0.1"
#
# Commands:
#   None
#
# Author:
#   kenzo-tanaka
#
# Use if the user name of jira and slack is different
# "github": "slackName"

users = {
    "kenzo-tanaka": "kenzo0107",
    "no_receive_user": "no_send"
}

module.exports = (robot) ->

  convertHandleName = (name) ->
    users[name] || name

  # Git の username から Slack の username 取得
  getSlackUsernameByGitUsername = (gitUsername) ->
    gitUsername = gitUsername.replace(/-/g , "." )
    gitUsername = gitUsername.replace(/@/g , "" )
    return gitUsername

  # コメント本文のメンションを取得
  mentionsSearch = (body) ->
    mentions = []
    regexp_str = body.match /(^|\s)(@[\w\-\/]+)/g
    if regexp_str
      for mention in regexp_str
        mention = getSlackUsernameByGitUsername(mention.trim())
        mentions.push(mention)
      mentions
    else
      null

  robot.router.post "/git-comments", (req, response) ->
    timestamp = new Date/1000|0

    data = req.body
    event_type = req.get 'X-Github-Event'
    if event_type not in ["pull_request", "issue_comment"]
      response.end 'ng'
      return

    switch event_type
      when 'issue_comment'
        action = data.action
        cbody  = data.comment.body
        user   = data.comment.user.login
        url    = data.comment.html_url
        title  = data.issue.title
        number = data.issue.number
        repoName = data.repository.full_name
      when 'pull_request'
        action = data.action
        cbody  = data.pull_request.body
        user   = data.pull_request.user.login
        url    = data.pull_request.html_url
        title  = data.pull_request.title
        number = data.pull_request.number
        repoName = data.repository.full_name

    if action not in ['created', 'opened', 'reopened', 'edited']
      response.end 'ng'
      return

    slackUserName = getSlackUsernameByGitUsername(user)

    attachments = [
      {
        fallback: "[#{repoName}] #{user} #{action} #{title}",
        color: 'good',
        pretext: "[<#{url}|#{repoName}>] @#{slackUserName} #{action}"
        title: title,
        title_link: url,
        fields: [
          {
            title: "",
            value: "#{cbody}",
            short: false
          }
        ],
        footer: user,
        footer_icon: 'https://assets-cdn.github.com/images/modules/logos_page/Octocat.png',
        ts: timestamp
      }
    ]

    options = { as_user: true, link_names: 1, attachments: attachments }

    if !!robot.adapter.client
      client = robot.adapter.client
      mentions = mentionsSearch(cbody)
      return unless mentions?
      for mention in mentions
        userName = convertHandleName(mention)
        userId = client.rtm.dataStore.getUserByName(userName).id
        return unless userId?
        client.web.chat.postMessage(userId, '', options)

    response.end 'OK'
