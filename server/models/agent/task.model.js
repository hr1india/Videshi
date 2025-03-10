const mongoose = require('mongoose')

const AgentTaskSchema = mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    startDate: {
        type: Date,
        required: true
    },
    dueDate: {
        type: Date,
        required: true
    },
    taskType: {
        type: String,
        default: "Undefined"
    },
    assignedClient: {
        type: String,
        required: true
    },
    action: {
        type: String
    },
    status: {
        type: String,
        default: "Pending"
    }
})

const AgentTaskModel = mongoose.model("task", AgentTaskSchema)

module.exports = AgentTaskModel