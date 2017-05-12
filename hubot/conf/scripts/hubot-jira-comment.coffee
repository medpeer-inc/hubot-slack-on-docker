# Description:
#   hubot monitoring jira comments mention and slack DM
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JIRA_URL
#
# Commands:
#   None
#
# Author:
#   futabooo


# Use if the user name of jira and slack is different
# "jiraName": "slackName"
map =


module.exports = (robot) ->

  convertHandleName = (name) ->
    map[name] || name

  extractHandleName = (body) ->
    temp = body.match(/\[~.+?]/g)
    unless temp is null
      name = []
      for i in temp
        name.push("#{i}".replace(/[\[~\]]/g, ""))
      return name

  robot.router.post '/hubot/jira-comment-dm', (req, res) ->
    body = req.body
    if body.webhookEvent == 'jira:issue_updated' && body.comment
      issue = "#{body.issue.key} #{body.issue.fields.summary}"
      url = "#{process.env.HUBOT_JIRA_URL}/browse/#{body.issue.key}"
      handleNameList = extractHandleName(body.comment.body)

      unless handleNameList is null
        for i in handleNameList
          userName = convertHandleName(i)
          userId = robot.adapter.client.rtm.dataStore.getUserByName(userName).id
          robot.send(room: userId,
            "*#{issue}* _(#{url})_\n@#{body.comment.author.name}'s comment:\n```#{body.comment.body}```")
    res.send 'OK'
