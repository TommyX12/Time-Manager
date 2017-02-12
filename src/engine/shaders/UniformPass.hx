package engine.shaders;

import openfl.gl.*;
import openfl.display.OpenGLView;
import flash.geom.*;

class UniformPass extends OpenGLView {

	public var func:Dynamic;
	
	public function new(updateFunc:Dynamic)
	{
        super();
		
		func = updateFunc;
		
		//this.render = _render;
    }
 
	//public function _render() {
    override public function render(rect : Rectangle) {
		func();
    }
}