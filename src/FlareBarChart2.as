package {
  import flare.scale.ScaleType;
  import flare.util.Shapes;
  import flare.vis.data.Data;
  import flare.vis.data.DataSprite;
  import flare.vis.operator.Operator;
  import flare.vis.operator.encoder.ColorEncoder;
  import flare.vis.operator.layout.AxisLayout;
  
  import flash.geom.Rectangle;
  
  import org.juicekit.events.JuiceKitEvent;
  import org.juicekit.flare.util.palette.ColorPalette;
  import org.juicekit.util.helper.CSSUtil;
  import org.juicekit.visual.controls.FlareControlBase;



  /**
   *  Sets the color of text.
   *
   *  @default 0x000000
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
   *  @default "Verdana"
   */
  [Style(name="fontFamily", type="String", inherit="yes")]
  
  /**
   *  Sets the height of the text, in pixels.
   *
   *  @default 10
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
  [Style(name="strokeAlphas", type="Array", arrayType="Number", inherit="no")]

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


  public class FlareBarChart2 extends FlareControlBase {
    public function FlareBarChart2() {
      super();
    }
    
    private const OP_IX_LAYOUT:int = 0;
    private const OP_IX_COLOR:int = 1; 
    

    // Invoke the class constructor to initialize the CSS defaults.
    classConstructor();


    private static function classConstructor():void {
      CSSUtil.setDefaultsFor("FlareBarChart2",
        { fontColor: 0x000000
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
      const textStyleProps:Array = [ "fontColor"
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
        if (isTextStyle(styleProp)) {
          _labelStyleChanged = true;
        } else if (isLayoutStyle(styleProp)) {
          _layoutStyleChanged = true;
        }
      }
      invalidateProperties();
    }
    
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
     * Store the colorEncodingField property.
     */
    private var _colorEncodingField:String = "color";
    private var _colorEncodingUpdated:Boolean = false;

    /**
     * Specifies a data <code>Object</code> property's name used
     * to encode a treemap rectangle's color.
     *
     * @default "color"
     */
    [Inspectable(category="General")]
    [Bindable]
    public function set colorEncodingField(propertyName:String):void {
      _colorEncodingField = propertyName;
      _colorEncodingUpdated = true;
      invalidateProperties();
    }


    /**
     * @private
     */
    public function get colorEncodingField():String {
      return _colorEncodingField;
    }


    //-------------  x encoding field ------------------
    

    /**
     * Store the xEncodingField property.
     */
    private var _xEncodingField:String = "x";
    private var _xEncodingUpdated:Boolean = false;


    /**
     * Specifies a data <code>Object</code> property's name used
     * to encode the x variable.
     *
     * @default "x"
     */
    [Inspectable(category="General")]
    [Bindable]
    public function set xEncodingField(propertyName:String):void {
      _xEncodingField = propertyName;
      _xEncodingUpdated = true;
      invalidateProperties();
    }


    /**
     * @private
     */
    public function get xEncodingField():String {
      return _xEncodingField;
    }
    

    //-------------  y encoding field ------------------
    


    /**
     * Store the yEncodingField property.
     */
    private var _yEncodingField:String = "y";
    private var _yEncodingUpdated:Boolean = false;


    /**
     * Specifies a data <code>Object</code> property's name used
     * to encode the y variable.
     *
     * @default "y"
     */
    [Inspectable(category="General")]
    [Bindable]
    public function set yEncodingField(propertyName:String):void {
      _yEncodingField = propertyName;
      _yEncodingUpdated = true;
      invalidateProperties();
    }


    /**
     * @private
     */
    public function get yEncodingField():String {
      return _yEncodingField;
    }
    

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
      value = value is Data ? value : null;
      newDataLoaded = value !== this.data;
      if (newDataLoaded) {
        vis.data = value as Data;
        super.data = value;
        
        vis.operators.clear();
        vis.operators.add(createAxisLayout());
        vis.operators.add(createColorEncoder());
        
        vis.xyAxes.xAxis.axisScale['preferredMax'] = 100;        
        styleNodes();
        
        dispatchEvent(new JuiceKitEvent(JuiceKitEvent.DATA_ROOT_CHANGE));
      }
    }


    /**
     * @private
     */
    override public function get data():Object {
      return super.data;
    }
    
    
    private function createColorEncoder():ColorEncoder {
      return new ColorEncoder(asFlareProperty(_colorEncodingField)
                              , Data.NODES
                              , "fillColor"
                              , ScaleType.LINEAR
                              , colorPalette.toFlareColorPalette());
    }


    

    private function createAxisLayout():Operator {
      var axisLayout:AxisLayout = new AxisLayout(asFlareProperty(xEncodingField), asFlareProperty(yEncodingField), true, false);
      return axisLayout;      
    }


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
      vis.data.nodes.setProperties({shape: Shapes.HORIZONTAL_BAR, 
                                    lineWidth: lineWidth, 
                                    lineAlpha: alpha, 
                                    lineColor: color, 
                                    size: 2.5 * vis.bounds.height / vis.data.nodes.length});
//                                    size: 200 / vis.data.nodes.length});
    }


    
    /**
     * @private
     */
    override protected function initVisualization():void {
      // Create an empty initial bounds.
      vis.bounds = new Rectangle(0, 0, 0, 0);
      super.initVisualization();
    }

    public function getLayout():AxisLayout {
      return vis.operators.getOperatorAt(OP_IX_LAYOUT) as AxisLayout;
    }
    

    /**
     * @private
     */
    override protected function commitProperties():void {
      super.commitProperties();

      var updateVis:Boolean = false;

      if (vis && vis.data != null) {
        const colorEncoder:ColorEncoder = vis.operators.getOperatorAt(OP_IX_COLOR) as ColorEncoder;
        const layout:AxisLayout = vis.operators.getOperatorAt(OP_IX_LAYOUT) as AxisLayout;

        if (_colorEncodingUpdated) {
          _colorEncodingUpdated = false;

          colorEncoder.source = asFlareProperty(_colorEncodingField);

          updateVis = true;
        }
        
        if (_xEncodingUpdated) {
          _xEncodingUpdated = false;
          layout.xField = asFlareProperty(xEncodingField);
        }
        
        if (_yEncodingUpdated) {
          _yEncodingUpdated = false;
          layout.yField = asFlareProperty(yEncodingField);
        }

        if (_layoutStyleChanged) {
          _layoutStyleChanged = false;

          colorEncoder.palette = colorPalette;

          styleNodes();

          updateVis = true;
        }


        if (_labelStyleChanged) {
          _labelStyleChanged = false;
          updateVis = true;
        }

        if (this.data is Data) {
          if (newDataLoaded) {
            newDataLoaded = false;
            if (layout == null) {
              createAxisLayout();
            }
            styleNodes();
            updateVis = true;
          }

          if (updateVis) {
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
          data.addNode({y: s, 
                        s: j, 
                        state: Math.random()>0.5? 'Vermont': 'Virginia', 
                        x: int(1 + 10 * Math.random())});
        }
      }
      return data;
    }

    public function updateData():void {
      vis.data.nodes.visit(function(d:DataSprite):void {
          d.data.x = int(1 + 10 * Math.random());
        });
    }

  }
}