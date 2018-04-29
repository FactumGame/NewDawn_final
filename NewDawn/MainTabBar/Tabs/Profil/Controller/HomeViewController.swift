//
//  HomeViewController.swift
//  NewDawn
//
//  Created by Mathieu Janneau on 13/03/2018.
//  Copyright © 2018 Mathieu Janneau. All rights reserved.

// swiftlint:disable trailing_whitespace

import UIKit
import JTAppleCalendar
import Firebase
import FirebaseDatabase
/// Profil view controller which displays a user summary
/// and let him access to his personnal data
class HomeViewController: UIViewController {
  var currentUser = ""
  // ////////////////// //
  // MARK: - PROPERTIES //
  // ////////////////// //
  var data = [Challenge]()
  var selectedChallenge: Challenge?
  /// Reuse id for challenge table view cells
  let reuseId = "myCell"
  let dateFormatter = DateFormatter()
  var iii: Date?
  open var events: [String] = []
  
  var databaseRef : DatabaseReference = {
    return Database.database().reference()
  }()
  
  // ////////////////// //
  // MARK: - OUTLETS    //
  // ////////////////// //
  

  @IBOutlet var moodButtons: [CustomUIButtonForUIToolbar]!
  @IBOutlet weak var calendarView: JTAppleCalendarView!
  @IBOutlet weak var montDisplay: UILabel!
  // ///////////////////////// //
  // MARK: - LIFECYCLE METHODS //
  // ///////////////////////// //

  override func viewDidLoad() {

    super.viewDidLoad()
    // load logged user
    if let user = UserDefaults.standard.object(forKey: "currentUser") as? String {
      currentUser = user
    }
    
    // load Challenges for current User
    data = CoreDataService.loadData(for: currentUser)
    for item in data {
    dateFormatter.dateFormat = DateFormat.annual.rawValue
      let eventDate = dateFormatter.string(from: Date(timeIntervalSince1970: item.dueDate))
      events.append(eventDate)
    }
   
    // set up notification observers
    handleNotifications()
    shouldDisplayUI()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    data = CoreDataService.loadData(for: currentUser)
    calendarView.reloadData()
  }
  // ////////////////// //
  // MARK: - UI         //
  // ////////////////// //
  
  fileprivate func shouldDisplayUI() {
  
    // set up of mood button color behavior on tap
    for button in moodButtons {
      button.typeOfButton = .imageButton
    }
    
    let rightButton: UIBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addChallenge))
    self.navigationItem.rightBarButtonItem = rightButton
    setupCalendarView()
  }
  func setupCalendarView() {
    // register cell
    let nib = UINib(nibName: "CalendarCell", bundle: nil)
    let headerNib = UINib(nibName: "headerView", bundle: nil)
    calendarView.register(nib, forCellWithReuseIdentifier: "dateCell")
    calendarView.register(headerNib, forSupplementaryViewOfKind: "header", withReuseIdentifier: "header")
    // UI appearance settings
    calendarView.minimumLineSpacing = 0
    calendarView.minimumInteritemSpacing = 0
    calendarView.backgroundColor = .clear
    // delegation attribtution
    calendarView.ibCalendarDelegate = self
    calendarView.ibCalendarDataSource = self
    calendarView.isScrollEnabled = false
    calendarView.scrollToDate(Date(),animateScroll: false)
    calendarView.selectDates([Date()])
    calendarView.scrollingMode = .stopAtEachCalendarFrame
    self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
      self.setupViewsOfCalendar(from: visibleDates)
    }
   
    
  }
  
  fileprivate func handleNotifications() {
    NotificationCenter.default.addObserver(self, selector:#selector(addChallenge), name: NSNotification.Name(rawValue: "calendarActive"), object: nil)

    print(currentUser)
  }
  // ////////////////// //
  // MARK: - ACTIONS    //
  // ////////////////// //
  
  /// handle the color display behavior when user tap a button
  ///
  /// - Parameter sender: CustomUIButtonForUIToolbar
  @IBAction func moodButtonTapped(_ sender: CustomUIButtonForUIToolbar) {
    evaluateMoodButtonState()
    
    CoreDataService.saveMood(user: currentUser, date: Date(), value: sender.tag)
    let moodRef = databaseRef.child("moods").childByAutoId()
    let moodToStore = TempMood(user: currentUser, state: sender.tag, date: Date().timeIntervalSince1970)
    moodRef.setValue(moodToStore.toAnyObject())
    sender.userDidSelect()
  }
  
  @IBAction func previousMonth(_ sender: UIButton) {
    calendarView.scrollToSegment(.previous)
    calendarView.reloadData()
  }
  @IBAction func nextMonth(_ sender: UIButton) {
    calendarView.scrollToSegment(.next)
    calendarView.reloadData()
  }
  

  /// Iterate throught all mood buttons state and reset to
  /// initial color to allow user to to color the last selected Mood
  fileprivate func evaluateMoodButtonState() {
    for moodButton in moodButtons where moodButton.choosen {  
      moodButton.reset()
    }
  }
  
  
  
  // ////////////////// //
  // MARK: - SELECTORS  //
  // ////////////////// //
 func showChallenge() {
    if let challengeToPresent = selectedChallenge{
      let challengeVc = ProgressViewController()
      challengeVc.challenge = challengeToPresent
      self.navigationController?.pushViewController(challengeVc, animated: true)
      }
    
  }
  
  @objc func addChallenge() {
    let alert = UIAlertController(title: "Add a New Challenge", message: "", preferredStyle: .actionSheet) // 1
    let firstAction = UIAlertAction(title: "New Challenge", style: .default) { (alert: UIAlertAction!) -> Void in
      let objVc = ObjectiveViewController()
      // Renvoyer la date
      self.navigationController?.pushViewController(objVc, animated: true)
    } // 2
    
    let secondAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
      NSLog("You pressed button two")
    } // 3
    
    alert.addAction(firstAction) // 4
    alert.addAction(secondAction) // 5
    present(alert, animated: true, completion:nil) // 6
  }
}