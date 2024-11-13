console.log("Old BSSyncManager Master with UDP control test 2.1");

const dgram = require('dgram');
const server = dgram.createSocket('udp4');
const videoElement1 = document.querySelector(".container1 video");
const videoElement2 = document.querySelector(".container2 video");

let MediaSync = new BSSyncManager("media", "224.0.126.10", 5439);
MediaSync.SetMaster(1);

let syncFileName = "Future Neon - UR.mp4";
let nonSyncFileName = "logi-1.mp4";

videoElement1.src = syncFileName;
videoElement2.src = nonSyncFileName;
MediaSync.Synchronize(0, 1000);
console.log("Sync command sent to sync video playback");

MediaSync.onsyncevent = function(e){
    console.log(" Master MediaSync.onsyncevent to play video: " + e.iso_timestamp + " File Index: " + e.id)
    videoElement1.setSyncParams(e.domain, e.id, e.iso_timestamp);
	videoElement1.load();
    videoElement1.play();
}

videoElement1.addEventListener("ended", (event) => {
    console.log("Video ended/stopped for video 1 - synchronized video");
    MediaSync.Synchronize(0, 1000)
    console.log("Send Sync playback again to restart video");
});

videoElement2.addEventListener("ended", (event) => {
    console.log("Video ended/stopped for video 2 - non synchronized video");
    videoElement2.load();
    videoElement2.play();
});

// Event listener for incoming messages
server.on('message', (message, remote) => {
    console.log(`Received message: ${message} from ${remote.address}:${remote.port}`);

    if(message == "play-sync"){
        console.log("Play synchronized video");
        videoElement1.style.display = "block";
        videoElement2.style.display = "none";  
    }else if(message == "play-other"){
        console.log("Play non-synchronized video");
        videoElement2.load();
        videoElement2.play();
        videoElement2.style.display = "block";
        videoElement1.style.display = "none";   
    }
});

// Error event listener
server.on('error', (err) => {
    console.log(`Server error:\n${err.stack}`);
    server.close();
});

// Bind the server to a port
const PORT = 5000;
server.bind(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});