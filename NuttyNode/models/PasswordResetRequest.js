//models/PasswordResetRequest.js
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var PasswordResetRequestSchema = new Schema({
    username: String,    
    requesttoken: String,
    datecreated: { type: Date, default: Date.now() } 
});

module.exports = mongoose.model('PasswordResetRequest', PasswordResetRequestSchema);