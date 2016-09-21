(function (seedData) {
    
    seedData.sdname = "Funny Name";

    seedData.initialNotes = [{
            name: "History",
            notes: [
                { note: "Testing history", author: "Dave Butz", color: "Yellow" },
                { note: "Testing history2", author: "Adam Butz", color: "Blue" }
            ]
        },
        {
            name: "Current",
            notes: [
                { note: "Testing Current", author: "Dave Douglass", color: "Red" },
                { note: "Testing Current2", author: "Adam Douglass", color: "Green" }
            ]
        }];
})(module.exports);