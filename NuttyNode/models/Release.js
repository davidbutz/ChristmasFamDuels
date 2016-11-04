//models/Artist
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var ReleasesSchema = new Schema({
    release: String,
    discogReleaseID: Number
});

module.exports = mongoose.model('Release', ReleasesSchema);