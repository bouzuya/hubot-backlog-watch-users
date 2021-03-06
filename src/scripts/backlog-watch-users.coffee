# Description
#   A Hubot script that watch the users and theirs processing issue.
#
# Dependencies:
#   "q": "^1.0.1",
#   "request": "^2.42.0"
#
# Configuration:
#   HUBOT_BACKLOG_WATCH_USERS_USE_SLACK
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

  useSlack = process.env.HUBOT_BACKLOG_WATCH_USERS_USE_SLACK
  spaceId = process.env.HUBOT_BACKLOG_WATCH_USERS_SPACE_ID
  apiKey = process.env.HUBOT_BACKLOG_WATCH_USERS_API_KEY
  projects = JSON.parse(process.env.HUBOT_BACKLOG_WATCH_USERS_PROJECTS ? '{}')
  interval = parseInt(
    process.env.HUBOT_BACKLOG_WATCH_USERS_INTERVAL ? '3600000', 10)

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

  rpad = (s, l) ->
    while s.length < l
      s += ' '
    s

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
          width = usersAndIssues.reduce (w, { user }) ->
            Math.max(w, user.name.length)
          , 0
          'backlog-watch-users:\n' +
          usersAndIssues.filter((i) -> i.issue).map(({ user, issue }) ->
            name = rpad(user.name, width)
            "#{name} : #{baseUrl}/view/#{issue.issueKey} #{issue.summary}"
          ).join '\n'
        .then (message) ->
          wrapped = if useSlack then '```\n' + message + '\n```' else message
          robot.messageRoom(room, wrapped)
    ), Promise.resolve()

  watch = ->
    next = ->
      setTimeout (-> watch()), interval
    displayUsers()
      .then next, next

  watch()
