module.exports = (robot) ->
  robot.hear /(ES-[1-9]+)/, (res) ->
   jiraLink = "https://everydollar.atlassian.net/browse/" + res.match[0] 
   res.reply "Here ya go: " + jiraLink
