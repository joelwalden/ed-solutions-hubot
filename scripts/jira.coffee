util = require "util"
_ = require "lodash"

module.exports = (robot) ->
  robot.hear /(ES-[0-9]+)/, (res) ->
   jiraLink = "https://everydollar.atlassian.net/browse/" + res.match[0] 
   res.reply "Here's a link for you: " + jiraLink

  robot.hear /thanks,? edubot/i, (res) ->
    res.reply "You're welcome"

  robot.hear /^@edubot$/, (res) ->
    res.reply _.sample(["Yes?", "I'm listening", "What do you need?", "How can I help?", "Is there something I can do for you?", "What can I help you with?"])

  robot.router.post "/hubot/jiralink", (req, res) ->
    data = if req.body.payload? then JSON.parse req.body.payload else req.body
    robot.logger.info util.inspect(data, false, null)

    if data.issue
      isES = (data.issue.key.match(/ES-[0-9]+/).length > 0)
      if isES
        salutations = ["Hi there", "Greetings", "Salutations", "Good day", "Hello", "What's up", "How do you do"]
        names = ["team", "comrades", "human beings", "inferior intelligences", "fellow kids"]
        ticket = data.issue.key

        if data.webhookEvent == "jira:issue_created"
          msg = "#{ticket} has been created."
        else
          status = data.issue.fields.status.name
          switch status
            when "Develop Underway" then msg = "#{ticket} is currently being developed."
            when "Develop Pullable" then msg = "#{ticket} is ready for code review."
            when "Code Review Pullable" then msg = "#{ticket} is ready for test!"
            when "Test Pullable" then msg = "#{ticket} is ready for QA."
            when "Deploy Underway" then msg = "#{ticket} is moving to Production."
            when "Done" then msg = "#{ticket} is in Production."
            else msg = null

        if msg 
          msg += "\n>*Summary*: #{data.issue.fields.summary}\n>*Link*: https://everydollar.atlassian.net/browse/#{ticket}"
          composedMsg = "#{_.sample(salutations)}, #{_.sample(names)}! #{msg}"

          robot.messageRoom "jira_test", composedMsg
    res.send "OK"
