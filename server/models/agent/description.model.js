const mongoose = require('mongoose')

const AgentDescriptionSchema = mongoose.Schema({
    id: {
        type: String,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    location: {
        type: String,
        required: true
    },
    role: {
        type: String,
        required: true
    },
    experience: {
        type: Number,
        required: true
    },
    successRate: {
        type: Number
    },
    rating: {
        type: Number,
        required: true
    },
    overview: {
        type: String
    },
    services: {
        type: [String]
    },
    expertiseCountries: {
        type: [String]
    }
})

const AgentDescriptionModel = mongoose.model("description", AgentDescriptionSchema)

module.exports = AgentDescriptionModel