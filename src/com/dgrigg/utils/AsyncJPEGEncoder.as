/**
 * Extends the JPEGEncoder class to allow asynchronous file encoding.
 * Author:	Derrick Grigg
 * Url:		www.dgrigg.com
 * Created:	Jan 30, 2009
 */

package com.dgrigg.utils
{
	import com.adobe.images.BitString;
	import com.adobe.images.JPGEncoder;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.events.DynamicEvent;
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	
	public class AsyncJPEGEncoder extends JPGEncoder implements IEventDispatcher
	{
		protected  var _dispatcher:EventDispatcher;
		protected  var _encodeTimer:int;
		protected  var DCY:Number;
		protected  var DCU:Number;
		protected  var DCV:Number;
		protected  var _ypos:int;
		public  var imgFileName:String;
		
		public function AsyncJPEGEncoder(quality:Number=50)
		{
			super(quality);
			_dispatcher = new EventDispatcher(this);
		}
		
		/**
		 * Created a JPEG image from the specified BitmapData
		 *
		 * @param image The BitmapData that will be converted into the JPEG format.
		 * @return a ByteArray representing the JPEG encoded image data.
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */	
		
		
		override public function encode(image:BitmapData):ByteArray
		{
			// Initialize bit writer
			byteout = new ByteArray();
			bytenew=0;
			bytepos=7;
	
			// Add JPEG headers
			writeWord(0xFFD8); // SOI
			writeAPP0();
			writeDQT();
			writeSOF0(image.width,image.height);
			writeDHT();
			writeSOS();

			// Encode 8x8 macroblocks
			DCY=0;
			DCU=0;
			DCV=0;
			bytenew=0;
			bytepos=7;
			
			_ypos = 0;
			flash.utils.clearInterval(_encodeTimer);
			_encodeTimer = flash.utils.setInterval(doEncode, 1, image);
			
			
			return byteout;

		}
		import flash.display.Stage;
		
		protected function doEncode(image:BitmapData):void 
		{
			for (var xpos:int=0; xpos<image.width; xpos+=8) 
			{
				RGB2YUV(image, xpos, _ypos);
				DCY = processDU(YDU, fdtbl_Y, DCY, YDC_HT, YAC_HT);
				DCU = processDU(UDU, fdtbl_UV, DCU, UVDC_HT, UVAC_HT);
				DCV = processDU(VDU, fdtbl_UV, DCV, UVDC_HT, UVAC_HT);
			}
			_ypos += 8;
			
			var e:DynamicEvent =  new DynamicEvent('encodeProgress');
			if (_ypos<image.height)
			{
				e.bytesLoaded = _ypos;
				e.bytesTotal = image.height;
				e.imgFileName = imgFileName;
				dispatchEvent(e);
			}
			else
			{
				flash.utils.clearInterval(_encodeTimer);
				e.bytesLoaded = image.height;
				e.bytesTotal = image.height;
				e.imgFileName = imgFileName;
				dispatchEvent(e);
				finishEncode();
			}

		}
		
		protected function finishEncode():void 
		{
			// Do the bit alignment of the EOI marker
			if ( bytepos >= 0 ) {
				var fillbits:BitString = new BitString();
				fillbits.len = bytepos+1;
				fillbits.val = (1<<(bytepos+1))-1;
				writeBits(fillbits);
			}
	
			writeWord(0xFFD9); //EOI
			//return byteout;
			
			var e:DynamicEvent = new DynamicEvent('encodeComplete');
			e.imgFileName = imgFileName;
			e.bytes = getBytes();
			dispatchEvent(e);
			
		}
		
		public function cancel():void 
		{
			var e:Event = new Event(Event.CANCEL);
			dispatchEvent(e);
			
			flash.utils.clearInterval(_encodeTimer);
		}
		
		public function getBytes():ByteArray
		{
			return byteout;
		}
		
	           
	    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
	        _dispatcher.addEventListener(type, listener, useCapture, priority);
	    }
	           
	    public function dispatchEvent(evt:Event):Boolean{
	        return _dispatcher.dispatchEvent(evt);
	    }
	    
	    public function hasEventListener(type:String):Boolean{
	        return _dispatcher.hasEventListener(type);
	    }
	    
	    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
	        _dispatcher.removeEventListener(type, listener, useCapture);
	    }
	                   
	    public function willTrigger(type:String):Boolean {
	        return _dispatcher.willTrigger(type);
	    }

		
	}
}