# m_matschiner Mon Feb 6 16:54:43 CET 2017

# This script generates dot plots from two sequences provided in fasta format.

# Load required libraries.
require 'optparse'

# Define a class for SVG graphs.
class SVG
	attr_reader :width, :height
	def initialize(width, height)
		@width = width
		@height = height
		@elements = []
	end
	def add_element(element)
		@elements << element
	end
	def to_s
		svg_string = ""
		svg_string << "<?xml version=\"1.0\" standalone=\"no\"?>\n"
		svg_string << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
		svg_string << "<svg width=\"#{@width}mm\" height=\"#{@height}mm\" viewBox=\"0 0 #{@width} #{@height}\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">\n"
		@elements.each {|e| svg_string << "    #{e.to_s}\n"}
		svg_string << "</svg>\n"
		svg_string
	end
	def to_uniq_s
		svg_string = ""
		svg_string << "<?xml version=\"1.0\" standalone=\"no\"?>\n"
		svg_string << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
		svg_string << "<svg width=\"#{@width}mm\" height=\"#{@height}mm\" viewBox=\"0 0 #{@width} #{@height}\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">\n"
		svg_elements_string_array = []
		@elements.each {|e| svg_elements_string_array << "    #{e.to_s}\n"}
		svg_elements_string_array.uniq.each do |i|
			svg_string << i
		end
		svg_string << "</svg>\n"
		svg_string
	end
end

# Define a class for lines of the SVG graph.
class Line
	attr_reader :x_start, :y_start, :x_end, :y_end, :stroke_color, :stroke_width, :opacity
	def initialize(x_start,y_start,x_end,y_end,stroke_color,stroke_width,opacity)
		@x_start = x_start
		@y_start = y_start
		@x_end = x_end
		@y_end = y_end
		if stroke_color == nil
			@stroke_color = "black"
		else
			@stroke_color = stroke_color
		end
		if stroke_width == nil
			@stroke_width = 1.0
		else
			@stroke_width = stroke_width
		end
		if opacity == nil
			@opacity = 1.0
		else
			@opacity = opacity
		end
	end
	def to_s
		svg = "<line x1=\"#{@x_start.round(3)}\" y1=\"#{@y_start.round(3)}\" x2=\"#{@x_end.round(3)}\" y2=\"#{@y_end.round(3)}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" stroke-opacity=\"#{@opacity}\" />"
		# svg = "<line x1=\"#{@x_start.round(3)}\" y1=\"#{@y_start.round(3)}\" x2=\"#{@x_end.round(3)}\" y2=\"#{@y_end.round(3)}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" />"
		svg
	end
end

# Define class for circles of the SVG graph.
class Circle
	attr_reader :x, :y, :r, :fill_color, :stroke_color, :stroke_width, :opacity
	def initialize(x,y,r,fill_color,stroke_color,stroke_width,opacity)
		@x = x
		@y = y
		@r = r
		@fill_color = fill_color
		@stroke_color = stroke_color
		@stroke_width = stroke_width
		@opacity = opacity
	end
	def to_s
		svg = "<circle cx=\"#{@x.round(3)}\" cy=\"#{y.round(3)}\" r=\"#{r.round(3)}\" fill=\"#{@fill_color}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" fill-opacity=\"#{@opacity}\" stroke-opacity=\"#{@opacity}\" />"
		# svg = "<circle cx=\"#{@x.round(3)}\" cy=\"#{y.round(3)}\" r=\"#{r.round(3)}\" fill=\"#{@fill_color}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" />"
		svg
	end
end

