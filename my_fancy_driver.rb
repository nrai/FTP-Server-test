require 'aws/s3'
require 'eventmachine'

class MyFancyDriver
  CREDENTIALS = YAML.load_file("/home/nitish/Work/test/credentials.yml")
  S3_KEYS = YAML.load_file("/home/nitish/Work/test/s3.yml")
  @@current_directory = ""

  def change_dir(path, &block)
    puts "in change_dir"
    puts "path = " + path
    if @@current_directory != "/"
     @@current_directory = path[1..path.length]
    else
     @@current_directory = ""
    end
    yield true
  end

  def dir_contents(path, &block)
    puts "in dir_contents , path = " + path
    @@current_directory = path[1..path.length] unless path == "/"
    puts "@@current_directory = " + @@current_directory
    get_connection
    bucket = AWS::S3::Bucket.find(S3_KEYS["BUCKET"])
    objects = bucket.objects
    object_array = Array.new
    keys_array = Array.new
    bucket.objects.each do |object|
      puts object.key
      if object.key.include?@@current_directory
        temp_key = object.key.gsub(@@current_directory,"")
        temp_key = temp_key.to_s
        if(temp_key != "" && temp_key.start_with?("/") )
          puts temp_key + " starts with /"
          temp_key = temp_key[1..temp_key.length]
        else
          puts temp_key + " doesnt start with /"
        end
        puts "temp key=" + temp_key
        if temp_key.include?"/"
          key = (temp_key.split("/")).first
          if !keys_array.include?key
            keys_array << key
            object_array << dir_item(key)
          end
        else
          key = temp_key
          object_array << file_item(key,object.about["content-length"]) unless key == ""
        end
      end
    end
    puts "keys = " + keys_array.inspect
    yield object_array
    
  end

  def authenticate(user, pass, &block)
  puts "inside authenticate"
  if user == CREDENTIALS['username'].to_s && pass == CREDENTIALS['password'].to_s 
   # EventMachine.start_tls(:private_key_file => '/tmp/server.key', :cert_chain_file => '/tmp/server.crt', :verify_peer => false)
   yield true
  else
   puts "Unsuccessful connection from client " + user+"/"+pass   
   yield false
  end
  end

  def bytes(path, &block)
    puts "in bytes"
    yield case path
          when "/one.txt"       then FILE_ONE.size
          when "/files/two.txt" then FILE_TWO.size
          else
            false
          end
  end

  def get_file(path, &block)
   puts "in get file" 
   get_connection
    AWS::S3::S3Object.store(path,data,S3_KEYS["BUCKET"])
  end
  

  def put_file(path, data, &block)
    puts " in put file "
    puts "path = " + path
    get_connection
    AWS::S3::S3Object.store(path,data,S3_KEYS["BUCKET"])
    yield true
  end

  def delete_file(path, &block)
    yield false
  end

  def delete_dir(path, &block)
    yield false
  end

  def rename(from, to, &block)
    puts "in rename"
    yield false
  end

  def make_dir(path, &block)
    puts "in make_dir"
    yield false
  end

  private


  def dir_item(name)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => true, :size => 0)
  end

  def file_item(name, bytes)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => bytes)
  end

  def get_connection
    AWS::S3::Base.establish_connection!(
    :access_key_id     => S3_KEYS['ACCESS_KEY'],
    :secret_access_key => S3_KEYS['SECRET_KEY']
  )
  end

end

