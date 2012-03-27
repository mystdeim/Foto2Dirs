#!/usr/bin/env ruby
#coding: utf-8

#Откуда копировать
if ARGV[0].nil? then
  Input = '/media'
else
  Input = ARGV[0]
end

#Куда копировать
if ARGV[1].nil? then
  Output = '/home/deim/foto/raws'
else
  Output = ARGV[1]
end

#Взятие даты
def getCreateDate str

  #Фикс для пробелов в именах файла
  strf = str.gsub(' ', '\ ').gsub('(', '\(').gsub(')', '\)')

  begin
    ret = `exiftool -createdate #{strf}`.split(':')
    ret[1].sub(' ', '')+'.'+ret[2]+'.'+ret[3].split(' ')[0]
  rescue
    puts "Error, when work with '#{strf}'"
    false
  end
end

#Создание каталогов
def createDir dir
  arr = dir.split('/')
  path = '/'
  0.upto(arr.count-1) do |item|
    if arr[item] != '' then
      path += arr[item]+ '/' if arr[item] != ''
      begin
        Dir.mkdir(path) if !Dir.exist?(path)
      rescue
        puts "Cannot create dir '#{path}'"
      end
    end
  end

end

#Копирование файлов
def copyFiles

  arr = Dir.glob(Input+'/**/*.{ORF,JPG}').sort_by { |filename| File.mtime(filename) }
  bytes = 0
  files = 0
  dirs = Hash.new

  arr.each do |origin|

    dir_date = getCreateDate(origin)

    if dir_date then
      #Создаём каталог
      dir = Output + '/' + getCreateDate(origin)
      if !dirs.has_key?(dir) then
        dirs[dir] = nil
        createDir(dir)
        puts
        print dir + ' '
      end

      #Копируем файл
      file_new = Output + '/' + getCreateDate(origin) + '/' + origin.split('/').last
      if !File.exist?(file_new) then
        bytes += IO.copy_stream(origin, file_new)
        files += 1
        print '.'
      else
        print '!'
      end
    end
  end

  puts
  puts
  puts 'Moved: ' + files.to_s + ' files'
  puts 'Moved: ' + (bytes/1000000).to_s + ' Mbytes'
  puts

end

copyFiles