# Define class for rectangles of the SVG graph.
class Rectangle
	attr_reader :x, :y, :width, :height, :fill_color, :stroke_color, :stroke_width, :opacity
	def initialize(x,y,width,height,fill_color,stroke_color,stroke_width,opacity)
		@x = x
		@y = y
		@width = width
		@height = height
		if fill_color == nil
			@fill_color = "none"
		else
			@fill_color = fill_color
		end
		if stroke_color == nil
			@stroke_color = "black"
		else
			@stroke_color = stroke_color
		end
		if stroke_width == nil
			@stroke_width = 1.0
		else
			@stroke_width = stroke_width
		end
		if opacity == nil
			@opacity = 1.0
		else
			@opacity = opacity
		end
	end
	def to_s
		svg = "<rect x=\"#{@x}\" y=\"#{@y}\" width=\"#{@width}\" height=\"#{@height}\" fill=\"#{@fill_color}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" fill-opacity=\"#{@opacity}\" stroke-opacity=\"#{@opacity}\" />"
		# svg = "<rect x=\"#{@x}\" y=\"#{@y}\" width=\"#{@width}\" height=\"#{@height}\" fill=\"#{@fill_color}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" />"
		svg
	end
end

# Define class for paths of the SVG graph.
class Path
	attr_reader :x, :y, :fill_color, :stroke_color, :stroke_width, :opacity
	def initialize(x,y,fill_color,stroke_color,stroke_width,opacity)
		@x = [x]
		@y = [y]
		@fill_color = fill_color
		@stroke_color = stroke_color
		@stroke_width = stroke_width
		@opacity = opacity
	end
	def add_point(x,y)
		@x << x
		@y << y
	end
	def to_s
		svg = "<path d=\"M #{@x[0]} #{@y[0]} "
		if @x.size > 1
			1.upto(@x.size-1) do |z|
				svg << "L #{@x[z]} #{@y[z]} "
			end
		end
		svg << "z\" fill=\"#{@fill_color}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" fill-opacity=\"#{@opacity}\" stroke-opacity=\"#{@opacity}\"/>"
		# svg << "z\" fill=\"#{@fill_color}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" />"
		svg
	end
end

# Define class for texts of the SVG graph.
class Text
	attr_reader :x, :y
	def initialize(x,y,font_size,string,anchor,baseline,rotation)
		@x = x
		@y = y
		@font_size = font_size
		@string = string
		if anchor == nil
			@anchor = "middle"
		else
			@anchor = anchor
		end
		if baseline == nil
			@baseline = "auto"
		else
			@baseline = baseline
		end
		if rotation == nil
			@rotation = nil
		else
			@rotation = rotation
		end
	end
	def to_s
		svg = ""
		if @rotation == nil
			svg << "<text text-anchor=\"#{@anchor}\" dominant-baseline=\"#{@baseline}\" x=\"#{@x}\" y=\"#{@y}\" font-family=\"Helvetica\" font-size=\"#{@font_size}pt\">#{@string}</text>"
		else
			svg << "<text text-anchor=\"#{@anchor}\" dominant-baseline=\"#{@baseline}\" x=\"#{@x}\" y=\"#{@y}\" font-family=\"Helvetica\" font-size=\"#{@font_size}pt\" transform=\"rotate(#{@rotation} #{@x} #{@y})\">#{@string}</text>"
		end
		svg
	end
end

# Define default options.
options = {}
options[:tupel_size] = 11
options[:circle_radius] = 0.1
options[:seq1] = "lg.fasta"
options[:first1] = 1
options[:last1] = -1
options[:seq2] = "contig.fasta"
options[:first2] = 1
options[:last2] = -1
options[:out] = "out.svg"

