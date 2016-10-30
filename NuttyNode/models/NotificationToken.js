//models/NotificationToken.js
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var NotificationTokensSchema = new Schema({
    notification_token_id: String,       
    endpointARN: String,
    type: String,
    datecreated: { type: Date, default: Date.now() }
});

module.exports = mongoose.model('NotificationTokens', NotificationTokensSchema);