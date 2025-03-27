import Foundation
import Ignite
import CodableCSV


enum TransportModes: String, CaseIterable{
    case car = "000000"
    case plane = "3CB44B"
    case train = "a9a9a9"
    case bus = "E6194B"
    case ferryOrShip = "4363D8"
    case campervan = "F032E6"
    case motorbike = "9A6324"
    case cablecar = "42D4F4"
}


/// Can't make variables lowercase without also changing .csv files or using CodingKeys
struct CSVStop: Codable {
    let Location: String
    let LatLong: String
    let Curvature: Double
    let Stop: Int
    let Mode: Int
    let Notes: String
}


struct TripPage: ArticlePage{
    @Environment(\.decode) var decode
    
    var layout = TripLayout()
    
    var body: some HTML{
        let decoder = CSVDecoder {
            $0.delimiters.field = "\t"
            $0.headerStrategy = .firstLine
        }
        
        /// Get the trip URL from the content YAML and decode the stops
        let url = article.metadata["tsv"] as! String
        let fullURL = decode.url(forResource: "/trips/" + url)
        
        let fileContents = try! String(contentsOf: fullURL!, encoding: .utf8).replacingOccurrences(of: "\r\n", with: "\n")
        let stops = try! decoder.decode([CSVStop].self, from: fileContents)
        
        /// Get the map bounds from the content YAML
        let map = createMap(bounds: article.metadata["mapbounds"] as! String)
        /// Add curves and markers. Markers go on top.
        let curves = mapCurves(stops: stops)
        let markers = mapMarkers(stops: stops)
        let legendAndMapControls = legendAndMapControls(data: decode.data(forResource: "legend.svg")!)
        let labels = addLabels(stops: stops)
        
        Section{
            /// Title and blurb
            Section{
                Section{
                    Link(Image(systemName: "arrow-left"), target: "/" + subsite)
                        .font(.title3)
                        .margin(.leading, -33)
                        .margin(.trailing, 5)
                    Text(article.subtitle ?? article.metadata["title"] as! String)
                        .font(.title2)
                }.class("d-flex justify-content-left")  /// 'bootstrap' - place side by side
                Text(article.text)
                    .margin(.top, -15)
            }.class("top-content")
            
            /// Map and sidebar
            Section{
                Sidebar(stops: stops, excursionStr: article.metadata["excursions"] as? String ?? "[]")
                Section{
                    /// This is where the map will appear because this section has a 'map' id
                    /// This script creates the map and adds markers, labels, curves and other items
                    Script(code: map + curves + markers + legendAndMapControls + labels)
                    /// Initialise the pulsating icon marker
                    Script(code: initPulsatingIcon())
                }.id("map")
                    .onClick{
                        CustomAction(cancelPulse())
                    }
            }.class("map-sidebar-container")

            TripFooter()
        }.class("flex-container")
    }
}


/// Sidebar list
struct Sidebar: HTML {
    let stops: [CSVStop]
    let excursionStr: String
    
    var body: some HTML {
        Section{
            List{
                ZStack{
                    let stopList = stops.filter({ $0.Stop != 3 })
                    let excursions = decodeExcusions(excursions: excursionStr)

                    DrawExcursions(stops: stopList, excursions: excursions)
                    Section{
                        var count = 0
                        ForEach(stopList){ stop in
                            Section{
                                Text(addSpace(index: &count, excursions: excursions) + stop.Location)
                                    .onClick{
                                        CustomAction(stopItemClicked(stop: stop))
                                    }
                                    .class("listItem")
                            }
                        }
                    }
                }
            }.class("listbox")
        }.class("sidebar")
    }
}


func stopItemClicked(stop: CSVStop) ->String{
    let point = parsePoint(from: stop.LatLong)
    
    return """
        stopItemClicked("\(stop.Location)",\(point.x), \(point.y))
    """
}


func cancelPulse() ->String{
    return """
        map.removeLayer(marker);
        sessionStorage.setItem("location", "");
    """
}


func initPulsatingIcon()->String{
    
    return """
        const generatePulsatingMarker = function(){
            const cssStyle = `margin-left:-2px;
            margin-top:-2px;
            width: 16px;
            height: 16px;
            background: none;
            color: red;`
            return L.divIcon({html: `<span style="${cssStyle}" class="pulse"/>`,className: 'pulsatingIcon'})
        }
    
        const stopItemClicked = function(location, lat, long){
            map.removeLayer(marker);
            
            if (sessionStorage.getItem("location") == location){
                sessionStorage.setItem("location", "");
            } else {
                marker.setLatLng([lat, long]);
                marker.addTo(map);
                map.setView(marker.getLatLng(), map.getZoom());
                sessionStorage.setItem("location", location);
            }
        }
            
        // Create Pulsating Marker
        var marker = L.marker([0, 0], {
            icon: generatePulsatingMarker()
        })
          
        // Have to initialise the storage
        sessionStorage.setItem("location", "");
    """
}


