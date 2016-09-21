//models/Week
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var WeeksSchema = new Schema({
    weekStart: Date,  
    weekEnd: Date
});

module.exports = mongoose.model('Weeks', WeeksSchema);