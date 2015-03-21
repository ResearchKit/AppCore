/*
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import ResearchKit

struct TableRow {
    var label: String?
    var value: String?
    var image: UIImage?
    
    init(label: String?, value: String?) {
        self.label = label
        self.value = value
    }
    
    init(image: UIImage?) {
        self.image = image
    }
}

extension ORKResult {
    
    func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return ResultTableViewProvider(result: self)
    }
    
    class ResultTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
        
        var result: ORKResult
        
        init!(result: ORKResult!) {
            self.result = result
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.tableRows(section).count
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return UITableViewAutomaticDimension
        }
        
        func tableRows(section: Int) -> [TableRow] {
            
            return (section == 0) ? [TableRow(label: "type", value: NSStringFromClass(result.dynamicType)),
                TableRow(label: "identifier", value: result.identifier),
                TableRow(label: "start", value: result.startDate?.description),
                TableRow(label: "end", value: result.endDate?.description)] : []
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
            
            let row = indexPath.row
            
            let tableRow = self.tableRows(indexPath.section)[row] as TableRow
            
            cell.detailTextLabel?.text = tableRow.value
            cell.textLabel?.text = tableRow.label
            
            if tableRow.image != nil {
                for view in cell.contentView.subviews {
                    view.removeFromSuperview()
                }
                let imageView = UIImageView(image: tableRow.image)
                imageView.frame = cell.bounds
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                cell.contentView.addSubview(imageView)
            }
            
            return cell
        }
    }
}

extension ORKScaleQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return ScaleQuestionResultTableViewProvider(result: self)
    }
    
    class ScaleQuestionResultTableViewProvider: ORKQuestionResult.ResultTableViewProvider {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let scaleQuestionResult = result as ORKScaleQuestionResult
        
            return super.tableRows(section) +
                [TableRow(label: "scaleAnswer", value: scaleQuestionResult.scaleAnswer?.description)]
        }
    }
}

extension ORKNumericQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return NumericQuestionResultTableViewProvider(result: self)
    }
    
    class NumericQuestionResultTableViewProvider: ORKQuestionResult.ResultTableViewProvider {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKNumericQuestionResult
            
            return super.tableRows(section) +
                [TableRow(label: "numericAnswer", value: questionResult.numericAnswer?.description)]
        }
    }
}

extension ORKTimeOfDayQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return TimeOfDayQuestionResultTableViewProvider(result: self)
    }
    
    class TimeOfDayQuestionResultTableViewProvider: ORKQuestionResult.ResultTableViewProvider {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKTimeOfDayQuestionResult
            let date = questionResult.dateComponentsAnswer
            let value = "\(date.hour) : \(date.minute)"
            return super.tableRows(section) + [TableRow(label: "dateComponentsAnswer", value: value)]
        }
    }
}

extension ORKDateQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return DateQuestionResultTableViewProvider(result: self)
    }
    
    class DateQuestionResultTableViewProvider: ORKQuestionResult.ResultTableViewProvider {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKDateQuestionResult
            
            return super.tableRows(section) +
                [TableRow(label: "dateAnswer", value: questionResult.dateAnswer?.description),
                    TableRow(label: "calendar", value: questionResult.calendar?.calendarIdentifier),
                    TableRow(label: "timeZone", value: questionResult.timeZone?.description)]
        }
    }
}

extension ORKTimeIntervalQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return TimeIntervalQuestionResultTableViewProvider(result: self)
    }
    
    class TimeIntervalQuestionResultTableViewProvider: ORKQuestionResult.ResultTableViewProvider {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKTimeIntervalQuestionResult
            
            return super.tableRows(section) +
                [TableRow(label: "intervalAnswer", value: questionResult.intervalAnswer?.description)]
        }
    }
}

extension ORKTextQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return TimeIntervalQuestionResultTableViewProvider(result: self)
    }
    
    class TimeIntervalQuestionResultTableViewProvider: ORKQuestionResult.ResultTableViewProvider {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKTextQuestionResult
            
            return super.tableRows(section) +
                [TableRow(label: "textAnswer", value: questionResult.textAnswer)]
        }
    }
}

extension ORKTappingIntervalResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return TappingIntervalResultTableViewProvider(result: self)
    }
    
    class TappingIntervalResultTableViewProvider: ORKResult.ResultTableViewProvider {
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 2
        }
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKTappingIntervalResult
            
            var rows: [TableRow] = []
            
            if section == 0 {
                rows =  [TableRow(label: "stepViewSize", value: NSStringFromCGSize(questionResult.stepViewSize)),
                    TableRow(label: "buttonRect1", value: NSStringFromCGRect(questionResult.buttonRect1)),
                    TableRow(label: "buttonRect2", value: NSStringFromCGRect(questionResult.buttonRect2))]
            }
            else
            {
                for sample in questionResult.samples {
                    let tappingSample = sample as ORKTappingSample
                    let button = (tappingSample.buttonIdentifier == .None) ? "None" : "button \(tappingSample.buttonIdentifier.rawValue)"
                    rows = rows + [TableRow(label: NSString(format: "%.3f", tappingSample.timestamp), value: button + "  " + NSStringFromCGPoint(tappingSample.location))]
                }
            }
            
            return super.tableRows(section) + rows
        }
        
        func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return (section == 0) ? "Result" : "Samples"
        }
        
        func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return false
        }
    }
}

extension ORKSpatialSpanMemoryResult {

    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return SpatialSpanMemoryResultTableViewProvider(result: self)
    }
    
    class SpatialSpanMemoryResultTableViewProvider: ORKResult.ResultTableViewProvider {
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 2
        }
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKSpatialSpanMemoryResult
            
            var rows: [TableRow] = []
            
            if section == 0 {
                rows =  [TableRow(label: "score", value: "\(questionResult.score)"),
                    TableRow(label: "numOfGames", value: "\(questionResult.numberOfGames)"),
                    TableRow(label: "numOfFailures", value: "\(questionResult.numberOfFailures)")]
            } else {
                for record in questionResult.gameRecords {
                    let gameRecord = record as ORKSpatialSpanMemoryGameRecord
                    rows = rows + [TableRow(label:  "Game", value: "\(gameRecord.score)")]
                }
            }
            
            return super.tableRows(section) + rows
        }
        
        func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return (section == 0) ? "Result" : "Game Records"
        }
        
        func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return false
        }
    }
}

extension ORKFileResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return FileResultTableViewProvider(result: self)
    }
    
    class FileResultTableViewProvider: ORKResult.ResultTableViewProvider {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let questionResult = result as ORKFileResult
            
            return super.tableRows(section) +
                [TableRow(label: "contentType", value: questionResult.contentType),
                  TableRow(label: "fileURL", value: questionResult.fileURL?.description)]
        }
    }
}

extension ORKConsentSignatureResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return ConsentSignatureResultTableViewProvider(result: self)
    }
    
    class ConsentSignatureResultTableViewProvider: ORKResult.ResultTableViewProvider {
        
        override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            
            if indexPath.row == (self.tableRows(indexPath.section).count - 1) {
                return 120
            }
            
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let signatureResult = result as ORKConsentSignatureResult
            let signature: ORKConsentSignature = signatureResult.signature
            
            return super.tableRows(section) +
                [TableRow(label: "identifier", value: signature.identifier),
                    TableRow(label: "title", value: signature.title),
                    TableRow(label: "Given Name", value: signature.givenName),
                    TableRow(label: "Family Name", value: signature.familyName),
                    TableRow(label: "Date", value: signature.signatureDate),
                    TableRow(image: signature.signatureImage)]
        }
    }
}

extension ORKChoiceQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return ChoiceQuestionResultTableViewProvider(result: self)
    }
    
    class ChoiceQuestionResultTableViewProvider: ORKResult.ResultTableViewProvider   {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let choiceResult = result as ORKChoiceQuestionResult
            
            return super.tableRows(section) +
                [TableRow(label: "choices", value: choiceResult.choiceAnswers?.description)]
        }
    }
}

extension ORKBooleanQuestionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return BooleanQuestionResultTableViewProvider(result: self)
    }
    
    class BooleanQuestionResultTableViewProvider: ORKResult.ResultTableViewProvider   {
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let boolResult = result as ORKBooleanQuestionResult
            
            return super.tableRows(section) +
                [TableRow(label: "bool", value: boolResult.booleanAnswer.boolValue ? "YES" : "NO")]
        }
    }
}

extension ORKCollectionResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return CollectionResultTableViewProvider(result: self)
    }
    
    class CollectionResultTableViewProvider: ORKResult.ResultTableViewProvider {
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 2
        }
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let collectionResult = result as ORKCollectionResult
            
            var rows: [TableRow] = []
            
            if section == 1 {
                for subResult in collectionResult.results {
                    rows = rows + [TableRow(label: NSStringFromClass(subResult.dynamicType), value: subResult.identifier)]
                }
            }
            
            return super.tableRows(section) + rows
        }
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            
            cell.accessoryType = (indexPath.section == 0) ? .None : .DisclosureIndicator
            
            return cell
            
        }
        
        func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return (section == 0) ? "Result" : "Sub Results"
        }
        
        func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return indexPath.section == 1
        }
    }
}

extension ORKTaskResult {
    
    override func resultTableViewProvider() -> protocol<UITableViewDataSource, UITableViewDelegate> {
        return TaskResultTableViewProvider(result: self)
    }
    
    class TaskResultTableViewProvider: ORKCollectionResult.CollectionResultTableViewProvider {
        
        
        override func tableRows(section: Int) -> [TableRow] {
            
            let taskResult = result as ORKTaskResult
            
            var rows: [TableRow] = []
            
            if section == 0 {
                
                rows = [TableRow(label: "taskRunUUID", value: taskResult.taskRunUUID.UUIDString),
                    TableRow(label: "outputDirectory", value: taskResult.outputDirectory?.description)]
                
            }
            
            return super.tableRows(section) + rows
        }
    }
}
