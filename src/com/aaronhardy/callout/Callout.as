// Copyright (c) 2009 Aaron Hardy
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

package com.aaronhardy.callout
{
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.Container;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	import mx.utils.ObjectUtil;
	
	/**
	 * Name of class use as the skin for the callout tail (the triangle extending
	 * into the bubble).
	 * 
	 * If you are designing a skin to be used as a tail,
	 * keep in mind the skin will be sized to a square.  This is so
	 * it can be rotated if needed to different sides/corners of the callout
	 * bubble and retain an expected perspective.
	 * 
	 * Also take into consideration how the tail will match up with the bubble.
	 * You can move the tail closer to or farther away from the bubble by using
	 * the <code>tailOffset</code> style.
	 * 
	 * Currently, this skin cannot be swapped after the callout has been created.
	 * 
	 * @default callout.TailSkin
	 */
	[Style(name="tailSkin",type="Class",inherit="no")]
	
	/**
	 * Name of the class used as the skin for the callout bubble
	 * (the container for the callout content).
	 * 
	 * If you are designing a skin to be used as a bubble,
	 * take into consideration how the tail will match up with the bubble.
	 * You can move the tail closer to or farther away from the bubble by using
	 * the <code>tailOffset</code> style.
	 * 
	 * Currently, this skin cannot be swapped after the callout has been created.
	 * 
	 * @default callout.BubbleSkin
	 */
	[Style(name="bubbleSkin",type="Class",inherit="no")]
	
	/**
	 * The number of pixels the tail should be moved closer to or farther away
	 * from the callout bubble.  Because the callout can't determine exactly where
	 * to position the tail so it fits correctly with the bubble, this is used as
	 * an adjustment so you as the developer can make it fit.
	 * 
	 * An example of how this might work is if you had a bubble with large rounded
	 * corners, you will likely need to decrease the tail offset to move the tail
	 * closer to the bubble.  Negative values are accepted.
	 * 
	 * @default 0
	 */
	[Style(name="tailOffset",type="Number",format="Length",inherit="no")]
	
	/**
	 * The width and height of the tail in pixels. Because the tail skin will be sized
	 * to a square, the tailSize will be the same for both the width and
	 * the height.
	 * 
	 * @default 30
	 */  
	[Style(name="tailSize",type="Number",format="Length",inherit="no")]
	
	/**
	 * The position where you would prefer the tail to be positioned in relation
	 * to the bubble.  For example, "bottomLeft" would place the tail below and to
	 * the left of the bubble.
	 * 
	 * This style is "preferred" and not necessarily the actual position where
	 * the tail will be placed.  The callout evaluates its position on the
	 * screen to determine if it will fit on the screen using the preferred
	 * tail position.  If it cannot, it will evaluate other tail positions
	 * until one is found that will result in the full callout being displayed
	 * on the screen.  Tail positions are evaluated in clockwise order.
	 * 
	 * If you would like to force the preferred tail position to be the actual tail position
	 * regardless of whether the callout will fit on the screen, set forcePreferredTailPosition
	 * to true.
	 * 
	 * @default bottomLeft
	 */
	[Style(name="preferredTailPosition",type="String",enumeration="bottomLeft,left,topLeft,top,topRight,right,bottomRight,bottom",inherit="no")]
	
	/**
	 * If set the true, this forces the preferred tail position to be the actual tail position 
	 * regardless of whether the callout will fit on the screen.
	 */
	[Style(name="forcePreferredTailPosition",type="Boolean", inherit="no")]
	
	/**
	 * The padding on the top side of the bubble.
	 */
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	
	/**
	 * The padding on the right side of the bubble.
	 */
	[Style(name="paddingRight", type="Number", format="Length", inherit="no")]
	
	/**
	 * The padding on the bottom side of the bubble.
	 */
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	
	/**
	 * The padding on the left side of the bubble.
	 */
	[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
	
	/**
	 * The color of the callout's tail and bubble.
	 */
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	
	/**
	 * The alpha for the callout's tail and bubble.  This alpha will also be
	 * applied to custom skins. If you specify an alpha other than 1, you WILL NOT 
	 * be able to expect a portion of the skin to be completely opaque.  The alpha
	 * is applied to the skins regardless of their content. 
	 */
	[Style(name="backgroundAlpha", type="Number", inherit="no")]
	
	/**
	 * This style dictates how positioning is retrieved when the callout is anchored
	 * to a display object rather than a specified point.  Let's say the anchoring
	 * display object is rectangular in form and our callout by default has its
	 * tail extending from the bottom-left of the bubble.  This normally works
	 * fine if the button is not rotated; the callout extends from the top-right
	 * off the button.  However, if the button is rotated 180 degrees so that it
	 * is upside down, how do we anchor the callout?
	 * 
	 * If this style is set to its default, false, then we get the external
	 * bounds of the rotated button.  The callout extends from the same position
	 * as it would if the button were not rotated, that is, the top-right most
	 * pixel of the button in the stage.
	 * 
	 * If this style is set to true, then we use the internal bounds
	 * of the rotated button.  The callout extends from the literal top-right
	 * of the button, that is, the bottom-left most pixel of the button in the stage.
	 */
	[Style(name="useInternalBoundPositioning", type="Boolean", inherit="no")]
	
	/**
	 * Customizable callout component.
	 * 
	 * @author Aaron Hardy - aaronhardy.com
	 */
	public class Callout extends Container
	{
		// Default styles
		//////////////////////////////
		private static var classConstructed:Boolean = classConstruct();
		
		/**
		 * @private
		 * Creates default styles that can be overridden by the developer.
		 */
		private static function classConstruct():Boolean {
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration('Callout');
			
			if (!styleDeclaration) {
				styleDeclaration = new CSSStyleDeclaration();
			}
			
			styleDeclaration.defaultFactory = function():void {
				this.tailOffset = 0;
				this.tailSize = 30;
				this.paddingTop = 10;
				this.paddingRight = 10;
				this.paddingBottom = 10;
				this.paddingLeft = 10;
				this.preferredTailPosition = TAIL_POSITION_BOTTOM_LEFT;
				this.forcePreferredTailPosition = false;
				this.backgroundColor = 0xFFFFFF;
				this.backgroundAlpha = 1;
			}
			
			StyleManager.setStyleDeclaration('Callout', styleDeclaration, false);
			
			return true;
		}
		
		// Properties and styles
		//////////////////////////////
		
		private var _content:UIComponent;
		private var contentChanged:Boolean = true;
		
		/**
		 * The content to be placed within the callout bubble.
		 */
		public function get content():UIComponent {
			return _content;
		}
		
		/**
		 * @private
		 */
		public function set content(value:UIComponent):void {
			if (_content == value) {
				return;
			}
			
			_content = value;
			contentChanged = true;
			invalidateProperties();
			invalidateDisplayList();
			invalidateSize();			
		}
		
		private var _anchorPoint:Point;
		private var anchorPointChanged:Boolean = true;
		
		/**
		 * The anchor point from which the callout should extend.
		 * In other words, the callout will point to this anchor point.
		 * This should be a point in the global scope and not within just
		 * a particular container or element.
		 * 
		 * If the <code>anchorDisplayObject</code> is set, this will
		 * have no affect.
		 * 
		 * @default new Point(0, 0);
		 * @see #anchorDisplayObject
		 */
		public function get anchorPoint():Point {
			return _anchorPoint;
		}
		
		/**
		 * @private
		 */
		public function set anchorPoint(value:Point):void {
			if (_anchorPoint == value) {
				return;
			}
			
			_anchorPoint = value;
			anchorPointChanged = true;
			invalidateProperties();
			invalidateDisplayList();
			invalidateSize();
		}
		
		private var paddingChanged:Boolean = true;
		private var preferredTailPositionChanged:Boolean = true;
		private var forcePreferredTailPositionChanged:Boolean = true;
		
		/**
		 * Detects style changes and calls related invalidate functions
		 * when necessary.
		 */
		override public function styleChanged(styleProp:String):void {
			super.styleChanged(styleProp);
			
			if (styleProp == 'paddingTop' || styleProp == 'paddingRight' ||
					styleProp == 'paddingBottom' || styleProp == 'paddingLeft') {
				paddingChanged = true;
				invalidateProperties();
			}
			
			if (styleProp == 'preferredTailPosition') {
				preferredTailPositionChanged = true;
				invalidateProperties();
			}
			
			if (styleProp == 'forcePreferredTailPosition') {
				forcePreferredTailPositionChanged = true;
				invalidateProperties();
			}
		}
		
		/**
		 * @protected
		 * We are extending Container yet we are using <code>backgroundColor</code> and
		 * <code>backgroundAlpha</code> without our Callout.  By overriding
		 * <code>createBorder()</code> and not calling <code>super.createBorder()</code>
		 * we are in effect keeping Container from drawing a background and border of
		 * its own.  We know we never want Container to do so.
		 */
		override protected function createBorder():void {
			// Do nothing.
		}
		
		// Validation
		//////////////////////////////
		
		// Possible tail positions.
		public static const TAIL_POSITION_BOTTOM_LEFT:String = 'bottomLeft';
		public static const TAIL_POSITION_LEFT:String = 'left';
		public static const TAIL_POSITION_TOP_LEFT:String = 'topLeft';
		public static const TAIL_POSITION_TOP:String = 'top';
		public static const TAIL_POSITION_TOP_RIGHT:String = 'topRight';
		public static const TAIL_POSITION_RIGHT:String = 'right';
		public static const TAIL_POSITION_BOTTOM_RIGHT:String = 'bottomRight';
		public static const TAIL_POSITION_BOTTOM:String = 'bottom';
		
		/**
		 * @protected
		 * The tail positions that should be evaluated and the order in which they
		 * should be evaluated in order to determine which would support displaying the callout
		 * within the screen's viewable area.  This order is adjusted when the developer
		 * specifies a <code>preferredTailPosition</code>.
		 * 
		 * @see #preferredTailPosition
		 */
		protected const TAIL_POSITION_ORDER_BLUEPRINT:Array = 
				[TAIL_POSITION_BOTTOM_LEFT, TAIL_POSITION_LEFT, TAIL_POSITION_TOP_LEFT, TAIL_POSITION_TOP,
				TAIL_POSITION_TOP_RIGHT, TAIL_POSITION_RIGHT, TAIL_POSITION_BOTTOM_RIGHT, TAIL_POSITION_BOTTOM];
		
		/**
		 * @protected
		 * The instantiated tail skin.
		 */
		protected var tailSkin:IFlexDisplayObject;
		
		/**
		 * @protected
		 * The instantiated bubble skin.
		 */
		protected var bubbleSkin:IFlexDisplayObject;
		
		protected var alphaLayer:Shape;
				
		/**
		 * @protected
		 * The actual tail position that will be used for displaying the callout.
		 * This is set after tail positions are evaluated to determine which would
		 * support displaying the callout within the screen's viewable area.
		 */
		protected var actualTailPosition:String;
		protected var actualAnchorPoint:Point;
		
		/**
		 * @protected
		 * Creates skin elements.
		 */
		override protected function createChildren():void {
			super.createChildren();
			tailSkin = createSkin('tailSkin', TailSkin);
			bubbleSkin = createSkin('bubbleSkin', BubbleSkin);
			
			// Create an alpha layer.  If a backgroundAlpha lower than 1 is specified
			// for the callout, we will use this layer to "remove" part of the
			// opacity of the underlaying skins.  We cannot simply set the opacities
			// of each of the skins because they can overlap, which would show the
			// overlapping part of one through the other.
			// Because of this overlapping nature, you CANNOT expect to set
			// an alpha other than 1 and hope to see part of your skin as a completely
			// opaque color.
			var alphaLayerUI:UIComponent = new UIComponent();
			alphaLayer = new Shape();
			alphaLayer.graphics.beginFill(0x000000);
			alphaLayer.graphics.drawRect(0, 0, 10, 10); // Random size. Will be resized in updateDisplayList()
			alphaLayer.graphics.endFill();
			alphaLayer.blendMode = BlendMode.ERASE;
			alphaLayerUI.addChild(alphaLayer);
			rawChildren.addChild(alphaLayerUI);
		}
		
		/**
		 * @protected
		 * Creates skin elements. If the user specifies a custom skin, 
		 * it will be created; otherwise, the default skin will be used.
		 * 
		 * @param skinName The name of the skin to create.
		 * @param defaultSkin The class of the default skin to use if the
		 * developer did not specify a custom skin.
		 */
		protected function createSkin(skinName:String, defaultSkin:Class):IFlexDisplayObject {
			var newSkin:IFlexDisplayObject = 
					IFlexDisplayObject(getChildByName(skinName));
			
			if (!newSkin) {
				var newSkinClass:Class = Class(getStyle(skinName));
				
				if (!newSkinClass) {
					newSkinClass = defaultSkin;
				}
				
				if (newSkinClass) {
					newSkin = IFlexDisplayObject(new newSkinClass());
					
					newSkin.name = skinName;
					if (newSkin is ISimpleStyleClient) {
						ISimpleStyleClient(newSkin).styleName = this;
					}
					
					// Use rawChildren so the skin doesn't get mixed up with
					// our content display object.
					rawChildren.addChild(DisplayObject(newSkin));
				}
			}
			
			return newSkin;
		}
		
		/**
		 * @protected
		 * Adds elements to the display list.  Evaluates tail positions to
		 * determine which would support displaying the callout within the 
		 * screen's viewable area.
		 */
		override protected function commitProperties():void {
			super.commitProperties();
			
			// If the content has changed, remove the skins and the content.
			// replace the old with the new.
			if (contentChanged) {
				while (numChildren > 0) {
					removeChildAt(0);
				}
				addChild(DisplayObject(_content));
			}
			
			// If anything that will affect the tail position has changed, start evaluating
			// possible tail positions.
			if (anchorPointChanged || contentChanged || preferredTailPositionChanged ||
					forcePreferredTailPositionChanged || paddingChanged) {
				
				// Create the tail position array which we will use when evaluating possible
				// tail positions.  When a preferred tail position is provided, the tail position array
				// will be rearranged so that the preferred tail position will be evaluated first.
				// Possible tail positions will then be evaluated in a clock-wise order.
				var tailPositionOrder:Array = ObjectUtil.copy(TAIL_POSITION_ORDER_BLUEPRINT) as Array;
				var deprioritizedPositions:Array = tailPositionOrder.splice(0, tailPositionOrder.indexOf(getStyle('preferredTailPosition')));
				tailPositionOrder = tailPositionOrder.concat(deprioritizedPositions);
				
				// Reset the actual tail position. We will use this variable to detect
				// if a valid tail position has been found.
				actualTailPosition = null;
				
				// The content size is used in the tail position evaluation process to see
				// if the callout will fit in the screen's viewable area.  However, the content's
				// size has not been validated because we are still in commitProperties() (size validation
				// occurs in measure()).  We force the contents to validate its size here so we can use its 
				// measurements in getWidthByTailPosition() and getHeightByTailPosition().
				_content.validateSize(true);
				
				// Evaluate possible tail positions in order.
				for each (var proposedTailPosition:String in tailPositionOrder) {
					// Set the default anchor point to be evaluated.  This is the anchor point
					// if one was given. If a display object (owner) was provided, change the anchor 
					// point to be evaluated to one that relates to the display object.  The 
					// corner/side from which the callout would extend depends on the tail position.  
					// For example, if the tail position comes out of the bottom-left of the callout,
					// we want to evaluate the top-right point of the display object.
					var evalAnchorPoint:Point;
					
					if (_anchorPoint)
					{
						evalAnchorPoint = _anchorPoint;
					}
					else
					{
						evalAnchorPoint = getAnchorPointByTailPosition(proposedTailPosition);
					}
					
					// If the developer has chosen to force their preferred tail position, we will
					// skip evaluating whether the callout will fit on the screen.  The tail
					// position will be whatever is set as the preferredTailPosition, regardless
					// of screen size and callout positioning. If forcePreferredTailPosition is
					// true and preferredTailPosition has not been set, this will naturally be
					// the first tail position in the default tail position evaluation order.
					if (getStyle('forcePreferredTailPosition'))
					{
						actualAnchorPoint = evalAnchorPoint;
						actualTailPosition = proposedTailPosition;
						break;
					}
					
					switch (proposedTailPosition) {
						case TAIL_POSITION_BOTTOM_LEFT:
							// Evaulate the width/height of the callout in relation to the anchor point we
							// are evaluating to see if the callout will fit within the viewable screen area.
							// If so, set the actualTailPosition and actualAnchorPoint variables that will be used
							// it the actual display layout.
							if (evalAnchorPoint.x + getWidthByTailPosition(TAIL_POSITION_BOTTOM_LEFT) < screen.width &&
									evalAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_BOTTOM_LEFT) > 0) {
								actualTailPosition = TAIL_POSITION_BOTTOM_LEFT;
								actualAnchorPoint = evalAnchorPoint;
							}
							
							break;
						case TAIL_POSITION_LEFT:
							// See first case.							
							if (evalAnchorPoint.x + getWidthByTailPosition(TAIL_POSITION_LEFT) < screen.width &&
									evalAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_LEFT) / 2 > 0 &&
									evalAnchorPoint.y + getHeightByTailPosition(TAIL_POSITION_LEFT) / 2 < screen.height) {
								actualTailPosition = TAIL_POSITION_LEFT;
								actualAnchorPoint = evalAnchorPoint;
							}
							
							break;
						case TAIL_POSITION_TOP_LEFT:
							// See first case.
							if (evalAnchorPoint.x + getWidthByTailPosition(TAIL_POSITION_TOP_LEFT) < screen.width &&
									evalAnchorPoint.y + getHeightByTailPosition(TAIL_POSITION_TOP_LEFT) < screen.height) {
								actualTailPosition = TAIL_POSITION_TOP_LEFT;
								actualAnchorPoint = evalAnchorPoint;	
							}
							
							break;
						case TAIL_POSITION_TOP:
							// See first case.
							if (evalAnchorPoint.x + getWidthByTailPosition(TAIL_POSITION_TOP) / 2 < screen.width &&
									evalAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_TOP) / 2 > 0 &&
									evalAnchorPoint.y + getHeightByTailPosition(TAIL_POSITION_TOP) < screen.height) {
								actualTailPosition = TAIL_POSITION_TOP;
								actualAnchorPoint = evalAnchorPoint;	
							}
							
							break;
						case TAIL_POSITION_TOP_RIGHT:
							// See first case.
							if (evalAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_TOP_RIGHT) > 0 &&
									evalAnchorPoint.y + getHeightByTailPosition(TAIL_POSITION_TOP_RIGHT) < screen.height) {
								actualTailPosition = TAIL_POSITION_TOP_RIGHT;	
								actualAnchorPoint = evalAnchorPoint;	
							}
							
							break;
						case TAIL_POSITION_RIGHT:
							// See first case.
							if (evalAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_RIGHT) > 0 &&
									evalAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_RIGHT) / 2 > 0 &&
									evalAnchorPoint.y + getHeightByTailPosition(TAIL_POSITION_RIGHT) / 2 < screen.height) {
								actualTailPosition = TAIL_POSITION_RIGHT;
								actualAnchorPoint = evalAnchorPoint;
							}
							
							break;
						case TAIL_POSITION_BOTTOM_RIGHT:
							// See first case.
							if (evalAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_BOTTOM_RIGHT) > 0 &&
									evalAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_BOTTOM_RIGHT) > 0) {
								actualTailPosition = TAIL_POSITION_BOTTOM_RIGHT;
								actualAnchorPoint = evalAnchorPoint;
							}
							
							break;
						case TAIL_POSITION_BOTTOM:
							// See first case.
							if (evalAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_BOTTOM) / 2 > 0 &&
									evalAnchorPoint.x + getWidthByTailPosition(TAIL_POSITION_BOTTOM) / 2 < screen.width &&
									evalAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_BOTTOM) > 0) {
								actualTailPosition = TAIL_POSITION_BOTTOM;
								actualAnchorPoint = evalAnchorPoint;
							}
							
							break;
					}
					
					// If the actualTailPosition and actualAnchorPoint have been set, we have found
					// an adequate tail position and there is no need to evaluate additional tail positions.
					if (actualTailPosition && actualAnchorPoint) {
						break;
					}
				}
				
				// If no adequate tail position was found, set them to defaults.
				if (!actualTailPosition && !actualAnchorPoint) {
					actualTailPosition = TAIL_POSITION_BOTTOM_LEFT;
					
					if (owner) {
						actualAnchorPoint = getAnchorPointByTailPosition(TAIL_POSITION_BOTTOM_LEFT);
					} else {
						actualAnchorPoint = _anchorPoint;
					}
				}
				
				// Reset flags.
				anchorPointChanged = false;
				contentChanged = false;
				preferredTailPositionChanged = false;
				forcePreferredTailPositionChanged = false;
				paddingChanged = false;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Set the actual skin sizes.
			tailSkin.setActualSize(getStyle('tailSize'), getStyle('tailSize'));
			bubbleSkin.setActualSize(bubbleWidth, bubbleHeight);
			
			// Reset the tail skin transform matrix.  We may be rotating it from
			// its native orientation after we adjust its position.
			tailSkin.transform.matrix = new Matrix();
			
			// If the tail skin is at the edge of the callout component and is then rotated
			// 45 degrees, a peak of the skin will be outside the callout component area.  This is
			// essentially equal to the diameter of the skin (one corner to the opposite corner) minus
			// the skin's width divided by two.
			var tailNudgeForRotation:Number = (tailDiameter - getStyle('tailSize')) / 2;
			
			switch (actualTailPosition) {
				case TAIL_POSITION_BOTTOM_LEFT:
					// Because we've found the bottom-left tail position to be adequate, we will
					// move the callout to right above and to the right of the anchor point.
					move(actualAnchorPoint.x, actualAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_BOTTOM_LEFT));
					// Move the tail to the bottom-left corner of the callout component.
					tailSkin.move(0, unscaledHeight - tailSkin.height);
					// Move the bubble skin to the top right corner of the callout component.
					bubbleSkin.move(getTailOccupiedSpace(TAIL_POSITION_BOTTOM_LEFT), 0);
					break;
				case TAIL_POSITION_LEFT:
					// See first case for more info.
					move(actualAnchorPoint.x, actualAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_LEFT) / 2);
					tailSkin.move(tailNudgeForRotation, (unscaledHeight / 2) - (tailSkin.height / 2));
					rotateTail(45);
					bubbleSkin.move(getTailOccupiedSpace(TAIL_POSITION_LEFT), 0);
					break;
				case TAIL_POSITION_TOP_LEFT:
					// See first case for more info.
					move(actualAnchorPoint.x, actualAnchorPoint.y);
					tailSkin.move(0, 0);
					rotateTail(90);
					bubbleSkin.move(getTailOccupiedSpace(TAIL_POSITION_TOP_LEFT), getTailOccupiedSpace(TAIL_POSITION_TOP_LEFT));
					break;
				case TAIL_POSITION_TOP:
					// See first case for more info.
					move(actualAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_TOP) / 2, actualAnchorPoint.y);
					tailSkin.move((unscaledWidth / 2) - (tailSkin.width / 2), tailNudgeForRotation);
					rotateTail(135);
					bubbleSkin.move(0, getTailOccupiedSpace(TAIL_POSITION_TOP));
					break;
				case TAIL_POSITION_TOP_RIGHT:
					// See first case for more info.
					move(actualAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_TOP_RIGHT), actualAnchorPoint.y);
					tailSkin.move(unscaledWidth - tailSkin.width, 0);
					rotateTail(180);
					bubbleSkin.move(0, getTailOccupiedSpace(TAIL_POSITION_TOP_RIGHT));
					break;
				case TAIL_POSITION_RIGHT:
					// See first case for more info.
					move(actualAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_RIGHT), actualAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_RIGHT) / 2);
					tailSkin.move(unscaledWidth - tailSkin.width - tailNudgeForRotation, (unscaledHeight / 2) - (tailSkin.height / 2));
					rotateTail(225);
					bubbleSkin.move(0, 0);
					break;
				case TAIL_POSITION_BOTTOM_RIGHT:
					// See first case for more info.
					move(actualAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_BOTTOM_RIGHT), actualAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_BOTTOM_RIGHT));
					tailSkin.move(unscaledWidth - tailSkin.width, unscaledHeight - tailSkin.height);
					rotateTail(270);
					bubbleSkin.move(0, 0);
					break;
				case TAIL_POSITION_BOTTOM:
					// See first case for more info.
					move(actualAnchorPoint.x - getWidthByTailPosition(TAIL_POSITION_BOTTOM) / 2, actualAnchorPoint.y - getHeightByTailPosition(TAIL_POSITION_BOTTOM));
					tailSkin.move((unscaledWidth / 2) - (tailSkin.width / 2), unscaledHeight - tailSkin.height - tailNudgeForRotation);
					rotateTail(315);
					bubbleSkin.move(0, 0);
					break;
			}
			
			// Set and move the content
			_content.setActualSize(_content.getExplicitOrMeasuredWidth(), _content.getExplicitOrMeasuredHeight());
			_content.move(bubbleSkin.x + getStyle('paddingLeft'), bubbleSkin.y + getStyle('paddingTop'));
			
			// Use our alpha layer to remove some of the
			// opacity of underlying layers (the bubble and tail skins)
			// if a backgroundAlpha was set. Also resize the alpha layer
			// to fill to full size of the component.
			alphaLayer.alpha = 1 - getStyle('backgroundAlpha');
			alphaLayer.width = unscaledWidth;
			alphaLayer.height = unscaledHeight;
			
			// If a backgroundAlpha lower than 1 was specified, that
			// means we are using our alphaLayer to actually do something.
			// Since alphaLayer uses an erase blend mode, we must
			// turn cacheAsBitmap to true for it to be supported.
			if (getStyle('backgroundAlpha') < 1) {
				this.cacheAsBitmap = true;
			}
		}
		
		/**
		 * @protected
		 * Get the measured and minimum dimensions of the callout.
		 */
		override protected function measure():void {
			super.measure();
			measuredWidth = minWidth = getWidthByTailPosition(actualTailPosition);
			measuredHeight = minHeight = getHeightByTailPosition(actualTailPosition); 
		}
		
		/**
		 * Pops up the callout using the PopUpManager.
		 * 
		 * @param parent DisplayObject to be used for determining which SystemManager's layers
		 * to use.
		 */
		public function show(owner:DisplayObjectContainer):void {
			if (!isPopUp) {
				this.owner = owner;
				PopUpManager.addPopUp(this, owner);
			}
		}
		
		/**
		 * Hides the callout.
		 */
		public function hide():void {
			if (isPopUp) {
				PopUpManager.removePopUp(this);
			}
		}
		
		/**
		 * @protected
		 * Gets the width of the callout given a specific tail position.
		 * 
		 * @param tailPosition The tail position to use when evaluating the width.
		 * @returns The callout width given the specified tail position.
		 */
		protected function getWidthByTailPosition(tailPosition:String):Number {
			switch (tailPosition) {
				case TAIL_POSITION_TOP_RIGHT:
				case TAIL_POSITION_RIGHT:
				case TAIL_POSITION_BOTTOM_RIGHT:
				case TAIL_POSITION_BOTTOM_LEFT:
				case TAIL_POSITION_LEFT:
				case TAIL_POSITION_TOP_LEFT:
					return bubbleWidth + getTailOccupiedSpace(tailPosition);
				default:
					return bubbleWidth;
			}
		}
		
		/**
		 * @protected
		 * Gets the height of the callout given a specific tail position.
		 * 
		 * @param tailPosition The tail position to use when evaluating the height.
		 * @returns The callout height given the specified tail position.
		 */
		protected function getHeightByTailPosition(tailPosition:String):Number {
			switch (tailPosition) {
				case TAIL_POSITION_TOP_LEFT:
				case TAIL_POSITION_TOP:
				case TAIL_POSITION_TOP_RIGHT:
				case TAIL_POSITION_BOTTOM_RIGHT:
				case TAIL_POSITION_BOTTOM:
				case TAIL_POSITION_BOTTOM_LEFT:
					return bubbleHeight + getTailOccupiedSpace(tailPosition);
				default:
					return bubbleHeight;
			}
		}
		
		/**
		 * @protected
		 * 
		 * Gets the space occupied by the tail given a specific tail position.
		 * "Space" essentially is essentially the distance between the edge of the
		 * callout and the bubble due to the area needed for the tail.
		 * 
		 * This calculation also takes into account the tail offset if it exists.
		 * 
		 * @param tailPosition The tail position to be evaluated.
		 * @return The space taken by the tail (or the distance between the edge of the
		 * callout and the bubble due to the area needed for the tail).
		 */
		protected function getTailOccupiedSpace(tailPosition:String):Number {
			switch (tailPosition) {
				case TAIL_POSITION_TOP:
				case TAIL_POSITION_RIGHT:
				case TAIL_POSITION_BOTTOM:
				case TAIL_POSITION_LEFT:
					return (tailDiameter / 2) + getStyle('tailOffset');
				default:
					// Because the tail is on the corner, the space taken by the tail does not directly correlate
					// to the space between the edge of the callout and the bubble taken by the tail.  The tail
					// moves diagonally.  Crack out your trusty pythagorean theorem and you can find out how movement
					// in a diagonal direction translates into needed space vertically and horizontally.
					var spaceTakenFromTailOffset:Number = Math.sqrt(Math.pow(getStyle('tailOffset'), 2) / 2);
					
					// Because we just square-rooted our tail offset, that means we long our sign (+/-).  Let's
					// restore it.
					if (getStyle('tailOffset') < 0) {
						spaceTakenFromTailOffset *= -1;
					}
					
					// Return half the tail width/hight plus any spake taken by the tail offset.
					return (getStyle('tailSize') / 2) + spaceTakenFromTailOffset;
			}
		}
		
		/**
		 * @protected
		 * Gets the distance from one corner of the tail skin to the other corner.  Remember, this is
		 * just the skin container, not whatever the skin actually shows.  Refer to the pythagorean theorum
		 * for more info.
		 */
		protected function get tailDiameter():Number {
			return Math.sqrt(Math.pow(getStyle('tailSize'), 2) + Math.pow(getStyle('tailSize'), 2));
		}
		
		/**
		 * @protected
		 * The width of the content placed in the callout bubble.
		 * 
		 * @default 0
		 */
		protected function get contentWidth():Number {
			return (_content) ? _content.getExplicitOrMeasuredWidth() : 0;
		}
		
		/**
		 * @protected
		 * The height of the content placed in the callout bubble.
		 * 
		 * @default 0
		 */
		protected function get contentHeight():Number {
			return (_content) ? _content.getExplicitOrMeasuredHeight() : 0;
		}
		
		/**
		 * @protected
		 * The width of the bubble.  Includes padding and content dimensions.
		 */
		protected function get bubbleWidth():Number {
			return getStyle('paddingLeft') + _content.getExplicitOrMeasuredWidth() + getStyle('paddingRight');
		}
		
		/**
		 * @protected
		 * The height of the bubble.  Includes padding and content dimensions.
		 */
		protected function get bubbleHeight():Number {
			return getStyle('paddingTop') + _content.getExplicitOrMeasuredHeight() + getStyle('paddingBottom');
		}
		
		/**
		 * @protected
		 * Rotates the tail a specified number of degrees.
		 * 
		 * @param degrees The number of degrees to rotate the tail skin.
		 */
		protected function rotateTail(degrees:Number):void {
			var matrix:Matrix = tailSkin.transform.matrix;
			rotateAroundInternalPoint(matrix, getStyle('tailSize') / 2, getStyle('tailSize') / 2, degrees);
			tailSkin.transform.matrix = matrix;
		}
		
		/**
		 * @private
		 * Gets the anchor point of the callout based of the tail position and the display object
		 * that "owns" the callout.  For example, if the tail position is on the bottom-left,
		 * this will return the point at the top-right of the owner display object.  This makes
		 * the callout appear as if it is extending naturally from the owner display object.
		 */
		protected function getAnchorPointByTailPosition(tailPosition:String):Point
		{
			var ownerBounds:Rectangle;
			
			// See the documentation for the useInternalBoundPositioning style
			// to understand what we're doing here.
			if (getStyle('useInternalBoundPositioning'))
			{
				// The unrotated, unscaledWidth of the owner.  This is used so we can get a point
				// within the owner's coordinate space and then convert it to the global 
				// coordinate space.
				ownerBounds = owner.getBounds(owner);
				var pointWithinOwner:Point;
				switch (tailPosition) {
					default:
					case TAIL_POSITION_BOTTOM_LEFT:
						pointWithinOwner = new Point(ownerBounds.width, 0);
						break;
					case TAIL_POSITION_LEFT:
						pointWithinOwner = new Point(ownerBounds.width, ownerBounds.height / 2);
						break;
					case TAIL_POSITION_TOP_LEFT:
						pointWithinOwner = new Point(ownerBounds.width, ownerBounds.height);
						break;
					case TAIL_POSITION_TOP:
						pointWithinOwner = new Point(ownerBounds.width / 2, ownerBounds.height);
						break;
					case TAIL_POSITION_TOP_RIGHT:
						pointWithinOwner = new Point(0, ownerBounds.height);
						break;
					case TAIL_POSITION_RIGHT:
						pointWithinOwner = new Point(0, ownerBounds.height / 2);
						break;
					case TAIL_POSITION_BOTTOM_RIGHT:
						pointWithinOwner = new Point(0, 0);
						break;
					case TAIL_POSITION_BOTTOM:
						pointWithinOwner = new Point(ownerBounds.width / 2, 0);
						break;
				}
				return owner.localToGlobal(pointWithinOwner);
			}
			else
			{
				ownerBounds = owner.getBounds(stage);
				switch (tailPosition) {
					default:
					case TAIL_POSITION_BOTTOM_LEFT:
						return new Point(
								ownerBounds.x + ownerBounds.width, 
								ownerBounds.y);
					case TAIL_POSITION_LEFT:
						return new Point(
								ownerBounds.x + ownerBounds.width, 
								ownerBounds.y + ownerBounds.height / 2);
					case TAIL_POSITION_TOP_LEFT:
						return new Point(
								ownerBounds.x + ownerBounds.width, 
								ownerBounds.y + ownerBounds.height);
					case TAIL_POSITION_TOP:
						return new Point(
								ownerBounds.x + ownerBounds.width / 2,
								ownerBounds.y + ownerBounds.height);
					case TAIL_POSITION_TOP_RIGHT:
						return new Point(
								ownerBounds.x,
								ownerBounds.y + ownerBounds.height);
					case TAIL_POSITION_RIGHT:
						return new Point(
								ownerBounds.x,
								ownerBounds.y + ownerBounds.height / 2);
					case TAIL_POSITION_BOTTOM_RIGHT:
						return new Point(
								ownerBounds.x,
								ownerBounds.y);
					case TAIL_POSITION_BOTTOM:
						return new Point(
								ownerBounds.x + ownerBounds.width / 2,
								ownerBounds.y);
				}
			}
			
			return new Point();
		}
		
		/**
		 * @private
		 * Rotates an element around an internal (local) point.
		 */
		private function rotateAroundInternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void {	
			var p:Point = m.transformPoint(new Point(x, y));
			rotateAroundExternalPoint(m, p.x, p.y, angleDegrees);
		}
 
 		/**
		 * @private
		 * Rotates an element around an external (global) point.
		 */
		private function rotateAroundExternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void {
			m.translate(-x, -y);
			m.rotate(angleDegrees*(Math.PI/180));
			m.translate(x, y);
		}
	}
}