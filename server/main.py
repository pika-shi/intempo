#!/usr/bin/python
# -*- coding:utf-8 -*-

import json, urllib2
import cgi, cgitb

def application(environ, start_response):
  # Get Request(GET) from app
  query = cgi.parse_qsl(environ.get('QUERY_STRING'))
  param_dict, ret_dict = {}, {}
  for params in query:
    param_dict[params[0]] = params[1]

  start_response("200 OK", [('Content-Type','application/json'), ('charset', 'utf-8')])

  station_lat, station_lon = get_station_place(param_dict['departure_station'])
  if station_lat == -1:
    return json.dumps({'error':'ekispert station api connection error'})
  if station_lat == -2:
    return json.dumps({'error':'ekispert station api not found error'})

  distance = get_distance_to_station(param_dict['lat'], param_dict['lon'], station_lat, station_lon)
  if distance == -1:
    return json.dumps({'error':'google api connection error'})
  if distance == -2:
    return json.dumps({'error':'google api json parse error'})
  ret_dict['distance'] = distance

  departure_time = get_route(param_dict['departure_station'], param_dict['arrival_station'], param_dict['arrival_time'])
  if departure_time == -1:
    return json.dumps({'error':'ekispert route api connection error'})
  if departure_time == -2:
    return json.dumps({'error':'ekispert route api json parse error'})
  ret_dict['departure_time'] = departure_time

  return json.dumps(ret_dict)

def get_station_place(station):
  url = 'http://api.ekispert.com/v1/json/station?key=Eyvxmasfk98nJP6e&name={0}'.format(station)
  try:
    req = urllib2.urlopen(url)
    res = json.loads(req.read())
    req.close()
  except:
    return -1, -1

  try:
    point = res['ResultSet']['Point']
    geopoint = point[0]['GeoPoint'] if (isinstance(point, list)) else point['GeoPoint']
    return geopoint['lati_d'], geopoint['longi_d']
  except:
    return -2, -2

def get_distance_to_station(gps_lat, gps_lon, station_lat, station_lon):
  url = 'http://maps.googleapis.com/maps/api/distancematrix/json?origins={0},{1}&destinations={2},{3}&sensor=false'.format(gps_lat, gps_lon, station_lat, station_lon)
  try:
    req = urllib2.urlopen(url)
    res = json.loads(req.read())
    req.close()
  except:
    return -1

  try:
    return res['rows'][0]['elements'][0]['distance']['value']
  except:
    return -2

def get_route(departure_station, arrival_station, arrival_time):
  url = 'http://api.ekispert.com/v1/json/search/course/extreme?key=Eyvxmasfk98nJP6e&viaList={0}:{1}&time={2}&searchType=arrival'.format(departure_station, arrival_station, arrival_time)
  try:
    req = urllib2.urlopen(url)
    res = json.loads(req.read())
    req.close()
  except:
    return -1

  try:
    line = res['ResultSet']['Course'][0]['Route']['Line']
    departure_time = line[0]['DepartureState']['Datetime']['text'] if (isinstance(line, list)) else line['DepartureState']['Datetime']['text']
    return departure_time[11:16]
  except:
    return -2
