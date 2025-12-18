####
# Welcome to your project's Gemfile, used by Rubygems & Bundler.
#
# To install a plugin, run:
#
#   bundle add new-plugin-name
#
# and add a relevant init comment to your config/initializers.rb file.
#
# When you run Bridgetown commands, we recommend using a binstub like so:
#
#   bin/bridgetown start (or console, etc.)
#
# This will help ensure the proper Bridgetown version is running.
####

source "https://gem.coop"

git_source(:github) { "https://github.com/#{it}.git" }
git_source(:codeberg) { "https://codeberg.org/#{it}.git" }

# Uncomment to add file-based dynamic routing to your project:
# gem "bridgetown-routes", "~> 2.0.5"

group :development do
  gem "puma", "< 8"
  gem "standard"
end

gem "bridgetown"
# gem "bridgetown-sitemap", "~> 3.0"
gem "bridgetown-feed", "~> 4.0"
