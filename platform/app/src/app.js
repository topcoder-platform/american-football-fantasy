
const config = require('config')
const cors = require('cors')
const express = require('express')
const _ = require('lodash')
const httpStatus = require('http-status-codes')
const routes = require('./routes')

const logger = require('./common/logger')
const helper = require('./common/helper')

const app = express()
app.set('port', config.PORT)
app.use(cors())

const apiRouter = express.Router()

_.each(routes, (verbs, url) => {
  _.each(verbs, (def, verb) => {
    const actions = []
    const method = require('./controllers/' + def.controller)[def.method]
    if (!method) {
      throw new Error(def.method + ' is undefined')
    }
    actions.push((req, res, next) => {
      req.signature = `${def.controller}#${def.method}`
      next()
    })
    actions.push(method)
    apiRouter[verb](url, helper.autoWrapExpress(actions))
  })
})

app.use('/', apiRouter)

app.use((err, req, res, next) => {
  logger.logFullError(err, req.signature)
  let status = err.httpStatus || httpStatus.INTERNAL_SERVER_ERROR
  if (err.isJoi) {
    status = httpStatus.BAD_REQUEST
  }
  res.status(status)
  if (err.isJoi) {
    res.json({
      error: err.details[0].message
    })
  } else {
    res.json({
      error: err.message
    })
  }
})

// Check if the route is not found or HTTP method is not supported
app.use('*', (req, res) => {
  const route = routes[req.baseUrl]
  if (route) {
    res.status(httpStatus.METHOD_NOT_ALLOWED).json({ message: 'The requested HTTP method is not supported.' })
  } else {
    res.status(httpStatus.NOT_FOUND).json({ message: 'The requested resource cannot be found.' })
  }
})

if (!module.parent) {
  app.listen(app.get('port'), () => {
    logger.info(`Express server listening on port ${app.get('port')}`)
  })
}

module.exports = {
  expressApp: app
}
