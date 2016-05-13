//
//  GradientBarChartRenderer.swift
//  Charts
//
//  Created by Shannon Wu on 5/13/16.
//  Copyright © 2016 dcg. All rights reserved.
//

import UIKit

final public class GradientBarChartRenderer: BarChartRenderer
{
    public var bottomColor: NSUIColor = NSUIColor.lightGrayColor()
    public var topColor: NSUIColor = NSUIColor.blackColor()
    
    public override func drawDataSet(context context: CGContext, dataSet: IBarChartDataSet, index: Int)
    {
        func drawGradientInRect(barRect: CGRect)
        {
            CGContextSaveGState(context)
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0)
            let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [topColor.CGColor, bottomColor.CGColor], [0, 1])!
            
            let rectanglePath = UIBezierPath(roundedRect: CGRect(x: barRect.origin.x, y: barRect.origin.y, width: barRect.width, height: barRect.height), cornerRadius: barRect.width / 2.0)
            rectanglePath.addClip()
            CGContextDrawLinearGradient(context, gradient, CGPoint(x: barRect.origin.x + barRect.width / 2.0, y: barRect.origin.y), CGPoint(x: barRect.origin.x + barRect.width / 2.0, y: barRect.origin.y + barRect.height), [])
            CGContextRestoreGState(context)
        }
        
        guard let
            dataProvider = dataProvider,
            barData = dataProvider.barData,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let drawBarShadowEnabled: Bool = dataProvider.isDrawBarShadowEnabled
        let dataSetOffset = (barData.dataSetCount - 1)
        let groupSpace = barData.groupSpace
        let groupSpaceHalf = groupSpace / 2.0
        let barSpace = dataSet.barSpace
        let barSpaceHalf = barSpace / 2.0
        let containsStacks = dataSet.isStacked
        let isInverted = dataProvider.isInverted(dataSet.axisDependency)
        let barWidth: CGFloat = 0.5
        let phaseY = animator.phaseY
        var barRect = CGRect()
        var barShadow = CGRect()
        var y: Double
        
        // do the drawing
        for j in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
        {
            guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
            
            // calculate the x-position, depending on datasetcount
            let x = CGFloat(e.xIndex + e.xIndex * dataSetOffset) + CGFloat(index)
                + groupSpace * CGFloat(e.xIndex) + groupSpaceHalf
            var vals = e.values
            
            if (!containsStacks || vals == nil)
            {
                y = e.value
                
                let left = x - barWidth + barSpaceHalf
                let right = x + barWidth - barSpaceHalf
                var top = isInverted ? (y <= 0.0 ? CGFloat(y) : 0) : (y >= 0.0 ? CGFloat(y) : 0)
                var bottom = isInverted ? (y >= 0.0 ? CGFloat(y) : 0) : (y <= 0.0 ? CGFloat(y) : 0)
                
                // multiply the height of the rect with the phase
                if (top > 0)
                {
                    top *= phaseY
                }
                else
                {
                    bottom *= phaseY
                }
                
                barRect.origin.x = left
                barRect.size.width = right - left
                barRect.origin.y = top
                barRect.size.height = bottom - top
                
                trans.rectValueToPixel(&barRect)
                
                if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                {
                    continue
                }
                
                if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                {
                    break
                }
                
                if (drawBarShadowEnabled)
                {
                    barShadow.origin.x = barRect.origin.x
                    barShadow.origin.y = viewPortHandler.contentTop
                    barShadow.size.width = barRect.size.width
                    barShadow.size.height = viewPortHandler.contentHeight
                    
                    CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor)
                    CGContextFillRect(context, barShadow)
                }
                
                drawGradientInRect(barRect)
            }
            else
            {
                var posY = 0.0
                var negY = -e.negativeSum
                var yStart = 0.0
                
                if (drawBarShadowEnabled)
                {
                    y = e.value
                    
                    let left = x - barWidth + barSpaceHalf
                    let right = x + barWidth - barSpaceHalf
                    var top = isInverted ? (y <= 0.0 ? CGFloat(y) : 0) : (y >= 0.0 ? CGFloat(y) : 0)
                    var bottom = isInverted ? (y >= 0.0 ? CGFloat(y) : 0) : (y <= 0.0 ? CGFloat(y) : 0)
                    
                    if (top > 0)
                    {
                        top *= phaseY
                    }
                    else
                    {
                        bottom *= phaseY
                    }
                    
                    barRect.origin.x = left
                    barRect.size.width = right - left
                    barRect.origin.y = top
                    barRect.size.height = bottom - top
                    
                    trans.rectValueToPixel(&barRect)
                    
                    barShadow.origin.x = barRect.origin.x
                    barShadow.origin.y = viewPortHandler.contentTop
                    barShadow.size.width = barRect.size.width
                    barShadow.size.height = viewPortHandler.contentHeight
                    
                    CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor)
                    CGContextFillRect(context, barShadow)
                }
                
                for k in 0 ..< vals!.count
                {
                    let value = vals![k]
                    
                    if value >= 0.0
                    {
                        y = posY
                        yStart = posY + value
                        posY = yStart
                    }
                    else
                    {
                        y = negY
                        yStart = negY + abs(value)
                        negY += abs(value)
                    }
                    
                    let left = x - barWidth + barSpaceHalf
                    let right = x + barWidth - barSpaceHalf
                    var top: CGFloat, bottom: CGFloat
                    if isInverted
                    {
                        bottom = y >= yStart ? CGFloat(y) : CGFloat(yStart)
                        top = y <= yStart ? CGFloat(y) : CGFloat(yStart)
                    }
                    else
                    {
                        top = y >= yStart ? CGFloat(y) : CGFloat(yStart)
                        bottom = y <= yStart ? CGFloat(y) : CGFloat(yStart)
                    }
                    
                    // multiply the height of the rect with the phase
                    top *= phaseY
                    bottom *= phaseY
                    
                    barRect.origin.x = left
                    barRect.size.width = right - left
                    barRect.origin.y = top
                    barRect.size.height = bottom - top
                    
                    trans.rectValueToPixel(&barRect)
                    
                    if (k == 0 && !viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                    {
                        break
                    }
                    
                    drawGradientInRect(barRect)
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
}
