class Photo
  ALLOWED_EXTENSIONS = %w(png jpg jpeg)

  attr_reader :id, :title, :description, :extension, :path, :created_at

  def initialize(path)
    @path = path

    extname = File.extname(path)
    @extension = extname.delete('.').downcase
    fail "Ignoring unsupported extension #{@extension}" unless ALLOWED_EXTENSIONS.include?(@extension)

    @id, @title, @description = File.basename(path, extname).split('_')
    @created_at = File.mtime(path)
  end

  def thumb_filename
    "#{@id}.thumb.#{@extension}"
  end

  def filename
    "#{@id}.large.#{@extension}"
  end

  def fullscreen_filename
    "#{@id}.full.#{@extension}"
  end
end
