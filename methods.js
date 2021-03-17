let hostname = "http://flask-env.eba-m9sv8kxe.us-east-2.elasticbeanstalk.com/";
let localhost = "http://127.0.0.1:5000";

function makeRequest(message)
{

  console.log(JSON.stringify(message));
  if (message.type == "sendPose") {
    sendPose(message.contents);
  } else {
    throw "Unsupported message type" + message.type;
  }

}

function sendPose(contents) {
  
  console.log(JSON.stringify(contents));

  var xhr = new XMLHttpRequest();
  let url = localhost + "/pose1" 
    + "/" + contents.macAddress 
    + "/" + contents.pose.x 
    + "/" + contents.pose.y 
    + "/" + contents.pose.theta;
    
  console.log(url);
  xhr.open("POST", url, true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.setRequestHeader("Connection", "close");

  xhr.onreadystatechange = function() {
      if (this.readyState === XMLHttpRequest.DONE && this.status === 200) {
          // Request finished. Do processing here.
          console.log(xhr.responseText);
      }
  }
  xhr.send();
}
