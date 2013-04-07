package  {
	import flash.display.Shape;
	import flash.display.DisplayObject;
    import flash.display.Graphics;
	
	public class AStar {
		private static const B:uint = 0;
		private static const P:uint = 1;
		private static const S:uint = 2;
		private static const E:uint = 3;
		private static const RED:uint = 0xFF0000;
		private static const GREEN:uint = 0x00FF00;
		private static const BLUE:uint = 0x0000FF;
		private static const YELLOW:uint = 0xFFFF00F;
		private static const SIZE:int = 50;
		private static const COL:int = 8;
		private static const ROW:int = 6;
		private static const COST1:int = 10; //vertical & horizontal
		private static const COST2:int = 14; //diagonal
		
		private static var map_:Array;
		private var shape_:Shape;
		private var canvas_:Object;
		private var startPos_:Array;
		private var endPos_:Array;
		private var openList_:Array;
		private var closeList_:Array;
		
		public function AStar( _canvas:Object ) {
			// constructor code
			canvas_ = _canvas;
			map_ = new Array();
			map_[0] = [ P, P, P, P, P, P, P, P ];
			map_[1] = [ P, P, P, P, B, P, P, P ];
			map_[2] = [ P, P, S, P, B, P, E, P ];
			map_[3] = [ P, P, P, P, B, P, P, P ];
			map_[4] = [ P, P, P, P, P, P, P, P ];
			map_[5] = [ P, P, P, P, P, P, P, P ];
			
			startPos_ = new Array();
			startPos_ = [ 2, 2 ];
			endPos_ = new Array();
			endPos_ = [ 6, 2 ];
			
			shape_ = new Shape(); 
			canvas_.addChild(shape_);
		}
		
		public function createTrace():Array{
            var round:int = 0
			openList_ = new Array();
			closeList_ = new Array();
			var startNode:AStarNode = new AStarNode( startPos_ );
			openList_.push( startNode );
			
			var destNode:AStarNode;
			while( true ){
				var curNode:AStarNode = openList_.shift();
				closeList_.push( curNode );
				if( curNode.pos_[0] == endPos_[0] && curNode.pos_[1] == endPos_[1] ){
					destNode = curNode;
					break;
				}
				for( var x:int=-1; x<= 1; x++ ){
					for( var y:int=-1; y<=1; y++ ){
						var pos:Array = new Array( curNode.pos_[0] + x, curNode.pos_[1] + y );
						if( isValidPos( curNode.pos_, pos ) ){
							var node:AStarNode = checkOnList( openList_, pos );
							if( node ){
								updateNode( node, curNode );
							}else{
								var newNode:AStarNode = new AStarNode( pos, curNode );
								openList_.push( newNode );
							}
						}
					}
				}
				if( openList_.length <= 0 ){
					break;
				}
				openList_.sort( sortOnScoreF );
                round++;
                if( round > 100 ){
                    break;
                }
			}
            trace("DBG (createTrace) round: ", round);
			if( !destNode ){
                trace("ERR (createTrace) no destNode");
				return null;
			}
			var myTrace:Array = new Array();
            var node:AStarNode = destNode;
			while( node != startNode ){
				myTrace.unshift( node );
				node = AStarNode( node.parent_ );
			}
			myTrace.unshift( startNode );
			return myTrace;
		}

		public function createTrace2():Array{
			var myTrace:Array = new Array();
			myTrace[0] = [ 2, 2 ];
			myTrace[1] = [ 3, 3 ];
			myTrace[2] = [ 3, 4 ];
			myTrace[3] = [ 4, 4 ];
			myTrace[4] = [ 5, 4 ];
			myTrace[5] = [ 6, 3 ];
			myTrace[6] = [ 6, 2 ];
            //return null;
			return myTrace;
		}
		
		public function drawMap(){
			for( var y:uint=0; y< ROW; y++ ){
				for( var x:uint=0; x<COL; x++ ){
					if( map_[y][x] == P ){
						shape_.graphics.beginFill(GREEN, 0.5); 
					}else if( map_[y][x] == B ){
						shape_.graphics.beginFill(BLUE, 0.5); 
					}else{
						shape_.graphics.beginFill(YELLOW, 0.5); 
					}
					shape_.graphics.drawRect(x*SIZE, y*SIZE, SIZE-1, SIZE-1); 
				}
			}
			shape_.graphics.endFill();
			var myTrace:Array = createTrace();
            if( !myTrace ){
                trace( "[ERR] no trace found!" );
                return;
            }
			shape_.graphics.lineStyle(2, RED, 0.75);
			var pix:Array = pos2pix( myTrace[0].pos_ ); 
			shape_.graphics.moveTo( pix[0], pix[1] );
			for( var i in myTrace ){
				pix = pos2pix( myTrace[i].pos_ ); 
				shape_.graphics.lineTo( pix[0], pix[1] );
			}
		}
		
		private function sortOnScoreF( a:AStarNode, b:AStarNode ):Number{
			if( a.scoreG_ + a.scoreH_ < b.scoreG_ + b.scoreH_ ){
				return -1;
			}else if( a.scoreG_ + a.scoreH_ > b.scoreG_ + b.scoreH_ ){
				return 1;
			}else{
				return 0;
			}
		}
		
		private function isCrossCorner( _oriPos:Array, _pos:Array ):Boolean{
			var x1:int = _oriPos[0];
			var y1:int = _oriPos[1];
			var x2:int = _pos[0];
			var y2:int = _pos[1];
    		var dX:int = Math.abs( x1 - x2 );
    		var dY:int = Math.abs( y1 - y2 );
    		if( dX == 1 && dY == 1 ){
        		if( ( map_[y1][x2] == B ) || ( map_[y2][x1] == B ) ){
            		return true;
				}
			}
    		return false;
		}
		
		private function isValidPos( _oriPos:Array, _pos:Array ):Boolean{
			var x:int = _pos[0];
			var y:int = _pos[1];
    		if( _oriPos[0] == x && _oriPos[1] == y ){
        		return false;
			}
    		if( y>=ROW || x>=COL || y<0 || x<0 ){
       			return false;
			}
    		if( map_[y][x] == B ){
        		return false;
			}
    		if( isCrossCorner( _oriPos, _pos ) ){
        		return false;
			}
    		return true;
		}
		
		private function checkOnList( _list:Array, _p:Array ):AStarNode{
			for( var i in _list ){
				if( _list[i].pos_[0] == _p[0] && _list[i].pos_[1] == _p[1] ){
					return _list[i];
				}
			}
			return null;
		}
		
		private function updateNode( _node:AStarNode, _parent:AStarNode ){
			if( isCrossCorner( _parent.pos_, _node.pos_ ) ){
				return;
			}
			var scoreG:int = getScoreG( _parent, _node.pos_ );
    		if( scoreG >= _node.scoreG_ ){ 
				return; 
			}
    		_node.parent_ = _parent;
    		_node.scoreG_ = scoreG;
		}

		private function getScoreG( _parent:AStarNode, _pos:Array ):int{
    		var p0:Array = _parent.pos_;
    		var dX:int = Math.abs( p0[0] - _pos[0] );
    		var dY:int = Math.abs( p0[1] - _pos[1] );
    		if( ( dX == 1 && dY == 0 ) || ( dX == 0 && dY == 1 ) ){
				return COST1 + _parent.scoreG_;
			}else if( dX == 1 && dY == 1 ){
        		return COST2 + _parent.scoreG_;
			}else{
    			return 0;
			}
		}
		
		private function getScoreH( _p:Array ):int{
    		return ( ( Math.abs( _p[0] - endPos_[0] ) + Math.abs( _p[1] - endPos_[1] ) ) * COST1 );
		}
		
		private function pos2pix( _pos:Array ):Array{
			var pix:Array = new Array();
			pix[0] = _pos[0] * SIZE + SIZE/2;
			pix[1] = _pos[1] * SIZE + SIZE/2;
			return pix;
		}
	}
}
