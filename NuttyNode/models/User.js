//models/User
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var UsersSchema = new Schema({
    username: String,       
    password: String,      
    user_id: String,
    fname: String,
    lname: String
});

module.exports = mongoose.model('Users', UsersSchema);