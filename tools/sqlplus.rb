require 'yaml'

module Store
  class SQLPlus

    def initialize
      myenv = ENV['RAILS_ENV']
      myenv = 'test' unless myenv
      puts "SQLPlus using environment: #{myenv}"

      cf = File.expand_path(File.dirname(__FILE__)) + '/../config/database.yml'
      config_list = YAML::load(File.open(cf))
      dbconfig = config_list[myenv]

      @password = dbconfig['password']
      @username = dbconfig['username']
      @sys_password = "har526"
      # The Oracle Enhanced Adapter requires the domain in the config
      # file, but sqlplus won't connect if we use it.  A bad hack.
      @database = dbconfig['database'].split('.').first
    end

    def reset_user
      sqlcmds = <<-SQLCMDS
        DROP USER #{@username} CASCADE;
        CREATE USER #{@username} IDENTIFIED BY #{@password};
        GRANT CREATE SESSION TO #{@username};
        GRANT CREATE TABLE TO #{@username};
        GRANT CREATE VIEW TO #{@username};
        GRANT CREATE SEQUENCE TO #{@username};
        GRANT UNLIMITED TABLESPACE TO #{@username}; 
        GRANT CREATE PROCEDURE TO #{@username};
        GRANT CREATE TYPE TO #{@username};
        GRANT CREATE ANY INDEX TO #{@username};
        GRANT CREATE TRIGGER TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_CLS TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_DDL TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_DOC TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_OUTPUT TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_QUERY TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_REPORT TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_THES TO #{@username};
        GRANT EXECUTE ON CTXSYS.CTX_ULEXER TO #{@username};
      SQLCMDS
      run_sqlplus(sqlcmds, true)
    end

    def load_plsql
      ['store', 'store2'].each do |f|
        p = File.join(File.expand_path(File.dirname(__FILE__)), f)
        run_sqlplus("@#{p}")
      end
    end

    def run_sqlplus(cmds, sysdba = false)
      fork do
        input = "echo \'#{cmds}\'"
        if sysdba
          connect_string = "sys/#{@sys_password}@#{@database} as sysdba"
        else
          connect_string = "#{@username}/#{@password}@#{@database}"
        end
        exec "#{input} | sqlplus -S #{connect_string}"
      end
      Process.wait
    end
  end
end

