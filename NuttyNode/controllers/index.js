(function (controllers){
    var homeController = require('./HomeController.js');
    controllers.init = function (app) {
        homeController.init(app);
    };
})(module.exports);