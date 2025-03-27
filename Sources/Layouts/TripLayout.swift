import Foundation
import Ignite


struct TripLayout: Layout {
    var body: some HTML {
        Head{
            /// Add leaflet
            MetaLink(href: "/ourtravels/css/leaflet.css", rel: .stylesheet)
            Script(file: "/ourtravels/leaflet/leaflet.js")
            
            /// Add leaflet plugin to create bezier curves
             Script(file: "/ourtravels/leaflet/leaflet.curve.js")
                            
            /// Add a zoombar
            MetaLink(href: "/ourtravels/zoombar/L.Control.ZoomBar.css", rel: .stylesheet)
            Script(file: "/ourtravels/zoombar/L.Control.ZoomBar.js")
            
            /// Add a navbar - gives forward and back buttons through navigation history
            MetaLink(href: "/ourtravels/navbar/Leaflet.NavBar.css", rel: .stylesheet)
            Script(file: "/ourtravels/navbar/Leaflet.NavBar.js")
            
            /// Add css for the map labels
            MetaLink(href: "/ourtravels/css/labels.css", rel: .stylesheet)
            /// Add css for the map legend
            MetaLink(href: "/ourtravels/css/legend.css", rel: .stylesheet)
            
            /// Add layer collision
            Script(file: "/ourtravels/label-collision/rbush.js")
            Script(file: "/ourtravels/label-collision/Leaflet.LayerGroup.Collision.js")
            
            /// Add css for the trip page layout
            MetaLink(href: "/ourtravels/css/trip.css", rel: .stylesheet)
        }
        Body {
            Section{
                content
            }
        }.ignorePageGutters()
    }
}
