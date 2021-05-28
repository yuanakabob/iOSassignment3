//
//  ViewController.swift
//  MyReminders
//
//  Created by Chuanxu WANG on 3/20/20.



import UserNotifications
import UIKit
import Foundation
import CoreLocation

var myCustomViewController: WeatherViewController = WeatherViewController(nibName: nil, bundle: nil)
var getThatValue = myCustomViewController.weatherImage


class AlarmViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    var condition: String = ""
    var models = [MyReminder]()
    var weatherSoundName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        print (models.count)
        
        //use user default passing data to alarm
        if let item = UserDefaults.standard.value(forKey:"condition") as? String{
            self.condition = item
        }
        print("alarm + \(condition)")
        //user notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success {
                // schedule test
                print("success")
            }
            else if error != nil {
                print("error occurred")
            }
        })
    }
    
    @IBAction func didTapAdd() {
        // show add vc
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        //play different sounds according to weather
        switch weatherSoundName {
        case _ where condition == "Thunderstorm":
            weatherSoundName = "Swallowing Dust-30.wav"
        case _ where condition == "Drizzle":
            weatherSoundName = "Rain-30.wav"
        case _ where condition == "Rain":
            weatherSoundName = "LittleDarkAge-30.wav"
        case _ where condition == "Snow":
            weatherSoundName = "Snow-30.wav"
        case _ where condition == "Clouds":
            weatherSoundName = "JourneyToTheWest-30.wav"
        case _ where condition == "Clear":
            weatherSoundName = "clear-30.wav"
        default:
            weatherSoundName = "LittleDarkAge-30.wav"
            return
        }
        
        vc.title = "New Alarm"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = MyReminder(title: title, date: date, identifier: "id_\(title)")
                self.models.append(new)
                self.table.reloadData()
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: self.weatherSoundName))
                content.body = body
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                                          from: targetDate), repeats: false
                )
                let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("something went wrong")
                    }
                })
            }
        }
        navigationController?.pushViewController(vc, animated: true)
        print (models.count)
    }
}

extension AlarmViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AlarmViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        let date = models[indexPath.row].date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM dd    hh:mm a"
        cell.detailTextLabel?.text = formatter.string(from: date)
        
        cell.textLabel?.font = UIFont(name: "System", size: 25)
        cell.detailTextLabel?.font = UIFont(name: "System", size: 22)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            models.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            print (models.count)
            if models.count == 0 {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["some_long_id"])
            }
        }
    }
}

struct MyReminder {
    let title: String
    let date: Date
    let identifier: String
}
