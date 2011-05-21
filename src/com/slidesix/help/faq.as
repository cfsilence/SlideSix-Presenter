
import mx.collections.ArrayCollection;
[Bindable] public var faqs:ArrayCollection = new ArrayCollection([
	{
	q: "How do I upload a presentation?",
	a: "To queue a presentation for upload to SlideSix you can click 'Upload' from the 'Presentations' panel located at the top of the application.  You can also simply drag a presentation file into the 'Presentations' panel.  Once a file has been queued for upload you will be asked to provide a title, description and tags before you can initiate the upload by clicking 'Upload Now' from within the file upload dialog.",
	c: "presentations",
	s: 1
	},
	{
	q: "Can I delete a presentation?",
	a: "Deleting presentations is not supported from the SlideSix Presenter application.  To fully manage your account please log in to the <a href='http://slidesix.com/slideManager' target='_blank'><font color='#0000ff'>SlideSix Management Console</font></a> on the web.",
	c: "presentations",
	s: 2
	},
	{
	q: "Can I edit my slide notes?",
	a: "Editing slide notes is not supported.  The SlideSix Presenter application is not intended to fully replace the functionality of the SlideSix web application.  To edit your slide notes please log in to the <a href='http://slidesix.com/slideManager' target='_blank'><font color='#0000ff'>SlideSix Management Console</font></a> on the web.",
	c: "presentations",
	s: 3
	},
	{
	q: "Can I show my slides on a different monitor?",
	a: "Of course!  Make sure that your external monitor is connected to your computer before clicking 'Enter Presenter Mode' in the 'Slide' panel.  Before entering presenter mode you will be prompted to choose which monitor to display your slide material on.",
	c: "presentations,slides",
	s: 4
	},
	{
	q: "What shortcuts can I use in presenter mode?",
	a: "To advance to the next slide you can single left click on your mouse or use the following keys on your keyboard: space bar, enter key, right arrow, down arrow, 'N' or page down.  To go to the previous slide you can use the following keys: backspace, delete, left arrow, up arrow, 'P' or page up.  To exit presenter mode you can right click and select 'End Show' or press the Esc key on your keyboard. ",
	c: "presentations,slides",
	s: 4
	},
	{
	q: "How can I save a presentation to my computer?",
	a: "To save a presentation to your computer just single click on the presentation thumbnail within the 'Presentations' panel and click 'Save Offline'.  The offline save process may take several minutes to complete for larger presentations.",
	c: "presentations",
	s: 5
	},
	{
	q: "How do I work with my offline presentations?",
	a: "From the main login screen you can click 'Work Offline' and the 'Presentations' panel will be loaded with all presentations that have been saved offline.  You can also click 'Work Offline' from the 'Presentations' panel while working online to switch to offline mode.",
	c: "presentations",
	s: 6
	},
	{
	q: "Can I use online features in offline mode?",
	a: "Actually, yes, you usually can.  Saving a presentation to your computer is good insurance against dropped internet connections, but presenting an offline presentation does not mean you can't use online features like broadcasting, chat and Twitter Monitoring assuming that your computer is connected to the internet.  You can check your internet connectivity at any time by viewing the status area in the top right corner of the 'Presentations' panel.  A green ball next to 'Network' means that internet connectivity is verified, but a red ball means no connection is available.  You must be connected to the internet to use online functionality.",
	c: "presentations,twitter,broadcasting,chat",
	s: 7
	},
	{
	q: "How do I monitor a Twitter backchannel?",
	a: "Before monitoring a Twitter backchannel you must enter your Twitter credentials.  Click 'Options' within the 'Presentations' panel and choose the 'Twitter' tab of the options dialog.  Enter your username and password and click save.  Once saved you can close the options dialog, enter a search term or hashtag in the 'Twitter Monitor' panel and click 'Listen'.  The Twitter Monitor automatically searches for new Tweets for your search term or hashtag about every 60 seconds.",
	c: "presentations,twitter",
	s: 8
	},
	{
	q: "How do I broadcast live audio and video?",
	a: "Before broadcasting audio and/or video you must choose a preferred web cam and mic.  Click 'Options' within the 'Presentations' panel and choose the 'Broadcast' tab of the options dialog.  Choose your cam and mic and click save.  Once saved you can close the options dialog and click 'Broadcast' from within the 'Live Broadcast' panel to stream audio and/or video to the web.  For more information see the 'Broadcasting' tutorial from the Help menu.",
	c: "presentations,broadcasting",
	s: 9
	}
	
	/* {
	q: "",
	a: "",
	c: "",
	s: 1
	} */
]);
