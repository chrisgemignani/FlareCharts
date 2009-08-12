package {
  import flare.util.Shapes;
  import flare.vis.axis.Axis;
  import flare.vis.operator.Operator;
  import flare.vis.operator.layout.AxisLayout;
  
  import org.juicekit.util.helper.CSSUtil;
  

  [Bindable]
  public class FlareBarChart2 extends FlareCategoryValueChart {
    public function FlareBarChart2() {
      super();
      super.shape = Shapes.HORIZONTAL_BAR;
      
    }
    
    // Invoke the class constructor to initialize the CSS defaults.
    classConstructor();


    private static function classConstructor():void {      
      CSSUtil.setDefaultsFor("FlareBarChart2",
        { fontColor: 0x333333
        , fontFamily: 'Arial'
        , fontSize: 12
        , fontWeight: 'normal'
        , fontStyle: 'normal'
        , textPosition: "top"
        , strokeAlpha: 1.0
        , strokeColor: 0x000000
        , strokeThickness: 0
        , encodedColorAlpha: 1.0
        , palette: 'hot'
        }
      );
    }

    override protected function get categoryWidth():Number {
      return vis.bounds.height;
    }
    /** The tooltip format string. */
    private var _tipText:String = "<b>Category</b>: {0}<br/>" + "<b>Position</b>: {1}<br/>" + "<b>Value</b>: {2}";

    override public function get xyAxesCategoryReverse():Boolean { return vis.xyAxes.yReverse }
    override public function set xyAxesCategoryReverse(v:Boolean):void { vis.xyAxes.yReverse = v }
    override public function get xyAxesValueReverse():Boolean { return vis.xyAxes.xReverse }
    override public function set xyAxesValueReverse(v:Boolean):void { vis.xyAxes.xReverse = v }
    
    override public function get categoryAxis():Axis { return vis.xyAxes.yAxis; }
    override public function get valueAxis():Axis { return vis.xyAxes.xAxis; }
    
   /**
    * Create the axis layout
    */
    override protected function createAxisLayout():Operator {
      return new AxisLayout(asFlareProperty(valueEncodingField), 
                            asFlareProperty(categoryEncodingField), 
                            true, 
                            false);
    }

  }
}