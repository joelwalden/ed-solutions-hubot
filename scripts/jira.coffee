util = require "util"
_ = require "lodash"

module.exports = (robot) ->
  robot.hear /(ES-[0-9]+)/, (res) ->
   jiraLink = "https://everydollar.atlassian.net/browse/" + res.match[0] 
   res.reply "Here's a link for you: " + jiraLink

  robot.hear /thanks,? edubot/i, (res) ->
    res.reply "You're welcome"

  robot.router.post "/hubot/jiralink", (req, res) ->
    data = if req.body.payload? then JSON.parse req.body.payload else req.body

    if data.issue
      isES = (data.issue.key.match(/ES-[0-9]+/).length > 0)
      if isES
        salutations = ["Hi there", "Greetings", "Salutations", "Good day", "Hello", "Whassup", "How do you do"]
        names = ["team", "comrades", "human beings", "inferior intelligences", "fellow kids"]
        valedictions = ["Go get 'em!", "You rock", "Yay"]
        ticket = data.issue.key

        if data.webhookEvent == "jira:issue_created"
          msg = "#{ticket} has been created."
        else
          status = data.issue.fields.status.name
          switch status
            when "Backlog" then msg = "#{ticket} has been updated in the backlog."
            when "Backlog Pullable" then msg = "#{ticket} is now pullable from the backlog."
            when "Develop Underway" then msg = "#{ticket} is currently being developed."
            when "Develop Pullable" then msg = "#{ticket} is ready for code review."
            when "Code Review Underway" then msg = "#{ticket} is being code reviewed."
            when "Code Review Pullable" then msg = "#{ticket} is ready for test!"
            when "Test Underway" then msg = "#{ticket} is being moved to test."
            when "Test Pullable" then msg = "#{ticket} is ready for QA."
            when "Merge Underway" then msg = "#{ticket} is being QA'd."
            when "Merge Pullable" then msg = "#{ticket} is ready to move to Production."
            when "Deploy Underway" then msg = "#{ticket} is moving to Production."
            when "Done" then msg = "#{ticket} is in Production."
            else msg = "Something happened with #{ticket}, but I'm not entirely sure what."
        
        msg += "\n>*Summary*: #{data.issue.fields.summary}\n>*Link*: https://everydollar.atlassian.net/browse/#{ticket}"
        composedMsg = "#{_.sample(salutations)}, #{_.sample(names)}! #{msg} #{_.sample(valedictions)}!"

        robot.messageRoom "jira_test", composedMsg
    res.send "OK"
