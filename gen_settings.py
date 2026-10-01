#!/usr/bin/env python3
#### @martysama0134 start scripts ####
"""Generator settings for the FreeBSD 14.x amd64 Metin2 runtime."""

import os
import platform
import subprocess

v_system = platform.system()


def fShell(szCmd, bRet=False):
	"""Compatibility helper used by gen.py, with Python 3 text output."""
	try:
		result = subprocess.run(
			szCmd,
			shell=True,
			check=bRet,
			text=True,
			stdout=subprocess.PIPE if bRet else None,
		)
		if bRet:
			return result.stdout.rstrip("\\n")
		return result.returncode
	except subprocess.CalledProcessError:
		return -1


def _detect_admin_ip():
	override = os.environ.get("M2_ADMIN_IP")
	if override:
		return override

	if v_system == "FreeBSD":
		try:
			route = subprocess.run(
				["route", "-n", "get", "default"],
				check=True,
				text=True,
				stdout=subprocess.PIPE,
			).stdout
			iface = ""
			for line in route.splitlines():
				if "interface:" in line:
					iface = line.split(":", 1)[1].strip()
					break
			if iface:
				ifconfig = subprocess.run(
					["ifconfig", iface],
					check=True,
					text=True,
					stdout=subprocess.PIPE,
				).stdout
				for line in ifconfig.splitlines():
					parts = line.split()
					if len(parts) >= 2 and parts[0] == "inet" and parts[1] != "127.0.0.1":
						return parts[1]
		except (OSError, subprocess.CalledProcessError):
			pass

	if v_system == "Linux":
		try:
			output = subprocess.run(
				["hostname", "-I"],
				check=True,
				text=True,
				stdout=subprocess.PIPE,
			).stdout.split()
			if output:
				return output[0]
		except (OSError, subprocess.CalledProcessError):
			pass

	return "127.0.0.1"


v_admusrS = _detect_admin_ip()

v_admpwdS=os.environ.get("M2_ADMIN_PASSWORD", '58948HG83H4G8H84G')		#adminpage_password
v_svrhstS=os.environ.get("M2_SQL_HOST", 'localhost')		#host for sql connections
v_svrdttS=os.environ.get("M2_SQL_AUTH", 'metin2 ASSBDAS!#FSABFASI!#JYXYXKAFAF')	#user&pwd for sql connections
v_svrdtaS="%s %s"%(v_svrhstS, v_svrdttS)	#host, user and pwd for db sql connections

v_dbhstS='127.0.0.1'#default hostname for db
v_dbipS=30000		#default port for db (the others will be automatically calculated)
v_lognS='logs'		#name of the all_log path
v_chanS='channel/'		#name of the channel path
v_chalS='../'		#workaround that should be equivalent to $v_charS paths per ../

M2SD = {
	"account":		"account",
	"common":		"common",
	"hotbackup":	"hotbackup",
	"log":			"log",
	"player":		"player",
}

class M2TYPE:
	SERVER, DB, AUTH, CHANFOLDER, CHANNEL, CORE = range(6)
	NOCHAN = 0

class PORT:
	RANDOMI = v_dbipS	# a random port will start from such value
	RANDOM = 0
	PORT, P2P_PORT, DB_PORT, BIND_PORT = range(4)
	lPORT = ("PORT", "P2P_PORT", "DB_PORT", "BIND_PORT")

