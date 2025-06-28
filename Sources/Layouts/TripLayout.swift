import Foundation
import Ignite


struct TripLayout: Layout {
    var body: some Document {
        Head{
            /// Add css for the trip page layout
            MetaLink(href: "\(subsite)/css/peter.css", rel: .stylesheet)
            
            /// Add leaflet
            MetaLink(href: "\(subsite)/map/css/leaflet.css", rel: .stylesheet)
            Script(file: "\(subsite)/map/leaflet/leaflet.js")
            
            /// Add leaflet plugin to create bezier curves
             Script(file: "\(subsite)/map/leaflet/leaflet.curve.js")
                            
            /// Add a zoombar
            MetaLink(href: "\(subsite)/map/zoombar/L.Control.ZoomBar.css", rel: .stylesheet)
            Script(file: "\(subsite)/map/zoombar/L.Control.ZoomBar.js")
            
            /// Add a navbar - gives forward and back buttons through navigation history
            MetaLink(href: "\(subsite)/map/navbar/Leaflet.NavBar.css", rel: .stylesheet)
            Script(file: "\(subsite)/map/navbar/Leaflet.NavBar.js")

            /// Add css for the map labels
            MetaLink(href: "\(subsite)/map/css/labels.css", rel: .stylesheet)
            /// Add css for the map legend
            MetaLink(href: "\(subsite)/map/css/legend.css", rel: .stylesheet)

            /// Add layer collision
            Script(file: "\(subsite)/map/label-collision/rbush.js")
            Script(file: "\(subsite)/map/label-collision/Leaflet.LayerGroup.Collision.js")

            /// Add css for the trip page layout
            MetaLink(href: "\(subsite)/map/css/trip.css", rel: .stylesheet)
        }
        Body {
            Section{
                content
            }
        }.ignorePageGutters()
    }
}
