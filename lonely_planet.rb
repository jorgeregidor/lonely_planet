require 'nokogiri'
load 'functions.rb'


@taxonomyXml = nil
@destinationsXml = nil
@finalPath = nil

exit if not inputValidations

readArgv
#exit if not formatValidations

@example = File.read("output-template/example.html")

startParseTaxonomyXml(@taxonomyXml)




