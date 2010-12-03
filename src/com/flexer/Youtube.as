package com.flexer
{
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import mx.core.UIComponent; 
        
	public class Youtube extends UIComponent 
	{
		[Bindable]
		private var _loader:Loader; 
        private var _player:Object;  
        private var _videoId:String;
		private var _state:int = -1;
        
        public function Youtube()
        { 
        	super();
        	//allow domains
			Security.allowDomain("www.youtube.com");
        	Security.allowDomain("video-stats.video.google.com");
 
			//load youtube api
			 _loader  = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderInit);
			_loader.load(new URLRequest("http://www.youtube.com/apiplayer?version=3"));
  
			//add loader to our component
			addChild(_loader);  
        } 
   
		//get movie state
		public function get state():int
		{
			return _state;
		}

		//set youtube video ID
        public function set videoId(v:String):void
        {
        	_videoId = v;
        }
 
		//stop movie
 		public function stop():void
 		{
			if ( _player != null )
 				_player.stopVideo();
 		}
 
		//play movie
 		public function play():void
 		{
			if ( _player != null )
 				_player.playVideo();
 		}
 		
		//pause movie
 		public function pause():void
 		{
			if ( _player != null )
 				_player.pauseVideo();
 		}
 		
		//mute movie
 		public function mute():void
 		{
			if ( _player != null )
 				_player.mute();
 		}
 
		//unmute movie
 		public function unMute():void
 		{
			if ( _player != null )
 			 _player.unMute();
 		}
		
		//check if the sound it's muted
		public function isMuted():Boolean
		{
			return _player.isMuted();
		}
		
		//get sound volume
		public function getVolume():Number
		{
			return _player.getVolume();
		}
		
		//set sound volume (0-100);
		public function setVolume(v:Number):void
		{
			_player.setVolume(v);
		}
 		
		//seek to second
 		public function seekTo(v:Number):void
 		{
			if ( _player != null )
 				_player.seekTo(v,true)
 		}
  
		//total movie duration in seconds
 		public function getDuration():int
		{
			if ( _player != null )
				return int(_player.getDuration());
			else
				return -1;	
		} 
		
		//current movie second
		public function getCurrentTime():int
		{
			if ( _player != null )
				return int(_player.getCurrentTime());
			else
				return -1;	
		}
		
		//set events for our movie
		private function onLoaderInit(event:Event):void {
		     
		    _loader.content.addEventListener("onReady", onPlayerReady);
		    _loader.content.addEventListener("onError", onPlayerError);
		    _loader.content.addEventListener("onStateChange", onPlayerStateChange);
		    _loader.content.addEventListener("onPlaybackQualityChange",  onVideoPlaybackQualityChange);
		}
		
		private function onPlayerReady(event:Event):void {
		    // Event.data contains the event parameter, which is the Player API ID 
		     trace("player ready:", Object(event).data);
		
		    // Once this event has been dispatched by the player, we can use
		    // cueVideoById, loadVideoById, cueVideoByUrl and loadVideoByUrl
		    // to load a particular YouTube video.
		    _player = _loader.content;
			//load our video ID
		    _player.loadVideoById(_videoId);
			//set movie size
		    _player.setSize(480,270);   
		}
		
		private function onPlayerError(event:Event):void {
		    // Event.data contains the event parameter, which is the error code
		    trace("player error:", Object(event).data);
		}
		
		private function onPlayerStateChange(event:Event):void {
		    // Event.data contains the event parameter, which is the new player state
			_state = int(Object(event).data);
		}
		
		private function onVideoPlaybackQualityChange(event:Event):void {
		    // Event.data contains the event parameter, which is the new video quality
		    trace("video quality:", Object(event).data);
		} 
		
		
		
		

	}
}