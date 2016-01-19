from ucloud.Client import *

if __name__ == "__main__":
	ucloud_client = Client(api_type='watch',api_key="jUMEGdE43x_hnj0P3BeICCQ7BFntIokmrOb8tV5B-y0VkSVtOH0EAvtKOEP5G-mMEGSTSy02B44tjAxWwcNEsQ",secret="dFy9HakzEPgWSxe0pJN-wbog5K293_un_bsb84cqI17YqWsNsJ0EUQT0qkd6jz9v6zCqKsWiQL2_N_iTq-Ab3Q")
        response = ucloud_client.request('listMetrics')
	dump_result = json.dumps(response)
	print dump_result
	
