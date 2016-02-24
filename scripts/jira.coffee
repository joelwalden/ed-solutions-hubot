module.exports = (robot) ->
  robot.hear /(ES-[0-9]+)/, (res) ->
   jiraLink = "https://everydollar.atlassian.net/browse/" + res.match[0] 
   res.reply "Here's a link for you: " + jiraLink

  robot.router.post "/hubot/jiralink", (req, res) ->
    data = if req.body.payload? then JSON.parse req.body.payload else req.body

    robot.logger.info data
    if data.issue
      robot.logger.info "RAW:"
      robot.logger.info req.body
      robot.messageRoom "jira_test", "#{data.webhookEvent}: #{data.issue.key}"
    res.send "OK"
