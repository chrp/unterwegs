class Index
  attr_accessor :galleries

  def initialize(path)
    path.chomp!('/')
    dir = Dir.new(path)

    @galleries = dir.map do |sub_dir|
      sub_path = "#{path}/#{sub_dir}"
      next if sub_dir == '.' || sub_dir == '..'
      next if File.file?(sub_path)

      begin
        Gallery.new(sub_path)
      rescue RuntimeError => e
        puts e.message
      end
    end.compact.sort_by(&:created_at).reverse

    dir.close
  end
end
