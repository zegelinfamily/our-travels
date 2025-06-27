import Foundation
import Ignite


struct Home: StaticPage{
    @Environment(\.articles) var content
    var title = "Home"
    
    var body: some HTML{
        Section{
            Text("Our Travels").horizontalAlignment(.center).font(.title1)
           // ThemeSwitcher().style(.marginTop, "-42px")
            Text{
                Link("zegelin.com", target: "/")
                    .style(.textDecoration, "none")
                    .style(.color, "#aaa")
            }.horizontalAlignment(.leading)
                .style(.marginTop, "-31px")
            Text("""
                One of Chris's and my great loves is travelling, and over the years we've managed to do quite a bit of it! Keeping track of all our trips using a large paper map of the world would be completely impractical by now, so I came up with the idea of a website where each trip could be shown separately. The result is what you see here. It isn't quite finished yet, with some trips missing, and a list of improvements that could be made, but I had to start somewhere so it is what it is.
                """).style(.marginTop, "20px")
            Text("Best viewed on a Desktop or Tablet. Click on an image to see the trip map!").horizontalAlignment(.center).font(.title5)
        }.padding(.top, 20)
        
        Section{
            ForEach(content.all){ content in
                let date = content.date
                let endDate = content.metadata["endDate"] as? String
                let days = calcdays(startDate: date, endDateStr: endDate, days: content.metadata["days"] as? String)
                
                let title = content.metadata["title"] as! String
                let image = content.image ?? "_blank.jpg"

                Section{
                    Link(target: content.path) {
                        Image("/images/\(image)", description: content.imageDescription)
                            .frame(width: 280)
                            .margin(12)
                    }
                    Section{
                        Text(date.formatted(Date.FormatStyle().year()))
                            .horizontalAlignment(.leading)
                            .font(.title5)
                        Text(days + " days")
                            .horizontalAlignment(.trailing)
                            .font(.title5)
                            .margin(.top, -36)
                        Text(title).horizontalAlignment(.leading)
                            .margin(.top, 0)
                            .padding(.bottom, 8)
                            .style(.fontSize, "0.9em")
                    }.margin([.leading,.trailing], 12)
                    .margin(.top, -6)
                }.background(.lightGray)
                .foregroundStyle(.dimGray)
                .frame(width: 304)
                .margin(5)
                .style(.display, "inline-block")
            }
        }.horizontalAlignment(.center)
    }
}



struct ThemeSwitcher: HTML {
    @Environment(\.themes) private var themes

    var body: some HTML {
        Section{
            ForEach(themes) { theme in
                Button(theme.name) {
                    SwitchTheme(theme)
                }.style(.color, "#aaa")
            }
        }.horizontalAlignment(.trailing)
        
    }
}


/// Calculate days between two dates, adding 2 for beginning and end.
/// If endDate doesn't exist ( unknown ) we use the 'days' metadata
func calcdays(startDate: Date, endDateStr: String?, days: String?) ->String{
    let calendar = Calendar.current
    let dateFormatter = ISO8601DateFormatter()
    
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.formatOptions = [
        .withYear,
        .withMonth,
        .withDay,
        .withDashSeparatorInDate,
    ]
    
    if let endDateStr = endDateStr{
        let endDate = dateFormatter.date(from:endDateStr)!
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let daysBetween = components.day! + 2
        
        return String(daysBetween)
    }else{
        return "\(days ?? "0")"
    }
}

