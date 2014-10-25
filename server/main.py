#!/usr/bin/python
# -*- coding:utf-8 -*-

import json, urllib2, time, sys
from datetime import datetime, date
import cgi, cgitb
reload(sys)
sys.setdefaultencoding('utf-8')

def application(environ, start_response):
  # Get Request(GET) from app
  query = cgi.parse_qsl(environ.get('QUERY_STRING'))
  param_dict, ret_list = {}, []
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
  ret_list.append(distance)

  departure_time = get_departure_time(distance)

  route_url = get_route_url(param_dict['departure_station'],
          param_dict['arrival_station'], departure_time)
  if route_url == -1:
    return json.dumps({'error':'ekispert light api connection error'})
  if route_url == -2:
    return json.dumps({'error':'ekispert light api json parse error'})
  ret_list.append(route_url)

  route = get_route(param_dict['departure_station'],
          param_dict['arrival_station'], departure_time)
  if route == -1:
    return json.dumps({'error':'ekispert extreme api connection error'})
  if route == -2:
    return json.dumps({'error':'ekispert extreme api json parse error'})
  ret_list.append(route)

  return json.dumps({'ret': ','.join(map(str, ret_list))})

def get_departure_time(distance):
  departure_time = datetime.fromtimestamp(int(time.time()) + distance * 3/ 4)
  return '{0:02d}{1:02d}'.format(departure_time.hour, departure_time.minute)

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

def get_route(departure_station, arrival_station, departure_time):
  url = 'http://api.ekispert.com/v1/json/search/course/extreme?key=Eyvxmasfk98nJP6e&viaList={0}:{1}&time={2}&searchType=departure'.format(departure_station, arrival_station, departure_time)
  try:
    req = urllib2.urlopen(url)
    res = json.loads(req.read())
    req.close()
  except:
    return -1

  course_list = []
  try:
    courses = res['ResultSet']['Course']
    for course in courses:
      price, line = course['Price'][0]['Oneway'], course['Route']['Line']
      departure_time = line[0]['DepartureState']['Datetime']['text'][11:16] if (isinstance(line, list)) else line['DepartureState']['Datetime']['text'][11:16]
      arrival_time = line[-1]['ArrivalState']['Datetime']['text'][11:16] if (isinstance(line, list)) else line['ArrivalState']['Datetime']['text'][11:16]
      route = '発→' + '→'.join([point['Station']['Name'] for point in course['Route']['Point']]) + '→着'
      course_list.append('.'.join([departure_time, arrival_time, price, route]))
    return ' '.join(course_list)
  except:
    return -2

def get_route_url(departure_station, arrival_station, departure_time):
  url = 'http://api.ekispert.com/v1/json/search/course/light?key=EnDgxDu5SWrS4g7m&from={0}&to={1}&time={2}&searchType=departure'.format(departure_station, arrival_station, departure_time)
  try:
    req = urllib2.urlopen(url)
    res = json.loads(req.read())
    req.close()
  except:
    return -1

  try:
    return res['ResultSet']['ResourceURI']
  except:
    return -2
