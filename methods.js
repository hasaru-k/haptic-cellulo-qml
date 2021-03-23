let remotehost = "http://cellulo-live.herokuapp.com";
let localhost = "http://127.0.0.1:5000";


// host: remotehost | localhost
let host = remotehost;

/* Sends a message to the backend.
 *
 * message: { type: <string>, contents: <object> }
 * requestStatus: { text: <string> }
 */
function makeRequest(message, requestStatus)
{
  if (message.type === "sendPose") {
    sendPose(message.contents, requestStatus);
  } else {
    throw "Unsupported message type" + message.type;
  }
}

function sendPose(contents, requestStatus) {
  var xhr = new XMLHttpRequest();
  let params = serialisePoseMessage(contents);
  let url = host + "/pose/" + params;
  console.log("Opening POST request to " + url);
  xhr.open("POST", url, true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.setRequestHeader("Connection", "close");

  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
        // Request finished. Do processing here.
        if (xhr.status === 200) {
            let response = JSON.parse(xhr.responseText);
            if (response.type === "success") {
                requestStatus.text = "loaded";
            } else {
                requestStatus.text = "Something went wrong: " + xhr.status + " " + response.content;
            }
        } else {
            requestStatus.text = "Couldn't connect: " + xhr.status + " " + xhr.responseText;
        }
    }
  }

  xhr.send();
  requestStatus.text = "loading";
}

/* Sends a message to the backend.
 *
 * requestStatus: { text: <string> }
 * id: <string>
 */
function getRobots(requestStatus, id) {
  var xhr = new XMLHttpRequest();
  let url = host + "/robots/";
  console.log("Opening GET request to " + url);
  xhr.open("GET", url, true);
  xhr.setRequestHeader("Connection", "close");

  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
            let response = JSON.parse(xhr.responseText);
            if (response.type === "success") {
                console.log(response.content);
                let robots = response.content;
                let isValidId = robots.indexOf(id) >= 0;
                requestStatus.text = isValidId ?
                    "loaded" : "Hmmm, we couldn't find that id."
            } else {
                requestStatus.text = "Something went wrong: " + xhr.status + " " + response.content;
            }
        } else {
            requestStatus.text = "Couldn't connect: " + xhr.status + " " + xhr.responseText;
        }
    }
  }

  xhr.send();
  requestStatus.text = "loading";
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
