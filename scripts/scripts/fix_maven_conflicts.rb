#!/usr/bin/env ruby

require 'tempfile'
require 'optparse'

def parse_version(text)
  if (text.match(/^\s*<version>\s*(.*?)\s*<\/version>\s*$/))
    $1
  else
    nil
  end
end

def format_conflict(conflict)
  "<<<<<<<\n" +
  "#{conflict[:left_conflict]}\n" +
  "=======\n" +
  "#{conflict[:right_conflict]}\n" +
  ">>>>>>>\n"
end

def resolve_conflicts(filename, preferred_version, scm)
  state = :body
  conflict = nil
  outstanding_conflicts = []

  tmpFile = Tempfile.open('fix_maven_conflicts')
  
  File.open(filename, "r") { |conflictFile|
    conflictFile.each_with_index { |line, index|
      if (line.match(/^<{7}/))
        raise "Encountered conflict start marker at line #{index + 1}, but conflict at line #{conflict[:lineno]}" if state != :body

        state = :left_conflict
        conflict = {
            :lineno => index + 1
        }
      elsif (line.match(/^={7}/))
        raise "Encountered conflict separator at line #{index + 1}, but not in a left-side conflict (state is #{state})" if state != :left_conflict

        state = :right_conflict
      elsif (line.match(/^>{7}/))
        raise "Encountered conflict end at line #{index + 1}, but not in a right-side conflict (state is #{state})" if state != :right_conflict

        left_version = parse_version(conflict[:left_conflict])
        right_version = parse_version(conflict[:right_conflict])
        if (left_version == preferred_version)
          puts "Resolved conflict at line #{conflict[:lineno]}"
          tmpFile.puts conflict[:left_conflict]
        elsif (right_version == preferred_version)
          puts "Resolved conflict at line #{conflict[:lineno]}"
          tmpFile.puts conflict[:right_conflict]
        else
          if (left_version.nil? or right_version.nil?)
            puts "Skipping conflict at line #{conflict[:lineno]} as it contains more than conflicting versions"
          else
            puts "Skipping conflict at line #{conflict[:lineno]} as neither version matches"
          end
          puts format_conflict(conflict)
          tmpFile.puts format_conflict(conflict)
        end

        state = :body
      else
        if (state != :body)
          conflict[state] = "" if conflict[state].nil?
          conflict[state] += line
        else
          tmpFile.puts line
        end
      end
    }
  }
  raise "Unclosed conflict marker at line #{conflict[:lineno]}" if state != :body

  tmpFile.close

  if (!conflict.nil?)
    File.rename filename, "#{filename}.conflicts"
    File.rename tmpFile, filename

    `git add #{filename}` if outstanding_conflicts.empty? and scm == :git
    `svn resolved #{filename}` if outstanding_conflicts.empty? and scm == :svn
  else
    tmpFile.unlink
  end
end

def find_pom_files
  pom_files = []
  target_files = File.join("**", "target", "**")
  src_files = File.join("**", "src", "**")
  Dir.glob(File.join("**", "pom.xml")) { |filename|
    if !File.fnmatch(target_files, filename) and !File.fnmatch(src_files, filename)
      pom_files << filename
    end
  }
  pom_files
end



options = {
  :scm => :git
}
 
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: fix_maven_conflicts.rb -v VERSION [options]"
 
  opts.on( '-s', '--scm SCM', [:git,:svn,:none], 'Add resolved files to the specified SCM afterwards (git [default], svn, none)' ) do |scm|
    options[:scm] = scm
  end
 
  opts.on( '-v', '--version VERSION', 'Specify the version to select in conflicts' ) do |version|
    options[:version] = version
  end
 
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

if options[:version].nil?
  puts "ERROR: Version is required"
  puts optparse.help
  exit 1
end

# TODO: consider getting list from git status / svn status instead
find_pom_files.each { |filename|
  puts "Reviewing #{filename} for conflicts"
  resolve_conflicts(filename, options[:version], options[:scm])
}
