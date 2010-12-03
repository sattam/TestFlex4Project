////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.flexer.skin
{

import flash.display.GradientType;
import flash.geom.Matrix;

import mx.containers.TabNavigator;
import mx.core.EdgeMetrics;
import mx.core.UIComponent;
import mx.skins.Border;
import mx.skins.halo.HaloColors;
import mx.styles.IStyleClient;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The skin for all the states of a Tab in a TabNavigator or TabBar.
 */
public class PlayButtonSkin extends Border
{


	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var cache:Object = {};

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Several colors used for drawing are calculated from the base colors
	 *  of the component (themeColor, borderColor and fillColors).
	 *  Since these calculations can be a bit expensive,
	 *  we calculate once per color set and cache the results.
	 */
	private static function calcDerivedStyles(themeColor:uint,
											  borderColor:uint,
											  falseFillColor0:uint,
											  falseFillColor1:uint,
											  fillColor0:uint,
											  fillColor1:uint):Object
	{
		var key:String = HaloColors.getCacheKey(themeColor, borderColor,
												falseFillColor0,
												falseFillColor1,
												fillColor0, fillColor1);
		
		if (!cache[key])
		{
			var o:Object = cache[key] = {};

			// Cross-component styles.
			HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
			
			// Tab-specific styles.
			o.borderColorDrk1 =
				ColorUtil.adjustBrightness2(borderColor, 0);
			o.falseFillColorBright1 =
				ColorUtil.adjustBrightness(falseFillColor0, 0);
			o.falseFillColorBright2 =
				ColorUtil.adjustBrightness(falseFillColor1, 0);
		}
		
		return cache[key];
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function PlayButtonSkin()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  borderMetrics
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the borderMetrics property.
	 */
	private var _borderMetrics:EdgeMetrics = new EdgeMetrics(1, 1, 1, 1);

	/**
	 *  @private
	 */
	override public function get borderMetrics():EdgeMetrics
	{
		return _borderMetrics;
	}

	//----------------------------------
	//  measuredWidth
	//----------------------------------
	
	/**
	 *  @private
	 */
	override public function get measuredWidth():Number
	{
		return UIComponent.DEFAULT_MEASURED_MIN_WIDTH;
	}
	
	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredHeight():Number
	{
		return UIComponent.DEFAULT_MEASURED_MIN_HEIGHT;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);
		
	

		// User-defined styles.
		var backgroundAlpha:Number = 1;		
		var backgroundColor:uint = 0x000000;; 
		var drawColor:uint = 0xFFFFFF;  
		var cornerRadius:Number = 0;
		 
		
		var drawBottomLine:Boolean =
			parent != null &&
			parent.parent != null &&
			parent.parent.parent != null &&
			parent.parent.parent is TabNavigator &&
			IStyleClient(parent.parent.parent).getStyle("borderStyle") != "none";
		
		drawBottomLine = false;
		
		
		var cr:Object = { tl: cornerRadius, tr: cornerRadius, bl: cornerRadius, br: cornerRadius}; 

		graphics.clear(); 
 
		
		switch (name)
		{
			case "upSkin":
			case "overSkin":
			{
   
 				 // fill
				drawRoundRect(
					0, 0, w, h , cr,
					backgroundColor, backgroundAlpha);
					
				graphics.beginFill(drawColor,0.8);
            	graphics.lineStyle(1, drawColor); 
            	graphics.moveTo(5,5);
            	graphics.lineTo(15,10);
            	graphics.lineTo(5,15);
            	graphics.lineTo(5,5);
            	graphics.endFill();
 	
					  
				break;
			}


			case "disabledSkin":
			{
				// fill
   				drawRoundRect(
					0, 0, w, h , cr,
					backgroundColor, 0.5);
					
				graphics.beginFill(drawColor,0.4);
            	graphics.lineStyle(1, drawColor); 
            	graphics.moveTo(5,5);
            	graphics.lineTo(15,10);
            	graphics.lineTo(5,15);
            	graphics.lineTo(5,5);
            	graphics.endFill();	
					
				break;
			}
			
			case "downSkin":
			case "selectedUpSkin":
			case "selectedDownSkin":
			case "selectedOverSkin":
			case "selectedDisabledSkin":
			{
				
				 // fill
				drawRoundRect(
					0, 0, w, h , cr,
					backgroundColor, backgroundAlpha);
					
				graphics.beginFill(drawColor,0.5);
            	graphics.lineStyle(1, drawColor); 
            	graphics.moveTo(5,5);
            	graphics.lineTo(15,10);
            	graphics.lineTo(5,15);
            	graphics.lineTo(5,5);
            	graphics.endFill();	
	
				break;
			}
		}
	}
}

}