M2CONFIG = {
	"db": {
		"general": (
			("SQL_ACCOUNT = \\\"%s %s %s 0\\\"", (v_svrhstS, M2SD["account"], v_svrdttS)),
			("SQL_COMMON = \\\"%s %s %s 0\\\"", (v_svrhstS, M2SD["common"], v_svrdttS)),
			("SQL_PLAYER = \\\"%s %s %s 0\\\"", (v_svrhstS, M2SD["player"], v_svrdttS)),
			("SQL_HOTBACKUP = \\\"%s %s %s 0\\\"", (v_svrhstS, M2SD["hotbackup"], v_svrdttS)),
			("TABLE_POSTFIX = \\\"%s\\\"", ("")),
			# ("BIND_PORT = %s", (v_dbipS,)),
			# ("DB_SLEEP_MSEC = 10", ()),
			("CLIENT_HEART_FPS = %u", (25)),
			# ("HASH_PLAYER_LIFE_SEC = %u", (600)),
			("PLAYER_ID_START = %u", (1000)),
			("PLAYER_DELETE_LEVEL_LIMIT = %u", (70)),
			# ("PLAYER_DELETE_LEVEL_LIMIT_LOWER = %u", (15)),
			("ITEM_ID_RANGE = %u %u ", (100000000, 200000000)),
			# ("BACKUP_LIMIT_SEC = %u", (3600)),
			("DISABLE_HOTBACKUP = %u", (True)),
			("LOCALE = %s", ("latin1")),
		),
		"extra": (
			("PROTO_FROM_DB = %u", (False)),
			("MIRROR2DB = %u", (True)),
			# ("BIND_IP = %u", (192.168.0.190)),
		)
	},
	"core": {
		M2TYPE.AUTH: (
			("AUTH_SERVER: %s", ("master")),
			("PLAYER_SQL: %s %s", (v_svrdtaS, M2SD["account"])),
		),
		M2TYPE.CORE: (
			("PLAYER_SQL: %s %s", (v_svrdtaS, M2SD["player"])),
		),
		"general": (
			# ("TABLE_POSTFIX: %s", ("")),
			# ("ITEM_ID_RANGE: %u %u", (5000001, 10000000)),
			("VIEW_RANGE: %u", (10000)),
			("PASSES_PER_SEC: %u", (25)),
			("SAVE_EVENT_SECOND_CYCLE: %u", (180)),
			("PING_EVENT_SECOND_CYCLE: %u", (180)),
			("DB_ADDR: %s", (v_dbhstS)),
			("COMMON_SQL: %s %s", (v_svrdtaS, M2SD["common"])),
			("LOG_SQL: %s %s", (v_svrdtaS, M2SD["log"])),
			# ("TEST_SERVER: %d", (True)),
			# ("PK_SERVER: %d", (True)),
			("ADMINPAGE_IP1: %s", (v_admusrS)),
			("ADMINPAGE_PASSWORD: %s", (v_admpwdS)),
			("MAX_LEVEL: %u", (120)),
		),
		"extra": (
			# ("CHECK_VERSION_SERVER: %u", (True)),
			# ("CHECK_VERSION_VALUE: %u", (1215955205)),
			("CHANGE_ATTR_TIME_LIMIT: %u", (False)),
			("EMOTION_MASK_REQUIRE: %u", (False)),
			("PRISM_ITEM_REQUIRE: %u", (False)),
			("SHOP_PRICE_3X_TAX: %u", (False)),
			("ENABLE_GLOBAL_SHOUT: %u", (1)),
			("GLOBAL_SHOUT: %u", (True)),
			("ITEM_COUNT_LIMIT: %u", (250)),
			("STATUS_POINT_GET_LEVEL_LIMIT: %u", (120)),
			("STATUS_POINT_SET_MAX_VALUE: %u", (90)),
			("SHOUT_LIMIT_LEVEL: %u", (15)),
			("SHOUT_LIMIT_TIME: %u", (5)),
			("DB_LOG_LEVEL: %u", (1)),
			("EMPIRE_LANGUAGE_CHECK: %u", (True)),
			# ("ITEM_DESTROY_TIME_AUTOGIVE: %u", (15)),
			# ("ITEM_DESTROY_TIME_DROPITEM: %u", (5)),
			# ("ITEM_DESTROY_TIME_DROPGOLD: %u", (15)),
			("PK_PROTECT_LEVEL: %u", (20)),
			("ADDSTONE_FAILURE0: %u", (80)),
			("ADDSTONE_FAILURE1: %u", (70)),
			("ADDSTONE_FAILURE2: %u", (60)),
			("ADDSTONE_FAILURE3: %u", (50)),
			("ADDSTONE_FAILURE4: %u", (40)),
			("START_GOLD: %u", (500)),
			#("HACKSHIELD_ENABLE: %u", (1)),
			#("CHECK_MULTIHACK: %u", (1)),
			("TRADE_EFFECT: %u", (1)),
			("ATTR_ALWAYS_5_ADD: %u", (1)),
			("PROTECT_NORMAL_PLAYER: %u", (1)),
			("DISABLE_PRISM_ITEM: %u", (0)),
			#("BLOCK_CHAR_CREATION: %u", (0)),
			("SKILLBOOK_NEED_EXP: %u", (20000)),
			("SKILLBOOK_NEXTREAD_MIN: %u", (28800)),
			("SKILLBOOK_NEXTREAD_MAX: %u", (43200)),
			("BLOCK_POTIONS_IN_DUELL: %u", (1)),
			("IMMUN_RATE: %u", (100)),
			("MAX_ADDON_FKS: %u", (35)),
			("MAX_ADDON_DSS: %u", (40)),
			("PC_MAX_MOVEMENT_SPEED: %u", (200)),
			("PC_MAX_ATTACK_SPEED: %u", (200)),
			("MOB_MAX_MOVEMENT_SPEED: %u", (250)),
			("MOB_MAX_ATTACK_SPEED: %u", (250)),
		),
	},
}

