# hubot-backlog-watch-users

A Hubot script that watch the users and theirs processing issue.

## Installation

    $ npm install git://github.com/bouzuya/hubot-backlog-watch-users.git

or

    $ # TAG is the package version you need.
    $ npm install 'git://github.com/bouzuya/hubot-backlog-watch-users.git#TAG'

## Example

    (every hours)
    hubot> backlog-watch-users:
           bouzuya   : https://space.backlog.jp/views/HUBOT-123 special issue
           emanon001 : https://space.backlog.jp/views/HUBOT-456 fix typo

## Configuration

See [`src/scripts/backlog-watch-users.coffee`](src/scripts/backlog-watch-users.coffee).

## Development

`npm run`

## License

[MIT](LICENSE)

## Author

[bouzuya][user] &lt;[m@bouzuya.net][mail]&gt; ([http://bouzuya.net][url])

## Badges

[![Build Status][travis-badge]][travis]
[![Dependencies status][david-dm-badge]][david-dm]
[![Coverage Status][coveralls-badge]][coveralls]

[travis]: https://travis-ci.org/bouzuya/hubot-backlog-watch-users
[travis-badge]: https://travis-ci.org/bouzuya/hubot-backlog-watch-users.svg?branch=master
[david-dm]: https://david-dm.org/bouzuya/hubot-backlog-watch-users
[david-dm-badge]: https://david-dm.org/bouzuya/hubot-backlog-watch-users.png
[coveralls]: https://coveralls.io/r/bouzuya/hubot-backlog-watch-users
[coveralls-badge]: https://img.shields.io/coveralls/bouzuya/hubot-backlog-watch-users.svg
[user]: https://github.com/bouzuya
[mail]: mailto:m@bouzuya.net
[url]: http://bouzuya.net
