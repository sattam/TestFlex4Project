package
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.SWFLoader;
	import mx.controls.TextInput;
	import mx.events.ListEvent;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerState;

	
	public class youTube extends Canvas { 
		// Member variables. 
		private var cueButton:Button; 
		private var isQualityPopulated:Boolean; 
		private var isWidescreen:Boolean; 
		private var pauseButton:Button; 
		private var playButton:Button; 
		private var player:Object; 
		private var playerLoader:SWFLoader; 
		private var qualityComboBox:ComboBox; 
		private var videoIdTextInput:TextInput; 
		private var youtubeApiLoader:URLLoader; 
		
		// CONSTANTS. 
		private static const DEFAULT_VIDEO_ID:String = "0QRO3gKj3qw"; 
		private static const PLAYER_URL:String = 
			"http://www.youtube.com/apiplayer?version=3"; 
		private static const SECURITY_DOMAIN:String = "http://www.youtube.com"; 
		private static const YOUTUBE_API_PREFIX:String = 
			"http://gdata.youtube.com/feeds/api/videos/"; 
		private static const YOUTUBE_API_VERSION:String = "2"; 
		private static const YOUTUBE_API_FORMAT:String = "5"; 
		private static const WIDESCREEN_ASPECT_RATIO:String = "widescreen"; 
		private static const QUALITY_TO_PLAYER_WIDTH:Object = { 
			small: 320, 
			medium: 640, 
			large: 854, 
			hd720: 1280 
		}; 
		private static const STATE_UNSTARTED:Number = -1; 
		private static const STATE_ENDED:Number = 0; 
		private static const STATE_PLAYING:Number = 1; 
		private static const STATE_PAUSED:Number = 2; 
		private static const STATE_BUFFER:Number = 3; 
		private static const STATE_CUED:Number = 5; 
		
		
		public var _autoPlay:Boolean;
		public var _autoRewind:Boolean;
		public var _loop:Boolean;
		public var _playerState:String = MediaPlayerState.UNINITIALIZED;
		public var _pauseWhenHidden:Boolean;
		public var _scaleMode:String;
		public var _source:Object;
		public var _thumbnailSource:Object;
		public var _bytesLoaded:Number = 0;
		public var _bytesTotal:Number =0;
		public var _currentTime:Number =0;
		public var _duration:Number = 0;
		public var myTimer:Timer ;
		
		
		public function youTube():void { 
			// Specifically allow the chromless player .swf access to our .swf. 
			Security.allowDomain(SECURITY_DOMAIN); 
			
		//	setupUi(); 
			setupPlayerLoader(); 
			setupYouTubeApiLoader(); 
		} 
		
		private function setupUi():void { 
			// Create a TextInput field for the YouTube video id, and pre-populate it. 
			videoIdTextInput = new TextInput(); 
			videoIdTextInput.text = DEFAULT_VIDEO_ID; 
			videoIdTextInput.width = 100; 
			videoIdTextInput.x = 10; 
			videoIdTextInput.y = 10; 
			addChild(videoIdTextInput); 
			
			// Create a Button for cueing up the video whose id is specified. 
			cueButton = new Button(); 
			cueButton.enabled = false; 
			cueButton.label = "Cue Video"; 
			cueButton.width = 100; 
			cueButton.x = 120; 
			cueButton.y = 10; 
		//	cueButton.addEventListener(MouseEvent.CLICK, cueButtonClickHandler); 
			addChild(cueButton); 
			
			// Create a ComboBox that will contain the list of available playback 
			// qualities. Selecting from the ComboBox will change the playback quality 
			// and resize the player. Note that playback qualities are only available 
			// once a video has started playing, so the values in this ComboBox can't 
			// be populated until then. 
			qualityComboBox = new ComboBox(); 
			qualityComboBox.prompt = "n/a"; 
			qualityComboBox.width = 100; 
			qualityComboBox.x = 230; 
			qualityComboBox.y = 10; 
			qualityComboBox.addEventListener(ListEvent.CHANGE, 
				qualityComboBoxChangeHandler); 
			addChild(qualityComboBox); 
			
			// Create a Button for playing the cued video. 
			playButton = new Button(); 
			playButton.enabled = false; 
			playButton.label = "Play"; 
			playButton.width = 100; 
			playButton.x = 340; 
			playButton.y = 10; 
		//	playButton.addEventListener(MouseEvent.CLICK, playButtonClickHandler); 
			addChild(playButton); 
			
			// Create a Button for pausing the cued video. 
			pauseButton = new Button(); 
			pauseButton.enabled = false; 
			pauseButton.label = "Pause"; 
			pauseButton.width = 100; 
			pauseButton.x = 450; 
			pauseButton.y = 10; 
		//	pauseButton.addEventListener(MouseEvent.CLICK, pauseButtonClickHandler); 
			addChild(pauseButton); 
		} 
		
		private function setupPlayerLoader():void { 
			playerLoader = new SWFLoader(); 
			playerLoader.addEventListener(Event.INIT, playerLoaderInitHandler); 
			playerLoader.load(PLAYER_URL); 
		} 
		
		private function playerLoaderInitHandler(event:Event):void { 
			addChild(playerLoader); 
			playerLoader.content.addEventListener("onReady", onPlayerReady); 
			playerLoader.content.addEventListener("onError", onPlayerError); 
			playerLoader.content.addEventListener("onStateChange", 
				onPlayerStateChange); 
			playerLoader.content.addEventListener("onPlaybackQualityChange", 
				onVideoPlaybackQualityChange); 
		} 
		
		private function setupYouTubeApiLoader():void { 
			youtubeApiLoader = new URLLoader(); 
			youtubeApiLoader.addEventListener(IOErrorEvent.IO_ERROR, 
				youtubeApiLoaderErrorHandler); 
			youtubeApiLoader.addEventListener(Event.COMPLETE, 
				youtubeApiLoaderCompleteHandler); 
			
			loadVideo()
		} 
		
		private function youtubeApiLoaderCompleteHandler(event:Event):void { 
			var atomData:String = youtubeApiLoader.data; 
			
			// Parse the YouTube API XML response and get the value of the 
			// aspectRatio element. 
			var atomXml:XML = new XML(atomData); 
			var aspectRatios:XMLList = atomXml..*::aspectRatio; 
			
			isWidescreen = aspectRatios.toString() == WIDESCREEN_ASPECT_RATIO; 
			
			isQualityPopulated = false; 
			// Cue up the video once we know whether it's widescreen. 
			// Alternatively, you could start playing instead of cueing with 
			// player.loadVideoById(videoIdTextInput.text); 
		//	player.cueVideoById(DEFAULT_VIDEO_ID); 
		} 
		
		private function onPlayerReady(event:Event):void { 
			player = playerLoader.content; 
			player.visible = false; 
			player.cueVideoById(_source); 
			
			//	cueButton.enabled = true; 
			myTimer = new Timer(50, 1000);
			myTimer.addEventListener("timer", updatePlayingStats);
			myTimer.start();
			
		} 
		
		private function qualityComboBoxChangeHandler(event:Event):void { 
			var qualityLevel:String = ComboBox(event.target).selectedLabel; 
			player.setPlaybackQuality(qualityLevel); 
		} 
		
		private function loadVideo():void { 
			var request:URLRequest = new URLRequest(YOUTUBE_API_PREFIX + 
				_source); 
			
			var urlVariables:URLVariables = new URLVariables(); 
			urlVariables.v = YOUTUBE_API_VERSION; 
			urlVariables.format = YOUTUBE_API_FORMAT; 
			request.data = urlVariables; 
			
			try { 
				youtubeApiLoader.load(request); 
			} catch (error:SecurityError) { 
				trace("A SecurityError occurred while loading", request.url); 
			} 
		} 
		
		public function play():void { 
			myTimer.reset();
			player.playVideo(); 
		} 
		
		public function pause():void { 
			player.pauseVideo(); 
		}
		
		public function stop():void { 
			player.stopVideo(); 
		}
		
		public function seek(seconds:Number):void { 
			player.seekTo(seconds,true);
		}
		
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}
		
		/**
		 * @private
		 */
		public function set autoPlay(value:Boolean):void
		{
			_autoPlay = value;
			
		}
		
		public function get autoRewind():Boolean
		{
			return _autoRewind;
		}
		
		/**
		 * @private
		 */
		public function set autoRewind(value:Boolean):void
		{
			_autoRewind = value;
		}
		
		public function get bytesLoaded():Number
		{
			return _bytesLoaded;
		}
		
		public function get bytesTotal():Number
		{
			return _bytesTotal; 
		}
		
		public function get currentTime():Number
		{
			return _currentTime; 
		}
		
		public function get duration():Number
		{
			return _duration ;
			
		}
		
		public function get loop():Boolean
		{
			
				return _loop;
			
		}
		
		/**
		 *  @private
		 */
		public function set loop(value:Boolean):void
		{
			_loop = value;
		}
		
		
		public function get mediaPlayerState():String
		{
			
				return _playerState;
		}
		
		public function get muted():Boolean
		{
			if (player) return player.isMuted();
			else return false;
		}
		
		/**
		 *  @private
		 */
		public function set muted(value:Boolean):void
		{
			if (value ) player.mute();
			else player.unMute();
		}
		
		
		
		public function get pauseWhenHidden():Boolean
		{
			return _pauseWhenHidden;
		}
		
		/**
		 *  @private
		 */
		public function set pauseWhenHidden(value:Boolean):void
		{
			_pauseWhenHidden = value;
		}
		
		public function get playing():Boolean
		{
			return (_playerState == MediaPlayerState.PLAYING);
		}
		
		public function get scaleMode():String
		{
			return _scaleMode;
		}
		
		/**
		 *  @private
		 */
		public function set scaleMode(value:String):void
		{
			_scaleMode = value;
		}
		
		public function get source():Object
		{
			return _source;
		}
		
		/**
		 * @private
		 */
		public function set source(value:Object):void
		{
			var s:String = value as String;
			if (s.lastIndexOf('?',s.length)>0)
			{
				var a:Array = s.split('?');
				var uv:URLVariables = new URLVariables(a[1]);
				_source=uv.v;
			}
			else _source = s;
		}
		
		
		public function get thumbnailSource():Object
		{
			return _thumbnailSource;
		}
		
		/**
		 * @private
		 */
		public function set thumbnailSource(value:Object):void
		{
			_thumbnailSource = value;
		}
		
		public function get videoObject():Video
		{
			return null;
		}
		
		public function get volume():Number
		{
			if (player) return player.getVolume();
			else return 100;
		}
		
		/**
		 * @private
		 */
		public function set volume(value:Number):void
		{
			player.setVolume(value)
		}
		
		
		private function youtubeApiLoaderErrorHandler(event:IOErrorEvent):void { 
			trace("Error making YouTube API request:", event); 
		} 
		
		
		
		private function onPlayerError(event:Event):void { 
			trace("Player error:", Object(event).data); 
		} 
		
		private function onPlayerStateChange(event:Event):void { 
			trace("State is", Object(event).data); 
			
			switch (Object(event).data) { 
				case STATE_ENDED: 
					_playerState = MediaPlayerState.PAUSED
					dispatchEvent(new TimeEvent(TimeEvent.COMPLETE));
					myTimer.stop();
				//	playButton.enabled = true; 
				//	pauseButton.enabled = false; 
					break; 
				
				case STATE_PLAYING: 
					_playerState = MediaPlayerState.PLAYING;
					myTimer.start();
				//	playButton.enabled = false; 
				//	pauseButton.enabled = true; 
					
					if(!isQualityPopulated) { 
				//		populateQualityComboBox(); 
					} 
					break; 
				
				case STATE_PAUSED: 
					_playerState = MediaPlayerState.PAUSED;
				//	playButton.enabled = true; 
				//	pauseButton.enabled = false; 
					break; 
				
				case STATE_BUFFER: 
					_playerState = MediaPlayerState.BUFFERING;
					//	playButton.enabled = true; 
					//	pauseButton.enabled = false; 
					break; 
				
				case STATE_CUED: 
					_playerState = MediaPlayerState.READY;
				//	playButton.enabled = true; 
				//	pauseButton.enabled = false; 
					
					resizePlayer("medium"); 
					break; 
			} 
		} 
		
		
		public function timerHandler(event:TimerEvent):void {
			trace("timerHandler: " + event);
		}

		
		private function updatePlayingStats(event:TimerEvent):void
		{
			if (_bytesLoaded!=player.getVideoBytesLoaded()) 
			{
				_bytesLoaded = player.getVideoBytesLoaded;
				dispatchEvent(new LoadEvent(LoadEvent.BYTES_LOADED_CHANGE));
			}
			if (_bytesTotal !=player.getVideoBytesTotal())
			{
				_bytesTotal = player.getVideoBytesTotal();
			}
			
			if (_currentTime != player.getCurrentTime())
			{
				_currentTime = player.getCurrentTime();
				dispatchEvent(new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE));
			}
			
			if (_duration != player.getDuration())
			{
				_duration =  player.getDuration();
				dispatchEvent((new TimeEvent(TimeEvent.DURATION_CHANGE)));
			}
			trace(player.getVideoBytesLoaded()+ '' +myTimer.currentCount );
			if (myTimer.currentCount >200) myTimer.reset();
		}
		
		private function onVideoPlaybackQualityChange(event:Event):void { 
			trace("Current video quality:", Object(event).data); 
			resizePlayer(Object(event).data); 
		} 
		
		private function resizePlayer(qualityLevel:String):void { 
			var newWidth:Number = QUALITY_TO_PLAYER_WIDTH[qualityLevel] || 640; 
			var newHeight:Number; 
			
			if (isWidescreen) { 
				// Widescreen videos (usually) fit into a 16:9 player. 
				newHeight = this.width * 9 / 16; 
			} else { 
				// Non-widescreen videos fit into a 4:3 player. 
				newHeight = newWidth * 3 / 4; 
			} 
			
			trace("isWidescreen is", isWidescreen, ". Size:", newWidth, newHeight); 
			player.setSize(this.width, this.height); 
			
			// Center the resized player on the stage. 
			player.x = 0;//(this.width - newWidth) / 2; 
			player.y = 0 ;//(this.height - newHeight) / 2; 
			
			player.visible = true; 
		} 
		
		public function resize(nWidth:Number,nHeight:Number):void { 
			
			
			
			player.setSize(nWidth, nHeight); 
			
			// Center the resized player on the stage. 
			player.x = 0;//(stage.stageWidth - newWidth) / 2; 
			player.y = 0;//(stage.stageHeight - newHeight) / 2; 
			
			player.visible = true; 
		} 
		
		private function populateQualityComboBox():void { 
			isQualityPopulated = true; 
			
			var qualities:Array = player.getAvailableQualityLevels(); 
			qualityComboBox.dataProvider = qualities; 
			
			var currentQuality:String = player.getPlaybackQuality(); 
			qualityComboBox.selectedItem = currentQuality; 
		} 
	} 
	
	
}