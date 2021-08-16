let remotehost = "http://cellulo-live.herokuapp.com";
let localhost = "http://127.0.0.1:5000";


// host: remotehost | localhost
let host = remotehost;
let REQUEST_SUCCESS = "loaded"


function sendPose(contents, requestStatus) {
    var xhr = new XMLHttpRequest();
    let params = serialisePoseMessage(contents);
    let url = host + "/pose/" + params;
    console.log("Opening POST request to " + url);
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.setRequestHeader("Connection", "close");

    // callback function for when a response is received
    let data = { requestStatus: requestStatus }
    let onMessageReceived = function(content, data) {
        data.requestStatus.text = REQUEST_SUCCESS;
    }
    sendRequest(xhr, onMessageReceived, data);
}

/* Sends a request to obtain the current pose for a robot
 * with a given id.
 *
 * partnerId: <string>
 * requestStatus: { text: <string> }
 * poseContainer: { partnerPose: <pose> }
 */
var mode = "vibrateMode";
function getPose(partnerId, data) {
    var xhr = new XMLHttpRequest();
    let url = host + "/pose/?name=" + partnerId;
    // console.log("Opening GET request to " + url);
    xhr.open("GET", url, true);
    xhr.setRequestHeader("Connection", "close");

    // callback function for when a response is received
    let onMessageReceived = function(content, data) {
        data.requestStatus.text = REQUEST_SUCCESS;
        data.app.partnerPose = content;
        robotComm.clearTracking();
        if (mode === "vibrateMode") {
          if (data.app.poseZone === data.app.partnerPose.zone
              && data.app.poseZone !== "cytosol") {
            data.robotComm.simpleVibrate(10, 0, 0, 10, 100);
          }
        } else {
          data.robotComm.setGoalPosition(
            data.app.partnerPose.x,
            data.app.partnerPose.y,
            40
          );
        }
        data.partnerAnimation.start();
    }
    sendRequest(xhr, onMessageReceived, data);
}


function switchMode() {
  if (mode === "vibrateMode") {
    mode = "moveToPartnerMode";
  } else {
    mode = "vibrateMode";
  }
}

function getMode() {
  return mode;
}

/* Uploads the given userId to the backend database.
 *
 * requestStatus: { text: <string> }
 * id: <string>
 */
function uploadUserId(requestStatus, id) {
    let pose = { x: -1, y: -1, theta: -1, zone: "cytosol" };
    let contents = {name: id, pose: pose};
    sendPose(contents, requestStatus);
}

/* Gets the current list of user ids in the backend.
 * Sets requestStatus.text to the success state if
 * id is in that list.
 *
 * requestStatus: { text: <string> }
 * id: <string>
 */
function validatePartnerId(requestStatus, id) {
  var xhr = new XMLHttpRequest();
  let url = host + "/robots/";
  console.log("Opening GET request to " + url);
  xhr.open("GET", url, true);
  xhr.setRequestHeader("Connection", "close");

  let data = { requestStatus: requestStatus, id: id };
  // callback function for when a response is received
  let onMessageReceived = function(content, data) {
      console.log(content);
      let isValidId = content.indexOf(data.id) >= 0;
      data.requestStatus.text = isValidId ?
          REQUEST_SUCCESS : "Hmmm, we couldn't find that id."
  }
  sendRequest(xhr, onMessageReceived, data);
}

/* Sends an initialised request to the backend.
 *
 * xhr: <XMLHttpRequest> object with request headers set
 * onMessageReceived: callback function for when a successful response is received,
 *         with the following prototype: <function(contents: <json>, data: <json>)>
 * data: <{ requestStatus: <requestStatus>, ... }>
 *
 */
function sendRequest(xhr, onMessageReceived, data) {
  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
          switch (xhr.status) {
              case 200:
                let response = JSON.parse(xhr.responseText);
                if (response.type !== "success") {
                  data.requestStatus.text = "Something went wrong: " + xhr.status + " " + response.content;
                  break;
                }
                onMessageReceived(response.content, data);
                break;
              default:
                data.requestStatus.text = "Couldn't connect: " + xhr.status + " " + xhr.responseText;
          }
      }
  }
  xhr.send();
  data.requestStatus.text = "Connecting...";
}

function serialisePoseMessage(contents) {
  return "?" +
  "name=" + contents.name +
  "&" +
  "x=" + contents.pose.x +
  "&" +
  "y=" + contents.pose.y +
  "&" +
  "theta=" + contents.pose.theta +
  "&" +
  "zone=" + contents.pose.zone;
}