# Get the command line options.
ARGV << '-h' if ARGV.empty?
opt_parser = OptionParser.new do |opt|
	opt.banner = "Usage: ruby #{$0} [OPTIONS]"
	opt.separator  ""
	opt.separator  "Example"
	opt.separator  "ruby #{$0} -s #{options[:seq1]} -f #{options[:first1]} -l #{options[:last1]} -r #{options[:seq2]} -p #{options[:first2]} -q #{options[:last2]}"
	opt.separator  ""
	opt.separator  "Options"
	opt.on("-s","--seq1 FILENAME","First sequence in fasta format (will be on x axis, and should be the longer one).") {|s1| options[:seq1] = s1}
	opt.on("-f","--first1 INTEGER",Integer,"First position to consider in first sequence.") {|f1| options[:first1] = f1}
	opt.on("-l","--last1 INTEGER",Integer,"Last position to consider in first sequence (sequence end: '-1').") {|l1| options[:last1] = l1}
	opt.on("-r","--seq2 FILENAME","Second sequence in fasta format (will be on y axis, and should be the shorter one).") {|s2| options[:seq2] = s2}
	opt.on("-p","--first2 INTEGER",Integer,"First position to consider in second sequence.") {|f2| options[:first2] = f2}
	opt.on("-q","--last2 INTEGER",Integer,"Last position to consider in second sequence (sequence end: '-1').") {|l2| options[:last2] = l2}
	opt.on("-g","--gff FILENAME","Annotation file for the first sequence.") {|g| options[:gff] = g}
	opt.on("-t","--tupel_size INTEGER",Integer,"Tupel size (should be an odd number).") {|t| options[:tupel_size] = t}
	opt.on("-c","--circle_radius FLOAT",Float,"Radius of circles drawn for each match.") {|c| options[:circle_radius] = c}
	opt.on("-o","--out FILENAME","Output file.") {|o| options[:out] = o}
	opt.on("-h","--help","Print this help text.") {
		puts opt_parser
		exit(0)
	}
	opt.separator  ""
end
opt_parser.parse!
linkage_group_from = options[:first1]
linkage_group_to = options[:last1]
contig_from = options[:first2]
contig_to = options[:last2]
plot_output_file_name = options[:out]

# Feedback.
puts "Beginning to generate file #{plot_output_file_name}."

# Read the linkage group file.
print "Reading file #{options[:seq1]}..."
linkage_group_file = File.open(options[:seq1])
linkage_group_lines = linkage_group_file.readlines
linkage_group_id = linkage_group_lines[0][1..-1].strip
linkage_group_seq = ""
linkage_group_lines[1..-1].each do |l|
	unless l.strip == ""
		linkage_group_seq << l.strip.upcase
	end
end
if options[:first1] < 1
	puts "ERROR: The first position to consider in the first sequence should at least be 1!"
	exit 1
else
	if options[:last1] == -1
		linkage_group_seq = linkage_group_seq[options[:first1]-1..-1]
	else
		if options[:last1] > options[:first1]
			linkage_group_seq = linkage_group_seq[linkage_group_from-1..linkage_group_to-1]
		else
			puts "ERROR: The last position to consider in the first sequence should be larger than the first position!"
			exit 1
		end
	end
end
puts " done."

# Read the contig file.
print "Reading file #{options[:seq2]}..."
contig_file = File.open(options[:seq2])
contig_lines = contig_file.readlines
contig_id = contig_lines[0][1..-1].strip
contig_seq = ""
contig_lines[1..-1].each do |l|
	unless l.strip == ""
		contig_seq << l.strip.upcase
	end
end
if options[:first2] < 1
	puts "ERROR: The first position to consider in the second sequence should at least be 1!"
	exit 1
else
	if options[:last2] == -1
		contig_seq = contig_seq[options[:first2]-1..-1]
	else
		if options[:last2] > options[:first2]
			contig_seq = contig_seq[contig_from-1..contig_to-1]
		else
			puts "ERROR: The last position to consider in the second sequence should be larger than the first position!"
			exit 1
		end
	end
end
puts " done."

# tmp_fasta_file = File.open("tmp.both.fasta","w")
# tmp_fasta_outstring = ">#{linkage_group_id}\n"
# tmp_fasta_outstring << "#{linkage_group_seq}\n"
# tmp_fasta_outstring << "<#{contig_id}\n"
# tmp_fasta_outstring << "#{contig_seq}\n"
# tmp_fasta_file.write(tmp_fasta_outstring)
# exit

