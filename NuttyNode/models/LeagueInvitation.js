//models/LeagueInvitation
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var LeagueInvitationsSchema = new Schema({
    leagueID: String,
    email: String,
    invitationToken: String
});

module.exports = mongoose.model('LeagueInvitations', LeagueInvitationsSchema);