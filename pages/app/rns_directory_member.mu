#!/usr/bin/env python3


##############################################################################################################
# Manual


# - This program is compatible with: Communicator
# - Copy file to any subfolder or root folder of nomadnet pages.
# - Make the file executable with the command chmod +x <filename>
# - Rename the file as you want.
# - Modify the configuration section in this file according to your own needs. This can, but does not have to be changed.


##############################################################################################################
# Configuration


# Debug mode (display of debug information).
DEBUG = False #True/False

# Alternative path
PATH = None

KEY_RESULT        = 0x0A # Result
KEY_RESULT_REASON = 0x0B # Result - Reason
KEY_DATA          = "var_data"
KEY_ENTRYS        = "rx_entrys"
KEY_ENTRYS_COUNT  = "rx_entrys_count"
KEY_CMD           = "cmd"
KEY_CMD_ENTRY     = "cmd_entry"
KEY_CMD_RESULT    = "cmd_result"

RESULT_ERROR = 0x00
RESULT_OK    = 0x01

# Database
DB_HOST     = "192.168.10.229"
DB_PORT     = 5432
DB_USER     = "postgres"
DB_PASSWORD = "p@ssw0rd"
DB_DATABASE = "testdb"
DB_ENCODING = "utf8"

# Admin destinations (LXMF-Adresses)
ADMINS = ["dece1ff47066e7e2ef55bf56e8b69aad"] #Array

# Admin CMDs
ADMINS_CMD       = [] #Array
ADMINS_CMD_ENTRY = ["role_0", "role_1", "role_2", "role_3", "state_0", "state_1", "state_2", "delete"] #Array


##############################################################################################################
# Include


#### System ####
import sys
import os
import base64
import datetime

#### Database ####
# Install: pip3 install psycopg2
# Install: pip3 install psycopg2-binary
# Source: https://pypi.org/project/psycopg2/
import psycopg2

#### Reticulum ####
import RNS
import RNS.vendor.umsgpack as msgpack


##############################################################################################################
# Globals  - System (Not changeable)


FILE = os.path.splitext(os.path.basename(__file__))[0]

if PATH == None:
    PATH = os.path.expanduser("~")+"/.config/"+FILE

DB = None


##############################################################################################################
# Database


def db_connect():
    global DB

    try:
        if DB == None:
            DB = psycopg2.connect(user=DB_USER, password=DB_PASSWORD, host=DB_HOST, port=DB_PORT, database=DB_DATABASE, client_encoding=DB_ENCODING)
    except:
        DB = None

    return DB


def db_commit():
    global DB

    if DB != None:
        try:
            DB.commit()
        except:
            DB.rollback()


def db_sanitize(value):
    value = str(value)
    value = value.replace('\\', "")
    value = value.replace("\0", "")
    value = value.replace("\n", "")
    value = value.replace("\r", "")
    value = value.replace("'", "")
    value = value.replace('"', "")
    value = value.replace("\x1a", "")
    return value


def db_init(init=True):
   pass


def db_migrate():
    pass


def db_indices():
    pass


def db_load():
    pass


def db_filter(filter):
    if filter == None:
        return ""

    querys = []

    if "display_name" in filter and filter["display_name"] != None:
        querys.append("devices.device_display_name ILIKE '%"+db_sanitize(filter["display_name"])+"%'")

    if "city" in filter and filter["city"] != None:
        querys.append("members.member_city ILIKE '%"+db_sanitize(filter["city"])+"%'")

    if "country" in filter and filter["country"] != None:
        querys.append("members.member_country = '"+db_sanitize(filter["country"])+"'")

    if "state" in filter and filter["state"] != None:
        querys.append("members.member_state = '"+db_sanitize(filter["state"])+"'")

    if "occupation" in filter and filter["occupation"] != None:
        querys.append("members.member_occupation ILIKE '%"+db_sanitize(filter["occupation"])+"%'")

    if "skills" in filter and filter["skills"] != None:
        querys.append("members.member_skills ILIKE '%"+db_sanitize(filter["skills"])+"%'")

    if "tasks" in filter and filter["tasks"] != None:
        querys.append("members.member_tasks ILIKE '%"+db_sanitize(filter["tasks"])+"%'")

    if "wallet_address" in filter and filter["wallet_address"] != None:
        querys.append("members.member_wallet_address ILIKE '%"+db_sanitize(filter["wallet_address"])+"%'")

    if "type" in filter and filter["type"] != None:
        if isinstance(filter["type"], int):
            querys.append("members.member_type = '"+db_sanitize(filter["type"])+"'")
        else:
            array = [db_sanitize(key) for key in filter["type"]]
            querys.append("(members.member_type = '"+"' OR members.member_type = '".join(array)+"')")

    if "auth_role" in filter and filter["auth_role"] != None:
        querys.append("members.member_auth_role = '"+db_sanitize(filter["auth_role"])+"'")

    if "ts_min" in filter and filter["ts_min"] != None:
        querys.append("members.member_ts_add >= "+datetime.datetime.fromtimestamp(filter["ts_min"]).strftime('%Y-%m-%d %H:%M:%S'))

    if "ts_max" in filter and filter["ts_max"] != None:
        querys.append("members.member_ts_add <= "+datetime.datetime.fromtimestamp(filter["ts_max"]).strftime('%Y-%m-%d %H:%M:%S'))

    if len(querys) > 0:
        query = " AND "+" AND ".join(querys)
    else:
        query = ""

    return query


