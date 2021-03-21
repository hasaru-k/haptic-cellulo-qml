let hostname = "http://cellulo-live.herokuapp.com";
let localhost = "http://127.0.0.1:5000";

function makeRequest(message)
{

  console.log(JSON.stringify(message));
  if (message.type === "sendPose") {
    sendPose(message.contents);
  } else {
    throw "Unsupported message type" + message.type;
  }

}

function sendPose(contents) {
  
  console.log(JSON.stringify(contents));

  var xhr = new XMLHttpRequest();
  let params = serialisePoseMessage(contents);
  let url = hostname + "/pose/" + params;
  console.log(url);
  xhr.open("POST", url, true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.setRequestHeader("Connection", "close");

  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
        // Request finished. Do processing here.
        console.log("Received:" + xhr.responseText);
    }
  }

  xhr.send();
}

function serialisePoseMessage(contents) {
  return "?" +
  "name=" + contents.name +
  "&" +
  "x=" + contents.pose.x +
  "&" +
  "y=" + contents.pose.y +
  "&" +
  "theta=" + contents.pose.theta;
}
