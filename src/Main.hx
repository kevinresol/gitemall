package;

import haxe.Json;
import Sys.*;
import sys.io.Process;

using sys.io.File;
using sys.FileSystem;
using haxe.io.Path;
using StringTools;

class Main {
	static function main()
		new Main();
		
	var cwd:String;
		
	public function new() {
		var libPath = getCwd();
		var args = args();
		cwd = args.pop();
		setCwd(cwd);
		
		var hxml = switch args {
			case []:
				findHxml();
			case [v] if(v.extension() == 'hxml'):
				if(!'$cwd$v'.exists()) fail('The specified hxml does not exist ($cwd$v)') else v;
			default:
				showUsage();
		}
		
		prepare();
		
		var libs = parseHxml(hxml);
		
		function handleLib(lib) {
			if(submoduleExists('haxelib/$lib')) {
				info('Submodule $lib already exists, skipping');
				return;
			}
			var url = getLibUrl(lib);
			addSubmodule(lib, url);
			haxelibInstall(lib);
			var haxelibJson = findHaxelibJson('haxelib/$lib/');
			var libs = parseHaxelibJson(haxelibJson);
			info(libs.length > 0 ? '$lib has the following dependencies: ' + libs.join(', ') : '$lib has no dependencies');
			for(lib in libs) handleLib(lib);
		}
		
		for(lib in libs) handleLib(lib);
		
		info('Done!');
	}
	
	function prepare() {
		var git = '.git';
		if(!git.exists() || !git.isDirectory()) fail('Current directory is not a git repo, run `git init` first ($cwd)');
		function create(f:String) {
			if(!f.exists()) f.createDirectory();
		}
		create('.haxelib');  
		create('haxelib');  
	}
	
	function findHxml() {
		info('Finding hxml');
		for(f in cwd.readDirectory()) {
			if(!f.isDirectory() && f.extension() == 'hxml')
				return f;
		}
		throw fail('Cannot find hxml file in current directory ($cwd)');
	}
	
	function parseHxml(file:String) {
		info('Parsing hxml');
		var content = file.getContent();
		var libs = [];
		var tokens = content.replace('\n', ' ').replace('\t', ' ').split(' ');
		var i = 0;
		while(i < tokens.length) {
			if(tokens[i] == '-lib') libs.push(tokens[++i]);
			i++;
		}
		return libs;
	}
	
	function findHaxelibJson(path:String) {
		info('Finding haxelib.json in $path');
		
		function find(dir:String) {
			for(f in dir.readDirectory()) {
				var full = dir.addTrailingSlash() + f;
				if(full.isDirectory()) switch find(full) {
					case null: // continue
					case v: return v;
				}
				if(f == 'haxelib.json') return full;
				if(f == 'haxelib.xml') {
					info('Converting haxelib.xml ($full)');
					setCwd(dir);
					var proc = new Process('haxelib', ['convertxml']);
					proc.exitCode();
					setCwd(cwd);
					return full.withoutExtension().withExtension('json');
				}
			}
			return null;
		} 
		return find(path);
	}
	
	function parseHaxelibJson(path:String) {
		info('Parsing haxelib.json at ${path.directory()}');
		var json = Json.parse(path.getContent());
		return json.dependencies == null ? [] : Reflect.fields(json.dependencies);
	}
	
	function getLibUrl(name:String) {
		info('Getting the url for $name');
		var proc = new Process('haxelib', ['info', name]);
		var out = proc.stdout.readAll().toString();
		for(line in out.split('\n')) if(line.startsWith('Website:')) {
			var url = line.replace('Website:', '').trim();
			if(url != '') return url;
			break;
		}
		return prompt('Cannot find the url of $name from lib.haxe.org, please input mannually:');
	}
	
	function addSubmodule(name:String, url:String) {
		var dest = 'haxelib/$name';
		info('Adding $name as submodule from $url');
		var proc = new Process('git', ['submodule', 'add', url, dest]);
		var out = proc.stdout.readAll().toString();
		var err = proc.stderr.readAll().toString();
		if(proc.exitCode() != 0) fail(err);
	}
	
	var submoduleRe = ~/\[submodule "([^"]*)"\]/;
	function submoduleExists(relPath:String) {
		var f = '.gitmodules';
		if(!f.exists()) return false;
		for(line in f.getContent().split('\n')) if(submoduleRe.match(line) && submoduleRe.matched(1) == relPath) return true;
		return false;
	}
	
	function haxelibInstall(name:String) {
		info('Installing haxelib $name');
		var f = '.haxelib/$name';
		if(!f.exists()) f.createDirectory();
		'$f/.dev'.saveContent('haxelib/$name');
	}
	
	function prompt(msg:String) {
		println('Prompt: $msg');
		print('> ');
		return stdin().readLine();
	}
	
	function showUsage<T>():T {
		println('Usage: haxelib run --global gitemall [hxml]');
		exit(0);
		return null;
	}
	
	function info(msg:String, ?pos:haxe.PosInfos) {
		println('Info: $msg');
	}
	
	function fail<T>(msg:String, ?pos:haxe.PosInfos):T {
		println('Error: $msg');
		exit(1);
		return null;
	}
}