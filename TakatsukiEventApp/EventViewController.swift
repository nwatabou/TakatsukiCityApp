//
//  EventViewController.swift
//  TakatsukiEventApp
//
//  Created by 仲西 渉 on 2016/11/07.
//  Copyright © 2016年 nwatabou. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class EventViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{
    
    @IBOutlet weak var myMapView: MKMapView!
    
    var eventData:[[String]] = []
    var facilityData:[[String]] = []
    
    var selectEventTitle:String = ""
    
    var myLocationManager:CLLocationManager = CLLocationManager()
    
    let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
    
    var myLat: CLLocationDegrees!
    var myLong: CLLocationDegrees!
    
    //最初からあるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲート先を自分に設定する。
        myMapView.delegate = self
        myLocationManager.delegate = self
        
        //位置情報の利用許可を変更する画面をポップアップ表示する。
        myLocationManager.requestWhenInUseAuthorization()
        
        //位置情報の取得を要求する。
        myLocationManager.requestLocation()
        
        loadCSV()
        
        //日付，時刻のフォーマット
        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "yyyy-MM-dd"
        let nowDate = formatterDate.string(from: NSDate() as Date)
        print(nowDate)
        
        let formatterTime = DateFormatter()
        formatterTime.dateFormat = "HH:mm:ss"
        let nowTime = formatterTime.string(from: NSDate() as Date)
        print(nowTime)
        
        
        for i in 0 ..< eventData.count {
            for j in 0 ..< facilityData.count {
                if(eventData[i][2] == facilityData[j][1]) {
                    
                    
                    //let eventDate = formatterDate.date(from: eventData[i][3])
                    //let eventStartTime = formatterTime.date(from: eventData[i][4])
                    
                    /*
                    if(calendar.isDateInToday(eventDate!)) {
                        let lat:CLLocationDegrees = atof(facilityData[j][5])
                        let long:CLLocationDegrees = atof(facilityData[j][6])
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
                        annotation.title = eventData[i][1]
                        annotation.subtitle = eventData[i][2]
                        myMapView.addAnnotation(annotation)
                    }
 */
                    let lat:CLLocationDegrees = atof(facilityData[j][5])
                    let long:CLLocationDegrees = atof(facilityData[j][6])
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
                    annotation.title = eventData[i][1]
                    annotation.subtitle = eventData[i][2]
                    myMapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    
    
    //位置情報取得時の呼び出しメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        for location in locations {
            //現在位置をマップの中心にする。
            myLat = location.coordinate.latitude
            myLong = location.coordinate.longitude
            
            let center = CLLocationCoordinate2DMake(myLat, myLong)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(center, span)
            myMapView.setRegion(region, animated:true)
        }
        
        
    }
    
    
    
    //位置情報取得失敗時の呼び出しメソッド
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    //アノテーションビューを返すメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //現在位置の点滅がピンにならないように、アノテーションがUserLocationの場合は何もしないようにする。
        if( annotation is MKUserLocation ) {
            return nil
        }
        
        //アノテーションビューを生成する。
        let myView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        //吹き出しを表示可能にする。
        myView.canShowCallout = true
        
        //経路ボタンをアノテーションビューに追加する。
        let button = UIButton()
        button.frame = CGRect(x:0,y:0,width:40,height:30)
        button.setTitle("経路", for: .normal)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(UIColor.white, for:.highlighted)
        myView.leftCalloutAccessoryView = button
        
        let detailButton = UIButton(type: UIButtonType.detailDisclosure)
        myView.rightCalloutAccessoryView = detailButton
        
        return myView
    }
    
    
    //ピンタップ時の処理
    //ピンと現在地の中間地点を中心に設定，移動時間を計測
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("イベントTap")
        
        let requestLat: CLLocationDegrees = view.annotation!.coordinate.latitude
        let requestLong: CLLocationDegrees = view.annotation!.coordinate.longitude
        
        let requestCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(requestLat, requestLong)
        let fromCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLong)
        
        print(requestCoordinate)
        print(fromCoordinate)
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake((myLat + requestLat)/2, (myLong + requestLong)/2)
        
        myMapView.setCenter(center, animated: true)
        
        
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        
        myMapView.region = myRegion
        self.view.addSubview(myMapView)
        
        
        let fromPlace: MKPlacemark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlace: MKPlacemark = MKPlacemark(coordinate: requestCoordinate, addressDictionary: nil)
        
        
        let fromItem: MKMapItem = MKMapItem(placemark: fromPlace)
        let toItem: MKMapItem = MKMapItem(placemark: toPlace)
        
        let myRequest: MKDirectionsRequest = MKDirectionsRequest()
        
        myRequest.source = fromItem
        myRequest.destination = toItem
        
        //myRequest.requestsAlternateRoutes = true
        myRequest.requestsAlternateRoutes = true
        
        myRequest.transportType = MKDirectionsTransportType.automobile
        
        let myDirections: MKDirections = MKDirections(request: myRequest)
        
        myDirections.calculate { (response, error) in
            
            if error != nil || response!.routes.isEmpty {
                print("return")
                return
            }
            
            let route: MKRoute = response!.routes[0] as MKRoute
            print("目的地まで \(Double(route.distance)/1000)km")
            print("所要時間 \(Int(route.expectedTravelTime/60))分")
        }
    }
    
    
    //ボタン押下時の呼び出しメソッド
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if(control == view.leftCalloutAccessoryView) {
            
            //マップアプリに渡す目的地の位置情報を作る。
            let coordinate = CLLocationCoordinate2DMake(view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude)
            let placemark = MKPlacemark(coordinate:coordinate, addressDictionary:nil)
            let mapItem = MKMapItem(placemark: placemark)
            
            //起動オプション
            let option:[String:AnyObject] = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit as AnyObject, //公共交通機関で移動
                MKLaunchOptionsMapTypeKey : MKMapType.hybrid.rawValue as AnyObject]  //地図表示はハイブリッド
            //マップアプリを起動する。
            mapItem.openInMaps(launchOptions: option)
            
            
        }else if(control == view.rightCalloutAccessoryView){
            print(view.annotation!.title! ?? "")
            selectEventTitle = view.annotation!.title! ?? ""
            segueToCommentViewController()
        }
    }
    
    //csvファイルの読み込み
    func loadCSV(){
        var csvString = ""
        
        //イベント情報読み込み
        let eventURL = NSURL(string: "http://linkdata.org/api/1/rdf1s4721i/takatsuki_event.csv")
        
        do {
            csvString = try NSString(contentsOf: eventURL as! URL, encoding: String.Encoding.utf8.rawValue) as String
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        csvString.enumerateLines { (line, stop) -> () in
            self.eventData.append(line.components(separatedBy: ","))
        }
        
        
        //施設情報読み込み
        let facilityURL = NSURL(string: "http://linkdata.org/api/1/rdf1s4730i/takatsuki_facility.csv")
        
        do {
            csvString = try NSString(contentsOf: facilityURL as! URL, encoding: String.Encoding.utf8.rawValue) as String
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        csvString.enumerateLines { (line, stop) -> () in
            self.facilityData.append(line.components(separatedBy: ","))
        }
    }
    
    func segueToCommentViewController() {
        self.performSegue(withIdentifier: "comment", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comment" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.selectEventTitle = selectEventTitle
            commentViewController.eventData = eventData
            commentViewController.facilityData = facilityData
            
        }
    }
}