COMMONCHAN=(
	{
		"name": "core1",
		"type": M2TYPE.CORE,
		"port": PORT.RANDOM,
		"p2p_port": PORT.RANDOM,
		"config": M2CONFIG["core"],
		"maps": "1 2 3 4 6",
	},
	{
		"name": "core2",
		"type": M2TYPE.CORE,
		"port": PORT.RANDOM,
		"p2p_port": PORT.RANDOM,
		"config": M2CONFIG["core"],
		"maps": "21 22 23 24 26",
	},
	{
		"name": "core3",
		"type": M2TYPE.CORE,
		"port": PORT.RANDOM,
		"p2p_port": PORT.RANDOM,
		"config": M2CONFIG["core"],
		"maps": "41 42 43 44 46",
	},
	{
		"name": "core4",
		"type": M2TYPE.CORE,
		"port": PORT.RANDOM,
		"p2p_port": PORT.RANDOM,
		"config": M2CONFIG["core"],
		"maps": "61 62 63 64 65 66 67 68 69 70 81 180 218 252 302 303 304 318",
	},
	{
		"name": "core5",
		"type": M2TYPE.CORE,
		"port": PORT.RANDOM,
		"p2p_port": PORT.RANDOM,
		"config": M2CONFIG["core"],
		"maps": "101 103 105 110 111 114 118 119 120 121 122 123 124 125 126 127 128 253 254 255 256 257 353 354 356 403 404",
	},
	# {
		# "name": "core3",
		# "type": M2TYPE.CORE,
		# "port": PORT.RANDOM,
		# "p2p_port": PORT.RANDOM,
		# "config": M2CONFIG["core"],
		# "maps": "",
	# },
)

# PREMIUMCHAN=(
	# {
		# "name": "core1",
		# "type": M2TYPE.CORE,
		# "port": PORT.RANDOM,
		# "p2p_port": PORT.RANDOM,
		# "config": M2CONFIG["core"],
		# "maps": "1 21 41 3 23 43 4 24 44 5 25 45 108 109 112",
	# },
	# {
		# "name": "core2",
		# "type": M2TYPE.CORE,
		# "port": PORT.RANDOM,
		# "p2p_port": PORT.RANDOM,
		# "config": M2CONFIG["core"],
		# "maps": "61 62 63 64 65 66 67 68 69 70 71 72 73 206 104 193 207",
	# },
