package;

import Sys.*;
import sys.io.Process;

using sys.io.File;
using sys.FileSystem;
using haxe.io.Path;
using StringTools;

class Main {
	static function main()
		new Main();
		
	public function new() {
		var libPath = getCwd();
		var args = args();
		var cwd = args.pop();
		var hxml = switch args {
			case []:
				findHxml(cwd);
			case [v] if(v.extension() == 'hxml'):
				if(!'$cwd$v'.exists()) fail('The specified hxml does not exist ($cwd$v)') else v;
			default:
				showUsage();
		}
		
		prepareFolders(cwd);
		
		var libs = parseHxml('$cwd$hxml');
		for(lib in libs) {
			var url = getLibUrl(lib);
			trace(url);
		}
		
	}
	
	function prepareFolders(path:String) {
		function create(folder:String) {
			var f = path + folder;
			if(!f.exists()) f.createDirectory();
		}
		create('.haxelib');  
		create('haxelib');  
	}
	
	function findHxml(path:String) {
		for(f in path.readDirectory()) {
			if(!'$path$f'.isDirectory() && f.extension() == 'hxml')
				return f;
		}
		throw fail('Cannot find hxml file in current directory ($path)');
	}
	
	function parseHxml(path:String) {
		var content = path.getContent();
		var libs = [];
		var tokens = content.replace('\n', ' ').replace('\t', ' ').split(' ');
		var i = 0;
		while(i < tokens.length) {
			if(tokens[i] == '-lib') libs.push(tokens[++i]);
			i++;
		}
		return libs;
	}
	
	function getLibUrl(name:String) {
		var proc = new Process('haxelib', ['info', name]);
		var out = proc.stdout.readAll().toString();
		for(line in out.split('\n')) if(line.startsWith('Website:')) return line.replace('Website:', '').trim();
		return null;
	}
	
	function showUsage<T>():T {
		println('Usage: haxelib run gitemall [hxml]');
		exit(0);
		return null;
	}
	
	function fail<T>(msg:String, ?pos:haxe.PosInfos):T {
		println('Error: $msg');
		exit(0);
		return null;
	}
}