# Travel Route Mapping

This Xcode package creates a website to display our travels using the [Ignite](https://github.com/twostraws/Ignite) static website builder. By placing a few files in the proper locations within this package and rebuilding the project, a new trip can be added to the website. This will show a new trip on the front page, with the latest trip at the top. Clicking on the trip image will take you to a trip page showing a map with with a sidebar list of all the locations visited.

The actual map is displayed using the [leaflet javascript library](https://leafletjs.com), with a few add ons to draw the curves, labels, zoom controls and to handle label collision. Label collision hides overlapping labels, showing the label with the higher priority, which is based on the Stop Type.

An example website can be found [here](https://zegelin.com/peter).

After making any changes or adding a new trip the website is rebuilt via the Run command '⌘ R'. Note that Ignite is still in Alpha so this package may not build unless Ignite v0.7-beta is used. The package manifest has been modified to specifically use this version of Ignite.

## Adding a New Trip
Requires 2 files, with an optional image file to display on the front page. The location specifies where the file should be placed within this package. See an example trip for a better understanding.

1. **Trip Markdown**
   - Format: YAML configuration header and optional blurb to be displayed on trip page
   - Location: `Content/trips
   - Naming: `[YYYY]_[trip_name].md` (NO SPACES! - Use '_')
   
2. **Stops Data**
   - Format: Tab-separated (.tsv) spreadsheet
   - Location: `Resources/trips`
   - Naming: `[YYYY] [trip name].tsv`
   
3. **Image**
   - Location: `Assets/ourtravels/images/`
   - Naming: [YYYY] [trip name].jpg (Match .tsv filename)


### Trip Markdown File Structure
#### YAML Header

```yaml
---
title: "Trip Card Name"
subtitle: "Trip Page Name"  		    # Optional, defaults to title
date: "YYYY-MM-DD"          		    # Start date, only year is displayed
endDate: "YYYY-MM-DD"      		    # Optional, end date is used for duration calculations
days: Integer                    	    # Optional, use if dates unknown
image: "[YYYY] [trip name].jpg" 	    # Optional, else you will get a white rectangle. Size 350W x 233H
tsv: "[YYYY] [trip name].tsv"  		    # Required stops file
excursions: [(idx,idx),(idx,idx)]           # Optional excursions list - see below
mapbounds: [lat1, long1], [lat2, long2]     # Initial map bounding box
---
```

#### Blurb
A blurb can be added after the YAML header. This will be displayed above the map on the individual trip page.

### Stops Data

See one of the trips .tsv files for an example.

#### Spreadsheet Format - Required Columns.
- Location
- LatLong
- Curvature
- Stop
- Mode
- Notes - unused but will eventually show on the trip sidebar as an info symbol and on the map as a label containing the note text

*NOTE: Do not add more columns and do not rename.*

#### Data Guidelines
- Use Numbers spreadsheet application or a spreadsheet app that will export tab-delimited.
- Get LatLong coordinates of individual stops from Google Maps "What is here" feature
  - Copy coordinates directly for correct format
- Save final file as tab-delimited (.tsv).
- I use BBEdit for minor tweeks to this file since it preserves tabs and doesn't require re-export to .tsv
- File name must match the name displayed in the tsv: row in the YAML header

#### Curvature Values - this will show a curved line between stops
- 0.3: Default value for typical routes
- 0.05: Recommended for longer continental routes
- Negative values: This will curve line in opposite direction
- Often requires manual tweaking to get them looking good, especially where there are lots of locations in a small area

#### Stop Types
- `0`: Stay (extended visit of a few days)
- `1`: Visit (short stop)
- `2`: Waypoint (route guidance marker)
- `3`: Don't show (especially used for day trips from a base location)

#### Mode Types
- `0`: Car
- `1`: Plane
- `2`: Train
- `3`: Bus
- `4`: Ferry or Ship
- `5`: Campervan
- `6`: Motorbike
- `7`: Cablecar
- `8`: Walk 

#### Excursions list

The excursions YAML lets you show excursions from a location where you stayed and had multiple trips out and back. The excursions will show indented in the sidebar list of a trip, with a bracket outlining the excursion. The YAML is a comma delimited list of tuples, where each tuple specifies the start and end index of an excursion. Excursions can only be one level deep.

#### International Date Line

Trips segments that cross the International Date Line need special handling. This is best explained via an example:

If you view the 1980 Europe and Kenya.tsv file you will see that the longitude for the start of the trip at Sydney is 151.175287° and the first stop in London is -0.129757°. This causes the curve joining the two locations to be how you would expect, flying over Asia to London. However, if you examine the latitude for Sydney in the 1997 USA.tsv file, you will see it is  -210.93395°. This also draws the curve as you would expect, but in the opposite direction, flying over the Pacific Ocean to Auckland and on to L.A. Note that the longitude for Auckland also has to be adjusted in this map. If we were just flying from Australia to New Zealand and back there would be no need to adjust the longitude values as we are not crossing the international date line.

The value of -210.93395° for Sydney in the second example is calculated by subtracting 360° from the actual longitude of 151.175287°.

By manually tweaking the longitude of some locations you can get the curve to draw in the desired direction. The only situation where there could be a problem is if a trip goes 'around the world'. In this case you have to figure out where you want the map to break and put two values for the location there. This is best seen in the 1986 Around The World.tsv where there are 2 values for Honolulu and a value of 100 for the mode of travel between the two. This mode of travel prevents a curve from being drawn between the 'two' Honolulu's. If you change the mode of travel to anything visible - say 1 - then you will see a curve connecting Honolulu to itself by stretching from one side of the map to the other.

## Uploading to a Website.

The Site.swift file has a global variable 'subsite' which can be used to add this project to an existing website but keep it as a seperate project. There may be a better way to do this but I haven't managed to find it.

The following is for our family website zegelin.com, hosted at Github, but should be similar for other websites.

To make this a sub-site of zegelin.com you need to do the following:
-   Build the website setting var subsite in Site.swift to ‘/name-of-subsite’ - leave blank for local build
-   Find the resulting Build folder and within it move the trips folder from Build/name-of-subsite to Build
-   Delete the name-of-subsite folder
-   Copy the resulting Build folder to eg: zegelinfamily.github.io and change its name to “name-of-subsite”
-   Upload zegelinfamily.github.io to GitHub.
    - Alternatively just replace name-of-subsite directory on Github directly.

## Bugs:

-   Dark mode doesn’t work on Firefox?
-   Maps don’t show properly on mobile phone


