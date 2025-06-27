import Foundation
import Ignite

@main
struct IgniteWebsite {
    static func main() async {
        var site = OurTravelSite()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}


let subsite = ""

struct OurTravelSite: Site {
    var name = "Our Trips"
    var titleSuffix = ""
    var url = URL(static: "https://www.zegelin.com")
    
    var builtInIconsEnabled = true

    var author = "Peter"

    var homePage = Home()
    var layout = MainLayout()
    
    var lightTheme: (any Theme)? = nil
    
    var articlePages: [any ArticlePage] {
        TripPage()
    }
}
