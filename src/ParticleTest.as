package {
    import openfl.display.Sprite;
    import openfl.events.Event;
    import openfl.display.Graphics;
    [ SWF( frameRate = 60 ) ]
    public class ParticleTest extends Sprite {
        public function ParticleTest() {
            var sw:int = stage.stageWidth;
            var sh:int = stage.stageHeight;
            var balls:Vector.<Ball> = new <Ball>[]
            var curves:Vector.<Curve> = new <Curve>[new Curve, new Curve, new Curve, new Curve]
            var gravity:Number = 0.7
            
            stage.addEventListener("mouseDown",function():void{for each(var c:Curve in curves)c.reset()})
            
            addEventListener( Event.ENTER_FRAME, ENTER_FRAME )
            function ENTER_FRAME( e:Event ):void {
                balls.push(new Ball)
                var ball:Ball, curve:Curve
                graphics.clear()
                for each(curve in curves) { drawCurve(graphics, curve) }
                for( var i:int = 0 ; i < balls.length ; i++ ){
                    ball = balls[i]
                    ball.x += ball.vx , ball.y += ball.vy
                    
                    var t:Number, theT:Number=2, theCurve:Curve
                    for each(curve in curves){
                        t = curve.getT( ball.prevx, ball.prevy, ball.x, ball.y)
                        if(t < theT) { theT = t , theCurve = curve }
                    }
                    if( 0 <= theT && theT <= 1 ) {
                        ball.resolve(theCurve, theT)
                    }
                    if( ball.y>sh || ball.x<0 || ball.x>sw ) {
                        balls.splice(i, 1)
                    }
                    drawBall(graphics, ball)
                    ball.prevx = ball.x
                    ball.prevy = ball.y
                    ball.vy += gravity
                }
            }
            
            function drawBall(g:Graphics, b:Ball):void {
                g.lineStyle( 3, 0xFF0000 )
                g.moveTo( b.prevx, b.prevy )
                g.lineTo( b.x, b.y )
            }
            function drawCurve(g:Graphics, c:Curve):void {
                g.lineStyle( 3, 0x000000 )
                g.moveTo( c.p0x, c.p0y )
                g.curveTo( c.p1x, c.p1y, c.p2x, c.p2y )
            }
        }
        public static function linear( start:Number, end:Number, t:Number ):Number
        {
            return start + ( end-start )*t;
        }
        public static function bezier( values:Array, t:Number ):Number
        {
            if( values.length < 2 ) return NaN;
            if( values.length == 2 ) return ParticleTest.linear( values[ 0 ], values[ 1 ], t );
            var postValues:Array = values.concat();
            var i:int;
            while( postValues.length > 1 )
            {
                var resultValues:Array = new Array;
                var count:int = postValues.length-1;
                for ( i = 0; i<count; ++i )
                {
                    resultValues.push( ParticleTest.linear( postValues[ i ], postValues[ i+1 ], t ) );
                }
                postValues = resultValues;
            }
            return postValues[ 0 ];
        }
    }
}

class Curve {
    private var _p0x:Number
    private var _p0y:Number
    private var _p1x:Number
    private var _p1y:Number
    private var _p2x:Number
    private var _p2y:Number
    public function get p0x(): Number { return _p0x; }
    public function get p0y(): Number { return _p0y; }
    public function get p1x(): Number { return _p1x; }
    public function get p1y(): Number { return _p1y; }
    public function get p2x(): Number { return _p2x; }
    public function get p2y(): Number { return _p2y; }
    public function set p0x(v: Number): void { _p0x = v; }
    public function set p0y(v: Number): void { _p0y = v; }
    public function set p1x(v: Number): void { _p1x = v; }
    public function set p1y(v: Number): void { _p1y = v; }
    public function set p2x(v: Number): void { _p2x = v; }
    public function set p2y(v: Number): void { _p2y = v; }

    public function Curve() {
        reset()
    }
    
    public function reset():void {
        p0x = Math.random()*200 , p0y = Math.random()*100+150
        p1x = Math.random()*550 , p1y = Math.random()*400
        p2x = Math.random()*200+350 , p2y = Math.random()*100+150
    }
    
