class Gallery
  attr_accessor :photos, :name, :created_at

  def initialize(path)
    path.chomp!('/')
    dir = Dir.new(path)

    @name = File.basename(path)
    @created_at = File.mtime(path)

    @photos = dir.map do |file|
      file_path = "#{path}/#{file}"
      next unless File.file?(file_path)

      begin
        Photo.new(file_path)
      rescue RuntimeError => e
        puts e.message
      end
    end.compact.sort_by(&:id).reverse

    dir.close
  end

  def url_name
    @name.downcase.gsub(/[^a-z0-9]/, '_').squeeze('_')
  end
end
