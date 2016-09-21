(function (data) {
    
    // in here we put things that are common to all data.
    
    
    //HISTORICAL: this was some sample i worked through...
    var seedData = require("./seedData");
    //console.log(seedData.sdname);
    data.getNoteCategories = function (next) {
        next (null, seedData.initialNotes);
    };
    //END HISTORICAL:
    

})(module.exports);