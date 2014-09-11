express = require 'express'
logger = require 'morgan'
sass = require 'node-sass'
coffee = require 'coffee-middleware'

app = express()
app.use logger 'dev'

# view engine setup
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'

app.use express.static "#{__dirname}/public"

app.use sass.middleware
  src: "#{__dirname}/assets"
  dest: "#{__dirname}/.cache"
  debug: true

app.use coffee
  src: "#{__dirname}/assets"
  debug: true

app.use express.static "#{__dirname}/.cache"

app.get '/', (req, res) ->
  res.render 'index'

module.exports = app
