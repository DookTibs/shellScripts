#!/usr/bin/env osascript -l JavaScript

console.log("THIS DOES NOT WORK!!!!");
exit;

// https://willcodefor.beer/posts/asjxa
// https://computers.tutsplus.com/a-beginners-guide-to-javascript-application-scripting-jxa--cms-27171t

// ObjC.import('Cocoa')

console.log("hi!");

var spotify = Application("Spotify");
 var t = spotify.currentTrack;
// var { artist, name, album, duration } = spotify.currentTrack;
 console.log("Artist: " + t.albumArtist);
// console.log("Album: " + t.album);
// console.log("Title: " + t.name);


/*
function run() {
  MainWindow.makeKeyAndOrderFront(null)
}

function reopen() {
  MainWindow.makeKeyAndOrderFront(null)
}
*/
