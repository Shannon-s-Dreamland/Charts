//
//  GradientBarChartView.swift
//  Charts
//
//  Created by Shannon Wu on 5/13/16.
//  Copyright © 2016 dcg. All rights reserved.
//

import UIKit

public class GradientBarChartView: BarChartView
{
    public var top = NSUIColor.redColor() {
        didSet {
            (renderer as! GradientBarChartRenderer).topColor = top
        }
    }
    public var bottom = NSUIColor.blueColor() {
        didSet {
            (renderer as! GradientBarChartRenderer).bottomColor = bottom
        }
    }
    
    public init(top: NSUIColor, bottom: NSUIColor)
    {
        self.top = top
        self.bottom = bottom
        
        super.init(frame: CGRect.zero)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        let gradientRenderer = GradientBarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        gradientRenderer.topColor = top
        gradientRenderer.bottomColor = bottom
        renderer = gradientRenderer
        _xAxisRenderer = ChartXAxisRendererBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        self.highlighter = BarChartHighlighter(chart: self)
        
        _xAxis._axisMinimum = -0.5
    }
}
