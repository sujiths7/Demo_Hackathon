#Program : Search Index
#Author  : Sujith S

require 'mysql2'
$client = Mysql2::Client.new(:host => "localhost", :username => "root",:password => "root",:database => "search_index"  )
$select_file=[]


#Method to find the files
def find_files()
	$files = Dir.glob('*.*')
end

#Method for search using filename..
def search_files(search_word,list_array)
	index_var=1
	list_array.each_with_index do |item, index|
  		if list_array[index].include?(search_word)
			puts "		"+index_var.to_s + ". "+ item
			$select_file[index_var]=item
			index_var += 1
  		end
	end
end

#Method for search in content of files 
def search_content (search_word,list_array)
	index_var = 1
	flag=0
	$select_file.clear
	list_array.each_with_index do |item, index|
  		file_temp = File.open(list_array[index],"r")
  		flag=0
  		while line = file_temp.gets do 
			if line.include?(search_word)
				if flag == 0
					$select_file[index_var]=item
					puts "		"+index_var.to_s + ". "+ item + ">>: " + line
					index_var += 1
					flag = 1
				else
					puts "		" + line
				end
			end
		end
		file_temp.close
	end
end

#Method for perform insertion on history table
def history_insert(file_x)
	list_time = Time.now
	$client.query("insert into history values('#{list_time.inspect}','#{file_x}')")
end

#Starts the main session
begin
	puts "1.Search File"
	puts "2.Open File"
	puts "3.History"
	puts "4.Exit"
	print "Enter Your choice "
	$choice = gets
	case $choice.to_i
	when 1
			puts "	a.Using Filename"
			puts "	b.Using Content "
			print "	Enter Choice "
			temp_ch=gets.chomp
		case temp_ch
		when 'a'
			find_files()
			print "\n		Enter filename or part of the file name : " 
			search_temp = gets.chomp
			search_files(search_temp,$files)
			print "		Enter file index you want to open : "
			temp_index=gets
			if $select_file.length > temp_index.to_i
				puts $select_file[temp_index.to_i]
				history_insert($select_file[temp_index.to_i])
				exec('gedit '+$select_file[temp_index.to_i])
			else 
				puts "		! Wrong Index"
			end
		when 'b'
			find_files()
			print "\n		Enter a phrase of the content that u know :"
			search_temp = gets.chomp
			search_content(search_temp,$files)
			print "		Enter file index you want to open : "
			temp_index=gets
			if $select_file.length > temp_index.to_i
				puts $select_file[temp_index.to_i]
				history_insert($select_file[temp_index.to_i])
				exec('gedit '+$select_file[temp_index.to_i])
			else
				puts "		! Wrong Index"
			end
		end
	when 2
		find_files()
		file_index=1
		$files.each do |item|
			puts "		"+file_index.to_s + ". " + item
			file_index += 1
		end
		puts "\n		Enter file index you want to open : "
		temp_index=gets
		puts $files[temp_index.to_i - 1]
		history_insert($files[temp_index.to_i])
		exec('gedit '+$files[temp_index.to_i - 1])
	when 3
		history_rec = $client.query("SELECT * FROM history")
		puts "		Time 				File Name"
		history_rec.each(:cache_rows => false) do |record| 
			print "		#{record['time_open'].to_s}  \t #{record['file_name'].to_s} \n"
   		end
	else
	end
end while $choice.to_i < 4