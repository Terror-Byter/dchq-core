require 'fileutils'
namespace :api do

  desc "Generate Api documentation"

  task :generate_docs => :environment do
    FileUtils.rm_rf "#{Rails.root}/public/apidoc"
    FileUtils.rm_rf "#{Rails.root}/public/apidoc-onepage.html"
    FileUtils.rm_rf "#{Rails.root}/public/apidoc.html"
    FileUtils.rm_rf "#{Rails.root}/public/apidoc-plain.html"

    Rake::Task["apipie:static"].invoke

    FileUtils.mv "#{Rails.root}/doc/apidoc", "#{Rails.root}/public/apidoc"
    FileUtils.mv "#{Rails.root}/doc/apidoc-onepage.html", "#{Rails.root}/public/apidoc-onepage.html"
    FileUtils.mv "#{Rails.root}/doc/apidoc.html", "#{Rails.root}/public/apidoc.html"
    FileUtils.mv "#{Rails.root}/doc/apidoc-plain.html", "#{Rails.root}/public/apidoc-plain.html"
  end
end
