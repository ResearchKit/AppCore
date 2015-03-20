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

class CatalogViewController: UITableViewController, ORKTaskViewControllerDelegate {

    var result: ORKResult?
    
    struct CatalogRow {
        var task: ORKTask
        var label: String
    }
    
    var tasks: [CatalogRow]
    
    required init(coder aDecoder: NSCoder) {
        
        tasks = []
        super.init(coder: aDecoder)
        
        tasks = [CatalogRow(task:buildConsentTask(), label: "Consent"),
                 CatalogRow(task:buildSurveyTask(), label: "Simple Survey"),
                 CatalogRow(task:buildFitnessTask(), label: "Fitness Check Active Task"),
                 CatalogRow(task:buildShortWalkTask(), label: "Short Walk Active Task"),
                 CatalogRow(task:buildAudioTask(), label: "Audio Active Task"),
                 CatalogRow(task:buildTwoFingerTappingIntervalTask(), label: "Two Finger Tapping Interval Active Task"),
                 CatalogRow(task:buildSpatialSpanMemoryTask(), label: "Spatial Span Memory Active Task"),
                 CatalogRow(task:buildBooleanQuestionTask(), label: "Boolean Question"),
                 CatalogRow(task:buildScaleQuestionTask(), label: "Scale Question"),
                 CatalogRow(task:buildValuePickerQuestionTask(), label: "Value Picker Question"),
                 CatalogRow(task:buildImageChoiceQuestionTask(), label: "Image choice Question"),
                 CatalogRow(task:buildTextChoiceQuestionTask(), label: "Text choice Question"),
                 CatalogRow(task:buildNumberQuestionTask(), label: "Number Question"),
                 CatalogRow(task:buildTimeOfDayQuestionTask(), label: "Time of Day Question"),
                 CatalogRow(task:buildDateTimeQuestionTask(), label: "Date and Time Question"),
                 CatalogRow(task:buildDateQuestionTask(), label: "Date Question"),
                 CatalogRow(task:buildTimeIntervalQuestionTask(), label: "Time Interval Question"),
                 CatalogRow(task:buildTextQuestionTask(), label: "Text Question"),
                 CatalogRow(task:buildFormTask(), label: "Form")]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let navigationController = self.tabBarController?.viewControllers?.last as UINavigationController
        navigationController.popToRootViewControllerAnimated(false)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = tasks[indexPath.row].label
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let task = tasks[indexPath.row].task
        let taskViewController = ORKTaskViewController(task: task, taskRunUUID: NSUUID())
        taskViewController.delegate = self
        
        self.presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    // MARK: - ORKTaskViewControllerDelegate
    
    func taskViewController(taskViewController: ORKTaskViewController!, didFinishWithResult result: ORKTaskViewControllerResult, error: NSError!) {
        
        self.result = taskViewController.result
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
