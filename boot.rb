require 'rubygems'
require 'bundler/setup'

require 'google_drive'
require 'httpclient'
require 'nokogiri'
require 'csv'
require './nico_community_management'

NicoCommunityManagement.configure = YAML.load_file("./config.yml")
