//models/Points
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var PointsSchema = new Schema({
    lineupID: String,
    leagueID: String,
    score: Number,
    referenceID: String,
    referenceType: String,
    referenceName: String,
    referenceUser: String,
    confirmationuserID: String,
    datecreated: { type: Date, default: Date.now() }
});

module.exports = mongoose.model('Points', PointsSchema);