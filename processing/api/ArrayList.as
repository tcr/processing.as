package processing.api
{
	dynamic public class ArrayList extends Array {
		private var _type:*;
	
		public function ArrayList( size1:int = 0, size2:int = undefined, size3:int = undefined, type:* = null ):void
		{
		//processing.debugTextField.text += "\r building an ArrayList with size1: " + size1 + " , size2 = " + size2; //ddc
			// preserve type
//[TODO] do something with type!
			_type = type;
	
			// first dimension
			for ( var i = 0; i < size1; i++ )
			{
				this[i] = 0;
				
				// second dimension
				if ( size2 )
				{
					this[i] = [];			
					for ( var j = 0; j < size2; j++ )
					{
						this[i][j] = 0;
		
						// third dimension
						if ( size3 )
						{
							this[i][j] = [];
							for ( var k = 0; k < size3; k++ )
							{
								this[i][j][k] = 0;
							}
						}
					}
				}
			}
		}
		
		public function size():int
		{
			return this.length;
		}
		
		public function get( i ):*
		{
			return this[ i ];
		}
		
		public function remove( i ):*
		{
			return this.splice( i, 1 );
		}
		
		public function add( item ):void
		{
			for ( var i = 0; this[ i ] != undefined; i++ );
			this[ i ] = item;
		}
		
		public function clone():ArrayList
		{
			var a = new ArrayList( this.length );
			for ( var i = 0; i < this.length; i++ )
			{
				a[ i ] = this[ i ];
			}
			return a;
		}
	
		public function isEmpty():Boolean
		{
			return !this.length;
		}
	
		public function clear():void
		{
			this.length = 0;
		}
	}
}