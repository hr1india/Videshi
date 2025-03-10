const mongoose = require('mongoose')

const RatingReviewSchema = mongoose.Schema({
    writerName: {
        type: String,
        required: true
    },
    reviewOn: {
        type: String,
        required: true
    },
    designation: {
        type: String,
        required: true
    },
    review: {
        type: String,
        required: true
    },
    rating: {
        type: Number,
        required: true
    }
})

const RatingReviewModel = mongoose.model("ratingAndReview", RatingReviewSchema)

module.exports = RatingReviewModel