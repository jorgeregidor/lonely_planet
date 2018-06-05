
# Validate that the inputs are correct
def inputValidations

	if not ARGV.count==3 
		puts "Invalid number of arguments"
	elsif not File.file?(ARGV[0])
		puts "Invalid Taxonomy XML file (parameter #1)"
	elsif not File.file?(ARGV[1])
		puts "Invalid Destinations XML file (parameter #2)"
	elsif not File.exist?(ARGV[2])
		puts "Invalid Path for new pages (parameter #3)"
	else
		return true
	end

	return false

end

# Read the ARGV to global Variables
def readArgv

	@taxonomyXml = Nokogiri::XML(open(ARGV[0]))
	@destinationsXml = Nokogiri::XML(open(ARGV[1]))
	@finalPath = ARGV[2]
end


# Validate the format of XML
# NOT USED: The format of the example files are not correct
def formatValidations

	if not @taxonomyXml.errors == 0
		puts "Invalid Taxonomy XML format (parameter #1)"
	elsif not @destinationsXml.error == 0
		puts "Invalid Destinations XML format (parameter #2)"
	else
		return true
	end

	return false
end


def getIntroductory(node)

	text = "<h2>Introduction</h2>"

	n2 = node.children
	n3 = n2.children
	n4 = n3.children

	text = text << "<p>#{n4.text.gsub(/\R+/,'</p><p>')}</p>"

	return text

end


def searchInformation(atlas_id)

	text = ""

	node = @destinationsXml.css("destination[atlas_id='#{atlas_id}']")

	node.children.map { |n2| 

		case n2.name

		when "introductory"
			text = text << getIntroductory(n2)
			
		end
	}

	return text

end

# search the info and create each page
def createPage(data, parent, childrens)

	example = @example.clone
	sexample = example.to_s
	links=""

	unless parent.nil?
		links = "<li><a href='#{parent[1]}.html'>#{parent[0]}</a></li>"
	end

	childrens.each { |c| 
		links = links << "<li><a href='#{c[1]}.html'>#{c[0]}</a></li>"
	}

	info = searchInformation(data[1])

	sexample.gsub!('DESTINATION_NAME', data[0])
	sexample.gsub!('LINK_LIST', links)
	sexample.gsub!('CONTENT_TEXT', info)

	output = File.new("#{@finalPath}#{data[1]}.html", "w")
	output.puts(sexample)
	output.close

end


# Start to parse the taxonomy file
def startParseTaxonomyXml(taxonomyXml)

 node = taxonomyXml.xpath("//taxonomy")

 node.children.map { |n2| 

		if n2.name == "node"
			parseTaxonomyXml(n2,nil)
		end
	}
end

# Parse the taxonomy file
def parseTaxonomyXml (node, parent)

	name = ""
	atlas_id = node.attribute("atlas_node_id")
	childrens = []

	node.children.map { |n2| 
		if n2.name == "node_name" 
			name = n2.text.strip
		end 

		if n2.name == "node"
			childrens << parseTaxonomyXml(n2, [name, atlas_id.value])
		end
	}
	createPage([name, atlas_id.value], parent, childrens)
	return [name, atlas_id.value]
end 