def db_order(order):
    if order == "A-ASC":
        query = " ORDER BY devices.device_display_name ASC"
    elif order == "A-DESC":
        query = " ORDER BY devices.device_display_name DESC"
    elif order == "ASC":
        query = " ORDER BY members.member_ts_add ASC, devices.device_display_name ASC"
    elif order == "DESC":
        query = " ORDER BY members.member_ts_add DESC, devices.device_display_name ASC"
    else:
        query = ""

    return query


def db_list(filter=None, search=None, order=None, limit=None, limit_start=None):
    db = db_connect()
    dbc = db.cursor()

    query_filter = db_filter(filter)

    query_order = db_order(order)

    if limit == None or limit_start == None:
        query_limit = ""
    else:
        query_limit = " LIMIT "+db_sanitize(limit)+" OFFSET "+db_sanitize(limit_start)

    if search:
        search = "%"+search+"%"
        query = "SELECT members.member_city, members.member_state, members.member_country, members.member_occupation, members.member_skills, members.member_tasks, members.member_wallet_address, members.member_auth_role, members.member_ts_add, members.member_ts_edit, devices.device_rns_id, devices.device_display_name FROM members LEFT JOIN devices ON devices.device_user_id = members.member_user_id WHERE members.member_user_id != '' AND (devices.device_display_name ILIKE %s OR members.member_city ILIKE %s OR members.member_occupation ILIKE %s OR members.member_skills ILIKE %s OR members.member_tasks ILIKE %s)"+query_filter+query_order+query_limit
        dbc.execute(query, (search, search, search, search, search))
    else:
        query = "SELECT members.member_city, members.member_state, members.member_country, members.member_occupation, members.member_skills, members.member_tasks, members.member_wallet_address, members.member_auth_role, members.member_ts_add, members.member_ts_edit, devices.device_rns_id, devices.device_display_name FROM members LEFT JOIN devices ON devices.device_user_id = members.member_user_id WHERE members.member_user_id != ''"+query_filter+query_order+query_limit
        dbc.execute(query)

    result = dbc.fetchall()

    if len(result) < 1:
        return []
    else:
        data = []
        for entry in result:
            if entry[10]:
                data.append({
                    "city": entry[0].strip(),
                    "state": entry[1].strip(),
                    "country": entry[2].strip(),
                    "occupation": entry[3].strip(),
                    "skills": entry[4].strip(),
                    "tasks": entry[5].strip(),
                    "wallet_address": entry[6].strip(),
                    "auth_role": int(entry[7].strip()),
                    "ts_add": entry[8].timestamp(),
                    "ts_edit": entry[9].timestamp(),
                    "dest": bytes.fromhex(entry[10].strip()),
                    "display_name": entry[11].strip()
                })

        return data


def db_count(filter=None, search=None):
    db = db_connect()
    dbc = db.cursor()

    query_filter = db_filter(filter)

    if search:
        search = "%"+search+"%"
        query = "SELECT COUNT(*) FROM members LEFT JOIN devices ON devices.device_user_id = members.member_user_id WHERE members.member_user_id != '' AND (devices.device_display_name ILIKE %s OR members.member_city ILIKE %s OR members.member_occupation ILIKE %s OR members.member_skills ILIKE %s OR members.member_tasks ILIKE %s)"+query_filter
        dbc.execute(query, (search, search, search, search, search))
    else:
        query = "SELECT COUNT(*) FROM members WHERE member_user_id != ''"+query_filter
        dbc.execute(query)

    result = dbc.fetchall()

    if len(result) < 1:
        return 0
    else:
        return result[0][0]


def db_get(dest):
    db = db_connect()
    dbc = db.cursor()

    query = "SELECT members.member_city, members.member_state, members.member_country, members.member_occupation, members.member_skills, members.member_tasks, members.member_wallet_address, members.member_auth_role, members.member_ts_add, members.member_ts_edit, devices.device_rns_id, devices.device_display_name FROM members LEFT JOIN devices ON devices.device_user_id = members.member_user_id WHERE devices.device_rns_id = %s"
    dbc.execute(query, (RNS.hexrep(dest, False),))
    result = dbc.fetchall()

    if len(result) < 1:
        return None
    else:
        entry = result[0]
        data = {
            "city": entry[0].strip(),
            "state": entry[1].strip(),
            "country": entry[2].strip(),
            "occupation": entry[3].strip(),
            "skills": entry[4].strip(),
            "tasks": entry[5].strip(),
            "wallet_address": entry[6].strip(),
            "auth_role": int(entry[7].strip()),
            "ts_add": entry[8].timestamp(),
            "ts_edit": entry[9].timestamp(),
            "dest": bytes.fromhex(entry[10].strip()),
            "display_name": entry[11].strip()
        }
        return data


