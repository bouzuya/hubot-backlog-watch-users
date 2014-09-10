# Description
#   A Hubot script that watch the users and theirs processing issue.
#
# Dependencies:
#   "q": "^1.0.1",
#   "request": "^2.42.0"
#
# Configuration:
#   HUBOT_BACKLOG_WATCH_USERS_SPACE_ID
#   HUBOT_BACKLOG_WATCH_USERS_API_KEY
#   HUBOT_BACKLOG_WATCH_USERS_PROJECTS
#   HUBOT_BACKLOG_WATCH_USERS_INTERVAL
#
# Commands:
#   None
#
# Author:
#   bouzuya <m@bouzuya.net>
#
module.exports = (robot) ->
  {Promise} = require 'q'
  request = require 'request'

  spaceId = process.env.HUBOT_BACKLOG_WATCH_USERS_SPACE_ID
  apiKey = process.env.HUBOT_BACKLOG_WATCH_USERS_API_KEY
  projects = JSON.parse(process.env.HUBOT_BACKLOG_WATCH_USERS_PROJECTS ? '{}')
  interval = parseInt(
    process.env.HUBOT_BACKLOG_WATCH_USERS_INTERVAL ? '3600,000', 10)

  baseUrl = "https://#{spaceId}.backlog.jp"

  getProject = (projectKey) ->
    new Promise (resolve, reject) ->
      request
        method: 'GET'
        url: "#{baseUrl}/api/v2/projects/#{projectKey}"
        qs:
          apiKey: apiKey
        json: true
      , (err, res) ->
        if err?
          reject err
        else
          resolve res.body

  getProjectUsers = (projectKey) ->
    new Promise (resolve, reject) ->
      request
        method: 'GET'
        url: "#{baseUrl}/api/v2/projects/#{projectKey}/users"
        qs:
          apiKey: apiKey
        json: true
      , (err, res) ->
        if err?
          reject err
        else
          resolve res.body

  getUserIssues = (projectId, userId) ->
    new Promise (resolve, reject) ->
      request
        method: 'GET'
        url: "#{baseUrl}/api/v2/issues"
        qs:
          'projectId[]': projectId
          'statusId[]': 2
          'assigneeId[]': userId
          apiKey: apiKey
        json: true
      , (err, res) ->
        if err?
          reject err
        else
          resolve res.body

  displayUsers = ->
    Object.keys(projects).reduce ((promise, projectKey) ->
      project = null
      room = null
      promise
        .then ->
          room = projects[projectKey]
          getProject(projectKey)
        .then (p) ->
          project = p
          getProjectUsers(projectKey)
        .then (users) ->
          usersAndIssues = []
          users.reduce ((promiseUser, user) ->
            promiseUser
              .then ->
                getUserIssues(project.id, user.id)
              .then (issues) ->
                issue = issues.sort((a, b) -> a.updated < b.updated)[0]
                usersAndIssues.push { issue, user }
                usersAndIssues
          ), Promise.resolve()
        .then (usersAndIssues) ->
          'backlog-watch-status:\n' +
          usersAndIssues.filter((i) -> i.issue).map(({ user, issue }) -> """
          #{user.name} : #{baseUrl}/views/#{issue.issueKey} #{issue.summary}
          """).join '\n'
        .then (message) ->
          console.log message
          res.messageRoom(room, message)
    ), Promise.resolve()

  watch = ->
    next = ->
      setTimeout (-> watch()), interval
    displayUsers()
      .then next, next

  watch()
