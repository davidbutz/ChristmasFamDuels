//models/Login.js

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var LoginsSchema = new Schema({
    user_id: String,    
    login_token: String,
    validuntil: Date
});

module.exports = mongoose.model('Logins', LoginsSchema);