def db_set(dest, role=None, state=None):
    db = db_connect()
    dbc = db.cursor()

    if role != None:
        query = "UPDATE members SET member_ts_edit = %s, member_auth_role = %s, member_update = '1' WHERE member_user_id = (SELECT device_user_id FROM devices WHERE device_rns_id = %s)"
        dbc.execute(query, (datetime.datetime.now(datetime.timezone.utc), str(role), RNS.hexrep(dest, False)))

    if state != None:
        query = "UPDATE members SET member_ts_edit = %s, member_auth_state = %s, member_update = '1' WHERE member_user_id = (SELECT device_user_id FROM devices WHERE device_rns_id = %s)"
        dbc.execute(query, (datetime.datetime.now(datetime.timezone.utc), str(state), RNS.hexrep(dest, False)))

    db_commit()


def db_delete(dest):
    db = db_connect()
    dbc = db.cursor()

    query = "SELECT device_user_id FROM devices WHERE device_rns_id = %s"
    dbc.execute(query, (RNS.hexrep(dest, False),))
    result = dbc.fetchall()

    if len(result) == 1:
        query = "DELETE FROM devices WHERE device_user_id = %s"
        dbc.execute(query, (result[0][0],))

        query = "DELETE FROM members WHERE member_user_id = %s"
        dbc.execute(query, (result[0][0],))

    db_commit()


##############################################################################################################
# CMD

def cmd(cmd):
    if cmd[0] == "role_0":
        db_set(cmd[1], role=0)

    if cmd[0] == "role_1":
        db_set(cmd[1], role=1)

    if cmd[0] == "role_2":
        db_set(cmd[1], role=2)

    if cmd[0] == "role_3":
        db_set(cmd[1], role=3)

    if cmd[0] == "state_0":
        db_set(cmd[1], state=0)

    if cmd[0] == "state_1":
        db_set(cmd[1], state=1)

    if cmd[0] == "state_2":
        db_set(cmd[1], state=2)

    if cmd[0] == "delete":
        db_delete(cmd[1])

    entry = db_get(cmd[1])
    if entry:
        return {KEY_CMD_RESULT: RESULT_OK, KEY_ENTRYS: [entry]}
    else:
        return {KEY_CMD_RESULT: RESULT_OK, KEY_ENTRYS: [{"dest": cmd[1], "ts_edit": 0}]}


##############################################################################################################
# Program


data_return = {}

try:
    data_return[KEY_RESULT] = RESULT_OK

    if DEBUG:
        print(os.environ)

    RIGHT = "user"
    if "remote_identity" in os.environ:
        dest = RNS.hexrep(RNS.Destination.hash_from_name_and_identity("lxmf.delivery", bytes.fromhex(os.environ["remote_identity"])), delimit=False)
        if dest != "" and dest in ADMINS:
            RIGHT = "admin"

    data = os.environ[KEY_DATA]
    data = msgpack.unpackb(base64.b64decode(data))

    if DEBUG:
        print(data)

    if "cmd" in data:
        if RIGHT == "admin":
            data_return.update(cmd(data["cmd"]))
    else:
        data_return[KEY_ENTRYS] = []
        data_return[KEY_ENTRYS_COUNT] = db_count(filter=data["filter"], search=data["search"])

        for entry in db_list(filter=data["filter"], search=data["search"], order=data["order"], limit=data["limit"], limit_start=data["limit_start"]):
            if entry["dest"] in data["entrys"]:
                if entry["ts_edit"] > data["entrys"][entry["dest"]]:
                    data_return[KEY_ENTRYS].append(entry)
                del data["entrys"][entry["dest"]]
            else:
               data_return[KEY_ENTRYS].append(entry)

        for dest in data["entrys"]:
            entry = db_get(dest=dest)
            if entry:
                if entry["ts_edit"] > data["entrys"][dest]:
                    data_return[KEY_ENTRYS].append(entry)
            else:
                data_return[KEY_ENTRYS].append({"dest": dest, "ts_edit": 0})

        if len(data_return[KEY_ENTRYS]) == 0:
            del data_return[KEY_ENTRYS]

        if RIGHT == "admin":
            data_return[KEY_CMD] = ADMINS_CMD
            data_return[KEY_CMD_ENTRY] = ADMINS_CMD_ENTRY

except Exception as e:
    data_return[KEY_RESULT] = RESULT_ERROR

sys.stdout.buffer.write(msgpack.packb(data_return))
sys.stdout.flush() 
