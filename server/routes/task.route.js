const express = require('express')
const AgentTaskModel = require('../models/agent/task.model')

const router = express.Router()

router.use(express.json())

router.post('/', async (req, res) => {
    const { title, startDate, dueDate, taskType, assignedClient, action } = req.body
    try {
        await AgentTaskModel.create({ title, startDate, dueDate, taskType, assignedClient, action })
            .then(() => res.json({ success: true }))
            .catch((err) => res.status(500).json({ error: err }))
    } catch (error) {
        console.log(error)
        res.status(500).json({ error: 'Internal Server error' })
    }
})

router.get('/', async (req, res) => {
    try {
        const tasks = await AgentTaskModel.find({})
        if (!tasks) {
            res.json({ message: "No tasks" })
        }
        res.status(200).json(tasks)
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: "Internal server error" })
    }
})

router.put('/:id', async (req, res) => {
    const id = req.params.id
    const { title, startDate, dueDate, assignedClient, action, status, taskType } = req.body
    try {
        const task = await AgentTaskModel.findOne({ _id: id })
        if (!task) {
            res.status(404).json({ message: "Not found" })
        }
        await AgentTaskModel.updateOne({ _id: id }, { title, startDate, dueDate, assignedClient, action, status, taskType })
            .then(() => res.status(200).json({ message: "Updates Successfully" }))
            .catch((err) => res.status(500).json({ message: "Error in updating" }))
    } catch (error) {
        console.log(error)
        res.status(500).json({ message: "Internal Server error" })
    }
})

router.delete('/:id', async (req, res) => {
    const id = req.params.id
    try {
        const task = await AgentTaskModel.findOne({ _id: id })
        if (!task) {
            res.status(404).json({ message: "Not found" })
        }
        await AgentTaskModel.deleteOne({ _id: id })
            .then(() => res.status(200).json({ message: "Deleted Successfully" }))
            .catch((err) => res.status(500).json({ message: "Error in deleting" }))
    } catch (error) {
        console.log(error)
        res.status(500).json({ message: "Internal Server error" })
    }
})

module.exports = router