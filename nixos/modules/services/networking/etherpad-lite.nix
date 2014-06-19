{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.etherpad;
  uid = config.ids.uids.etherpad;

in

{

  options = {

    services.etherpad = {

      enable = mkOption {
        default = false;
        description = ''
          Whether to enable the etherpad.
        '';
      };

      title = mkOption {
        default = "Etherpad";
        description = ''
          Name your instance.
        '';
      };

      ip = mkOption {
        default = "0.0.0.0";
        description = "IP used by node instance.";
      };

      port = mkOption {
        default = "9001";
        description = "Port used by node instance.";
      };

      sessionKey = mkOption {
        default = "";
        description = ''
          Session Key, used for reconnecting user sessions
          Set this to a secure string at least 10 characters long.  Do not share this value.
        '';
      };

      mysqlUser = mkOption {
        default = "root";
        description = "Mysql username with limited DB permissions (better not root).";
      };

      mysqlHost = mkOption {
        default = "localhost";
        description = "IP or name of MySQL server.";
      };

      mysqlPassword = mkOption {
        default = "";
        description = "Password to access MySQL server with mysqlUser username.";
      };

      mysqlDBName = mkOption {
        default = "ep_store";
        description = "Name of the database used by this etherpad instance.";
      };


      #= mkOption {
      #  default = "";
      #  description = "";
      #};

    };

  };


  ###### implementation

  config = mkIf config.services.etherpad.enable {

    #services.etherpad.netbios_hostname = mkDefault config.networking.hostName;
  
    users.extraUsers = singleton { 
      name = "etherpad";
      description = "etherpad system-wide daemon";
      home = "/var/empty";
    };

    jobs.etherpad =
      { description = "Etherpad is a highly customizable Open Source online editor providing collaborative editing in really real-time.";
      
        startOn = "started network-interfaces";

        daemonType = "fork";

        exec =
          ''
            ${pkgs.nodejs}/bin/node ${pkgs.etherpad}/node_modules/ep_etherpad-lite/node/server.js
          '';
      };

    services.etherpad.extraConfig =
      ''
        /*
          This file must be valid JSON. But comments are allowed
        
          Please edit settings.json, not settings.json.template
        */
        {
          // Name your instance!
          "title": "${cfg.title}",
        
          // favicon default name
          // alternatively, set up a fully specified Url to your own favicon
          "favicon": "favicon.ico",
          
          //IP and port which etherpad should bind at
          "ip": "${cfg.ip}",
          "port" : ${cfg.port},
        
          // Session Key, used for reconnecting user sessions
          // Set this to a secure string at least 10 characters long.  Do not share this value.
          "sessionKey" : "${cfg.sessionKey}",
        
          /*  
          // Node native SSL support
          // this is disabled by default
          //
          // make sure to have the minimum and correct file access permissions set
          // so that the Etherpad server can access them
        
          "ssl" : {
                    "key"  : "/path-to-your/epl-server.key",
                    "cert" : "/path-to-your/epl-server.crt"
                  },
        
          */
        
          //The Type of the database. You can choose between dirty, postgres, sqlite and mysql
          //You shouldn't use "dirty" for for anything else than testing or development
          /*"dbType" : "dirty",
          //the database specific settings
          "dbSettings" : {
                           "filename" : "var/dirty.db"
                         },
          */
                         
          // An Example of MySQL Configuration
           "dbType" : "mysql",
           "dbSettings" : {
                            "user"    : "${cfg.mysqlUser}", 
                            "host"    : "${cfg.mysqlHost}", 
                            "password": "${cfg.mysqlPassword}", 
                            "database": "${cfg.mysqlDBName}"
                          },
          
          //the default text of a pad
          "defaultPadText" : "Welcome to Etherpad!\n\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\n\nGet involved with Etherpad at http:\/\/etherpad.org\n",
          
          /* Users must have a session to access pads. This effectively allows only group pads to be accessed. */
          "requireSession" : false,
        
          /* Users may edit pads but not create new ones. Pad creation is only via the API. This applies both to group pads and regular pads. */
          "editOnly" : false,
          
          /* if true, all css & js will be minified before sending to the client. This will improve the loading performance massivly, 
             but makes it impossible to debug the javascript/css */
          "minify" : true,
        
          /* How long may clients use served javascript code (in seconds)? Without versioning this
             may cause problems during deployment. Set to 0 to disable caching */
          "maxAge" : 21600, // 60 * 60 * 6 = 6 hours
          
          /* This is the path to the Abiword executable. Setting it to null, disables abiword.
             Abiword is needed to advanced import/export features of pads*/  
          "abiword" : null,
         
          /* This setting is used if you require authentication of all users.
             Note: /admin always requires authentication. */
          "requireAuthentication": true,
        
          /* Require authorization by a module, or a user with is_admin set, see below. */
          "requireAuthorization": false,
          
          /*when you use NginX or another proxy/ load-balancer set this to true*/
          "trustProxy": false,
          
          /* Privacy: disable IP logging */
          "disableIPlogging": false,  
          
          /* Users for basic authentication. is_admin = true gives access to /admin.
             If you do not uncomment this, /admin will not be available! */
          "users": {
            "admin": {
              "password": "changeme1",
              "is_admin": true
            },
            "user": {
              "password": "changeme1",
              "is_admin": false
            }
          },
        
          // restrict socket.io transport methods
          "socketTransportProtocols" : ["xhr-polling", "jsonp-polling", "htmlfile"],
          
          /* The toolbar buttons configuration.
          "toolbar": {
            "left": [
              ["bold", "italic", "underline", "strikethrough"],
              ["orderedlist", "unorderedlist", "indent", "outdent"],
              ["undo", "redo"],
              ["clearauthorship"]
            ],
            "right": [
              ["importexport", "timeslider", "savedrevision"],
              ["settings", "embed"],
              ["showusers"]
            ],
            "timeslider": [
              ["timeslider_export", "timeslider_returnToPad"]
            ]
          },
          */
        
          /* The log level we are using, can be: DEBUG, INFO, WARN, ERROR */
          "loglevel": "INFO",
          
          //Logging configuration. See log4js documentation for further information
          // https://github.com/nomiddlename/log4js-node
          // You can add as many appenders as you want here:
          "logconfig" :
            { "appenders": [
                { "type": "console"
                //, "category": "access"// only logs pad access
                }
            /*
              , { "type": "file"
              , "filename": "your-log-file-here.log"
              , "maxLogSize": 1024
              , "backups": 3 // how many log files there're gonna be at max
              //, "category": "test" // only log a specific category
                }*/
            /*
              , { "type": "logLevelFilter"
                , "level": "warn" // filters out all log messages that have a lower level than "error"
                , "appender":
                  {  Use whatever appender you want here  }
                }*/
            /*
              , { "type": "logLevelFilter"
                , "level": "error" // filters out all log messages that have a lower level than "error"
                , "appender":
                  { "type": "smtp"
                  , "subject": "An error occured in your EPL instance!"
                  , "recipients": "bar@blurdybloop.com, baz@blurdybloop.com"
                  , "sendInterval": 60*5 // in secs -- will buffer log messages; set to 0 to send a mail for every message
                  , "transport": "SMTP", "SMTP": { // see https://github.com/andris9/Nodemailer#possible-transport-methods
                      "host": "smtp.example.com", "port": 465,
                      "secureConnection": true,
                      "auth": {
                          "user": "foo@example.com",
                          "pass": "bar_foo"
                      }
                    }
                  }
                }*/
              ]
            }
        }
      '';
  };
  
}
