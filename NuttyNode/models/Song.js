//models/Song
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var SongsSchema = new Schema({
    title: String
});

module.exports = mongoose.model('Song', SongsSchema);