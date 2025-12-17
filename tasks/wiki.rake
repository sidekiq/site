# Adapted from https://github.com/djacquel/WikiToJekyll/blob/master/Rakefile
require "yaml"
require "uri"

def g(key)
  {
    user_name: "sidekiq",
    repository_name: "sidekiq",
    deploy_remote: "origin",
    deploy_branch: "gh-pages",
    wiki_repository_url: "https://github.com/sidekiq/sidekiq.wiki.git",
    wiki_source: "src/_wiki",
    wiki_dest: "src/wiki"
  }[key.to_sym]
end

# IMPORTANT ++++++++++++++++
# you submodule MUST be added with the https:// scheme
# git add submoudle https://github.com/userName/RepositoryName.wiki.git
# otherwise you will have github errors
def update_wiki_submodule
  pull_command = "git pull origin master"
  output = ex(pull_command, message: "Updating _wiki submodule", cwd: g("wiki_source"))
  if output.include? "Already up-to-date"
    abort("No update necessary") # exit
  end
end

def ex(cmd, message: "Running command", cwd: ".")
  puts "#{message} (in #{cwd}): #{cmd}"
  cd cwd do
    `#{cmd}`
  end
end

def clean_wiki_folders
  if File.exist?(g("wiki_dest"))
    Dir.glob("#{g("wiki_dest")}/*.md") do |page|
      puts "removing #{g("wiki_dest")}"
      rm_rf page
    end
  else
    mkdir_p(g("wiki_dest"))
  end
end

def copy_wiki_pages
  # here we only glob page beginning by a letter
  # no _footer.md or thing like this
  Dir.glob("#{g("wiki_source")}/[A-Za-z]*.md") do |page|
    file_name = File.basename(page).tr(" ", "-")
    page_path = File.join(g("wiki_dest"), file_name)

    # remove extension
    name = file_name.sub(/.[^.]+\z/, "")
    title = name.tr("-", " ")
    content = File.read(page)

    puts "Generating #{page_path}"

    # write the new file with yaml front matter
    File.open(page_path, "w") do |new_page|
      new_page.puts "---"
      new_page.puts "layout: page"
      new_page.puts "title: #{title}"
      new_page.puts "wikiPageName: #{name}"
      new_page.puts "category: wiki"
      new_page.puts "updated_at: #{Time.now.utc.iso8601}"
      new_page.puts "---"
      new_page.puts ""
      new_page.puts content
    end
  end
end

namespace :wiki do
  desc "Synchronize GitHub wiki content to here"
  task :sync do |t|
    update_wiki_submodule
    clean_wiki_folders
    copy_wiki_pages
    puts "Wiki synchronisation success!"
  end

  desc "Create the Git submodule link to the GitHub wiki repository"
  task :submodule do |t|
    wiki_repository = g("wiki_repository_url")
    command = "git submodule add " + wiki_repository + " " + g("wiki_source")
    command += " && git submodule init"
    command += " && git submodule update"

    output = ex(command, message: "Adding wiki submodule")
    if output.include? "failed"
      abort("submodule add failed: verify you configuration and that you wiki is public\n#{output}") # exit
    end
  end
end
