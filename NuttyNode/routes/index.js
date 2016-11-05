// routes/index.js
module.exports = function (app, settings) {
    var mongoose = require('mongoose');
    mongoose.connect(settings.config().MONGOCONN);
    require("./SetUpActivities")(app, settings);
    require("./Authentication")(app, settings);
    require("./RegisterMobilePushService")(app, settings);
    require("./Scoring")(app, settings);
    require("./View")(app, settings);
    require("./LeagueMaintenance")(app, settings);
    require("./SetLineUp")(app, settings);
}
