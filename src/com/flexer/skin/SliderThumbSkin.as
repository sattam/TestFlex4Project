package com.flexer.skin
{
	import mx.controls.sliderClasses.SliderThumb;
	
	public class SliderThumbSkin extends SliderThumb
	{
		public function SliderThumbSkin()
		{
			super(); 
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
	        super.updateDisplayList(unscaledWidth,unscaledHeight);
	         
	        
		    this.graphics.beginFill(0xffffff,0.8); 
		    graphics.lineStyle(1, 0xffffff);
	        this.graphics.drawRect(0,0,3,10);
	        this.graphics.endFill();
       }

	}
}
