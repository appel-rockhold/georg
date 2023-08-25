// This file is part of Georg, a macOS/iOS program for displaying and
// editing "geofeatures" on a map.
//
// Copyright (C) 2023  Michael E. Rockhold
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https:www.gnu.org/licenses/>.
//
//  ViewController.swift
//  Georg
//
//  Created by Michael Rockhold on 8/21/23.
//

import Cocoa
import MapKit

class ViewController: NSViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var mapCenter: MapCenter? = nil
            
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let mv = mapView, let mc = mapCenter {
            mv.setCenter(CLLocationCoordinate2D(latitude: CLLocationDegrees(mc.latitude), longitude: CLLocationDegrees(mc.longitude)), animated: false)
        }
    }

    override var representedObject: Any? {
        willSet {
            if representedObject != nil { return }
            guard let moc = newValue as? NSManagedObjectContext else { return }
            guard let result = try? moc.execute(MapCenter.fetchRequest()) as? NSAsynchronousFetchResult<MapCenter> else { return }
            guard let countOfContents = result.finalResult?.count else { return }
            
            if countOfContents == 0, let mc = (NSEntityDescription.insertNewObject(forEntityName: "MapCenter", into: moc) as? MapCenter) {
                mc.longitude = 0.0
                mc.latitude = 0.0
            }
        }
        didSet {
            if let result = try? (representedObject as? NSManagedObjectContext)?.execute(MapCenter.fetchRequest()) as? NSAsynchronousFetchResult<MapCenter> {
                if let mc = result.finalResult?[0], let mv = mapView {
                    mapCenter = mc
                    mv.setCenter(CLLocationCoordinate2D(latitude: CLLocationDegrees(mc.latitude), longitude: CLLocationDegrees(mc.longitude)), animated: false)
                }
            }
        }
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let cntr = mapView.centerCoordinate
        if let mc = mapCenter {
            mc.longitude = Double(cntr.longitude)
            mc.latitude = Double(cntr.latitude)
        }
    }

}
