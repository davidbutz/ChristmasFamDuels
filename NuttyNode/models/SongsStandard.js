//models/SongsStandard
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var SongsStandardSchema = new Schema({
    song: String,
    discogArtistID: Number
});

module.exports = mongoose.model('SongsStandard', SongsStandardSchema);