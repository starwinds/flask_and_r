# -*- coding: utf-8 -*-
import pickle
import json
class Parse:
	def __init__(self):
		pass
	def parse(self,input_dict):
		#print "input_dict %s" % input_dict
		with open("metric.pickle", 'wb') as handle:
                	pickle.dump(input_dict, handle)
		temp_dict = json.loads(input_dict)	
		result_dict_list = []
		for i in range(0,len(temp_dict["metric"])):
		#for i in range(0,10):
			r_dict = dict()
			r_dict["namespace"] = temp_dict["metric"][i]["namespace"]
			if temp_dict["metric"][i]["dimensions"]["count"] == 0:
				r_dict["dimensions.name"] = "no dimension"
				r_dict["dimensions.value"] = "no dimension"
			else:
				r_dict["dimensions.name"] = temp_dict["metric"][i]["dimensions"]["dimension"][0]["name"]
                                r_dict["dimensions.value"] = temp_dict["metric"][i]["dimensions"]["dimension"][0]["value"]
			r_dict["metricname"] = temp_dict["metric"][i]["metricname"]
			result_dict_list.append(r_dict)
		return result_dict_list