# )

CHAN99=(
	{
		"name": "core99",
		"type": M2TYPE.CORE,
		"port": PORT.RANDOM,
		"p2p_port": PORT.RANDOM,
		"config": M2CONFIG["core"],
		"maps": "5 25 45 66 71 72 73 100 104 107 108 109 112 113 181 182 183 208 216 217 250 251 351 352 355",
	},
)

M2S=(
	{
		"name": "game",
		"type": M2TYPE.SERVER,
		"isextra": True,
		"sub": (
			{
				"name": "db",
				"type": M2TYPE.DB,
				"port": PORT.RANDOM,
				"config": M2CONFIG["db"],
			},
			{
				"name": "auth",
				"type": M2TYPE.AUTH,
				"port": PORT.RANDOM,
				"p2p_port": PORT.RANDOM,
				"config": M2CONFIG["core"],
			},
			{
				"name": "chan",
				"type": M2TYPE.CHANFOLDER,
				"sub": (
					{
						"name": "ch1",
						"type": M2TYPE.CHANNEL,
						"chan": 1,
						"sub": COMMONCHAN,
					},
					{
						"name": "ch2",
						"type": M2TYPE.CHANNEL,
						"chan": 2,
						"sub": COMMONCHAN,
					},
					# {
						# "name": "ch3",
						# "type": M2TYPE.CHANNEL,
						# "chan": 3,
						# "sub": COMMONCHAN,
					# },
					# {
                        # "name": "ch4p",
						# "type": M2TYPE.CHANNEL,
						# "chan": 4,
						# "sub": PREMIUMCHAN,
					# },
					{
						"name": "ch99",
						"type": M2TYPE.CHANNEL,
						"chan": 99,
						"sub": CHAN99,
					},
				)
			}
		)
	},
)

CustIpfwList="""#!/bin/sh
IPF="ipfw -q add"
ipfw -q -f flush

#loopback
$IPF 10 allow all from any to any via lo0
$IPF 20 deny all from any to 127.0.0.0/8
$IPF 30 deny all from 127.0.0.0/8 to any
$IPF 40 deny tcp from any to any frag

# stateful
$IPF 50 check-state
$IPF 60 allow tcp from any to any established
$IPF 70 allow all from any to any out keep-state
$IPF 80 allow icmp from any to any

# open port ftp (20, 21), ssh (22), mail (25)
# http (80), https (443), dns (53), mysql (3306)
default_udp_yes_ports='53'
default_tcp_yes_ports='22 53 3306'
default_tcp_no_ports=''

# here auth PORTs for "NORM"/"..." thing
metin2_udp_yes_ports='%s'
# here PORTs
metin2_tcp_yes_ports='%s'
# here DB_PORTs and P2P_PORTs
metin2_tcp_no_ports='%s'

# merge lists
udp_yes_ports="$default_udp_yes_ports $metin2_udp_yes_ports"
tcp_yes_ports="$default_tcp_yes_ports $metin2_tcp_yes_ports"
tcp_nop_ports="$default_tcp_no_ports $metin2_tcp_no_ports"

# white ip list
white_sites=''

# block tcp/udp ports
for val in $tcp_nop_ports; do
	$IPF 2220 allow all from 127.0.0.0/8 to any $val
	for whitez in $white_sites; do
		$IPF 2210 allow tcp from $whitez to any $val in
		$IPF 2210 allow tcp from 127.0.0.0/8 to $whitez $val out
	done
	$IPF 2230 deny all from any to me $val
done
# unblock tcp ports
for val in $tcp_yes_ports; do
	$IPF 2200 allow tcp from any to any $val in limit src-addr 20
	$IPF 2210 allow tcp from any to any $val out
done
# unblock udp ports
for val in $udp_yes_ports; do
	$IPF 2200 allow udp from any to any $val in limit src-addr 20
	$IPF 2210 allow udp from any to any $val out
done
"""
