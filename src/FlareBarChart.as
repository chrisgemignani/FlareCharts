package {
  import flare.vis.data.ScaleBinding;
  
  import flash.text.TextFormat;
  
  import org.juicekit.events.JuiceKitEvent;
  import org.juicekit.flare.util.palette.ColorPalette;
  import org.juicekit.visual.controls.FlareControlBase;

  public class FlareBarChart extends FlareControlBase {
    import flare.animate.Transitioner;
    import flare.display.TextSprite;
    import flare.scale.ScaleType;
    import flare.util.Shapes;
    import flare.util.Strings;
    import flare.vis.Visualization;
    import flare.vis.controls.TooltipControl;
    import flare.vis.data.Data;
    import flare.vis.data.DataSprite;
    import flare.vis.events.TooltipEvent;
    import flare.vis.operator.encoder.ColorEncoder;
    import flare.vis.operator.layout.AxisLayout;

    import flash.events.MouseEvent;

    /** The tooltip format string. */
    private static const _tipText:String = "<b>Category</b>: {0}<br/>" + "<b>Position</b>: {1}<br/>" + "<b>Value</b>: {2}";

    public function FlareBarChart() {
      super();
    }
    
    
    private var _initialized:Boolean = false;
    
    /*
    override public function set data(v:Object):void {
      vis.data = v as Data;
      
      if (!_initialized) {
        initVisualization();
        _initialized = true;
      } else {
      }
      (axisLayout.xScale as ScaleBinding).preferredMax = 400;
      vis.update();
    }
    override public function get data():Object {
      return vis.data;
    }
    */
    

    /**
     * Sets the data value to a <code>Data</code> data
     * object used for rendering position and color
     * of the bars.
     *
     * @see flare.vis.data.Data
     */
    override public function set data(value:Object):void {
      value = value is Data ? value : null;
      newDataLoaded = value !== this.data;
      if (newDataLoaded) {
        vis.data = value as Data;
        super.data = value;
        dispatchEvent(new JuiceKitEvent(JuiceKitEvent.DATA_ROOT_CHANGE));
      }

      if (!_initialized) {
        initVisualization();
        _initialized = true;
      } else {
      }
      (axisLayout.xScale as ScaleBinding).preferredMax = 100;      
    }


    /**
     * @private
     */
    override public function get data():Object {
      return super.data;
    }
    
    
	// listener function for changing the x-axis scale
	  public function setScale(v:String):void {
	    vis.continuousUpdates = true;
			var type:String = v;
			var xb:ScaleBinding = AxisLayout(vis.operators[0]).xScale;
			xb.scaleType = v;
		}
    

    public function setXMax(v:Number):void {
      var xb:ScaleBinding = AxisLayout(vis.operators[0]).xScale;      
      xb.preferredMax = v;
      invalidateProperties();
    }

    public var axisLayout:AxisLayout = new AxisLayout();
    
    public function set palette(v:String):void {
      var ce:ColorEncoder = vis.operators.getOperatorAt(COLORENCODER_INDEX) as ColorEncoder;
      var p:ColorPalette = ColorPalette.getPaletteByName(v, ce.palette.values.length);
      ce.palette = p;
      invalidateProperties();
    }

    public const COLORENCODER_INDEX:int = 1;

    override protected function initVisualization():void {
      if (vis.data != null) {
        vis.operators.clear();
        vis.controls.clear();
        axisLayout.xField = 'data.x';
        axisLayout.yField = 'data.y';
        axisLayout.xStacked = true;
        axisLayout.yStacked = false;
        vis.operators.add(axisLayout);
        vis.operators.add(new ColorEncoder("data.s", "nodes", "fillColor", ScaleType.CATEGORIES, ColorPalette.getPaletteByName('hot', 44).reverse()));
        vis.xyAxes.yAxis.showLines = false;
        
        vis.update();
        addChild(vis);
        vis.x = 50;
        vis.y = 20;
        vis.xyAxes.xAxis.labelTextFormat = new TextFormat('Arial', 10, 0x000000);
        vis.xyAxes.yAxis.labelTextFormat = new TextFormat('Arial', 10, 0x000000);
        
        vis.update();
          
        // add tooltip showing data values
        vis.controls.add(new TooltipControl(DataSprite, null, function(evt:TooltipEvent):void {
            var d:DataSprite = evt.node;
            TextSprite(evt.tooltip).htmlText = Strings.format(_tipText, d.data.s, d.data.y, d.data.x);
          }));
      }
    }
    
    private const OP_IX_COLOR:int = 1;
    private const OP_IX_LAYOUT:int = 0;
    
    private var newDataLoaded:Boolean = false;
    private var colorPalette:ColorPalette = ColorPalette.getPaletteByName('Blues');
    private var _colorEncodingField:String = '';
    private var _colorEncodingUpdated:Boolean = false;
    private var _layoutChanged:Boolean = false;
    
    private function styleNodes():void {
      vis.data.nodes.setProperties({shape: Shapes.HORIZONTAL_BAR, lineWidth: 1.0, lineAlpha: 0, lineColor: 0xffffff, size: 2 / vis.data.nodes.length});      
    }
    
    public function getLayout():AxisLayout {
      return vis.operators.getOperatorAt(OP_IX_LAYOUT) as AxisLayout;
    }
    
    
    
    override protected function commitProperties():void {
      trace('fbs: commitProperties', vis.data.length);
      super.commitProperties();

      var updateVis:Boolean = false;

      if (vis) {
        const colorEncoder:ColorEncoder = vis.operators.getOperatorAt(OP_IX_COLOR) as ColorEncoder;
        trace('fbs: colorEncoder.ssource', colorEncoder.source);
        const layout:AxisLayout = vis.operators.getOperatorAt(OP_IX_LAYOUT) as AxisLayout;
        if (layout != null) {
          trace('fbs: layout', layout.xField, ' ', layout.yField);          
        }

        if (_colorEncodingUpdated) {
          _colorEncodingUpdated = false;

          colorEncoder.palette = colorPalette;
          styleNodes();
          colorEncoder.source = asFlareProperty(_colorEncodingField);
//          setupColorEncoder(colorEncoder);

          updateVis = true;
        }

        if (_layoutChanged) {
          _layoutChanged = false;

          colorEncoder.palette = colorPalette;

          styleNodes();

          updateVis = true;
        }

        if (this.data is Data) {
          if (newDataLoaded) {
            newDataLoaded = false;            
            styleNodes();
            updateVis = true;
          }


          if (updateVis) {
            trace('fbs: updateVis');
            updateVisualization();
          }
        }
      }
    }
    

    public static function getData(N:int, M:int):Data {
      var data:Data = new Data();
      for (var i:uint = 0; i < N; ++i) {
        for (var j:uint = 0; j < M; ++j) {
          var s:String = String(i < 10 ? "0" + i : i);
          data.addNode({y: s, s: j, x: int(1 + 10 * Math.random())});
        }
      }
      return data;
    }

    public static function updateData(data:Data):void {
      data.nodes.visit(function(d:DataSprite):void {
          d.data.x = int(1 + 10 * Math.random());
        });
    }

  }
}
