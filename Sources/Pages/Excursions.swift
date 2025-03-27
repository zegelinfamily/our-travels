
import Foundation
import Ignite


/// Create a canvas on the sidebar list and draw the excursions
struct DrawExcursions: HTML {
    let stops: [CSVStop]
    let excursions: [(Int, Int)]
    
    var body: some HTML {
        Group{
            AnyHTML("""
            <canvas id="excursions" width="250" height="\(stops.count * 27)"></canvas>
            """
            )
            Script(code: drawExcursions(excursions: excursions))
        }
    }
}

/// Draw excursion lines on the sidebar list using the array of excursion tuples
func drawExcursions(excursions: [(Int, Int)]) ->String{
    /// Set up the canvas for drawing
    var text = """
            function draw() {
            const canvas = document.getElementById("excursions");
            if (canvas.getContext) {
            const ctx = canvas.getContext("2d");
            ctx.strokeStyle = "hotpink";
            ctx.lineWidth = 1.5;
    """
    /// Draw a 'bracket' for each excursion
    for excursion in excursions {
        text += """
            // Start a new Path
            ctx.beginPath();
            ctx.moveTo(27, \(excursion.0 * 27 + 2));
            ctx.lineTo(20, \(excursion.0 * 27 + 2));
            ctx.lineTo(20, \(excursion.1 * 27 - 5));
            ctx.lineTo(27, \(excursion.1 * 27 - 5));
            
            // Draw the Path
            ctx.stroke();
        """
    }
    /// Finalise drawing
    text += """
        }
        }
        draw();
    """
 
    return text
}


/// Excursions are formated like [(3, 6),(6, 17)] within the YAML of each trip.
/// This decodes them into an array of (Int,Int) tuples.
/// This array is then used as the input to draw the excursion lines on the sidebar list
func decodeExcusions(excursions : String) -> [(Int, Int)] {
    /// Remove square brackets and any whitespace
    let cleanedString = excursions.replacingOccurrences(of: "[\\[\\]\\s]", with: "", options: .regularExpression)
    
    /// Split into individual tuple strings
    let tupleStrings = cleanedString.split(separator: "),")
    
    /// Convert each tuple string to (Int, Int)
    let result = tupleStrings.compactMap { tupleStr -> (Int, Int)? in
        /// Remove parentheses and split by comma
        let numbers = tupleStr
            .replacingOccurrences(of: "[()]", with: "", options: .regularExpression)
            .split(separator: ",")
        
        /// Ensure we have exactly 2 numbers
        guard numbers.count == 2,
              let first = Int(numbers[0]),
              let second = Int(numbers[1]) else {
            return nil
        }
        
        return (first, second)
    }
    
    return result
}


/// If the current index is within one of the excursions then add some spaces to inset location
func addSpace(index: inout Int, excursions: [(Int, Int)]) ->String{
    
    for excursion in excursions {
        if index >= excursion.0 && index < excursion.1{
            index += 1
            return "&nbsp;&nbsp;&nbsp;"
        }
    }
    
    index += 1
    return ""
}
