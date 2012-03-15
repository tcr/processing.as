package processing.parser.statements
{
	import processing.parser.*;
	import flash.utils.getTimer; //ddc
	

	public class Loop implements IExecutable
	{
		public var condition:IExecutable;
		public var body:IExecutable;
	
		public function Loop(c:IExecutable, b:IExecutable)
		{
			condition = c;
			body = b;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			while (condition.execute(context)) {
				try {
					// execute body
					if (processing.TIMEKEEPING) { //ddc
						var theTimer:int = getTimer(); //ddc
						if (processing.TIMEKEEPINGDEBUGTEXT) processing.debugTextField.text = "excuting for body. Time since last refreshed: " + (theTimer-processing.lastDateOfRefresh); //ddc
						if (processing.TIMEKEEPINGDEBUGTEXT) processing.debugTextField.text += "\r checking if it takes more than " + processing.timeLimit; //ddc
						if ((theTimer-processing.lastDateOfRefresh) > processing.timeLimit) { //ddc
							if (processing.TIMEKEEPINGDEBUGTEXT) processing.debugTextField.text += "\r throwing an exception now"; //ddc
							// I don't catch the exception anywhere, cause I'm lazy and can't be bothered //ddc
							// to see where is the best place to catch it, so what I do instead // ddc
							// is I set a flag, and check the flag before executing the "draw" method // ddc
							processing.p.applet.removeAllEventListenersForMouseKeyboardAndEnterFrame();
							processing.p.applet.notifyUserOfSlowSketch();

							throw new UnresponsiveSketchError("it took a long time here while executing a loop", 1); //ddc
						} //ddc
						//processing.debugTextField.text = processing.debugTextField.text + "\r time: " + processing.lastDateOfRefresh; //ddc
						if (processing.TIMEKEEPINGDEBUGTEXT) processing.debugTextField.text += "\r time when last refreshed: " + processing.lastDateOfRefresh; //ddc
					}//ddc
					body.execute(context);
				} catch (b:Break) {
					// decrease level and rethrow if necessary
					if (--b.level)
						throw b;
					// else break loop
					break;
				} catch (c:Continue) {
					// decrease level and rethrow if necessary
					if (--c.level)
						throw c;
					// else continue loop
					continue;
				}
			}
		}
	}
}