# Read the gff file.
unless options[:gff] == nil
	print "Reading file #{options[:gff]}..."
	gff_file = File.open(options[:gff])
	gff_lines = gff_file.readlines
	cds_ids = []
	cds_starts = []
	cds_ends = []
	gff_lines.each do |l|
		next if l[0] == "#"
		line_ary = l.split
		if line_ary[2] == "CDS" and line_ary[5].to_f >= 0.95 and line_ary[0] == linkage_group_id
			cds_ids << line_ary[-1].gsub("\"","").chomp(";")
			cds_starts << line_ary[3].to_i
			cds_ends << line_ary[4].to_i
		end
	end
	puts " done."
end

# Initialize the SVG graph.
svg_width = 180
svg_margin = 5
tick_length = 0.5
font_size = 2.4705882353
font_spacer = 0.5
svg_height = (2*svg_margin + ((svg_width-2*svg_margin) * (contig_seq.size/linkage_group_seq.size.to_f))).to_i
window_width = svg_width-2*svg_margin
window_height = svg_height-2*svg_margin
svg = SVG.new(svg_width,svg_height)

# Add rectangles for exon regions in the first sequence.
unless options[:gff] == nil
	print "Searching for exon regions..."
	n_exons_inside = 0
	cds_ids.size.times do |x|
		x_start = nil
		if cds_starts[x] >= linkage_group_from and cds_starts[x] < linkage_group_to and cds_ends[x] > linkage_group_from and cds_ends[x] <= linkage_group_to
			x_start = svg_margin + ((cds_starts[x]-linkage_group_from)/linkage_group_seq.size.to_f) * window_width
			x_end = svg_margin + ((cds_ends[x]-linkage_group_from)/linkage_group_seq.size.to_f) * window_width
			# def initialize(x,y,width,height,fill_color,stroke_color,stroke_width,opacity)
			n_exons_inside += 1
		elsif cds_starts[x] >= linkage_group_from and cds_starts[x] < linkage_group_to and cds_ends[x] > linkage_group_to
			x_start = svg_margin + ((cds_starts[x]-linkage_group_from)/linkage_group_seq.size.to_f) * window_width
			x_end = svg_margin + window_width
			n_exons_inside += 1
		elsif cds_starts[x] < linkage_group_from and cds_ends[x] > linkage_group_from and cds_ends[x] <= linkage_group_from
			x_start = svg_margin
			x_end = svg_margin + ((cds_ends[x]-linkage_group_from)/linkage_group_seq.size.to_f) * window_width
			n_exons_inside += 1
		elsif cds_starts[x] <= linkage_group_from and cds_ends[x] >= linkage_group_to
			x_start = svg_margin
			x_end = svg_margin + window_width
			n_exons_inside += 1
		end
		svg.add_element(Rectangle.new(x_start,svg_margin,x_end-x_start,window_height,"#303030",nil,0,0.2)) unless x_start == nil
	end
	puts " done."
end

# Definitions for the dot plot.
tupel_size = options[:tupel_size]
if (tupel_size/2) * 2 == tupel_size
	puts "ERROR: The tupel size should be odd!"
	exit 1
end
tupel_shift_l = tupel_size/2 + 1
tupel_shift_s = tupel_size/2
contig_rand_max = contig_seq.size-tupel_size
linkage_group_rand_max = linkage_group_seq.size-tupel_size
circle_radius = options[:circle_radius]
if circle_radius <= 0
	puts "ERROR: The circle radius should be positive!"
	exit 1
end

