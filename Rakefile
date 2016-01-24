$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'bundler/setup'
require 'unterwegs'
require 'erb'
require 'rmagick'

SOURCE = 'src'
BIN = 'bin'
SIZE_THUMB = 100
SIZE_REGULAR = 800
SIZE_FULL = 1280

task :default do
  puts 'rake check   - test run for generating a new gallery'
  puts 'rake compile - generates a new gallery'
  puts 'rake deploy  - deploys the gallery to destination defined in dest.yml'
end

task :check do
  Gallery.new(SOURCE).photos.each do |photo|
    puts "#{photo.id}: #{photo.title}, #{photo.description} (#{photo.created_at})"
  end
end

task :compile do
  gallery = Gallery.new(SOURCE)

  puts "Preparing #{BIN}"
  FileUtils.rm_r(BIN, force: true)
  FileUtils.mkdir(BIN)
  FileUtils.cp_r('base/assets', "#{BIN}/assets")
  FileUtils.mkdir("#{BIN}/photos")

  puts "Resizing and rotating photos"
  gallery.photos.each do |photo|
    print "- "
    img = Magick::Image.read(photo.path).first
    print "#{photo.id}: "

    # Rotating
    begin
      orientation = img.get_exif_by_entry('Orientation').first[1].to_i
      if orientation == 8
        print 'rotating -90deg, '
        img.rotate!(-90)
      end
    rescue Exception => e
      print '(Cannot read EXIF orientation) '
    end

    # Resizing
    img.resize_to_fit(SIZE_THUMB, SIZE_THUMB).write("#{BIN}/photos/#{photo.thumb_filename}")
    print 'thumbnail, '
    img.resize_to_fit(SIZE_REGULAR, SIZE_REGULAR).write("#{BIN}/photos/#{photo.filename}")
    print 'regular, '
    img.resize_to_fit(SIZE_FULL, SIZE_FULL).write("#{BIN}/photos/#{photo.fullscreen_filename}")
    puts 'fullscreen'
  end

  puts "Writing HTML"
  template = ERB.new(File.read('base/index.html.erb'))
  File.open("#{BIN}/index.html", 'w') { |file| file.write(template.result(binding)) }
end

task :deploy do
  ruby 'deploy.rb'
  # use scp to push the bin dir to a remote host if you have ssh access:
  #   scp -r bin bla@blup.de:www/gallery
  # use ssh to clean the remote directory if needed
  #   ssh bla@blup.de "rm -rf www/gallery"
end