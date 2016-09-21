//models/Points
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var PointsSchema = new Schema({
    lineupID: String,
    score: Number,
    confirmationuserID: String
});

module.exports = mongoose.model('Points', PointsSchema);