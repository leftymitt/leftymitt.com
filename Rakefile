# rakefile for starting, editing, and publishing new posts.

desc "print usage information"
task :default do
	puts "options: "
	puts "   rake new \t\t - create a new draft"
	puts "   rake edit \t\t - edit an existing draft"
	puts "   rake publish \t - publish an existing draft"
end

desc "start a new draft."
task :new do
	puts "what's the title?"
	@name = STDIN.gets.chomp

	Dir.mkdir("_drafts") unless File.exists?("_drafts")

	unless @name.nil? || @name.empty?

		@slug = "#{@name}"
		@slug = @slug.tr('ÁáÉéÍíÓóÚú', 'AaEeIiOoUu')
		@slug = @slug.downcase.strip.gsub(' ', '-').gsub('.', '')
		@post_date = Time.now.strftime("%F")

		unless File.file?("_drafts/#{@slug}.md")
			FileUtils.touch("_drafts/#{@slug}.md")
			open("_drafts/#{@slug}.md", 'w' ) do |file|
				file.puts "---"
				file.puts "title: \"#{@name}\""
				file.puts "layout: post"
				file.puts "category: "
				file.puts "author: leftymitt"
				file.puts "format: text"
				file.puts "type: article"
				file.puts ""
				file.puts "added_date: \"#{@post_date}\""
				file.puts "published_date: "
				file.puts "icon: "
				file.puts "img: "
				file.puts "table_of_contents: "
				file.puts "code: false"
				file.puts "---"
			end
		end

		system ("#{ENV['EDITOR']} _drafts/#{@slug}.md")

	end
end

desc "edit a draft."
task :edit do
	Dir.mkdir("_drafts") unless File.exists?("_drafts")
	unless (Dir.entries('_drafts') - %w{ . .. }).empty?

		Dir.foreach("_drafts") do |fname|
			next if fname == '.' or fname == '..' 
			puts fname
		end

		puts ""
		puts "pick a page to edit."
		@name = STDIN.gets.chomp

		unless !File.exists?("_drafts/#{@name}")
			system ("#{ENV['EDITOR']} _drafts/#{@name}")
		end
	else 
		puts "no pages to edit."
	end
end

desc "publish an existing draft."
task :publish do
	Dir.mkdir("_drafts") unless File.exists?("_drafts")
	unless (Dir.entries('_drafts') - %w{ . .. }).empty?

		Dir.foreach("_drafts") do |fname|
			next if fname == '.' or fname == '..' 

			# only display drafts that are categorized. 
			if File.readlines("_drafts/#{fname}").grep(/categor(y|ies):.blog/).any?
				puts "blog: #{fname}"
			elsif File.readlines("_drafts/#{fname}").grep(/categor(y|ies):.media/).any?
				puts "media: #{fname}"
			elsif File.readlines("_drafts/#{fname}").grep(/categor(y|ies):.resource/).any?
				puts "resources: #{fname}"
			elsif File.readlines("_drafts/#{fname}").grep(/categor(y|ies):.project/).any?
				puts "projectss: #{fname}"
			end

		end

		puts ""
		puts "enter page to publish."

		@post_name = STDIN.gets.chomp
		@post_date = Time.now.strftime("%F")

		unless !File.exists?("_drafts/#{@post_name}")

			if File.readlines("_drafts/#{@post_name}").grep(/categor(y|ies):.resource/).any?
				Dir.mkdir("_resources") unless File.exists?("_resources")
				FileUtils.mv("_drafts/#{@post_name}", "_resources/#{@post_name}")
			elsif File.readlines("_drafts/#{@post_name}").grep(/categor(y|ies):.media/).any?
				Dir.mkdir("_media") unless File.exists?("_media")
				FileUtils.mv("_drafts/#{@post_name}", "_media/#{@post_name}")
			elsif File.readlines("_drafts/#{@post_name}").grep(/categor(y|ies):.project/).any?
				Dir.mkdir("_projects") unless File.exists?("_projects")
				FileUtils.mv("_drafts/#{@post_name}", "_projects/#{@post_name}")
			elsif File.readlines("_drafts/#{@post_name}").grep(/categor(y|ies):.blog/).any?
				Dir.mkdir("__posts") unless File.exists?("_posts")
				puts "publish as media? (y/N)"
				@yes = STDIN.gets.chomp

				if @yes == "Y" || @yes == "y"
					Dir.mkdir("_media") unless File.exists?("_media")

					# automatically fill the published_date field.
					text = File.read("_drafts/#{@post_name}")
					text = text.gsub(/published_date:\ /, "published_date: \"#{@post_date}\"")
					File.open("_drafts/#{@post_name}", "w") {|file| file.puts text}

					FileUtils.mv("_drafts/#{@post_name}", "_posts/#{@post_date}-#{@post_name}")
					FileUtils.symlink("../_posts/#{@post_date}-#{@post_name}", "_media/#{@post_name}")
				end
			end

			if File.exists?("_drafts/#{@post_name}")
				puts "error: publishing failed."
			else
				puts "done!"
			end

		end

	else 
		puts "no pages to publish."
	end

end
