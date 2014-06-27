require 'inifile'
class YarddogConf

    def parse_home_file
        if ENV['HOME']
            path = "#{ENV['HOME']}/.yarddog.conf" 
            if File.exists?(path)
                parse_file path
            else
                warn 'No home file found.'
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
    def [] section
        fail 'No file found.' unless @ini
        @ini[section]
    end

end
