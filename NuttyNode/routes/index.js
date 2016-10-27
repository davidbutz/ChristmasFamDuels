// routes/index.js
module.exports = function (app, settings) {
    var mongoose = require('mongoose');
    mongoose.connect(settings.config().MONGOCONN);
    require("./SetUpActivities")(app, settings);
    require("./Authentication")(app, settings);
}
