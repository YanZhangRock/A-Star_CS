package  {
	public class AStarNode {
		public var pos_:Array;
		public var parent_:Object;
		public var scoreH_:int;
		public var scoreG_:int;
		
		public function AStarNode( _pos:Array, _parent:Object = null ) {
			// constructor code
			pos_ = _pos;
        	parent_ = _parent;
        	scoreH_ = 0;
        	scoreG_ = 0;
		}
	}
}
