#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
#
import urllib
from urllib import quote
from urllib2 import urlopen, Request, HTTPError
from base64 import b64encode

import hmac
import hashlib
import json
import re
import os
import collections

UCLOUD_API_KEY="APIKEY"
UCLOUD_SECRET="SECRETKEY"

if "UCLOUD_API_KEY" in os.environ:
    UCLOUD_API_KEY = os.environ["UCLOUD_API_KEY"]
if "UCLOUD_SECRET" in os.environ:
    UCLOUD_SECRET = os.environ["UCLOUD_SECRET"]

UCLOUD_API_URLS = {
                   
    'server' : 'https://api.ucloudbiz.olleh.com/server/v1/client/api',
    
    'lb'     : 'https://api.ucloudbiz.olleh.com/loadbalancer/v1/client/api',
    'waf'    : 'https://api.ucloudbiz.olleh.com/waf/v1/client/api',
    'watch'  : 'https://api.ucloudbiz.olleh.com/watch/v1/client/api',
    'package': 'https://api.ucloudbiz.olleh.com/packaging/v1/client/api',
    'as'     : 'https://api.ucloudbiz.olleh.com/autoscaling/v1/client/api',
    'cdn'    : 'https://api.ucloudbiz.olleh.com/cdn/v1/client/api',
    'msg'    : 'https://api.ucloudbiz.olleh.com/messaging/v1/client/api',
    'nas'    : 'https://api.ucloudbiz.olleh.com/nas/v1/client/api',
    'db'     : 'https://api.ucloudbiz.olleh.com/db/v1/client/api',
}

class Client(object):
    def __init__(self, api_type = 'server', api_key=UCLOUD_API_KEY, secret=UCLOUD_SECRET,owner='owner'):
        self.api_url = UCLOUD_API_URLS[api_type]
        self.api_key = api_key
        self.secret  = secret
	self.owner = owner

    def request(self, command, input_args=None, post=None, debug=False, resptype="json"):
        if not command:
            raise RuntimeError('Command Missing !!')

	print "input args = '%s'" % input_args

	args = dict()
	if input_args != None:
		args = input_args
        args['command']  = command
        args['response'] = resptype
	args['apiKey']   = self.api_key
	args['owner'] = self.owner
	args['requesttype'] = 'test'
        
	args_sort = collections.OrderedDict(sorted(args.items(),key=lambda v:v[0].lower()))
        query = urllib.urlencode(args_sort)
        


	print "args = '%s'" % args
        print "query = '%s'" % (query.lower())
	print "secret ='%s'" % self.secret
        msg=query.lower()        
        signature = b64encode(hmac.new(
                str(self.secret),
                str(msg),
                digestmod=hashlib.sha1
        ).digest())

        if debug:
            print "Server: '%s'" % (self.api_url)
            print "Query (for Signiture):"
            print query
            print "Sigature:"
            print signature

	args["signature"]=signature
	args_sort = collections.OrderedDict(sorted(args.items(),key=lambda v:v[0].lower()))
	query = urllib.urlencode(args_sort)


        if debug:
            print "Query (Reconstructed/LEN: %d):" % len(query)
            print query
        #-------------------------------------------------------

        urls = self.api_url + '?' + query
	print "urls = '%s'" % (urls)
        if post is not None:
            post_enc = '&'.join(
                '='.join([k, quote(post[k])]) for k in sorted(post.keys()))
            req_data = Request(urls, post_enc)
            req_data.add_header('Content-type', 'application/x-www-form-urlencoded')
            
            
            
            if debug:
                print "POST(DICT/LEN: %d): " % (len(post)) , post
                print "POST(Encrypted/LEN: %d): " % (len(post_enc)) , post_enc
                print "HEADERS: ", req_data.headers
        else:
            req_data = Request(urls)

        try:
            response = urlopen(req_data)
        except HTTPError as e:
            # Printing Debugging Indformation.
            print e.read()
            raise RuntimeError("%s" % e)

        content = response.read()

        if resptype != "json":
            return content

        decoded  = json.loads(content)

        # response top node check
        response_header = command.lower() + 'response'
        if not response_header in decoded:
            if 'errorresponse' in decoded:
                raise RuntimeError(
                    "ERROR: " + decoded['errorresponse']['errortext'])

            # try one more thing
            response_header = command + 'response'
            if not response_header in decoded:
                raise RuntimeError("ERROR: Unable to parse the response")

        # return the response content
        return decoded.get(response_header, "")

""" command line : python Client.py command """

if __name__=="__main__":

    import sys

    if len(sys.argv) != 2:
        print "usage: python Client.py command"
        exit(-1)    

    command = sys.argv[1]
    client  = Client()
    result  = client.request(command)

    print json.dumps(result, sort_keys=True, indent=4)
