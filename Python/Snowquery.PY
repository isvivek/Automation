#!/usr/bin/python3
import pysnow
import requests
import pymsteams
from decouple import config
import os
import urllib3
urllib3.disable_warnings()

os.chdir("/root/snowautomation")
from decouple import config
user = config('userid')
pwd = config('password')

file_teamlist = open('./teammembers.txt', 'r')
teamlist = file_teamlist.readlines()
file_teamlist.close()

sessions = requests.Session()
sessions.verify = False
sessions.auth = requests.auth.HTTPBasicAuth(user, pwd)

qb = pysnow.QueryBuilder()
qb.field('assignment_group.name').equals('DTMS-ALL-MCS')
qb.OR()
qb.field('assignment_group.name').equals('IMS-APJ-CLOUD')
qb.AND()
qb.field('state').not_equals('3.0')
qb.AND()
qb.field('state').not_equals('4.0')
qb.AND()
qb.field('state').not_equals('5.0')
qb.AND()
qb.field('state').not_equals('17.0')
qb.AND()
qb.field('number').order_ascending()
qb.AND()
qb.field('assigned_to.user_name').equals(teamlist[0].rstrip("\n"))
for i in range(1,len(teamlist)):
    qb.OR()
    qb.field('assigned_to.user_name').equals(teamlist[i].rstrip("\n"))

c = pysnow.Client(instance='emcprod', session=sessions)

change = c.resource(base_path='/api', api_path='/sn_chg_rest/v1/change')

response = change.get(query=qb, stream=True)

for record in response.all():
#    data = json.dumps(record)
#    changeid = (((data['task_effective_number']).split("value':")[-1]).replace("'}","")).replace(" '","")
#    print(changeid)
    print(record['task_effective_number'])
c.close()