    // 0~1이면 충돌. NaN이면 비충돌
    public function getT(slx:Number,sly:Number, elx:Number,ely:Number):Number {
        // 선분이 수직일때 0으로 나누게 되는 문제를 편법으로 해결. 0.01을 더함
        if( slx == elx ) slx += 0.01
        var px:Number = p0x - 2*p1x + p2x, py:Number = p0y - 2*p1y + p2y
        var qx:Number = -2*p0x + 2*p1x, qy:Number = -2*p0y + 2*p1y
        var rx:Number = p0x, ry:Number = p0y
        var ax:Number = elx - slx, ay:Number = ely - sly
        var bx:Number = slx, by:Number = sly
        var X:Number = ay*px - ax*py
        var Y:Number = ay*qx - ax*qy
        var Z:Number = ay*rx - ay*bx - ax*ry + ax*by
        var d:Number = Y*Y - 4*X*Z
        if( d < 0 ) return NaN
        var t1:Number, s1:Number
        // d가 0일 경우는 거의 없다. 그래도 처리
        if( d == 0 ) {
            t1 = -Y/( 2*X )
            if( 0>t1 || 1<t1 ) {
                return NaN;
            } else {
                s1 = ( px*t1*t1 + qx*t1 + rx - bx )/ax
                if( 0<=s1 )if( s1<=1 ) return t1
                return NaN;
            }
        }
        var t2:Number, s2:Number
        var d2:Number = Math.sqrt( d )
        t1 = ( -Y + d2 )/( 2*X )
        t2 = ( -Y - d2 )/( 2*X )
        s1 = ( 0>t1 || 1<t1 )? 2 : ( px*t1*t1 + qx*t1 + rx - bx )/ax
        s2 = ( 0>t2 || 1<t2 )? 2 : ( px*t2*t2 + qx*t2 + rx - bx )/ax
        // 일반적인 처리
        if( s1 < s2 )if( 0<=s1 )if( s1<=1 ) return t1
        if( s2 < s1 )if( 0<=s2 )if( s2<=1 ) return t2
        // 둘중 하나가 음수일때 처리.
        // 베지어 곡선의 움푹한 부분에 선분이 들어가 있을 경우에 이런 상황이 발생한다.
        if( s1 < 0 )if( 0<=s2 )if( s2<=1 ) return t2
        if( s2 < 0 )if( 0<=s1 )if( s1<=1 ) return t1
        return NaN
    }

}
class Ball {
    private var _prevx:Number, _prevy:Number // 이전 위치
    private var _x:Number, _y:Number // 현재 위치
    private var _vx:Number, _vy:Number // 속도

    public function get prevx(): Number { return _prevx; }
    public function get prevy(): Number { return _prevy; }
    public function get x(): Number { return _x; }
    public function get y(): Number { return _y; }
    public function get vx(): Number { return _vx; }
    public function get vy(): Number { return _vy; }
    public function set prevx(v: Number): void { _prevx = v; }
    public function set prevy(v: Number): void { _prevy = v; }
    public function set x(v: Number): void { _x = v; }
    public function set y(v: Number): void { _y = v; }
    public function set vx(v: Number): void { _vx = v; }
    public function set vy(v: Number): void { _vy = v; }

    public function Ball() {
        reset()
    }
    
    public function resolve(curve:Curve, t:Number):void {
        var dx:Number = (2*curve.p0x - 4*curve.p1x + 2*curve.p2x)*t + (-2*curve.p0x + 2*curve.p1x)
        var dy:Number = (2*curve.p0y - 4*curve.p1y + 2*curve.p2y)*t + (-2*curve.p0y + 2*curve.p1y)
        var d:Number = Math.sqrt(dx*dx + dy*dy)
        dx /= d , dy /= d
        var K:Number = 2 * (this._vx*dx + this._vy*dy)
        
        this._x = ParticleTest.bezier( [ curve.p0x, curve.p1x, curve.p2x ], t )
        this._y = ParticleTest.bezier( [ curve.p0y, curve.p1y, curve.p2y ], t )
        this._vx = (K*dx - this._vx) * 0.7 // 속력 감쇠
        this._vy = (K*dy - this._vy) * 0.7 // 속력 감쇠
        
        //this._x += dy , this._y += -dx // 보정
        if(this._vy < 0) { this._x -= -dy ; this._y -= dx } else this._x += dy , this._y += -dx
    }
    
    public function reset():void {
        _vx = Math.random()*10-5 , _vy = Math.random()*10-5
        _prevx = _x = Math.random()*550
        _prevy = _y = 0
    }
}