# Prepare arrays of tupels.
print "Comparing sequences..."
contig_tupels = []
rev_comp_contig_tupels = []
current_contig_pos = tupel_shift_l
while current_contig_pos + tupel_shift_s < contig_seq.size
	contig_tupel = contig_seq[current_contig_pos-tupel_shift_s-1..current_contig_pos+tupel_shift_s-1]
	rev_comp_tupel = ""
	(contig_tupel.size-1).downto(0) do |x|
		if contig_tupel[x] == "A"
			rev_comp_tupel << "T"
		elsif contig_tupel[x] == "C"
			rev_comp_tupel << "G"
		elsif contig_tupel[x] == "G"
			rev_comp_tupel << "C"
		elsif contig_tupel[x] == "T"
			rev_comp_tupel << "A"
		elsif contig_tupel[x] == "N"
			rev_comp_tupel << "N"
		else
			puts "ERROR: Found unexpected nucleotide: #{contig_tupel[x]}"
			exit 1
		end
	end
	contig_tupels << contig_tupel
	rev_comp_contig_tupels << rev_comp_tupel
	current_contig_pos += 1
end
linkage_group_tupels = []
current_linkage_group_pos = tupel_shift_l
while current_linkage_group_pos + tupel_shift_s < linkage_group_seq.size
	linkage_group_tupel = linkage_group_seq[current_linkage_group_pos-tupel_shift_s-1..current_linkage_group_pos+tupel_shift_s-1]
	linkage_group_tupels << linkage_group_tupel
	current_linkage_group_pos += 1
end

# Generate the dot plot.
tupel_shift_l.upto(linkage_group_seq.size-tupel_shift_l) do |current_linkage_group_pos|
	tupel_shift_l.upto(contig_seq.size-tupel_shift_l) do |current_contig_pos|
		candidate = false
		linkage_group_tupel = linkage_group_tupels[current_linkage_group_pos-tupel_shift_l]
		if linkage_group_tupel == contig_tupels[current_contig_pos-tupel_shift_l]
			candidate = true
			color = "#00A3D7"
		elsif linkage_group_tupel == rev_comp_contig_tupels[current_contig_pos-tupel_shift_l]
			candidate = true
			color = "#F07D26"
		end
		if candidate
			unless linkage_group_tupel.include?("N")
				n_unique_bases = 0
				n_unique_bases += 1 if linkage_group_tupel.include?("A")
				n_unique_bases += 1 if linkage_group_tupel.include?("C")
				n_unique_bases += 1 if linkage_group_tupel.include?("G")
				n_unique_bases += 1 if linkage_group_tupel.include?("T")
				if n_unique_bases >= 3
					x = svg_margin + ((current_linkage_group_pos-1)/linkage_group_seq.size.to_f) * window_width
					y = svg_margin + window_height - ((current_contig_pos-1)/contig_seq.size.to_f) * window_height
					opacity = 1.0
					svg.add_element(Circle.new(x,y,circle_radius,color,"none","none",opacity))
				end
			end
		end
	end
end
puts " done."

# Add horizontal lines for contig boundaries (series of at least 10 Ns) in the second sequence.
print "Searching for contig boundaries..."
contig_boundaries = []
in_ns = false
first_pos_with_ns = nil
contig_seq.size.times do |x|
	if in_ns == true and contig_seq[x] == "N"
		next
	elsif in_ns == true and contig_seq[x] != "N"
		in_ns = false
		if first_pos_with_ns == nil
			puts "ERROR: Found a region of Ns but the first position of that region was not recorded."
			exit 1
		end
		if x-first_pos_with_ns >= 10
			contig_boundaries << first_pos_with_ns + (x-first_pos_with_ns)/2
		end
	elsif in_ns == false and contig_seq[x] == "N"
		in_ns = true
		first_pos_with_ns = x
	elsif in_ns == false and contig_seq[x] != "N"
		next
	else
		puts "ERROR: Unexpected case!"
		exit 1
	end
end
puts " done. Found #{contig_boundaries.size} contig boundaries."
contig_boundaries.each do |b|
	x_start = svg_margin
	x_end = svg_margin + window_width
	y = svg_margin + window_height - (b/contig_seq.size.to_f) * window_height
	svg.add_element(Line.new(x_start,y,x_end,y,nil,0.5,nil))
end

