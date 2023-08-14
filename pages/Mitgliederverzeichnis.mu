#!/usr/bin/env python3


##############################################################################################################
# Manual


# - This program is compatible with: Communicator
# - Copy file to any subfolder or root folder of nomadnet pages.
# - Make the file executable with the command chmod +x <filename>
# - Rename the file as you want.
# - Modify the configuration section in this file according to your own needs. This can, but does not have to be changed.
# - Create a link to this file on the start page or another nomadnet page.
# - Open the page in nomandet client.
# - The first time the page is opened, the data file will be created in the .filename folder in the user's home directory.


##############################################################################################################
# Configuration


# Debug mode (display of debug information).
DEBUG = False #True/False

# Number of datasets which will be saved (older datasets will be deleted).
DATA_COUNT_SAVE = 0 #0=No limit

# Number of datasets which will be viewed.
DATA_COUNT_VIEW = 0 #0=No limit

# Database
DB_HOST = "192.168.10.229"
DB_PORT = 5432
DB_USER = "postgres"
DB_PASSWORD = "p@ssw0rd"
DB_DATABASE = "testdb"
DB_ENCODING = "utf8"

# Browser pages cache time in seconds.
CACHE_TIME = 300 #0=No cache, None=Default

# Date/time format for formatting on the screen.
DATE_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

# Screen template - Main (Use on all pages)
TEMPLATE_MAIN = """
>`cMitgliederverzeichnis

`[Übersicht`:`]`        `[Details`:?page=detail`]`

Letztes Update: {date_time}`c

{msg}
{entrys}
`c`[Startseite`:/page/index.mu]`
"""

# Screen template - Entry (Use for each entry)
TEMPLATE_ENTRY_OVERVIEW = """`;1l;;{device_display_name};;;lxmf@{device_rns_id};`"""
TEMPLATE_ENTRY_DETAIL = """`;3s;;{device_display_name};{member_country} - {member_state} - {member_city};{member_occupation} - {member_skills} - {member_tasks};>`c{device_display_name}\\n`[lxmf@{device_rns_id}]`c\\n\\n>>Standort\\nLand: {member_country}\\nBundesland: {member_state}\\nStadt/Region: {member_city}\\n\\n>>Arbeitsdaten\\nBeruf: {member_occupation}\\nKenntnisse: {member_skills}\\nFDG interne Aufgaben: {member_tasks};`"""

# Text of the status confirmations.
MSG_OVERVIEW = ">`cÜbersicht`c"
MSG_DETAIL = ">`cDetails`c"


##############################################################################################################
# Include


#### System ####
import os
import time

#### Database ####
# Install: pip3 install psycopg2
# Install: pip3 install psycopg2-binary
# Source: https://pypi.org/project/psycopg2/
import psycopg2

#### Reticulum ####
import RNS


##############################################################################################################
# Globals  - System (Not changeable)


FILE = os.path.splitext(os.path.basename(__file__))[0]


##############################################################################################################
# Program


if "remote_identity" in os.environ:
    DEST = RNS.hexrep(RNS.Destination.hash_from_name_and_identity("lxmf.delivery", bytes.fromhex(os.environ["remote_identity"])), delimit=False)
else:
    DEST = ""


if "var_dn" in os.environ:
    NAME = os.environ["var_dn"]
else:
    NAME = ""


if "var_page" in os.environ and os.environ["var_page"] == "detail":
    TEMPLATE_ENTRY = TEMPLATE_ENTRY_DETAIL
    MSG = MSG_DETAIL
else:
    TEMPLATE_ENTRY = TEMPLATE_ENTRY_OVERVIEW
    MSG = MSG_OVERVIEW


if CACHE_TIME != None:
    print("#!c="+str(CACHE_TIME))


if DEBUG:
    print(os.environ)


entrys = ""
db = None
try:
    db = psycopg2.connect(user=DB_USER, password=DB_PASSWORD, host=DB_HOST, port=DB_PORT, database=DB_DATABASE, client_encoding=DB_ENCODING)
    dbc = db.cursor()
    if DATA_COUNT_VIEW > 0:
        query_limit = " LIMIT "+str(DATA_COUNT_VIEW)
    else:
        query_limit = ""
    dbc.execute("SELECT members.member_city, members.member_state, members.member_country, members.member_occupation, members.member_skills, members.member_tasks, members.member_wallet_address, devices.device_rns_id, devices.device_display_name FROM members LEFT JOIN devices ON devices.device_user_id = members.member_user_id ORDER BY devices.device_display_name"+query_limit)
    result = dbc.fetchall()
    if len(result) > 0:
        for entry in result:
            try:
                tpl = TEMPLATE_ENTRY
                tpl = tpl.replace("{member_city}", entry[0].strip())
                tpl = tpl.replace("{member_state}", entry[1].strip())
                tpl = tpl.replace("{member_country}", entry[2].strip())
                tpl = tpl.replace("{member_occupation}", entry[3].strip().replace("\n", " "))
                tpl = tpl.replace("{member_skills}", entry[4].strip().replace("\n", " "))
                tpl = tpl.replace("{member_tasks}", entry[5].strip().replace("\n", " "))
                tpl = tpl.replace("{member_wallet_address}", entry[6].strip().replace("\n", " "))
                tpl = tpl.replace("{device_rns_id}", entry[7].strip())
                tpl = tpl.replace("{device_display_name}", entry[8].strip())
                entrys += tpl+"\n"
            except:
                pass

except psycopg2.DatabaseError as e:
    pass


if db:
    dbc.close()
    db.close()
    db = None


tpl = TEMPLATE_MAIN
tpl = tpl.replace("{self}", FILE)
tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(time.time())))
tpl = tpl.replace("{msg}", MSG)
tpl = tpl.replace("{entrys}", entrys)
print(tpl)
