$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'bundler/setup'
require 'unterwegs'
require 'erb'
require 'rmagick'

SOURCE = 'src'
BIN = 'bin'
RES_THUMB = 100
RES_REGULAR = 800
RES_FULL = 1280
QUALITY_THUMB = 40
QUALITY_REGULAR = 70
QUALITY_FULL = 70

task :default do
  puts 'rake check   - test run for generating a new gallery'
  puts 'rake clear   - removes bin, use this to create a gallery from scratch without using cache'
  puts 'rake compile - generates a new gallery'
  puts 'rake deploy  - deploys the gallery to destination defined in dest.yml'
end

task :check do
  FileUtils.mkdir_p(SOURCE)
  FileUtils.mkdir_p(BIN)
  fail 'Galleria is missing! See README.md.' unless File.exists?('base/assets/galleria')

  Gallery.new(SOURCE).photos.each do |photo|
    puts "#{photo.id}: #{photo.title}, #{photo.description} (#{photo.created_at})"
  end
end

task :clear do
  FileUtils.rm_r(BIN, force: true)
end

task :compile do
  gallery = Gallery.new(SOURCE)

  puts "Preparing #{BIN}"
  FileUtils.rm_r('tmp', force: true)
  File.exists?(BIN) ? FileUtils.mv(BIN, 'tmp') : FileUtils.mkdir('tmp')
  FileUtils.mkdir(BIN)
  FileUtils.cp_r('base/assets', "#{BIN}/assets")
  FileUtils.mkdir("#{BIN}/photos")

  puts "Resizing and rotating photos"
  gallery.photos.each do |photo|
    print "- #{photo.id}: "

    # Check if photos still exist from last compile run
    files_cached = File.exists?("tmp/photos/#{photo.thumb_filename}") &&
                   File.exists?("tmp/photos/#{photo.filename}") &&
                   File.exists?("tmp/photos/#{photo.fullscreen_filename}")

    if files_cached
      # Move existing files
      [photo.thumb_filename, photo.filename, photo.fullscreen_filename].each do |file|
        FileUtils.mv("tmp/photos/#{file}", "#{BIN}/photos/#{file}")
      end
      puts 'using cached files'
    else
      # Use image magick
      img = Magick::Image.read(photo.path).first

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
      jobs = {
        thumbnail:  { resolution: RES_THUMB, quality: QUALITY_THUMB, file: "#{BIN}/photos/#{photo.thumb_filename}" },
        regular:    { resolution: RES_REGULAR, quality: QUALITY_REGULAR, file: "#{BIN}/photos/#{photo.filename}" },
        fullscreen: { resolution: RES_FULL, quality: QUALITY_FULL, file: "#{BIN}/photos/#{photo.fullscreen_filename}" },
      }

      jobs.each do |job, options|
        resolution, quality, file = options.values
        img.resize_to_fit(resolution, resolution).write(file) { self.quality = quality }
        file_size = (File.stat(file).size/1024).round
        print "#{job} (#{file_size} KB)"
        print ", " unless job == :fullscreen # last job
      end
      puts ''
    end
  end

  puts "Writing HTML"
  template = ERB.new(File.read('base/index.html.erb'))
  File.open("#{BIN}/index.html", 'w') { |file| file.write(template.result(binding)) }

  FileUtils.rm_r('tmp', force: true)
end

task :deploy do
  FileUtils.touch('deploy.rb')
  ruby 'deploy.rb'
  # use scp to push the bin dir to a remote host if you have ssh access:
  #   scp -r bin bla@blup.de:www/gallery
  # use ssh to clean the remote directory if needed
  #   ssh bla@blup.de "rm -rf www/gallery"
end
