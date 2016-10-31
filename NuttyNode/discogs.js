var Discogs = require('disconnect').Client;

// Authenticate by consumer key and secret
var db = new Discogs({
    consumerKey: 'eUqBQAImwgSlkhFryVto', 
    consumerSecret: 'KOHYnCcrmyZJRrVfetBhROkOnqSFbHhD'
}).database();


var artist = "michael b";//"nat";//"gene";//"straight no chaser";//"toto";//"mariah carey";
var song = "baby it's cold outside";//"rudolph";//"12 days of christmas"//"africa";//"all i want for christmas";
var track = song;// + "*";
var artistsearch = artist;// + "*"

//db.search("artist:" + artist , { "type": "artist" } , function (err, data) {
db.search(artist , { "type": "artist" } , function (err, data) {
    if (err) {
        console.log(err);
    }
    //console.log(data.results.length);
    if (data.results.length > 0) {
        for (var x = 0; x < data.results.length; x++) {
            //console.log(data.results[x].title + "-" + data.results[x].id);
        }
        var artistID = data.results[0].id;
        console.log("______________________________________________");
        //console.log(artistID);
        db.getArtist(artistID, function (err, dataArtist) {
            //console.log(dataArtist);
            var newartistID = artistID;
            var artistname;
            var artisturl;
            //if (dataArtist.groups) {
            //    console.log("GROUPS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            //    if (dataArtist.groups.length > 0) {
            //        for (var x = 0; x < dataArtist.groups.length; x++) {
            //            console.log(dataArtist.groups[x].name);
            //            if (dataArtist.groups[x].name.toLowerCase().includes(artist.toLowerCase())) {
            //                newartistID = dataArtist.groups[x].id;
            //                break;
            //            }
            //        }
            //    }
            //    if (artistID != newartistID) {
            //        console.log("RESEARCH");
            //        db.getArtist(newartistID, function (err, newdataArtist) {
            //            console.log(newdataArtist);
                        
            //            if (newdataArtist.images.length > 0) {
            //                imageurl = newdataArtist.images[0].resource_url;
            //                //console.log(releasedata);
            //                //console.log("----------------");
            //                getImagefromRelease(imageurl, artist);
            //            }
            //        });
            //    }
            //    else {
            //        if (dataArtist.images.length > 0) {
            //            imageurl = dataArtist.images[0].resource_url;
            //            //console.log(releasedata);
            //            //console.log("----------------");
            //            getImagefromRelease(imageurl, artist);
            //        }
            //    }
            //}
            //else {
                if (dataArtist.images.length > 0) {
                    artisturl = dataArtist.images[0].resource_url;
                    //console.log(releasedata);
                    //console.log("----------------");
                    getImagefromRelease(artisturl, artist);
                }
            //}
            if (dataArtist.name) {
                artistname = dataArtist.name;
            }
            var buildJSON = { "imageurl" : artisturl, "artist" : artistname };
            console.log(buildJSON);
        });
    }
});

