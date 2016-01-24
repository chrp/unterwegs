class Gallery
  attr_accessor :photos

  def initialize(path)
    path.chomp!('/')
    dir = Dir.new(path)

    @photos = dir.map do |file|
      file_path = "#{path}/#{file}"
      next unless File.file?(file_path)

      begin
        Photo.new(file_path) rescue RuntimeError
      rescue RuntimeError => e
        puts e.message
      end
    end.compact.sort_by(&:id).reverse

    dir.close
  end
end
