// this class made by Davide Della Casa
// if, before executing a loop body, or when calling a function (to cover recursions) we
// find that more than a predetermined amount of time has passed since the last redraw, then
// we throw this error and we notify the user that the application may be unresponsive...
// This is so that we can unfreeze the browser, which is never a pleasant experience...

package processing.parser.statements {

public class UnresponsiveSketchError extends Error 
{ 
    public function UnresponsiveSketchError(message:String, errorID:int) 
    { 
        super(message, errorID); 
    } 
}
}
