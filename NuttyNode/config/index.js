//config/index.js

// Connection to Mongo.

// Account on Modulus, which hosts MongoDB. This is from a web example i was working on.
//mongoose.connect('mongodb://thrive:lockjaw@apollo.modulusmongo.net:27017/D7oxopad'); 

// Local account, used for hosting the data on Raspberry Pi.
//mongoose.connect('localhost:27017/test');

module.exports = function () {
    return {
    "MONGOCONN":"localhost:27017/test"
    };
}