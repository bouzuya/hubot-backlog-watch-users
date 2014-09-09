// Description
//   A Hubot script that watch the users and theirs processing issue.
//
// Dependencies:
//   "q": "^1.0.1",
//   "request": "^2.42.0"
//
// Configuration:
//   HUBOT_BACKLOG_WATCH_USERS_SPACE_ID
//   HUBOT_BACKLOG_WATCH_USERS_API_KEY
//   HUBOT_BACKLOG_WATCH_USERS_PROJECTS
//   HUBOT_BACKLOG_WATCH_USERS_INTERVAL
//
// Commands:
//   None
//
// Author:
//   bouzuya <m@bouzuya.net>
//
module.exports = function(robot) {
  var Promise, apiKey, baseUrl, displayUsers, getProject, getProjectUsers, getUserIssues, interval, projects, request, spaceId, watch, _ref, _ref1;
  Promise = require('q').Promise;
  request = require('request');
  spaceId = process.env.HUBOT_BACKLOG_WATCH_USERS_SPACE_ID;
  apiKey = process.env.HUBOT_BACKLOG_WATCH_USERS_API_KEY;
  projects = JSON.parse((_ref = process.env.HUBOT_BACKLOG_WATCH_USERS_PROJECTS) != null ? _ref : '{}');
  interval = parseInt((_ref1 = process.env.HUBOT_BACKLOG_WATCH_USERS_INTERVAL) != null ? _ref1 : '3600,000', 10);
  baseUrl = "https://" + spaceId + ".backlog.jp";
  getProject = function(projectKey) {
    return new Promise(function(resolve, reject) {
      return request({
        method: 'GET',
        url: "" + baseUrl + "/api/v2/projects/" + projectKey,
        qs: {
          apiKey: apiKey
        },
        json: true
      }, function(err, res) {
        if (err != null) {
          return reject(err);
        } else {
          return resolve(res.body);
        }
      });
    });
  };
  getProjectUsers = function(projectKey) {
    return new Promise(function(resolve, reject) {
      return request({
        method: 'GET',
        url: "" + baseUrl + "/api/v2/projects/" + projectKey + "/users",
        qs: {
          apiKey: apiKey
        },
        json: true
      }, function(err, res) {
        if (err != null) {
          return reject(err);
        } else {
          return resolve(res.body);
        }
      });
    });
  };
  getUserIssues = function(projectId, userId) {
    return new Promise(function(resolve, reject) {
      return request({
        method: 'GET',
        url: "" + baseUrl + "/api/v2/issues",
        qs: {
          'projectId[]': projectId,
          'statusId[]': 2,
          'assigneeId[]': userId,
          apiKey: apiKey
        },
        json: true
      }, function(err, res) {
        if (err != null) {
          return reject(err);
        } else {
          return resolve(res.body);
        }
      });
    });
  };
  displayUsers = function() {
    return Object.keys(projects).reduce((function(promise, projectKey) {
      var project, room;
      project = null;
      room = null;
      return promise.then(function() {
        room = projects[projectKey];
        return getProject(projectKey);
      }).then(function(p) {
        project = p;
        return getProjectUsers(projectKey);
      }).then(function(users) {
        var usersAndIssues;
        usersAndIssues = [];
        return users.reduce((function(promiseUser, user) {
          return promiseUser.then(function() {
            return getUserIssues(project.id, user.id);
          }).then(function(issues) {
            var issue;
            issue = issues.sort(function(a, b) {
              return a.updated < b.updated;
            })[0];
            usersAndIssues.push({
              issue: issue,
              user: user
            });
            return usersAndIssues;
          });
        }), Promise.resolve());
      }).then(function(usersAndIssues) {
        return 'backlog-watch-status:\n' + usersAndIssues.filter(function(i) {
          return i.issue;
        }).map(function(_arg) {
          var issue, user;
          user = _arg.user, issue = _arg.issue;
          return "" + user.name + " : " + baseUrl + "/views/" + issue.issueKey + " : " + issue.summary;
        }).join('\n');
      }).then(function(message) {
        console.log(message);
        return res.messageRoom(room, message);
      });
    }), Promise.resolve());
  };
  watch = function() {
    var next;
    next = function() {
      return setTimeout((function() {
        return watch();
      }), INTERVAL);
    };
    return displayUsers().then(next, next);
  };
  return watch();
};
