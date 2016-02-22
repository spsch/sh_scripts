#!/bin/bash

HOCKEYAPPURL="https://rink.hockeyapp.net/api/2"
ANDROIDMTID=""
VLADTOKEN=""
WCURL=$(which curl)
WJQ=$(which jq)
WGE=$(which wget)
#control curl
while [[ $WCURL == "" ]]; do
	echo "no curl installed, please install it via apt"
	exit 11
done

#control jq
while [[ WJQ == "" ]]; do
	echo "JQ parser is missing, please visit https://stedolan.github.io/jq/ and install it properly"
	exit 12
done

while [[ $WGE == "" ]]; do
	echo "wget is missing, please install it before using this script"
	exit 13
done

function help() {
	echo -e "Please use $(basename $0) COMMAND \n
	getlastapk - you will receive last APK uploaded to HockeyApp\n
	lstaps     - you will receive list of all applications in HockeyApp\n
	lstmtvios  - list of all iOS Multitool versions\n
	lstmtandr  - list pf all android Multitool versions\n
	delapp     - you can delete application from HockeyApp, but you have to know its ID\n
	lsinvites  - list of all active invites\n
	lsteams    - list of all teams\n
	lsteamsapp - list of teams belonging to app which ID you will provide\n
	lsusersapp - list of users belonging to app which ID you will provide\n
	addteamapp - add team to application, you need to provide team and application ID\n
	invite     - inviting user to application, you have to provide app ID and email\n
	rmteamapp  - you can remove team from application\n
	rmuserapp  - you can remove user from application"
}


function getLastApk() {
	#this fnc returns last builds with notes and will download last apk
	echo "Getting info and download last APK:"
	curl \
	  -s -H "X-HockeyAppToken: $VLADTOKEN" \
	  $HOCKEYAPPURL/$ANDROIDMTID/app_versions?include_build_urls=true \
	  | jq '. | {created: .app_versions[].created_at, APKversion: .app_versions[].shortversion, build_urls: .app_versions[].build_url, notes: .app_versions[].notes}' | head -4
	echo""
	URL=$(curl \
		-s -H "X-HockeyAppToken: $VLADTOKEN" \
		$HOCKEYAPPURL/$ANDROIDMTID/app_versions?include_build_urls=true \
		| jq '.app_versions[].build_url' | head -1 | sed 's/"//g')
	echo "Dowbloading from: $URL"
	
	wget $URL -O MultiTool_$(date +%F).apk

}

function listAps() {
	# this fnc returns all apps listed by version
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" \
	$HOCKEYAPPURL/apps | jq '.'
	#| jq '. | {title: .apps[].title, platform: .apps[].platform, id: .apps[].public_identifier}'
}

function listMultitoolVersion() {

	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" \
	$HOCKEYAPPURL/apps/$1/app_versions
}

function listMTVOS() {
	# this returns only multitool versions
	# "title": "MultiTool",
 #    "bundle_identifier": "co.cashplay.ios.utils.multitool",
 #    "public_identifier": "9d6e49f2e2a7f775edaadadaab9e3ac3"
	listMultitoolVersion 9d6e49f2e2a7f775edaadadaab9e3ac3 | jq '.'

}

function listMTVAndroid() {
	# this returns only android versions
	# "title": "MultiTool",
 #    "bundle_identifier": "co.cashplay.android.multitool",
 #    "public_identifier": "8b9dda005dbdb98015e348ed1c46bb74 - old one"
 #fd9b30754bf7b05bb1b663c8f9b64d4b
	listMultitoolVersion fd9b30754bf7b05bb1b663c8f9b64d4b | jq '.'

}

function deleteApp() {
	# this fnc will delete app by providing its ID
	
	echo "Deleting app by prodvided id: echo $1"
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" -X DELETE \
	$HOCKEYAPPURL/apps/$1
}

function listInvites() {
		echo "This will list all invites for logged user"
		curl \
		-s -H "X-HockeyAppToken: $VLADTOKEN" \
		  $HOCKEYAPPURL/invites | jq '.'

}

function listTeams() {
	echo "Listing teams"
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" \
	$HOCKEYAPPURL/teams | jq '.'

}

function listTeamsofApp() {
	
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" \
	$HOCKEYAPPURL/apps/$1/app_teams

}

function listUsersofApp() {
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" \
	$HOCKEYAPPURL/apps/$1/app_users
}

function addTeamtoApp() {
	#need to provide appID (first argument) and teamID (second argument)
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" -X PUT \
	$HOCKEYAPPURL/apps/$1/app_teams/$2
}

function inviteUsertoApp() {
	echo "These fields are mandatory: email"
	read email
	echo "APP ID you want to invite:"
	read appid
	if [[ $email == "" ]]; then
		echo "email is mandatory"
		exit 15
	fi

	curl \
	-F "email=$email" \
	-H "X-HockeyAppToken: $VLADTOKEN" -X POST\
	$HOCKEYAPPURL/apps/$appid/app_users
}

function removeTeamfromApp() {
	#need to provide appID (first argument) and teamID (second argument)
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" -X DELETE \
	$HOCKEYAPPURL/apps/$1/app_teams/$2
}

function removeUserfromApp() {
	#need to provide appID (first argument) and userID (second argument)
	curl \
	-s -H "X-HockeyAppToken: $VLADTOKEN" -x DELETE \
	$HOCKEYAPPURL/apps/$1/app_teams/$2
}

help
