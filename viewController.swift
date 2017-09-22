//
//  ViewController.swift
//  Sudoku Breaker
//
//  Created by Adil Rakhmetov on 2014-11-20.
//  Copyright (c) 2014 Bortas, LTD. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController, ADBannerViewDelegate {
    
    
    @IBOutlet var cells: Array<UITextField>!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var headLine: UILabel!
    @IBOutlet weak var guideText: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    
    var tableFinished = false
    var bannerView: ADBannerView?
    var originMatrix = [Int] (count: 81, repeatedValue: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
        self.bannerView?.delegate = self
        self.bannerView?.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // var screenRect = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.bannerView?.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) ->  Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        self.bannerView?.hidden = true
    }
    
    
    @IBAction func CellChanged(sender: AnyObject) {
    
        for i in 0...80 {
            if cells[i].text != "" {
                originMatrix[i] = cells[i].text.toInt()!
            } else {
                originMatrix[i] = 0
            }
            
            if cells[i].text == "0" {cells[i].text = ""}
            cells[i].textColor = UIColor.blackColor()
            guideText.textColor = UIColor.whiteColor()
            cells[i].resignFirstResponder()
        }
        
        // Checking the originMatrix for errors
        
        var errorCell : (Int,Int,Int)! = (0,0,0)
        var arrayCheck = [Int](count:9, repeatedValue: 0)
        var indexCheck = [Int](count:9, repeatedValue: 0)
        
        func SeekPairs(array: [Int], index: [Int]) -> (value: Int, first: Int, second: Int) {
            for i in 0...7 {
                if array[i] != 0 {
                    for j in ((i + 1)...8) {
                        if array[j] == 0 {continue}
                        else if array[i] == array[j] {
                            return (array[i], index[i], index[j])
                        }
                    }
                }
            }
            return (0,0,0)
        }
        
        for i in 0...8 {
            for j in 0...8 {
                indexCheck[j] = 9 * i + j
                arrayCheck[j] = originMatrix[indexCheck[j]]
            }
            errorCell = SeekPairs(arrayCheck, indexCheck)
            if  errorCell.0 != 0 { break }
            
            for j in 0...8 {
                indexCheck[j] = i + 9 * j
                arrayCheck[j] = originMatrix[indexCheck[j]]
            }
            errorCell = SeekPairs(arrayCheck, indexCheck)
            if  errorCell.0 != 0 { break }
            
            for j in 0...8 {
                indexCheck[j] = j + 6 * Int(j/3) + 3 * (i + 6 * Int(i/3))
                arrayCheck[j] = originMatrix[indexCheck[j]]
            }
            errorCell = SeekPairs(arrayCheck, indexCheck)
            if  errorCell.0 != 0 { break }
        }
        
        if errorCell.0 != 0 {
            
            cells[errorCell.1].textColor = UIColor.redColor()
            originMatrix[errorCell.1] = 0
            cells[errorCell.2].textColor = UIColor.redColor()
            originMatrix[errorCell.2] = 0
            headLine.textColor = UIColor.yellowColor()
            headLine.text = "ERROR"
            guideText.textColor = UIColor.yellowColor()
            guideText.text = "The highlighted numbers must be different."
            nextButton.enabled = false
            hintButton.enabled = false
            solveButton.enabled = false
            
        } else {
            nextButton.enabled = true
            tableFinished = true
            for i in originMatrix  {
                if i == 0 {tableFinished = false; break}
            }
            
            if tableFinished {
                headLine.textColor = UIColor.whiteColor()
                headLine.text = "BINGO!"
                guideText.text = "The puzzle is solved. Press Reset to start again"
                solveButton.enabled = false
                hintButton.enabled = false
                for typing in cells { typing.enabled = false}
                
            } else {
                
                solveButton.enabled = true
                hintButton.enabled = true
                headLine.textColor = UIColor.whiteColor()
                
                if nextButton.hidden {
                    headLine.text = ""
                    guideText.text = "Try to find hidden numbers. Use 'Hint' to unveil random number, 'Solve' to show them all."
                } else {
                    self.headLine.text = "LOAD YOUR SUDOKU"
                    self.guideText.text = "Tap and place all known numbers at their slots. Use '0' to delete. After finishing press 'Next'."
                }
            }
        }
    }
    @IBAction func nextButtonPressed(sender: AnyObject) {
        nextButton.hidden = true
        resetButton.hidden = false
        hintButton.hidden = false
        solveButton.hidden = false
        solveButton.enabled = true
        hintButton.enabled = true
        headLine.text = ""
        guideText.text = "Try to find hidden numbers. Use 'Hint' to unveil random number, 'Solve' to show them all."
    }
    
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        var alert = UIAlertController(title: "Warning", message: "Reset will clear all cells", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style {
                case .Default:
                    for (index, item) in enumerate(self.cells) {
                        item.text = ""
                        item.textColor = UIColor.blackColor()
                    }
                    for i in 0...80 {
                        self.cells[i].enabled = true
                        self.originMatrix[i] = 0
                    }
                    self.nextButton.hidden = false
                    self.resetButton.hidden = true
                    self.solveButton.hidden = true
                    self.hintButton.hidden = true
                    self.guideText.textColor = UIColor.whiteColor()
                    self.headLine.text = "LOAD YOUR SUDOKU"
                    self.guideText.text = "Tap and place all known numbers at their slots. Use '0' to delete. After finishing press 'Next'."
                
                default: break
                
            }
        }))
        
    }
    
    //Function to check the duplications in the matrix
    
    func checkCell(#matrix: [Int], index:Int, value:Int) -> Bool {
        
        var ones9 = index % 9
        var dozens9 = index - (index % 9)
        
        for n in 0...8 {
            if  matrix[ n +  dozens9] == value  ||
                matrix[9 * n + ones9] == value  {
                    return true
            }
            
        }
        
        var dx = 0
        
        switch dozens9 {
        case 0, 9, 18:
            dx = 0
        case 27, 36, 45:
            dx = 3
        default:
            dx = 6
            }
        
        var dy = 0
        
        switch ones9 {
        case 0, 1, 2:
            dy = 0
        case 3, 4, 5:
            dy = 3
        default:
            dy = 6
            }
        var index = 0
        for xx in 0...2 {
            for yy in 0...2 {
                var box = (dx + xx) * 9 + (dy + yy)
                
                if matrix [box] == value {return true}
                
            }
        }
        return false
    }
    
    
    
    func SudokuSolution( #originMatrix: [Int]) -> (matrix: Array<Int>, iterations: Int) {
        
        var prevCell = 1
        var iterations = 1
        var matrix = originMatrix
        var masterMatrix = originMatrix
        var indicator = 0
        var foundCellIndex = 0
        var digitExists = false
        var clusterIndex = 0
        var matrixChanged = true
        
        
        while matrixChanged {
            
            matrixChanged = false
            // checking for 1 place for the digit in rows
            for i in 0...8 {
                for digit in 1...9 {
                    indicator = 0
                    digitExists = false
                    for j in 9*i...9*i+8 {
                        if masterMatrix[j] == digit {digitExists = true; break}
                    }
                    
                    if digitExists {continue}
                    
                    for j in 9*i...9*i+8 {
                        if masterMatrix[j] != 0 {continue}
                        if checkCell(matrix: masterMatrix, index: j, value: digit) == false {
                            ++indicator; foundCellIndex = j}
                        if indicator > 1 { break}
                    }
                    if indicator == 0 { return (matrix, 0)}
                    if indicator == 1 { masterMatrix[foundCellIndex] = digit; matrixChanged = true}
                }
            }
            
            // checking for 1 place for the digit in columns
            for j in 0...8 {
                for digit in 1...9 {
                    indicator = 0
                    digitExists = false
                    for i in 0...8 {
                        if masterMatrix[9*i+j] == digit {digitExists = true; break}
                    }
                    
                    if digitExists {continue}
                    
                    for i in 0...8 {
                        if masterMatrix[9*i+j] != 0 {continue}
                        if checkCell(matrix: masterMatrix, index: 9*i+j, value: digit) == false {
                            ++indicator; foundCellIndex = 9*i+j}
                        if indicator > 1 {break}
                    }
                    if indicator == 0 { return (matrix, 0)}
                    if indicator == 1 { masterMatrix[foundCellIndex] = digit; matrixChanged = true}
                }
            }
            
            
            // checking for 1 place for the digit in clusters
            for i in 0...8 {
                for digit in 1...9 {
                    indicator = 0; digitExists = false
                    for j in 0...8 {
                        clusterIndex = j + 6 * Int(j/3) + 3 * (i + 6 * Int(i/3))
                        if masterMatrix[clusterIndex] == digit {digitExists = true; break}
                    }
                    
                    if digitExists {continue}
                    
                    for j in 0...8 {
                        clusterIndex = j + 6 * Int(j/3) + 3 * (i + 6 * Int(i/3))
                        if masterMatrix[clusterIndex] != 0 {continue}
                        if checkCell(matrix: masterMatrix, index: clusterIndex, value: digit) == false {
                            ++indicator; foundCellIndex = clusterIndex}
                        if indicator > 1 {break}
                    }
                    if indicator == 0 { return (matrix, 0)}
                    if indicator == 1 { masterMatrix[foundCellIndex] = digit; matrixChanged = true}
                }
            }
            
        }
        matrix = masterMatrix
        
        for var x = 0; x < 81; ++x {
            
            if masterMatrix[x] != 0 {continue}
            var foundCell = 0
            for cell in prevCell...9 {
                iterations++
                matrix[x] = 0
                
                if checkCell(matrix: matrix, index: x, value: cell) {continue}
                
                foundCell = cell
                
                break
            }
            prevCell = 1
            
            if foundCell == 0 {
                
                var i = 1
                
                for i = 1; i <= x; i++ {
                    if masterMatrix[x-i] != 0 {continue}
                    if matrix[x-i] == 9 {matrix[x-i] = 0;  continue}
                    break
                }
                if i > x { return (matrix, 0)}
                prevCell = ++matrix[x-i]
                x -= (i + 1)
                
            } else {
                
                matrix[x] = foundCell
            }
            
        }
        return(matrix, iterations)
    }
    
    
    
    @IBAction func solveButtonTouchedDown(sender: AnyObject) {
        
        headLine.text = "ANALYZING..."
        guideText.text = ""
    }
    @IBAction func solveButtonPressed(sender: AnyObject) {
        
        headLine.text = "ANALYZING..."
        let finalSolution = SudokuSolution(originMatrix: originMatrix)
        
        if finalSolution.iterations == 0 {
            guideText.textColor = UIColor.yellowColor()
            headLine.text = ""
            guideText.text = "Sorry, the puzzle has no solution. Please check."
            solveButton.enabled = false
            hintButton.enabled = false
        } else {
            
            for i in 0...80 {
                
                if cells[i].text == "" {
                    cells[i].textColor = UIColor(red: 0.055, green: 0.5, blue: 1.0, alpha: 1.0)
                }
                cells[i].text = "\(finalSolution.matrix[i])"
                cells[i].enabled = false
                
                
            }
            
            headLine.text = "BINGO!"
            guideText.text = "The puzzle is done. Press Reset to start again."
            solveButton.enabled = false
            hintButton.enabled = false
        }
        
    }
    
    
    @IBAction func hintButtonTouchedDown(sender: AnyObject) {
        
        headLine.text = "ANALYZING..."
        guideText.text = ""
    }
    
    @IBAction func HintButtonPressed(sender: AnyObject) {
        
        
        var hintCell = 0
        let finalSolution = self.SudokuSolution(originMatrix: self.originMatrix)
        
        if  finalSolution.iterations == 0 {
            self.guideText.textColor = UIColor.yellowColor()
            self.headLine.text = ""
            self.guideText.text = "Sorry, the puzzle has no solution. Please check."
            
            
        } else {
            
            // Showing randomly selected correct number
            
            
            do { hintCell = Int(arc4random_uniform(UInt32(81)))
            } while self.originMatrix[hintCell] != 0
            self.originMatrix[hintCell] = finalSolution.matrix[hintCell]
            self.cells[hintCell].text = "\(self.originMatrix[hintCell])"
            self.cells[hintCell].textColor = UIColor(red: 0.055, green: 0.5, blue: 1.0, alpha: 1.0)
            self.headLine.text = ""
            self.guideText.text = "Try to find hidden numbers. Use 'Hint' to unveil random number, 'Solve' to show them all."
            
            for i in self.originMatrix  {
                if i == 0 {hintCell = 81; break}
            }
            
            if hintCell != 81 {
                self.headLine.text = "BINGO!"
                self.guideText.text = "The puzzle is done. Press Reset to start again"
                self.solveButton.enabled = false
                self.hintButton.enabled = false
            }
        }
    }
}
