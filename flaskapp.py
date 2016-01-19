# -*- coding: utf-8 -*-

from flask import Flask,request, session, g, redirect, url_for, \
     abort, render_template, flash
import jinja2,os,json
import time
from ucloud.Client import *
from helper.parse import *

app = Flask(__name__)
#app.jinja_loader = jinja2.FileSystemLoader('/usr/src/flask_test/templates')
#tmpl_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'templates')
#app = Flask(__name__,template_folder=tmpl_dir)

app.config.from_envvar('flaskconfig')

@app.route('/')
def index():
	user_agent = request.headers.get('User-Agent')
	return '<p>Your browser is %s</p>' % user_agent

@app.route('/test/<apikey>/<secret>/<owner>')
def test(apikey,secret,owner):
	#return '<h1>Hello %s!, %s^^</h1>' %(apikey,secret) 
	print "apikey = %s, scret = %s, owner = %s" %(apikey,secret,owner)
	ucloud_client = Client(api_type='watch',api_key=apikey,secret=secret,owner=owner)
	response = ucloud_client.request('listMetrics')
        dump_result = json.dumps(response)
	return '%s' %dump_result

@app.route('/listmetrics')
def list_metric():
	apikey = request.args.get('apikey')
	secret = request.args.get('secret')
	owner = request.args.get('owner')
	ucloud_client = Client(api_type='watch',api_key=apikey,secret=secret,owner=owner)
        parser = Parse()
        response = ucloud_client.request('listMetrics')
        dump_result = json.dumps(response)
        parsed_result = parser.parse(dump_result)
	return '%s' %parsed_result
	

@app.route('/getmetricdata')

def get_metric_data():
	#apikey = str(session['apikey'])
        #secret = str(session['secret'])
	#apikey = "jUMEGdE43x_hnj0P3BeICCQ7BFntIokmrOb8tV5B-y0VkSVtOH0EAvtKOEP5G-mMEGSTSy02B44tjAxWwcNEsQ"
	#secret = "dFy9HakzEPgWSxe0pJN-wbog5K293_un_bsb84cqI17YqWsNsJ0EUQT0qkd6jz9v6zCqKsWiQL2_N_iTq-Ab3Q"
	apikey = request.args.get('apikey')
	secret = request.args.get('secret')
	owner = request.args.get('owner')
	input_args = dict()
	input_args["namespace"] = request.args.get('namespace')
	dimension_name = request.args.get('dimension_name')
	dimension_value = request.args.get('dimension_value')
	print "dimension_name = %s" % (dimension_name)
	print "dimension_value = %s" % (dimension_value)
	if dimension_name != "no dimension":
		input_args["dimensions.member.1.name"] = dimension_name
	if dimension_value != "no dimension":
		input_args["dimensions.member.1.value"] = dimension_value
	#input_args["dimensions.member.1.name"] = request.args.get('dimension_name')
	#input_args["dimensions.member.1.value"] = request.args.get('dimension_value')
	input_args["metricname"] = request.args.get("metricname")
	input_args["starttime"] = request.args.get('starttime')
	input_args["endtime"] = request.args.get('endtime')
	input_args["period"] = "5"
	input_args["statistics.member.1"] = "Maximum"
	input_args["statistics.member.2"] = "Minimum"
	input_args["statistics.member.3"] = "Average"
	input_args["statistics.member.4"] = "Sum"
	input_args["statistics.member.5"] = "SampleCount"
	if input_args["metricname"] == "CPUUtilization" or input_args["metricname"] == "load_avg1" or input_args["metricname"] == "CPUIoWait" or input_args["metricname"] == "CPULoadAverage":	
		input_args["unit"] = "Percent"
	else:
		input_args["unit"] = "Bytes"
	ucloud_client = Client(api_type='watch',api_key=apikey,secret=secret,owner=owner)
	response = ucloud_client.request(command='getMetricStatistics',input_args=input_args)
        dump_result = json.dumps(response)
        return '%s' %dump_result

@app.route('/result')
def show_result():
	#arg = session['arg']
	#arg = request.args['arg']
	#return '%s' % arg
	apikey = str(session['apikey'])
	secret = str(session['secret'])
	owner = str(session['account'])
	print 'apikey = %s, secret = %s, account = %s' %(apikey,secret,owner)
	keyparam = 'apikey=%s&secret=%s&owner=%s' %(apikey,secret,owner)
#	ucloud_client = Client(api_type='watch',api_key=apikey,secret=secret)
#	parser = Parse()
#        response = ucloud_client.request('listMetrics')
#        dump_result = json.dumps(response)
#	parsed_result = parser.parse(dump_result)
	#return '%s' % parsed_result
	base_url = "http://server_ip:3838/test/?"
	#request_url = base_url + keyparam + "&param=%s"%parsed_result
	request_url = base_url + keyparam
	print "request_url = %s"%request_url
	#return redirect("http://211.253.8.97:3838/test/?param=%s" % parsed_result)
	return redirect(request_url)

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
	session['apikey']=str(request.form['apikey']) 
	session['secret']=str(request.form['secretkey'])
	session['account']=str(request.form['account'])
	print "apikey=%s, secretkey=%s, account=%s" % (request.form['apikey'],request.form['secretkey'],request.form['account'])
#	ucloud_client = Client(api_type='watch',api_key=str(request.form['apikey']),secret=str(request.form['secretkey']))
	#ucloud_client = Client(api_type='watch',api_key=session['apikey'],secret=session['secret'])
	#response = ucloud_client.request('listMetrics')
	#dump_result = json.dumps(response)
	#session['arg'] = dump_result
	#arg = dump_result
	#time.sleep(1)
        #print dump_result
	#return redirect(url_for('.show_result',arg=arg))
	session.modified = True
	return redirect(url_for('.show_result'))
    return render_template('login.html', error=error)

@app.route('/logout')
def logout():
    #session.clear()
    session.pop('logged_in', None)
    flash('You were logged out')
   # return redirect(url_for('show_entries'))

if __name__ == '__main__':
    app.run(host='0.0.0.0')
