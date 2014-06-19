require 'inifile'
class YarddogConf

    def parse_home_file
        if ENV['HOME']
            path = "#{ENV['HOME']}/.yarddog.conf" 
            if File.exists?(path)
                parse_file path
            end
        end
        return self
    end

    def parse_file file
        if File.directory?(file)
            file = File.join(file, '.yarddog.conf')
        end
        return self unless File.exists?(file) # fail silently
        new_ini = IniFile.load(file)
        if @ini
            @ini.merge! new_ini
        else
            @ini = new_ini
        end
        return self
    end

    # example usage:
    # conf = YarddogConf.new.parse_home_file
    # conf['Server']['aws_key']
    def method_missing attempted_method, *args
        (@ini.respond_to? attempted_method) ? @ini.send(attempted_method, *args) : super
    end

    def respond_to_missing?
        @ini.respond_to? || super
    end

end
