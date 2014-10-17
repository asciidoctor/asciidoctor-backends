class File

  def self.relative_path(path)
    Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd))
  end
end
