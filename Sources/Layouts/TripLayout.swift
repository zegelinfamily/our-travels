import Foundation
import Ignite


struct TripLayout: Layout {
    var body: some Document {
        Head{
            /// Add leaflet
            MetaLink(href: "/css/leaflet.css", rel: .stylesheet)
            Script(file: "/leaflet/leaflet.js")
            
            /// Add leaflet plugin to create bezier curves
             Script(file: "/leaflet/leaflet.curve.js")
                            
            /// Add a zoombar
            MetaLink(href: "/zoombar/L.Control.ZoomBar.css", rel: .stylesheet)
            Script(file: "/zoombar/L.Control.ZoomBar.js")
            
            /// Add a navbar - gives forward and back buttons through navigation history
            MetaLink(href: "/navbar/Leaflet.NavBar.css", rel: .stylesheet)
            Script(file: "/navbar/Leaflet.NavBar.js")
            
            /// Add css for the map labels
            MetaLink(href: "/css/labels.css", rel: .stylesheet)
            /// Add css for the map legend
            MetaLink(href: "/css/legend.css", rel: .stylesheet)
            
            /// Add layer collision
            Script(file: "/label-collision/rbush.js")
            Script(file: "/label-collision/Leaflet.LayerGroup.Collision.js")
            
            /// Add css for the trip page layout
            MetaLink(href: "/css/trip.css", rel: .stylesheet)
        }
        Body {
            Section{
                content
            }
        }.ignorePageGutters()
    }
}