var testingboth = true;
if (testingboth) {
    db.search(track, { "track" : track, "artist" : artist, "type": "master", "page" : 1, "perpage" : 1 }, function (err, data) {
        console.log(err);
        
        var imagename = song.replace(/\s/g, '') + artist.replace(/\s/g, '');
        console.log(imagename);
        
        
        if (data.results.length > 0) {
            //console.log(data.results[0]);
            //console.log("----------------");
            if (data.results[0].type) {
                if (data.results[0].type == "master") {
                    db.getMaster(data.results[0].id, function (err, masterdata) {
                        var releaseID = masterdata.main_release;
                        //console.log(masterdata);
                        //console.log("----------------");
                        db.getRelease(releaseID, function (err, releasedata) {
                            //return to the user: 
                            var imageurl;
                            var videourl;
                            var title;
                            var artist;
                            var trackname;
                            
                            //imageurl (to see the image of the release)
                            if (releasedata.images.length > 0) {
                                imageurl = releasedata.images[0].resource_url;
                                //console.log(releasedata);
                                //console.log("----------------");
                                getImagefromRelease(imageurl, imagename);
                            }
                            //videouri (to listen to the song...)
                            if (masterdata.videos) {
                                if (masterdata.videos.length > 0) {
                                    videourl = masterdata.videos[0].uri;
                                }
                            }
                            if (masterdata.title) {
                                title = masterdata.title;
                            }
                            if (masterdata.artists.length > 0) {
                                artist = masterdata.artists[0].name;
                            }
                            if (masterdata.tracklist) {
                                //console.log("********************************");
                                //console.log(masterdata.tracklist);
                                if (masterdata.tracklist.length > 0) {
                                    for (var i = 0; i < masterdata.tracklist.length; i++) {
                                        if (masterdata.tracklist[i].title.toLowerCase().includes(track.toLowerCase())) {
                                            trackname = masterdata.tracklist[i].title;
                                            break;
                                        }
                                    }
                                }
                            }
                            var buildJSON = { "imageurl" : imageurl, "videourl" : videourl , "title" : title, "artist" : artist, "track" : trackname };
                            console.log(buildJSON);
                        });
                    });
                }
                if (data.results[0].type == "release") {
                    getImagefromRelease(data.results[0].id, imagename);
                }
            }
            else {
                console.log("why here?");
            }
        }
        else {
            //we have a tricker situation. lets start with the song search first...
            db.search(track, { "track" : track }, function (err, trackdata) {
                console.log(err);
                console.log("--------");
                //console.log(trackdata);
                console.log("--------");
                var output;
                if (trackdata.results.length > 0) {
                    for (var y = 0; y < trackdata.results.length; y++) {
                        if (trackdata.results[y].title.toLowerCase().includes(artist.toLowerCase())) {
                            //console.log(trackdata.results[y]);
                            output = trackdata.results[y];
                            break;
                        }
                    }
                    if (output !== undefined) {
                        //console.log(output);
                        if (output.type == "release") {
                            getReleaseInformation(output.id, imagename);
                        }
                    }
                    else {
                        console.log({ "success": false, "message": "Could not find your results" });
                    }
                }
                else {
                    //an even tougher road here...
                    console.log({ "success": false, "message": "Could not find your results" });
                }
            });
        }
    });
}

function getReleaseInformation(releaseID, imagename){
    db.getRelease(releaseID, function (err, releasedata) {
        //return to the user: 
        var imageurl;
        var videourl;
        var title;
        var artist;
        var trackname;
        //console.log(releasedata);
        db.getMaster(releasedata.master_id, function (err, masterdata) {
            //imageurl (to see the image of the release)
            if (releasedata.images.length > 0) {
                imageurl = releasedata.images[0].resource_url;
                //console.log(releasedata);
                //console.log("----------------");
                getImagefromRelease(imageurl, imagename);
            }
            //videouri (to listen to the song...)
            if (masterdata.videos) {
                if (masterdata.videos.length > 0) {
                    videourl = masterdata.videos[0].uri;
                }
            }
            if (masterdata.title) {
                title = masterdata.title;
            }
            if (masterdata.artists.length > 0) {
                artist = masterdata.artists[0].name;
            }
            if (masterdata.tracklist) {
                //console.log("********************************");
                //console.log(masterdata.tracklist);
                if (masterdata.tracklist.length > 0) {
                    for (var i = 0; i < masterdata.tracklist.length; i++) {
                        if (masterdata.tracklist[i].title.toLowerCase().includes(track.toLowerCase())) {
                            trackname = masterdata.tracklist[i].title;
                            break;
                        }
                    }
                }
            }
            var buildJSON = { "imageurl" : imageurl, "videourl" : videourl , "title" : title, "artist" : artist, "track" : trackname };
            console.log(buildJSON);
        });
    });
}

function getImagefromRelease(url, imagename) {
    db.getImage(url, function (err, data, rateLimit) {
        
        // save to AWS?
        
        // stream back to user?

        // Data contains the raw binary image data
        require('fs').writeFile('/tmp/' + imagename + '.jpg', data, 'binary', function (err) {
            console.log('Image saved!');
        });
    });
}

//db.getRelease(1540815, function (err, data) {
//    var url = data.images[0].resource_url;
//    db.getImage(url, function (err, data, rateLimit) {
//        // Data contains the raw binary image data
//        require('fs').writeFile('/tmp/image3.jpg', data, 'binary', function (err) {
//            console.log('Image saved!');
//        });
//    });
//});

//db.getArtist("33534", function (err, data) {
//    console.log(data);
//});

////var requestDataSaved;
//var oAuth = new Discogs().oauth();
//oAuth.getRequestToken(
//        'eUqBQAImwgSlkhFryVto', 
//        'KOHYnCcrmyZJRrVfetBhROkOnqSFbHhD', 
//        'http://your-script-url/callback', 
//        function (err, requestData) {
//            console.log(requestData);
//            requestDataSaved = requestData
//            // Persist "requestData" here so that the callback handler can 
//            // access it later after returning from the authorize url
//            //res.redirect(requestData.authorizeUrl);
//    }
//);


