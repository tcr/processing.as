package {
  import flash.display.*;
  import flash.text.*;
  import flash.events.*;
  import flash.utils.*;
  import flash.geom.*;

  // A simple draggable scrollbar that automatically updates its size
  // in response to changes in the size of a specified text field. 
  // Usage: 
  //   var theTextField:TextField = new TextField();
  //   someContainer.addChild(theTextField);
  //   var scrollbar:ScrollBar = new ScrollBar(theTextField);
  //   someContainer.addChild(scrollbar);
  public class ScrollBar extends Sprite {
    // The text field to which this scrollbar is applied
    private var t:TextField;
    // The current height of the text field. If the text field's height 
    // changes, we update the height of this scrollbar.
    private var tHeight:Number;
    // The background graphic for the scrollbar
    private var scrollTrack:Sprite;
    // The scrollbar's draggable "scroll thumb"
    private var scrollThumb:Sprite;
    // The scrollbar's width
    private var scrollbarWidth:int = 15;
    // The minimum height of the scrollbar's scroll thumb
    private var minimumThumbHeight:int = 10;
    // A flag indicating whether the user is currently dragging the 
    // scroll thumb
    private var dragging:Boolean = false;
    // A flag indicating whether the scrollbar should be redrawn at the next
    // scheduled screen update
    private var changed:Boolean = false;
    
    // Constructor.
    // @param textfield The TextField object to which to apply 
    //                  this scrollbar.
    public function ScrollBar (textfield:TextField) {
      // Store a reference to the TextField to which this 
      // scrollbar is applied
      t = textfield;
      // Remember the text field's height so that we can track it for 
      // changes that require a scrollbar redraw.
      tHeight = t.height;

      // Create the scrollbar background
      scrollTrack = new Sprite();
      scrollTrack.graphics.lineStyle();
      scrollTrack.graphics.beginFill(0x333333);
      scrollTrack.graphics.drawRect(0, 0, 1, 1);
      addChild(scrollTrack);

      // Create the draggable scroll thumb on the scrollbar
      scrollThumb = new Sprite();
      scrollThumb.graphics.lineStyle();
      scrollThumb.graphics.beginFill(0xAAAAAA);
      scrollThumb.graphics.drawRect(0, 0, 1, 1);
      addChild(scrollThumb);

      // Register an Event.SCROLL listener that will update the scrollbar
      // to match the current scroll position of the text field
      t.addEventListener(Event.SCROLL, scrollListener);

      // Register with scrollThumb for mouse down events, which will trigger
      // the dragging of the scroll thumb
      scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownListener);

      // Register to be notified when this object is added to or removed
      // from the display list (requires the custom helper class, 
      // StageDetector). When this object is added to the display list, 
      // register for stage-level mouse move and mouse up events that 
      // will control the scroll thumb's dragging operation.
      var stageDetector:StageDetector = new StageDetector(this);
      stageDetector.addEventListener(StageDetector.ADDED_TO_STAGE, 
                                     addedToStageListener);
      stageDetector.addEventListener(StageDetector.REMOVED_FROM_STAGE,
                                     removedFromStageListener);

      // Register to be notified each time the screen is about to be 
      // updated. Before each screen update, we check to see whether the
      // scrollbar needs to be redrawn. For information on the 
      // Event.ENTER_FRAME event, see Chapter ##, Programmatic Animation.
      addEventListener(Event.ENTER_FRAME, enterFrameListener);

      // Force an initial scrollbar draw.
      changed = true;
    }

    // Executed whenever this object is added to the display list
    private function addedToStageListener (e:Event):void {
      // Register for "global" mouse move and mouse up events
      stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
    }

    // Executed whenever this object is removed from the display list
    private function removedFromStageListener (e:Event):void {
      // Unregister for "global" mouse move and mouse up events
      stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
    }

    // Executed once for each screen update. This method checks 
    // whether any changes in the text field's scroll position, content,
    // or size have occurred since the last time the scrollbar was drawn.
    // If so, we redraw the scrollbar. By performing this "draw or not"
    // check once per screen-update only, we eliminate redundant calls to
    // updateScrollbar(), and we also avoid some Flash Player timing issues
    // with TextField.maxScrollV.
    private function enterFrameListener (e:Event):void {
      // If the text field has changed height, request a redraw of the
      // scrollbar
      if (t.height != tHeight) {
        changed = true;
        tHeight = t.height;
        // The height has changed, so stop any dragging operation in 
        // progress. The user will have to click again to start dragging
        // the scroll thumb once the scroll bar has been redrawn.
        if (dragging) {
          scrollThumb.stopDrag();
          dragging = false; 
        }
      }

      // If the scrollbar needs redrawing...
      if (changed) {
        // ...call the scrollbar drawing routine
        updateScrollbar();
        changed = false;
      } 
    }

    // Handles Event.SCROLL events
    private function scrollListener (e:Event):void {
      // In certain cases, when lines are removed from a text field,  
      // Flash Player dispatches two events: one for the reduction in 
      // maxScrollV (dispatched immediately) and one for the reduction in 
      // scrollV (dispatched several screen updates later). In such cases,
      // the scrollV property temporarily contains an erroneous value that
      // is greater than maxScrollV. As a workaround, we ignore the event 
      // dispatch for the change in maxScrollV, and wait for the event 
      // dispatch for the change in scrollV (otherwise, the rendered 
      // scrollbar would temporarily not match the text field's actual 
      // content).
      if (t.scrollV > t.maxScrollV) {
        return;
      }

      // If the user is not currently dragging the scrollbar's scroll 
      // thumb, then note that this scrollbar should be redrawn at the next 
      // scheduled screen update. (If the user is dragging the scroll thumb, 
      // then the scroll change that caused this event was the result of 
      // dragging the scroll thumb to a new position, so there's no need to 
      // update the scrollbar because the scroll thumb is already in the
      // correct position.)
      if (!dragging) {
        changed = true;
      }
    }

    // Sets the size and position of the scrollbar's background and scroll 
    // thumb in accordance with the associated text field's size and 
    // content. For information on the TextField properties scrollV, 
    // maxScrollV, and bottomScrollV, see Adobe's ActionScript Language 
    // Reference.
    public function updateScrollbar ():void {
      // Set the size and position of the scrollbar background.
      // This code always puts the scrollbar on the right of the text field.
      scrollTrack.x = t.x + t.width;  
      scrollTrack.y = t.y;
      scrollTrack.height = t.height;
      scrollTrack.width = scrollbarWidth;

      // Check the text field's number of visible lines
      var numVisibleLines:int = t.bottomScrollV - (t.scrollV-1);
      // If some of the lines in the text field are not currently visible...
      if (numVisibleLines < t.numLines) {
        // ... make the scroll thumb visible
        scrollThumb.visible = true;
        // Now set the scroll thumb's size
        //   The scroll thumb's height is the percentage of lines showing, 
        //   times the text field's height
        var thumbHeight:int = Math.floor(t.height * 
                                         (numVisibleLines/t.numLines));
        //   Don't set the scroll thumb height to anything less 
        //   than minimumThumbHeight
        scrollThumb.height = Math.max(minimumThumbHeight, thumbHeight);
        scrollThumb.width  = scrollbarWidth;
        
        // Now set the scroll thumb's position
        scrollThumb.x = t.x + t.width;
        //   The scroll thumb's vertical position is the number lines the 
        //   text field is scrolled, as a percentage, times the height of
        //   the "gutter space" in the scrollbar (the gutter space is the 
        //   height of the scroll bar minus the height of the scroll thumb).
        scrollThumb.y = t.y + (scrollTrack.height-scrollThumb.height) 
                        * ((t.scrollV-1)/(t.maxScrollV-1));
      } else {
        // If all lines in the text field are currently visible, hide the 
        // scrollbar's scroll thumb
        scrollThumb.visible = false;
      }
    }

    // Sets the text field's vertical scroll position to match the relative
    // position of the scroll thumb
    public function synchTextToScrollThumb ():void {
        var scrollThumbMaxY:Number = t.height-scrollThumb.height;
        var scrollThumbY:Number = scrollThumb.y-t.y;
        t.scrollV = Math.round(t.maxScrollV 
                               * (scrollThumbY/scrollThumbMaxY));
    }


    // Executed when the primary mouse button is depressed over the scroll
    // thumb
    private function mouseDownListener (e:MouseEvent):void {
      // Start dragging the scroll thumb. (The startDrag() method is 
      // inherited from the Sprite class.)
      var bounds:Rectangle = new Rectangle(t.x + t.width, 
                                       t.y,
                                       0, 
                                       t.height-scrollThumb.height);
      scrollThumb.startDrag(false, bounds);
      dragging = true;
    }

    // Executes when the primary mouse button is released (anywhere over, or
    // even outside of, Flash Player's display area)
    private function mouseUpListener (e:MouseEvent):void {
      // If the scroll thumb is being dragged, update the text field's 
      // vertical scroll position, then stop dragging the scroll thumb
      if (dragging) {
        synchTextToScrollThumb();
        scrollThumb.stopDrag();
        dragging = false;
      }
    }

    // Executes when the mouse pointer is moved (anywhere over Flash 
    // Player's display area)
    private function mouseMoveListener (e:MouseEvent):void {
      // If the scroll thumb is being dragged, set the text field's vertical
      // scroll position to match the relative position of the scroll thumb
      if (dragging) {
        synchTextToScrollThumb();
      }
    }
  }
}
