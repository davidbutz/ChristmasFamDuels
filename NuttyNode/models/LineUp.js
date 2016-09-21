//models/LineUp
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var LineUpsSchema = new Schema({
    userxleagueID: String,
    weekID: String,
    song: String,
    artist: String
});

module.exports = mongoose.model('LineUps', LineUpSchema);