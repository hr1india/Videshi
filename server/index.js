const mongoose = require('mongoose')
const express = require('express')
const cors = require('cors')
require("dotenv").config()

const app = express()

app.use(express.json())

const db_url = process.env.MONGODB_URL

const agentTaskRouter = require('./routes/task.route')
const agentDescriptionRouter = require('./routes/description.route')

app.use('/api/agent/tasks', agentTaskRouter)

app.use('/api/agent/description', agentDescriptionRouter)

mongoose.connect(db_url, {
    tls: true
})
    .then(() => console.log("MongoDB connected"))
    .catch((err) => console.log(err))

app.listen(5000, () => console.log("Server listening at 5000"))