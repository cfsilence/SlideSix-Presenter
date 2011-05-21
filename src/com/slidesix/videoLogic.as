
import flash.media.Microphone;
private var connection:NetConnection
private var stream:NetStream;
private var rtmpURL:String;
private var video:Video;
public var cam:Camera;
public var mic:Microphone;

[Bindable] public var broadcastStatus:String = 'Not Broadcasting';
[Bindable] public var isBroadcasting:Boolean = false;
[Bindable] public var hasCam:Boolean = false;
[Bindable] public var hasMic:Boolean = false;

public function initVideo():void{
	rtmpURL = 'rtmp://' + host + '/livestream';
	Camera.names.length > 0 ? hasCam = true : hasCam = false;
	Microphone.names.length > 0 ? hasMic = true : hasMic = false;
}

public function broadcast(action:String):void{
	switch(action){
		case 'start':
			if(!isChatting){
				joinChat();
			}
			initNetConnection();
			isBroadcasting = true;
			break;
		case 'stop':
			disconnectStream();
			isBroadcasting = false;
			broadcastStatus = 'Stopped';
			var t:Timer = new Timer(5000, 1);
			t.addEventListener(TimerEvent.TIMER, function(){broadcastStatus = 'Not Broadcasting';});
			t.start();
			break;
	}
	broadcastSlideChange();
}

public function disconnectNetConnection():void{
	connection.connect(null);
}
public function initNetConnection():void{
	connection = new NetConnection();
	connection.client = this;
    connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
    connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
    connection.connect(rtmpURL);
}

public function netStatusHandler(e:NetStatusEvent):void{
	trace(e.info.code);
	switch (e.info.code) {
        case "NetConnection.Connect.Success":
        	connectStream();
            break;
        case "NetStream.Play.StreamNotFound":
        	broadcastStatus = 'Error';
            //trace("Stream not found: " + rtmpURL);
            break;
       	case "NetStream.Play.Start":
       		break;
       	case "NetStream.Publish.Start":
       		broadcastStatus = 'Broadcasting';
       		break;
   		case "NetConnection.Connect.Closed":
   			broadcastStatus = 'Disconnected';
   			break;
    }
}	
private function nsOnMetaData(item:Object):void{
	trace('meta');
}
private function nsOnCuePoint(item:Object):void{
	trace('cue');
}

private function setUpCamMic():void{
	if(hasCam){
		var pref:Object = getPreferences();
		cam = Camera.getCamera(pref.preferredCamera.toString());
		cam.setQuality(0, 90);
		cam.setKeyFrameInterval(5);
		cam.setMode(320, 240, 15);
		if(isBroadcasting){
			if(useCam.selected){
				stream.attachCamera(cam);	
				video.height = vidContainer.height;
			}
			else{
				stream.attachCamera(null);
				video.height = 0;
			}
		}
	}
	else{
		Alert.show('No Camera Detected.  You will be unable to broadcast video.');
	}
	
	if(hasMic){
		mic = Microphone.getMicrophone(pref.preferredMicrophone.toString());
		mic.rate = 22;
		mic.gain = 30;
		mic.setSilenceLevel(10);
		
		if(isBroadcasting){
			if(useMic.selected){
				stream.attachAudio(mic);						
			}
			
			else{
				stream.attachAudio(null);
			}
		}
	}	
	else{
		Alert.show('No Mic Detected.  You will be unable to broadcast audio.');
		}		
}

private function connectStream():void {
	//trace('connecting stream');
    stream = new NetStream(connection);
    stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
    var nsClient:Object = {};
    nsClient.onMetaData = nsOnMetaData;
    nsClient.onCuePoint = nsOnCuePoint;
    
    stream.client = nsClient;
    stream.publish(uname, 'live');
    
    video = new Video();
    setUpCamMic();
    video.attachCamera(cam);
   
    video.width = vidContainer.width;
    video.height = vidContainer.height;
    vidContainer.addChild(video);
}

private function disconnectStream():void{
	stream.close();
}
public function securityErrorHandler(e:SecurityErrorEvent):void{
	Alert.show('security error');
}

public function onBWDone():void{
}