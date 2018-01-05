#
#
# main() will be invoked when you Run This Action.
# 
# @param OpenWhisk actions accept a single parameter,
#        which must be a JSON object.
#
# @return which must be a JSON object.
#         It will be the output of this action.
#
#
import sys, requests, urllib, simplejson

def main(args):
    name = args.get("schemaname", "testadsakshi")
    computenodes = args.get("computenodes", "0")
    refresh_token = args.get("refreshtoken","")
    api_key = args.get("apikey","")
    
    # Variables
    schematics_base_url = 'https://us-south.schematics.bluemix.net/v1/environments'
    
    # Get Auth Token
    auth_url = 'https://iam.bluemix.net/oidc/token'
    headers = {'Content-Type': 'application/x-www-form-urlencoded','Accept':'application/json'}
    params = urllib.parse.urlencode({'grant_type':'urn:ibm:params:oauth:grant-type:apikey','response_type':'cloud_iam','apikey':api_key})
    r = requests.post(auth_url, params=params, headers=headers)
    a = r.json()
    iam_token = a['access_token']
   
    # Get Environments
    schem_url = schematics_base_url
    headers = {'authorization':iam_token}
    r = requests.get(schem_url, headers=headers)
    a = r.json()
    #print (simplejson.dumps(a, sort_keys=True, indent=4 * ' '))
    
    env_id = None
    for env in a['resources']:
        if env['name'] == name:
            env_id = env['id']
            print ('\n\n#### FOUND ENVIRONMENT ####')
            print (env_id)
            
    if env_id:
        schem_url = schematics_base_url + '/' + env_id
        headers = {'authorization':iam_token}
        r = requests.get(schem_url, headers=headers)
        a = r.json()

        #update compute nodes
        variables = []
        for var in a['variablestore']:
            if var['name'] == 'computenode_count':
                var['value'] = computenodes
            if var['name'] == 'domain_exists':
                var['value'] = 'Y'
            variables.append(var)

        a['variablestore'] = variables

        print ('\n\n#### UPDATING ENVIRONMENT ####')
        schem_url = schematics_base_url + '/' + env_id
        headers = {'authorization':iam_token, 'Content-Type':'application/json'}
        r = requests.put(schem_url, data=simplejson.dumps(a), headers=headers)
        a = r.json()

        print ('\n\n#### APPLYING ENVIRONMENT ####')
        schem_url = schematics_base_url + '/' + env_id + '/apply'
        headers = {'authorization':iam_token}
        r = requests.put(schem_url, headers=headers)
        a = r.json()


    message = 'Building ' + computenodes +' compute nodes for ' + name
    return { 'message': message }
