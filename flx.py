#! /usr/local/bin/python
import os
import sys

#BASIC SCRIPT PRESETS
width = 320					# Width of your game in 'true' pixels (ignoring zoom)
height = 240				# Height of your game in 'true' pixels
zoom = 2					# How chunky you want your pixels
src = 'src/'				# Name of the source folder under the project folder (if there is one!)
preloader = 'Preloader'		# Name of the preloader class
flexBuilder = True			# Whether or not to generate a Default.css file
menuState = 'MenuState'		# Name of menu state class
playState = 'PlayState'		# Name of play state class

#Get name of project
if len(sys.argv) <= 1:
	sys.exit(0)
project = sys.argv[1]

#Generate basic game class
filename = project+'/'+src+project+'.as';
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open '+filename+' for writing.')
	sys.exit(0)
lines = []
lines.append('package\r\n')
lines.append('{\r\n')
lines.append('\timport org.flixel.*;\r\n')
lines.append('\t[SWF(width="'+str(width*zoom)+'", height="'+str(height*zoom)+'", backgroundColor="#000000")]\r\n')
lines.append('\t[Frame(factoryClass="Preloader")]\r\n')
lines.append('\r\n')
lines.append('\tpublic class '+project+' extends FlxGame\r\n')
lines.append('\t{\r\n')
lines.append('\t\tpublic function '+project+'()\r\n')
lines.append('\t\t{\r\n')
lines.append('\t\t\tsuper('+str(width)+','+str(height)+','+menuState+','+str(zoom)+');\r\n')
lines.append('\t\t\tshowLogo = false;\r\n')
lines.append('\t\t}\r\n')
lines.append('\t}\r\n')
lines.append('}\r\n')
fo.writelines(lines)
fo.close()

#Generate preloader
filename = project+'/'+src+preloader+'.as';
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open '+filename+' for writing.')
	sys.exit(0)
lines = []
lines.append('package\r\n')
lines.append('{\r\n')
lines.append('\timport org.flixel.data.FlxFactory;\r\n')
lines.append('\r\n')
lines.append('\tpublic class '+preloader+' extends FlxFactory\r\n')
lines.append('\t{\r\n')
lines.append('\t\tpublic function '+preloader+'()\r\n')
lines.append('\t\t{\r\n')
lines.append('\t\t\tclassName = "'+project+'";\r\n')
lines.append('\t\t\tsuper();\r\n')
lines.append('\t\t}\r\n')
lines.append('\t}\r\n')
lines.append('}\r\n')
fo.writelines(lines)
fo.close()

#Generate Default.css
if flexBuilder:
	filename = project+'/'+src+'Default.css';
	try:
		fo = open(filename, 'w')
	except IOError:
		print('Can\'t open '+filename+' for writing.')
		sys.exit(0)
	fo.write('set .actionScriptProject additionalCompilerArguments (line 3) to "-defaults-css-url Default.css"')
	fo.close()

#Generate game menu
filename = project+'/'+src+menuState+'.as';
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open '+filename+' for writing.')
	sys.exit(0)
lines = []
lines.append('package\r\n')
lines.append('{\r\n')
lines.append('\timport org.flixel.*;\r\n')
lines.append('\r\n')
lines.append('\tpublic class '+menuState+' extends FlxState\r\n')
lines.append('\t{\r\n')
lines.append('\t\tpublic function '+menuState+'()\r\n')
lines.append('\t\t{\r\n')
lines.append('\t\t\tvar t:FlxText;\r\n')
lines.append('\t\t\tt = new FlxText(0,FlxG.height/2-10,FlxG.width,"'+project+'");\r\n')
lines.append('\t\t\tt.size = 16;\r\n')
lines.append('\t\t\tt.alignment = "center";\r\n')
lines.append('\t\t\tadd(t);\r\n')
lines.append('\t\t\tt = new FlxText(FlxG.width/2-50,FlxG.height-20,100,"click to play");\r\n')
lines.append('\t\t\tt.alignment = "center";\r\n')
lines.append('\t\t\tadd(t);\r\n')
lines.append('\t\t}\r\n')
lines.append('\r\n')
lines.append('\t\toverride public function update():void\r\n')
lines.append('\t\t{\r\n')
lines.append('\t\t\tsuper.update();\r\n')
lines.append('\t\t\tif(FlxG.mouse.justPressed())\r\n')
lines.append('\t\t\t\tFlxG.switchState(PlayState);\r\n')
lines.append('\t\t}\r\n')
lines.append('\t}\r\n')
lines.append('}\r\n')
fo.writelines(lines)
fo.close()

#Generate basic game state
filename = project+'/'+src+playState+'.as';
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open '+filename+' for writing.')
	sys.exit(0)
lines = []
lines.append('package\r\n')
lines.append('{\r\n')
lines.append('\timport org.flixel.*;\r\n')
lines.append('\r\n')
lines.append('\tpublic class '+playState+' extends FlxState\r\n')
lines.append('\t{\r\n')
lines.append('\t\tpublic function '+playState+'()\r\n')
lines.append('\t\t{\r\n')
lines.append('\t\t\tadd(new FlxText(0,0,100,"INSERT GAME HERE"));\r\n')
lines.append('\t\t}\r\n')
lines.append('\t}\r\n')
lines.append('}\r\n')
fo.writelines(lines)
fo.close()

print('Successfully generated game class, preloader, menu state, and play state.')