util = require "util"
redis = require "redis"
_ = require "lodash"

redisClient = redis.createClient(process.env.REDIS_URL || "6379")

module.exports = (robot) ->
  robot.hear /set key to value/, (res) ->
    redisClient.set("key", "value")

  robot.hear /what is key/, (res) ->
    redisClient.get("key", (err, reply) ->
      res.reply reply
    )

  robot.hear /(ES-[0-9]+)/g, (res) ->
    createJiraLink res

  robot.hear /thanks,? @?edubot/i, (res) ->
    res.reply "You're welcome"

  robot.hear /^@?edubot\??$/, (res) ->
    res.reply _.sample(["Yes?", "I'm listening.", "What do you need?", "How can I help?", "Is there something I can do for you?", "What can I help you with?"])

  robot.router.post "/hubot/jiralink", (req, res) ->
    data = if req.body.payload? then JSON.parse req.body.payload else req.body
    robot.logger.info util.inspect(data, false, null)

    if data.issue
      isES = (data.issue.key.match(/ES-[0-9]+/).length > 0)
      if isES
        salutations = ["Hi there", "Greetings", "Salutations", "Good day", "Hello", "What's up", "How do you do"]
        ticket = data.issue.key

        if data.webhookEvent == "jira:issue_created"
          msg = "#{ticket} has been created."
        else
          status = data.issue.fields.status.name
          isQA = (_.indexOf(["Test Pullable", "Deploy Underway", "Done"], status) > -1)
          switch status
            when "Develop Pullable" then msg = "#{_.sample(salutations)}, team! #{ticket} is ready for code review."
            when "Code Review Pullable" then msg = "#{_.sample(salutations)}, team! #{ticket} is pullable from code review."
            when "Test Pullable" then msg = "#{_.sample(salutations)}, @emily.guadalupe! #{ticket} is ready for QA."
            when "Deploy Underway" then msg = "#{_.sample(salutations)}, team! #{ticket} is moving to Production."
            when "Done" then msg = "#{_.sample(salutations)}, team! #{ticket} is in Production."
            else msg = null

        if msg 
          msg += "\n>*Summary*: #{data.issue.fields.summary}\n>*Link*: https://everydollar.atlassian.net/browse/#{ticket}"
          if isQA
            broadcastRoom = "qa-ragecage"
          else
            broadcastRoom = "jira_test"

          robot.messageRoom broadcastRoom, msg 
    res.send "OK"

createJiraLink = (res) ->
  match = res.match
  if match.length == 1
    jiraLink = "https://everydollar.atlassian.net/browse/" + res.match[0] 
    res.reply "Here's a link for you:\n> #{jiraLink}"
  else if match.length > 1
    reply = "Here are some links for you: \n"
    _.each match, (val) ->
      reply += "> https://everydollar.atlassian.net/browse/#{val}\n"
    res.reply reply
