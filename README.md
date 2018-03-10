# Hitchspots

[![Build Status](https://travis-ci.org/NoryDev/hitchspots.svg?branch=master)](https://travis-ci.org/NoryDev/hitchspots) [![security](https://hakiri.io/github/NoryDev/hitchspots/master.svg)](https://hakiri.io/github/NoryDev/hitchspots/master)

## About

[Hitchwiki](https://www.hitchwiki.org) is the ultimate resource for hitchhikers. There you can find a map with crowdsourced, rated hitchhiking spots everywhere in the world.

This is very practical but hitchhikers might not have access to the Internet while they are on the road, and therefore would not be able to quickly go check if there is a good spot close to their location.

Hitchspots is here to close the gap: before going on your trip, get a digest of all the spots along your route in KML format. This way, you can import this file in [your favorite offline maps application](https://maps.me/en/home) and have access to all the spots along your route without the need for an Internet connection.

## License and Data

Code: [MIT](https://github.com/NoryDev/hitchspots/blob/master/LICENSE.md) Content: [Creative Commons BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

Data is provided by [Hitchwiki](https://www.hitchwiki.org), [OpenStreetMap](https://nominatim.openstreetmap.org/) and [OSRM](http://project-osrm.org/) (sometimes via [mapbox](https://www.mapbox.com/))

## Install

Hitchspots is a [Sinatra](http://www.sinatrarb.com/) application, so you will need an environment to run [Ruby](http://ruby-lang.org/) code.

On top of that you will need [mongoDB](https://www.mongodb.com/), and a mapbox API token if you use mapbox for directions.
