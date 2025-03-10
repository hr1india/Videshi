const express = require('express')
const AgentDescriptionModel = require('../models/agent/description.model')

const router = express.Router()

router.use(express.json())

router.post('/', async (req, res) => {
    const { id, name, location, role, experience, successRate, rating, overview, services, expertiseCountries } = req.body
    try {
        const description = await AgentDescriptionModel.findOne({ id })
        if (description) {
            res.status(500).json({ message: "Already description exists" })
        }
        await AgentDescriptionModel.create({ id, name, location, role, experience, successRate, rating, overview, services, expertiseCountries })
            .then(() => res.status(200).json({ message: "Inserted Successfully" }))
            .catch((err) => res.status(400).json({ message: "Error inserting" }))
    } catch (error) {
        console.log(error)
        res.status(500).json({ error: "Internal Server Error" })
    }
})

router.get('/:id', async (req, res) => {
    const id = req.params.id
    try {
        const description = await AgentDescriptionModel.findOne({ id })
        if (!description) {
            res.status(404).json({ message: "Not found" })
        }
        res.status(200).json({ description })
    } catch (error) {
        console.log(error)
        res.status(500).json({ error: "Internal Server Error" })
    }
})

router.put('/:id', async (req, res) => {
    const id = req.params.id
    const { name, location, role, experience, successRate, rating, overview, services, expertiseCountries } = req.body
    try {
        const description = await AgentDescriptionModel.findOne({ id })
        if (!description) {
            res.status(404).json({ message: "Not found" })
        }
        await AgentDescriptionModel.updateOne({ id }, { name, location, role, experience, successRate, rating, overview, services, expertiseCountries })
            .then(() => res.status(200).json({ message: "Updated successfully" }))
            .catch((err) => res.status(400).json({ message: "Error in updating" }))
    } catch (error) {
        console.log(error)
        res.status(500).json({ message: "Internal Server error" })
    }
})

router.delete('/:id', async (req, res) => {
    const id = req.params.id
    try {
        const description = await AgentDescriptionModel.findOne({ id })
        if (!description) {
            res.status(404).json({ message: "Not found" })
        }
        await AgentDescriptionModel.deleteOne({ id })
            .then(() => res.status(200).json({ message: "Deleted successfully" }))
            .catch((err) => res.status(400).json({ message: "Error in deleting" }))
    } catch (error) {
        console.log(error)
        res.status(500).json({ message: "Internal server error" })
    }
})

module.exports = router