//
//  MapSnapshot.swift
//  MapSnapshot
//
//  Created by Lonnie Gerol on 8/11/21.
//

import MapKit
import HealthKit

struct MapSnapshotter {
    static func generateSnapshot(size: CGSize, coordinates: [CLLocationCoordinate2D] ) async throws -> UIImage {
        let options = MKMapSnapshotter.Options()
        options.size = CGSize(width: 240, height: 240)
        options.showsBuildings = true
        options.mapType = .standard
        options.pointOfInterestFilter = .excludingAll
        if coordinates.count > 0 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            // options.region = MKCoordinateRegion(polyline.boundingMapRect)
            options.mapRect = polyline.boundingMapRect
        }
        let snapshotter = MKMapSnapshotter(options: options)
        do {
            let snapshot = try await snapshotter.start()
            let mapImage = snapshot.image
            let finalImage = UIGraphicsImageRenderer(size: mapImage.size).image { _ in

                mapImage.draw(at: .zero)

                guard coordinates.count > 1 else { return }

                let points = coordinates.map { coordinate in
                    snapshot.point(for: coordinate)
                }
                // build a bezier path using that `[CGPoint]`

                let path = UIBezierPath()
                path.move(to: points[0])

                for point in points.dropFirst() {
                    path.addLine(to: point)
                }

                path.lineWidth = 3
                UIColor.red.setStroke()
                path.stroke()
            }

            return finalImage
        } catch {
            print(error.localizedDescription)
            return UIImage()
        }
    }
}
