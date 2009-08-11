package {
  import flare.display.TextSprite;
  import flare.scale.ScaleType;
  import flare.util.Maths;
  import flare.util.Shapes;
  import flare.util.Strings;
  import flare.vis.axis.Axis;
  import flare.vis.axis.CartesianAxes;
  import flare.vis.controls.TooltipControl;
  import flare.vis.data.Data;
  import flare.vis.data.DataSprite;
  import flare.vis.data.ScaleBinding;
  import flare.vis.events.TooltipEvent;
  import flare.vis.operator.Operator;
  import flare.vis.operator.encoder.ColorEncoder;
  import flare.vis.operator.layout.AxisLayout;
  
  import flash.geom.Rectangle;
  import flash.text.TextFormat;
  
  import mx.collections.ArrayCollection;
  import mx.events.ResizeEvent;
  import mx.styles.StyleManager;
  
  import org.juicekit.events.JuiceKitEvent;
  import org.juicekit.flare.util.palette.ColorPalette;
  import org.juicekit.util.helper.CSSUtil;
  import org.juicekit.visual.controls.FlareControlBase;



  /**
   *  Sets the color of text.
   *
   *  @default 0x333333
   */
  [Style(name="fontColor", type="uint", format="Color", inherit="no")]
  
  /**
   *  Name of the font to use.
   *  Unlike in a full CSS implementation,
   *  comma-separated lists are not supported.
   *  You can use any font family name.
   *  If you specify a generic font name,
   *  it is converted to an appropriate device font.
   *
   *  @default "Arial"
   */
  [Style(name="fontFamily", type="String", inherit="yes")]
  
  /**
   *  Sets the height of the text, in pixels.
   *
   *  @default 12
   */
  [Style(name="fontSize", type="Number", format="Length", inherit="yes")]
  
  /**
   *  Determines whether the text is italic font.
   *  Recognized values are <code>"normal"</code> and <code>"italic"</code>.
   *
   *  @default "normal"
   */
  [Style(name="fontStyle", type="String", enumeration="normal,italic", inherit="yes")]
  
  /**
   *  Determines whether the text is boldface.
   *  Recognized values are <code>"normal"</code> and <code>"bold"</code>.
   *
   *  @default "normal"
   */
  [Style(name="fontWeight", type="String", enumeration="normal,bold", inherit="yes")]
  
  /**
   *  Determines the horizontal alignment of text within the cell.
   *  Possible values are <code>"left"</code>, <code>"center"</code>,
   *  or <code>"right"</code>.
   *
   *  @default "left"
   */
  [Style(name="textAlign", type="String", enumeration="left,center,right", inherit="yes")]


  /**
   * Determines the color palette to use
   * Possible values are <code>"hot"</code>, <code>"cool"</code>,
   * <code>"summer"</code>, <code>"winter"</code>, <code>"spring"</code>
   * <code>"autumn"</code>, <code>"bone"</code>, <code>"copper"</code>
   * or <code>"pink"</code>.
   *
   * @default "spectral"
   */
  [Style(name="palette", type="String", enumeration="hot,cool,summer,winter,spring,autumn,bone,copper,pink", inherit="yes")]



  /**
   * Determines the vertical position of text within the cell.
   * Possible values are <code>"top"</code>, <code>"middle"</code>,
   * or <code>"bottom"</code>.
   *
   * @default "top"
   */
  [Style(name="textPosition", type="String", enumeration="top,middle,bottom", inherit="yes")]

  /**
   * The alpha of the rectangles' stroke.
   *
   * @default [1.0]
   */
  [Style(name="strokeAlpha", type="Number", inherit="no")]

  /**
   * The color of the rectangles' stroke.
   *
   * @default [0x00000000]
   */
  [Style(name="strokeColor", type="uint", format="Color", inherit="no")]

  /**
   * Determines the thickness of the rectangles' stroke.
   *
   * @default [0]
   */
  [Style(name="strokeThickness", type="Number", inherit="no")]

  /**
   * Determines the alpha transparency value for rectangle colors.
   *
   * @default 1.0
   */
  [Style(name="encodedColorAlpha", type="Number", inherit="no")]


  [Bindable]
  public class FlareColumnChart extends FlareControlBase {
    public function FlareColumnChart() {
      super();
    }
    
    // Invoke the class constructor to initialize the CSS defaults.
    classConstructor();


    private static function classConstructor():void {      
      CSSUtil.setDefaultsFor("FlareColumnChart",
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



    /**
     * Is property name used for text styling?
     */
    private function isTextStyle(styleProp:String):Boolean {
      const textStyleProps:Array = [ "color"
                                   , "fontFamily"
                                   , "fontSize"
                                   , "fontStyle"
                                   , "fontWeight"
                                   , "textAlign"
                                   , "textPosition"
                                   ];
      return textStyleProps.indexOf(styleProp) !== -1;
    }

    /**
     * Is property name used for visualization layout styling?
     */
    private function isLayoutStyle(styleProp:String):Boolean {
      const paletteStyleProps:Array = [ "palette"
                                      , "strokeAlpha"
                                      , "strokeColor"
                                      , "strokeThickness"
                                      ];
      return paletteStyleProps.indexOf(styleProp) !== -1;
    }

    /**
     * Note changes to styles.
     */
    private var _labelStyleChanged:Boolean = false;

    /**
     * Note changes to styles.
     */
    private var _layoutStyleChanged:Boolean = false;


    /**
     * @private
     */
    override public function styleChanged(styleProp:String):void {
      super.styleChanged(styleProp);
      
      const allStyles:Boolean = !styleProp || styleProp == "styleName";
      if (!allStyles) {
        if (isTextStyle(styleProp)) _labelStyleChanged = true;
        else if (isLayoutStyle(styleProp)) _layoutStyleChanged = true;
      } else {
  		  // if runtime css swap or direct change of stylename
				var classSelector:Object = StyleManager.getStyleDeclaration("." + styleName);
				if (classSelector != null) {
				  // TODO: check all possible styles
  				for each (var s:String in ['fontFamily', 'fontSize', 'fontColor']) {
  				  var v:* = classSelector.getStyle(s);
  				  if (v != undefined) {
  				    setStyle(s, v);
  				    _labelStyleChanged = true;
  				  }
  				}
  		  }
      }
      invalidateProperties();
    }
    

    private function propertyChanged():void {
      _updateVis = true;
      invalidateProperties();
    }

    public var _updateVis:Boolean = false;

    
    
    //---------- color palette ----------
    
    private var _colorPaletteName:String = 'spectral';

    /**
     * Return a color palette for interpolating color values
     * from the <code>colorEncodingField</code>'s data value.
     */
    protected function get colorPalette():ColorPalette {
      return ColorPalette.getPaletteByName(getStyle("palette"));
    }

    //---------- color encoding field ----------

    /**
     * Specifies a data <code>Object</code> property's name used
     * to encode a treemap rectangle's color.
     *
     * @default "color"
     */
    [Inspectable(category="General")]
    public function set colorEncodingField(propertyName:String):void {
      _colorEncodingField = propertyName;
      if (colorEncoder != null) colorEncoder.source = asFlareProperty(_colorEncodingField);
      propertyChanged();
    }
    
    public function get colorEncodingField():String { return _colorEncodingField; }
    private var _colorEncodingField:String = "color";



    //-------------  x encoding field ------------------
    

    /**
     * Specifies a data <code>Object</code> property's name used
     * to encode the x variable.
     *
     * @default "x"
     */
    [Inspectable(category="General")]
    public function set xEncodingField(propertyName:String):void {
      _xEncodingField = propertyName;
      if (layout != null) layout.xField = asFlareProperty(_xEncodingField);
      _updateVis = true;
      invalidateProperties();
    }

    public function get xEncodingField():String { return _xEncodingField; }
    private var _xEncodingField:String = "x";
    

    //-------------  y encoding field ------------------
    

    /**
     * Specifies a data <code>Object</code> property's name used
     * to encode the y variable.
     *
     * @default "y"
     */
    [Inspectable(category="General")]
    public function set yEncodingField(propertyName:String):void {
      _yEncodingField = propertyName;
      if (layout != null) layout.yField = asFlareProperty(_yEncodingField);
      _updateVis = true;
      invalidateProperties();
    }

    public function get yEncodingField():String { return _yEncodingField; }    
    private var _yEncodingField:String = "y";
    
    

    //-------------  data ------------------
    
    /**
     * Flag whether a new data set is loaded or not.
     */
    private var newDataLoaded:Boolean = false;


    /**
     * Sets the data value to a <code>Data</code> data
     * object used for rendering position and color
     * of the chart.
     *
     * @see flare.vis.data.Data
     */
    override public function set data(value:Object):void {
      var newValue:Data = null;
      if (value is Array) 
        newValue = Data.fromArray(value as Array);
      if (value is ArrayCollection) 
        newValue = Data.fromArray(value.source as Array);
      if (value is Data) 
        newValue = value as Data;

      newDataLoaded = newValue !== this.data;
      if (newDataLoaded) {
        vis.data = newValue
        super.data = newValue;
        
        vis.operators.clear();
        vis.operators.add(createAxisLayout());
        vis.operators.add(createColorEncoder());
        
        vis.xyAxes.yAxis.axisScale['preferredMax'] = 100;        
        styleNodes();
        
        dispatchEvent(new JuiceKitEvent(JuiceKitEvent.DATA_ROOT_CHANGE));
      }
    }
    override public function get data():Object { return super.data }
    
    
    //------------ encoders and layouts -----------
    
    private const OP_IX_LAYOUT:int = 0;
    private const OP_IX_COLOR:int = 1; 
    
    public function get layout():AxisLayout {
      if (vis && vis.operators.length >= OP_IX_LAYOUT) {
        return vis.operators.getOperatorAt(OP_IX_LAYOUT) as AxisLayout;        
      } else {
        return null;    
      }
    }
    
    public function get colorEncoder():ColorEncoder {
      if (vis && vis.operators.length >= OP_IX_COLOR) {
        return vis.operators.getOperatorAt(OP_IX_COLOR) as ColorEncoder;        
      } else {
        return null;    
      }
    }


    /**
    * Create the color encoder to encode the _colorEncodingField
    */
    private function createColorEncoder():ColorEncoder {
      return new ColorEncoder(asFlareProperty(_colorEncodingField)
                              , Data.NODES
                              , "fillColor"
                              , ScaleType.LINEAR
                              , colorPalette.toFlareColorPalette());
    }


    
    /**
    * Create the axis layout
    */
    private function createAxisLayout():Operator {
      return new AxisLayout(asFlareProperty(xEncodingField), 
                           asFlareProperty(yEncodingField), 
                           false, 
                           true);
    }
    
    
    /**
    * Set the gap between horizontal bars
    * 
    * @default 0.25
    */
    public function set gapWidth(v:Number):void {
      _gapWidth = Maths.clampValue(v, 0.0, 1.0);
      styleNodes();
      invalidateProperties();
      _updateVis = true;
    }
    public function get gapWidth():Number { return _gapWidth; }
    private var _gapWidth:Number = 0.25;
    private var barSize:Number = 20;


    /**
     * Apply node stylings to each NodeSprite.
     */
    private function styleNodes():void {
      // Guard against data not being available.
      if (!vis || !vis.data)
        return;

      const alpha:Number = getStyle("strokeAlpha");
      const color:uint = getStyle("strokeColor");
      const lineWidth:Number = getStyle("strokeThickness");
      const numValues:int = vis.xyAxes.yAxis.axisScale.values().length;
      barSize = Math.max(4,((vis.bounds.height - 0) * (1.0 - gapWidth)) / numValues);
      
      vis.data.nodes.setProperties({shape: Shapes.VERTICAL_BAR, 
                                    lineWidth: lineWidth, 
                                    lineColor: color,
                                    lineAlpha: alpha, 
                                    size: barSize/6.0});
    }


    /** The tooltip format string. */
    private static const _tipText:String = "<b>Category</b>: {0}<br/>" + "<b>Position</b>: {1}<br/>" + "<b>Value</b>: {2}";
    
    /**
     * @private
     */
    override protected function initVisualization():void {
      // Create an empty initial bounds.
      vis.bounds = new Rectangle(0, 0, 0, 0);
      super.initVisualization();

      // add tooltip showing data values
      vis.controls.add(new TooltipControl(DataSprite, null, function(evt:TooltipEvent):void {
          var d:DataSprite = evt.node;
          TextSprite(evt.tooltip).htmlText = Strings.format(_tipText, d.data.s, d.data.y, d.data.x);
        }));

      /**
      * Style nodes on resize to maintain the gapWidth
      */
      this.addEventListener(ResizeEvent.RESIZE, function(e:ResizeEvent):void { styleNodes() });
    }
     
    //----------------- axis properties ---------------

    /**
    * Show gridlines for the xAxis
    */
    public function set xAxisShowLines(v:Boolean):void { 
      if (v != _xAxisShowLines) {
        _xAxisShowLines = v;
        if (vis != null) vis.xyAxes.xAxis.showLines = v;
        propertyChanged();
      } 
    }
    public function get xAxisShowLines():Boolean { return _xAxisShowLines; } 
    private var _xAxisShowLines:Boolean = true;
    
    /**
    * Show gridlines for the yAxis
    */
    public function set yAxisShowLines(v:Boolean):void { 
      if (v != _yAxisShowLines) {
        _yAxisShowLines = v;
        if (vis != null) vis.xyAxes.yAxis.showLines = v;
        propertyChanged();
      } 
    }
    public function get yAxisShowLines():Boolean { return _yAxisShowLines; } 
    private var _yAxisShowLines:Boolean = true;
    

    /**
    * Show labels for the xAxis
    * 
    * @default true
    */
    public function set xAxisShowLabels(v:Boolean):void { 
      if (v != _xAxisShowLabels) {
        _xAxisShowLabels = v;
        if (vis != null) vis.xyAxes.xAxis.showLabels = v;
        propertyChanged();
      } 
    }
    public function get xAxisShowLabels():Boolean { return _xAxisShowLabels; } 
    private var _xAxisShowLabels:Boolean = true;
    
    /**
    * Show labels for the yAxis
    * 
    * @default true
    */
    public function set yAxisShowLabels(v:Boolean):void { 
      if (v != _yAxisShowLabels) {
        _yAxisShowLabels = v;
        if (vis != null) vis.xyAxes.yAxis.showLabels = v;
        propertyChanged();
      } 
    }
    public function get yAxisShowLabels():Boolean { return _yAxisShowLabels; } 
    private var _yAxisShowLabels:Boolean = true;
    
    /**
    * Reverse the values on the xAxis
    * 
    * @default false
    */
    public function set xReverse(v:Boolean):void { 
      if (v != _xReverse) {
        _xReverse = v;
        if (vis != null) vis.xyAxes.xReverse = v;
        propertyChanged();
      } 
    }
    public function get xReverse():Boolean { return _xReverse; } 
    private var _xReverse:Boolean = false;
    
    /**
    * Reverse the values on the yAxis
    * 
    * @default false
    */
    public function set yReverse(v:Boolean):void { 
      if (v != _yReverse) {
        _yReverse = v;
        if (vis != null) vis.xyAxes.yReverse = v;
        propertyChanged();
      } 
    }
    public function get yReverse():Boolean { return _yReverse; } 
    private var _yReverse:Boolean = false;
    
    /**
    * The labelFormat for the xAxis. A Strings.format formatting
    * strings. For instance, "0.000" formats numbers with three
    * digits of precision.
    * 
    * @see flare.util.Strings
    */
    public function set xAxisLabelFormat(v:String):void { 
      if (v != _xAxisLabelFormat) {
        _xAxisLabelFormat = v;
        if (vis != null) vis.xyAxes.xAxis.labelFormat = v;
        propertyChanged();
      } 
    }
    public function get xAxisLabelFormat():String { return _xAxisLabelFormat; } 
    private var _xAxisLabelFormat:String = '0.00';
    
    /**
    * The labelFormat for the yAxis. A Strings.format formatting
    * strings. For instance, "0.000" formats numbers with three
    * digits of precision.
    * 
    * @see flare.util.Strings
    */
    public function set yAxisLabelFormat(v:String):void { 
      if (v != _yAxisLabelFormat) {
        _yAxisLabelFormat = v;
        if (vis != null) vis.xyAxes.yAxis.labelFormat = v;
        propertyChanged();
      } 
    }
    public function get yAxisLabelFormat():String { return _yAxisLabelFormat; } 
    private var _yAxisLabelFormat:String = '0.00';
    
    /**
    * Called when the visualiation is first set up to 
    * initialize properties 
    */
    private function formatAxes():void {
      // x axis properties
      vis.xyAxes.xAxis.showLines = _xAxisShowLines;
      vis.xyAxes.xAxis.showLabels = _xAxisShowLabels;
      vis.xyAxes.xReverse = _xReverse;
      vis.xyAxes.xAxis.labelFormat = _xAxisLabelFormat;
      vis.xyAxes.xAxis.labelTextFormat = new TextFormat(getStyle('fontFamily'), 
                                                        getStyle('fontSize'), 
                                                        getStyle('fontColor'),
                                                        getStyle('fontWeight')=='bold',
                                                        getStyle('fontStyle')=='italic');
      (vis.xyAxes.xAxis.axisScale as ScaleBinding).zeroBased = true;

      // y axis properties
      vis.xyAxes.yAxis.showLines = _yAxisShowLines;
      vis.xyAxes.yAxis.showLabels = _yAxisShowLabels;
      vis.xyAxes.yReverse = _yReverse;
      vis.xyAxes.yAxis.labelFormat = _yAxisLabelFormat;
      vis.xyAxes.yAxis.labelTextFormat = new TextFormat(getStyle('fontFamily'), 
                                                        getStyle('fontSize'), 
                                                        getStyle('fontColor'),
                                                        getStyle('fontWeight')=='bold',
                                                        getStyle('fontStyle')=='italic');
      
      // if the font is embedded, use TextSprite.EMBED to
      // get smoother display of small font sizes
      if (CSSUtil.isEmbeddedFont(new TextFormat(getStyle('fontFamily')))) {
        vis.xyAxes.xAxis.labelTextMode = TextSprite.EMBED;      
        vis.xyAxes.yAxis.labelTextMode = TextSprite.EMBED;              
      }
           
    }

    /**
     * @private
     */
    override protected function commitProperties():void {
      super.commitProperties();

      var updateVis:Boolean = false;

      if (vis && vis.data != null) {
        
        if (_layoutStyleChanged) {
          _layoutStyleChanged = false;
          colorEncoder.palette = colorPalette;

          updateVis = true;
        }


        if (_labelStyleChanged) {
          _labelStyleChanged = false;
          formatAxes();
          updateVis = true;
        }

        if (this.data is Data) {
          if (newDataLoaded) {
            newDataLoaded = false;
            if (layout == null) createAxisLayout();
            if (colorEncoder == null) {
               createColorEncoder();
            } 
            formatAxes();
            styleNodes();
            updateVis = true;
          }

          if (updateVis) {            
            updateVisualization();
          }
          if (_updateVis) {
            _updateVis = false;
            updateVisualization();
          }
        }
      }
    }
    


    /**
    * Create a sample dataset for the bar graph.
    * 
    * For debugging.
    */
    public static function getData(N:int, M:int):Data {
      var data:Data = new Data();
      for (var i:uint = 0; i < N; ++i) {
        for (var j:uint = 0; j < M; ++j) {
          var s:String = String(i < 10 ? "0" + i : i);
          data.addNode({y: s, 
                        s: j, 
                        state: Math.random()>0.5? 'Vermont': 'Virginia', 
                        x2: int(3 + 4 * Math.random()),
                        x: int(1 + 10 * Math.random())
                        });
        }
      }
      return data;
    }

    /**
    * Update the data in the nodes in place.
    * 
    * For debugging.
    */
    public function updateData():void {
      vis.data.nodes.visit(function(d:DataSprite):void {
          d.data.x = int(1 + 10 * Math.random());
        });
    }

  }
}