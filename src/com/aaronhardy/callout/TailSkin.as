package com.aaronhardy.callout
{
	import mx.skins.ProgrammaticSkin;

	/**
	 * Creates a default tail skin to be used in the Callout component.  The tail
	 * is the triangular portion that extends from the bubble (content area).
	 */
	public class TailSkin extends ProgrammaticSkin
	{
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.moveTo(unscaledWidth / 2, 0);
			graphics.beginFill(getStyle('backgroundColor'));
			graphics.lineTo(0, unscaledHeight);
			graphics.lineTo(unscaledWidth, unscaledHeight / 2);
			graphics.lineTo(unscaledWidth / 2, 0);
			graphics.endFill();
		}
	}
}