# Add frames to the SVG.
svg.add_element(Rectangle.new(svg_margin,svg_margin,window_width,window_height,nil,"#303030",0.5,nil))

# Add ticks to the SVG.
if linkage_group_seq.size > 1000000
	tick_interval = 200000
elsif linkage_group_seq.size > 500000
	tick_interval = 100000
elsif linkage_group_seq.size > 250000
	tick_interval = 50000
elsif linkage_group_seq.size > 100000
	tick_interval = 20000
elsif linkage_group_seq.size > 50000
	tick_interval = 10000
elsif linkage_group_seq.size > 25000
	tick_interval = 5000
elsif linkage_group_seq.size > 10000
	tick_interval = 2000
elsif linkage_group_seq.size > 5000
	tick_interval = 1000
elsif linkage_group_seq.size > 2500
	tick_interval = 500
elsif linkage_group_seq.size > 1000
	tick_interval = 200
elsif linkage_group_seq.size > 500
	tick_interval = 100
elsif linkage_group_seq.size > 250
	tick_interval = 50
elsif linkage_group_seq.size > 100
	tick_interval = 20
elsif linkage_group_seq.size > 50
	tick_interval = 10
elsif linkage_group_seq.size > 25
	tick_interval = 5
elsif linkage_group_seq.size > 10
	tick_interval = 2
else
	tick_interval = 1
end
linkage_group_from.upto(linkage_group_to) do |pos|
	if (pos/tick_interval)*tick_interval == pos
		tick_x = svg_margin + (pos-linkage_group_from)/linkage_group_seq.size.to_f * window_width
		svg.add_element(Line.new(tick_x,svg_margin+window_height,tick_x,svg_margin+window_height+tick_length,nil,0.5,nil))
		svg.add_element(Text.new(tick_x,svg_margin+window_height+tick_length+font_spacer,font_size,pos,nil,"hanging",nil))
	end
end
# current_tick_seq_pos = tick_interval
# while current_tick_seq_pos < linkage_group_seq.size
# 	puts current_tick_seq_pos
# 	exit
# 	tick_x = svg_margin + (current_tick_seq_pos-1)/linkage_group_seq.size.to_f * window_width
# 	svg.add_element(Line.new(tick_x,svg_margin+window_height,tick_x,svg_margin+window_height+tick_length,nil,0.5,nil))
# 	svg.add_element(Text.new(tick_x,svg_margin+window_height+tick_length+font_spacer,font_size,current_tick_seq_pos+linkage_group_from-1,nil,"hanging",nil))
# 	current_tick_seq_pos += tick_interval
# end
contig_from.upto(contig_to) do |pos|
	if (pos/tick_interval)*tick_interval == pos
		tick_y = svg_margin + window_height - (pos-contig_from)/linkage_group_seq.size.to_f * window_width
		svg.add_element(Line.new(svg_margin-tick_length,tick_y,svg_margin,tick_y,nil,0.5,nil))
		svg.add_element(Text.new(svg_margin-tick_length-2*font_spacer,tick_y,font_size,pos,nil,"alphabetic","-90"))
	end
end
# current_tick_seq_pos = tick_interval
# while current_tick_seq_pos < contig_seq.size
# 	tick_y = svg_margin + window_height - (current_tick_seq_pos-1)/linkage_group_seq.size.to_f * window_width
# 	svg.add_element(Line.new(svg_margin-tick_length,tick_y,svg_margin,tick_y,nil,0.5,nil))
# 	svg.add_element(Text.new(svg_margin-tick_length-2*font_spacer,tick_y,font_size,current_tick_seq_pos+contig_from-1,nil,"alphabetic","-90"))
# 	current_tick_seq_pos += tick_interval
# end

# Write the SVG graph to the plot output file.
plot_output_file = File.open(plot_output_file_name,"w")
plot_output_file.write(svg.to_uniq_s)

# Feedback.
puts "Wrote file #{plot_output_file_name}."