/// Create a map using the passed in bounds
func createMap(bounds: String) ->String{
    
    return """
        const map = L.map('map',{
            zoomDelta: 0.25,    // Controls zoom increment (default is 1)
            zoomSnap: 0.25,     // Snaps zoom to multiples of this value (default is 1)
            zoomControl: false
        });
        
        
        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
           attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        }).addTo(map);
        
        // Fit the map to the bounds with optional padding
        map.fitBounds([\(bounds)],{
        });
    """
}


/// Add labels to a collision layer, then add the collision layer to the map.
func addLabels(stops: [CSVStop]) ->String{
    /// Filter stops for duplicates and 'don't show'.
    let filtered = stops.reduce(into: [CSVStop]()){ result, stop in
        if !result.contains(where: { $0.Location == stop.Location && $0.Stop != 3 }){
            result.append(stop)
        }
    }
    /// Sort filtered stops by priority.
    let sorted = filtered.sorted{
        $0.Stop < $1.Stop
    }
    
    var labelStr = "collisionLayer = L.LayerGroup.collision({margin:0});"
    
    /// NOTE: empty className in the icon prevents another small box from appearing as a label as well
    for stop in sorted{
        labelStr += """
             var label = L.marker([\(stop.LatLong)],{
             icon: L.divIcon({
             iconAnchor:[-10,11],
             className: '',
             html:"<div class = 'city-label city-label-0'>\(stop.Location)</div>"
             }),
             interactive: false,
             clickable:   false,
             });
             collisionLayer.addLayer(label);
        """
    }
    
    labelStr += "collisionLayer.addTo(map);"
    
    return labelStr
}


/// Create a legend panel on the map. The SVG contains the actual drawing. Also add zoombar and navbar.
func legendAndMapControls(data: Data) ->String{
    var svg = String(decoding: data, as: UTF8.self)
    svg = svg.components(separatedBy: .newlines).joined()
    
    return """
        var legend = L.control({ position: "bottomleft" });
    
        legend.onAdd = function(map) {
            var div = L.DomUtil.create("div", "legend");
            div.innerHTML = '\(svg)';
    
            return div;
        };
    
        legend.addTo(map);
    
        var zoom_bar = new L.Control.ZoomBar({position: 'topleft'}).addTo(map);
        L.control.navbar().addTo(map);
    """
}


/// Create a list of markers to place on the map.
func mapMarkers(stops: [CSVStop]) ->String{
    var markerListStr = ""
    var radius = 5
    var fillColor = ""
    
    for stop in stops{
        switch stop.Stop{
        case 0:
            radius = 8
            fillColor = "#FF4D00"
        case 1:
            radius = 5
            fillColor = "#CEFA05"
        case 2:
            radius = 4
            fillColor = "#000000"
        default:
            continue
        }
        
        let marker = """
            var marker = new L.CircleMarker([\(stop.LatLong)], {
                       radius: \(radius),
                       fillColor: "\(fillColor)",
                       color: "#000",
                       weight: 1.7,
                       opacity: 1,
                       fillOpacity: 1,
                   });
             marker.addTo(map);
        """
        
        markerListStr += marker
    }
    
    return markerListStr
}


func parsePoint(from string: String) ->CGPoint{
    /// Split the string by comma and trim whitespace
    let components = string.split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
    
    return CGPoint(x:Double(components[0])!, y:Double(components[1])!)
}


/// Draw curves between markers. Uses leaflet.curve.js
func mapCurves(stops: [CSVStop]) ->String{
    var curveListStr = ""
    
    guard stops.count > 0 else { return "" }
    
    (0...stops.count - 2).forEach{ index in
        let start = parsePoint(from: stops[index].LatLong)
        let end = parsePoint(from: stops[index + 1].LatLong)
        let curvature = stops[index].Curvature
        let mode = stops[index].Mode
        
        if mode != 100{
            let e = CGPoint(x:end.x - start.x, y:end.y - start.y)               /// endpoint (end relative to start)
            let m = CGPoint(x:e.x/2, y:e.y/2)                                   /// midpoint
            let o = CGPoint(x:e.y, y:-e.x)                                      /// orthogonal
            let c = CGPoint(x:m.x + curvature * o.x, y:m.y + curvature * o.y)   /// curve control point
            
            let curve = """
                var curve = L.curve(
                [
                 'M', [\(start.x),\(start.y)], 
                 'Q', [\(start.x + c.x),\(start.y + c.y)],
                 [\(end.x),\(end.y)]
                ],
                {
                 color: '#\(TransportModes.allCases[mode].rawValue)',
                 weight: 2.0
                }
                ).addTo(map);
            """
            curveListStr += curve
        }
    }
    
    return curveListStr
}
