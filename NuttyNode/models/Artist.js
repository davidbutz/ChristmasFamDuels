//models/Artist
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var ArtistsSchema = new Schema({
    artist: String,
    discogArtistID: Number
});

module.exports = mongoose.model('Artist', ArtistsSchema);