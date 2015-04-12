db = require('../config/mysql-database')
jwt = require('jsonwebtoken')
secret = require('../config/secret')
tokenManager = require('../config/token-manager')

login = (req, res) ->
  username = req.body.username or ''
  password = req.body.password or ''
  if username == '' or password == ''
    return res.sendStatus 401

  db.user.findOne { username: username }, (error, user) ->

    if error or user is undefined
      console.log "#{error}"
      return res.sendStatus 401

    if password is user.password
      token = jwt.sign(
        { id: user.id },
        secret.secretToken,
        expiresInMinutes: tokenManager.TOKEN_EXPIRATION
      )
      console.log "Logged in as #{user.username}"
      res.json token: token
    else
      console.log "Attempt failed to login with #{user.username}"
      res.sendStatus 401

logout = (req, res) ->
  if req.user
    tokenManager.expireToken req.headers
    delete req.user
    console.log "Logged out"
    res.sendStatus 200
  else
    res.sendStatus 401

module.exports = {
  login
  logout
}