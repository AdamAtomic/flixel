#! /usr/local/bin/python
import os, os.path
import sys

#BASIC SCRIPT PRESETS
width = 320					# Width of your game in 'true' pixels (ignoring zoom)
height = 240				# Height of your game in 'true' pixels
zoom = 2					# How chunky you want your pixels
src = 'src' 				# Name of the source folder under the project folder (if there is one!)
preloader = 'Preloader'		# Name of the preloader class
flexBuilder = True			# Whether or not to generate a Default.css file
menuState = 'MenuState'		# Name of menu state class
playState = 'PlayState'		# Name of play state class

#Get name of project
if len(sys.argv) <= 1:
	print "Usage:"
	print "\t%s <project name>" % sys.argv[0]
	sys.exit(0)

project = sys.argv[1]

#Make the directory structure if it doesn't yet exist
project_dir = os.path.join(project, src)
if not os.path.isdir(project_dir):
    print "Creating project directories: %s" % project_dir
    os.makedirs(project_dir)

#Generate basic game class
filename = os.path.join(project, src, '%s.as' % project)
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open %s for writing.' % filename)
	sys.exit(0)

lines = """package
{
\timport org.flixel.*;
\t[SWF(width="%s", height="%s", backgroundColor="#000000")]
\t[Frame(factoryClass="Preloader")]

\tpublic class %s extends FlxGame
\t{
\t\tpublic function %s()
\t\t{
\t\t\tsuper(%s,%s,%s,%s);
\t\t}
\t}
}
""" % (
	str(width*zoom),
	str(height*zoom),
	project,
	project,
	str(width),
	str(height),
	menuState,
	str(zoom)
)
fo.write(lines)
fo.close()

#Generate preloader
filename = os.path.join(project, src, '%s.as' % preloader)
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open %s for writing.' % filename)
	sys.exit(0)

lines = """package
{
\timport org.flixel.system.FlxPreloader;

\tpublic class %s extends FlxPreloader
\t{
\t\tpublic function %s()
\t\t{
\t\t\tclassName = "%s";
\t\t\tsuper();
\t\t}
\t}
}""" % (preloader, preloader, project)
fo.write(lines)
fo.close()

#Generate Default.css
if flexBuilder:
	filename = os.path.join(project, src, 'Default.css')
	try:
		fo = open(filename, 'w')
	except IOError:
		print('Can\'t open %s for writing.' % filename)
		sys.exit(0)
	fo.write('/* Add this: "-defaults-css-url Default.css"\nto the project\'s additonal compiler arguments. */')
	fo.close()

#Generate game menu
filename = os.path.join(project, src, '%s.as' % menuState)
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open %s for writing.' % filename)
	sys.exit(0)

lines = """package
{
\timport org.flixel.*;

\tpublic class %s extends FlxState
\t{
\t\toverride public function create():void
\t\t{
\t\t\tvar t:FlxText;
\t\t\tt = new FlxText(0,FlxG.height/2-10,FlxG.width,"%s");
\t\t\tt.size = 16;
\t\t\tt.alignment = "center";
\t\t\tadd(t);
\t\t\tt = new FlxText(FlxG.width/2-50,FlxG.height-20,100,"click to play");
\t\t\tt.alignment = "center";
\t\t\tadd(t);
\t\t\t
\t\t\tFlxG.mouse.show();
\t\t}

\t\toverride public function update():void
\t\t{
\t\t\tsuper.update();

\t\t\tif(FlxG.mouse.justPressed())
\t\t\t{
\t\t\t\tFlxG.mouse.hide();
\t\t\t\tFlxG.switchState(new PlayState());
\t\t\t}
\t\t}
\t}
}""" % (menuState, project)
fo.write(lines)
fo.close()

#Generate basic game state
filename = os.path.join(project, src, '%s.as' % playState)
try:
	fo = open(filename, 'w')
except IOError:
	print('Can\'t open %s for writing.' % filename)
	sys.exit(0)

lines = """package
{
\timport org.flixel.*;

\tpublic class %s extends FlxState
\t{
\t\toverride public function create():void
\t\t{
\t\t\tadd(new FlxText(0,0,100,"INSERT GAME HERE"));
\t\t}
\t}
}""" % playState
fo.writelines(lines)
fo.close()

print('Successfully generated game class, preloader, menu state, and play state.')
