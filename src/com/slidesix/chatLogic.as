// ActionScript file
import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.formatters.DateFormatter;
import mx.messaging.ChannelSet;
import mx.messaging.Consumer;
import mx.messaging.Producer;
import mx.messaging.channels.AMFChannel;
import mx.messaging.events.MessageEvent;
import mx.messaging.events.MessageFaultEvent;
import mx.messaging.messages.AsyncMessage;
import mx.messaging.messages.IMessage;

//globals
public var slideChangedSubtopic:String;
public var chatSubtopic:String;
public var timeFormatter:DateFormatter = new DateFormatter();
public var currentUserUsername:String;
[Bindable] public var currentPresentation:String; 
public var room:String; 
public var isLoggedInToChat:Boolean = false;

public function initChat():void{
	slideChangedSubtopic = username.text  + '-slideChanged';
	chatSubtopic = username.text  + '-chat';
	timeFormatter.formatString = 'L:NN:SS';
	currentUserUsername = username.text;
	
	if(user != null){
		currentUserUsername = user.FIRSTNAME + ' ' + user.LASTNAME;
	}
	
	room = username.text;
	
	//set up producers
	initProducers();
	//set up channels
	initChannelSet();
	//set up consumers
	initChatConsumer();
	//set up sorting for user list
	initUserSort();
	
	broadcastLogin();
}

public function dedicatedRoomFaultHandler(e:MessageFaultEvent):void{
	trace(ObjectUtil.toString(e));
}

public var producer:Producer;
public function initProducers():void{
	producer = new Producer();
	producer.destination = 'ColdFusionGateway';
	producer.addEventListener(MessageFaultEvent.FAULT, dedicatedRoomFaultHandler);
}

public var chatConsumer:Consumer;

public function initChatConsumer():void{
	chatConsumer = new Consumer();
	chatConsumer.destination = 'ColdFusionGateway';
   	chatConsumer.subtopic = chatSubtopic;
   	chatConsumer.channelSet = myChannelSet;
   	chatConsumer.addEventListener(MessageEvent.MESSAGE, chatHandler);
   	chatConsumer.subscribe();	
   	broadcastSlideChange();
}

[Bindable] public var myChannelSet:ChannelSet;
public function initChannelSet():void{
	myChannelSet = new ChannelSet();
	var mChannel:AMFChannel = new AMFChannel('cf-polling-amf', 'http://' + host + '/flex2gateway/cfamfpolling/;jsessionid=' + sessionID);
	mChannel.enableSmallMessages = false;
	myChannelSet.addChannel(mChannel);
	producer.channelSet = myChannelSet;
}

public var sortField:SortField;
public var sort:Sort;
public function initUserSort():void{
	sortField = new SortField();
  	sortField.name = 'role';
  	sortField.numeric = false;
  	sortField.descending = true;
  	sortField.caseInsensitive = true;
  	sort = new Sort();
  	sort.fields = [sortField];
}

public var slideConsumer:Consumer;
public function initSlideConsumer():void{
	slideConsumer = new Consumer();
	slideConsumer.destination = 'ColdFusionGateway';
   	slideConsumer.subtopic = slideChangedSubtopic;
   	slideConsumer.channelSet = myChannelSet;
   	slideConsumer.addEventListener(MessageEvent.MESSAGE, slideChangedHandler);
   	slideConsumer.subscribe();
}

[Bindable] public var usersInThisRoom:ArrayCollection;

public function chatHandler(event:MessageEvent):void{
	var eventMsg:IMessage = event.message;
  	var info:Object = eventMsg.body;
  	var msg:String = info.MSG;          	
  	var userid:String = info.USERID;
  	var username:String = info.USERNAME
  	var slideNum:Number = info.SLIDE;
  	var cLog:Array = info.CHATLOG;
  	
  	usersInThisRoom = info.CURRENTUSERS;
  	usersInThisRoom.sort = sort;
  	usersInThisRoom.refresh();
  	
  	//trace(ObjectUtil.toString(info));
  	
  	if((userid != '' && userid != user.ID.toString()) || (userid == '' && username != currentUserUsername)){
  		chatDisplay.htmlText += msg + '<br />';
  		scrollChat()
  	}

  	if(info.LOGIN == 'yes' && cLog.length){
  		isLoggedInToChat = true;
  		chatDisplay.htmlText = cLog.join('<br />');
  		chatPanel.status = '';
  	}
  	
  	if(info.PRESENTATION != null){
  		/* currentPresentation = info.PRESENTATION; */
  	}
}

public function getUserTimeStamp():String{
	return '[' + timeFormatter.format(new Date()) + '] <b>' + currentUserUsername + '</b>: ';
}

public function chatButtonClicked(e:MouseEvent):void{
	var msg:String = chatInput.text;
	if(msg.length){
		var c:String = getUserTimeStamp() + msg;
		chatDisplay.htmlText += getUserTimeStamp() + htmlEditFormat(msg) + '<br />';
		chatInput.text = '';
		scrollChat();
		sendChat(c);
	}
}
public function sendChat(c:String):void{
	var d:Date = new Date();
	var msg:AsyncMessage = new AsyncMessage();
	msg.headers.gatewayid = gatewayName;
	msg.body = {userid: user.ID, chat: c, timestamp: d, room: room, username: currentUserUsername, presentation: currentPresentation};
	producer.subtopic = chatSubtopic;
	producer.send(msg);
}

//handler for the slide changed consumer
public function slideChangedHandler(event:MessageEvent):void{
	var msg:IMessage = event.message;
  	/* if(msg.body.SLIDE != currentSlideNumber){
  		advance('', false, msg.body.SLIDENUMBER);
  	}
  	if(msg.body.PRESENTATION != null){
  		currentPresentation = msg.body.PRESENTATION;
  	}
  	if(msg.body.ISBROADCASTING == 'yes'){
  		isBroadcasting = true;
  	} */
}

public function broadcastLogin():void{
	var d:Date = new Date();
	var msg:AsyncMessage = new AsyncMessage();
	msg.headers.gatewayid = gatewayName;
	var m:String = getUserTimeStamp() + '<i> joined the room</i>';
	var u:String = currentUserUsername;
	
	msg.body = {userid: user.ID, chat: m, timestamp: d, room: room, username: currentUserUsername, presentation: currentPresentation, login: true, displayname: u, role:'presenter'};
	producer.subtopic = chatSubtopic;
	producer.send(msg);
}

public function logoutChat():void{
	var d:Date = new Date();
	var msg:AsyncMessage = new AsyncMessage();
	msg.headers.gatewayid = gatewayName;
	var m:String = getUserTimeStamp() + '<i> left the room</i>';
	chatDisplay.htmlText += m + '<br />';
	msg.body = {userid: user.ID, chat: m, timestamp: d, room: room, username: currentUserUsername, presentation: currentPresentation, logout: true};
	producer.subtopic = chatSubtopic;
	producer.send(msg);
}

public function htmlEditFormat(h:String):String{
	var ret:String = h.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	return ret;
}

public function checkEnter(event:KeyboardEvent):void{
	/// <cr> or <enter>
	//trace(ObjectUtil.toString(event.target));
	if (event.keyCode == Keyboard.ENTER){
		var e:MouseEvent = new MouseEvent(MouseEvent.CLICK);
		chatButtonClicked(e);
	}
}
