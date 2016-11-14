#!/usr/bin/env ruby

$:<<'spec'  # add to load path
files = Dir.glob('spec/unit/**/*.rb') 
files.each{|file| require file.gsub(/^spec\/|.rb$/,'')}  
