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
    return json.dumps({'error':'ekispert api connection error'})
  if station_lat == -2:
    return json.dumps({'error':'ekispert api not found error'})
  ret_dict['station_lat'], ret_dict['station_lon'] = station_lat, station_lon

  distance = get_distance_to_station(param_dict['lat'], param_dict['lon'], station_lat, station_lon)
  if distance == -1:
    return json.dumps({'error':'google api connection error'})
  if distance == -2:
    return json.dumps({'error':'google api json parse error'})
  ret_dict['distance'] = distance

  return json.dumps(ret_dict)

def get_station_place(station):
  url = 'http://api.ekispert.com/v1/json/station?key=EnDgxDu5SWrS4g7m&name={0}'.format(station)
  try:
    req = urllib2.urlopen(url)
    res = json.loads(req.read())
    req.close()
  except:
    return -1, -1

  try:
    point = res['ResultSet']['Point']
    if (isinstance(point, list)):
      geopoint = point[0]['GeoPoint']
    else:
      geopoint = point['GeoPoint']
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
    return res['rows'][0]['elements'][1]['distance']['value']
  except:
    return -2
