#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
sys.path.append('/home/pika_shi/intempo/server')

import json, urllib2, pygn
import cgi, cgitb

clientID = '3446016-6BC841D74AE5ED4F1908FE96533976EB'
userID = pygn.register(clientID)

def application(environ, start_response):
  # Get Request(GET) from app
  query = cgi.parse_qsl(environ.get('QUERY_STRING'))
  param_dict, ret_dict = {'artist': '', 'track': ''}, {}
  for params in query:
    param_dict[params[0]] = params[1]

  start_response("200 OK", [('Content-Type','application/json'), ('charset', 'utf-8')])

  try:
    metadata = pygn.search(clientID=clientID, userID=userID, artist=param_dict['artist'].decode('utf-8'), track=param_dict['track'].decode('utf-8'))
    ret_dict['title'] = metadata['track_title']
    ret_dict['jacket'] = metadata['album_art_url']
    ret_dict['artist'] = metadata['album_artist_name']
    ret_dict['artist_art'] = metadata['artist_image_url']
    ret_dict['tempo'] = metadata['tempo']['3']['TEXT'][:-1]
    ret_dict['mood'] = metadata['mood']['1']['TEXT'][:-1]
  except:
    ret_dict['error'] = 'results not found'

  return json.dumps(ret_dict)
