//
//  MapView.swift
//  MapView
//
//  Created by Lonnie Gerol on 8/10/21.
//

import MapKit
import SwiftUI

fileprivate class ColorPicker {
    private var currentColor = -1

    func getColor() -> UIColor {
        if currentColor == 4 {
            self.currentColor = -1
        } else {
            self.currentColor += 1
        }

        switch currentColor {
        case 0:
            return .red
        case 1:
            return .blue
        case 2:
            return .green
        case 3:
            return .orange
        default:
            return .systemPink
        }
    }
}


// https://codakuma.com/the-line-is-a-dot-to-you/
struct MapView: UIViewRepresentable {

    // let region: MKCoordinateRegion
    let lineCoordinates: [UUID: [CLLocationCoordinate2D]]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        // mapView.region = region
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        context.coordinator.update(coordinates: lineCoordinates, for: view)
    }

    // Link it to the coordinator which is defined below.
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude, lhs.longitude) == (rhs.latitude, rhs.longitude)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var currentCoordinates:  [UUID:[CLLocationCoordinate2D]] = [:]
    private var colorPicker = ColorPicker()

    func update(coordinates: [UUID: [CLLocationCoordinate2D]], for view: MKMapView) {
        if currentCoordinates == coordinates { return }

        for overlay in view.overlays {
            if let polyline = overlay as? MKPolyline {
                view.removeOverlay(polyline)
            }
        }

        for items in coordinates.values {
            let polyline = MKPolyline(coordinates: items, count: items.count)
            view.addOverlay(polyline)

        }

        if let first = view.overlays.first {
            let rect = view.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
            view.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: false)
        }

        currentCoordinates = coordinates
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = colorPicker.getColor()
            polyLineRenderer.lineWidth = 4.0

            return polyLineRenderer
        }

        return MKPolylineRenderer()
    }
}

