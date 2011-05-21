package com.aaronhardy.callout
{
	import mx.skins.Border;
	
	/**
	 * Creates a default bubble skin to be used in the Callout component.  The bubble
	 * is the content area portion that extends from the tail.
	 */
	public class BubbleSkin extends Border
	{
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.beginFill(getStyle('backgroundColor'));
			graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 10);
		}
	}
}