import js.npm.Express;
import js.npm.express.*;
import js.Node;
import js.Node.*;
import js.npm.sequelize.Sequelize;
import js.node.Fs;
import mustache.Mustache;
import haxe.ds.Option;

import yaml.Yaml;
import yaml.Parser;
import yaml.Renderer;
import yaml.util.ObjectMap;

using Lambda;
using thx.Nulls;
using thx.Functions;

import Business;    // business logic goes and stays here

typedef ApiBinding = {
    site            : String, 
    localhost       : String, 
    operations      : Array<Dynamic>,
    userDomain      : String ,
    legacyDomain    : String

}

typedef Operation = {
    ?httpMethod     : String,
    ?path           : String,
    ?summary        : String,
    ?operationId    : String
}
  
class Main {

  private static var initDbCache    = Node.require('sequelize-redis-cache');
  private static var redis        = Node.require('redis');
  private static var session      = Node.require('express-session');
  private static var vm           = Node.require('vm');
  private static var swaggerTools = Node.require('swagger-tools');
  private static var jsyaml       = Node.require('js-yaml');
  private static var passport     = Node.require('passport');


  private static var options = {
    controllers: './',
    useStubs: false
  };

  public static function getConfKey(conf : Dynamic, key : String) : Option<String> {
    if (conf.get(key) == null)
      return None;
    else 
      return Some(conf.get(key));
  }
  
  public static function getCacheKey(conf : Dynamic, key : String) : Option<String> {
    if (conf.get(key) == null)
      return None;
    else 
      return Some(conf.get(key));
  }

  public static function initApiBinding(spec : String) : ApiBinding {
  
    var nativeObject = Yaml.parse(spec, Parser.options().useObjects());
   
    var info = Reflect.field(nativeObject, 'info');
        
    var sitePath = '';
    if (Reflect.hasField(info, 'x-website'))
        sitePath = Reflect.field(info, 'x-website');

    var localHost = '';
    if (Reflect.hasField(info, 'x-website'))
            localHost = Reflect.field(info, 'x-localhost');

    var userDomain = '';
    if (Reflect.hasField(info, 'x-domain'))
            userDomain = Reflect.field(info, 'x-domain');

    var legacyDomain = '';
    if (Reflect.hasField(info, 'x-legacy'))
            legacyDomain = Reflect.field(info, 'x-legacy');

    var paths  = Reflect.field(nativeObject, 'paths');
  
    var opPaths = [];
    var preparePath = Reflect.fields(nativeObject.paths);
    for (p in preparePath){
        var op = Reflect.field(nativeObject.paths,p);
        op.path = p;
        opPaths.push(op);
    }

    var operations = [];
       
    Lambda.map(opPaths, function(op) {
        var opex = Reflect.fields(op);

        var rPath = Reflect.field(op, 'path');
        Lambda.map(opex, function(opx) {
            var operation : Operation = {};
            switch(opx){
                case 'path' : operation.path = opx; 
                case _ : {
                    
                    operation.httpMethod = opx;
                    operation.path = rPath; 
                    operation.summary = '';
                    operation.operationId = '';
                   
                    var methodargs = Reflect.field(op, opx);      
                    var methodargsMap = Reflect.fields(methodargs);
                 
                    methodargsMap
                    .map(function (patharg) {
                        var val = Reflect.field(methodargs, patharg);
                        switch(patharg) {
                            case 'summary': operation.summary=val;
                            case 'operationId': operation.operationId=val;
                        }
                    }); 
                    operations.push({operation:operation});
                }
            }
        });
    });    

    return {
        site : sitePath, 
        localhost: localHost, 
        operations : operations, 
        userDomain : userDomain ,
        legacyDomain : legacyDomain
    }
  }

  public static function initMonitoring(conf: Dynamic) {
    switch (getConfKey(conf, 'ELK_SERVER')) {
        case None: {
          trace("#app : no monitoring");
        }
        case Some(s): {
          trace("#app : add monitoring");
          var config = {
               hosts: [ conf.get('ELK_SERVER') ],
               index: 'nodedata',
               applicationName: conf.get('APP_NAME')
          }
          var appmetrics = require('appmetrics-elk').monitor(config); 
        }
    }
  }

  public static function loadSpec() : String {
    var dn = Node.__dirname;
    var specPath = dn+'/api.yaml';
    return Fs.readFileSync(specPath, 'utf8');
  }

  public static function loadConfiguration() : Dynamic {
    var dn = Node.__dirname;
    var pEnv = 'local';
    if(process.env.exists("ENV")) {
       pEnv = process.env['ENV'];
       trace('#app : setting env to : '+pEnv);
    }
    else {
      trace('#app : ENV is not defined. using local env by default!');
    }

    var confPath = dn+'/conf/'+pEnv+'.yaml';
    var confFile = Fs.readFileSync(confPath, 'utf8');
    trace('#app : using '+ pEnv +'.yaml conf file');
    return Yaml.parse(confFile);
  }

  public static function initDb (conf : Dynamic) {

    var dbOpts = conf.get('DB_OPTIONS');
    var poolOpts = dbOpts.get('pool');
    var dialectOps = dbOpts.get('dialectOptions');
    var opts = {
        host: dbOpts.get('host'),
        dialect: dbOpts.get('dialect'),
        storage: dbOpts.get('storage'),
        pool: {
          max: poolOpts.get('max'),
          min: poolOpts.get('min'),
          idle: poolOpts.get('idle')
        },
        dialectOptions: {
          encrypt: dialectOps.get('encrypt')
        },
        logging: dbOpts.get('logging')
      };
    return new Sequelize(conf.get('DB_NAME'), conf.get('DB_USER'), conf.get('DB_PASSWORD'), untyped opts);
  }

  public static function initCacheClient (conf : Dynamic) {
      return redis.createClient(conf.get('REDIS_PORT'),conf.get('REDIS_HOST'));  
  }

  public static function initOutputCache (conf : Dynamic, redisClient : Dynamic) {
      var coTTL = conf.get('CACHE_OUT_TTL_DEFAULT');
      return Node.require('express-redis-cache')({
          client : redisClient,
          expire : coTTL,
          prefix : 'cacheout:'+conf.get('APP_NAME')+':'
      });
  }

  public static function initSession (conf : Dynamic, app: Dynamic, redisClient : Dynamic) {
      switch (getConfKey(conf, 'SESSION_TTL')) {
        case None: {
          trace("#app : no session");
        }
        case Some(s): {
          trace('#app : using standard session');
          var sessTTL = conf.get('SESSION_TTL');
          var redisStore = Node.require('connect-redis')(session);

          // SESSION
          app.use(new CookieParser(conf.get('APP_NAME')+'cookiekey'));
          var ars= untyped __js__("new redisStore( { client: redisClient, ttl :  sessTTL})");
          app.use(
            session(
              {
                secret: conf.get('APP_NAME')+'secretsessionkey',
                cookie: { maxAge: sessTTL },
                store: ars, 
                saveUninitialized: true,
                resave: true,
                rolling: true
              })
          ); 
        }
    }
  }

  public static function initJWT (conf : Dynamic, app: Dynamic, redisClient : Dynamic) {

      switch (getConfKey(conf, 'JWT_SECRET')) {
        case None: {
          trace("#app : no jwt");
        }
        case Some(s): {
          trace('#app : using JSON WEB TOKENs');
          var jwtSecret = conf.get('JWT_SECRET');
          var jwtTTL    = conf.get('JWT_TTL');

          var JWTRedisSession = require("jwt-redis-session");
  
          app.use(JWTRedisSession({
              client: redisClient,
              secret: jwtSecret,
              keyspace: "jwt:", 
              maxAge: jwtTTL,
              algorithm: "HS256",
              requestKey: "jwtSession",
              requestArg: "jwtToken"
          }));

          var handleRequest = function(req, res){

              var user : Dynamic= { id : 1 };

              req.jwtSession.user = haxe.Json.stringify(user); 

              // this will be attached to the JWT
              var claims = {
                  iss: conf.get('APP_NAME'),
                  aud: "dummy.com"
              };

              req.jwtSession.create(claims, function(error, token){
                  res.json({ token: token });

              });

          };

          app.get('/jwt', untyped handleRequest);
            
          var handleRequest2 = function(req, res){

              console.log("Request JWT session data: ", 
                  req.jwtSession.id, 
                  req.jwtSession.claims, 
                  req.jwtSession.jwt
              );

              res.json(req.jwtSession.toJSON());

          };
          
          app.get('/jwt2', untyped handleRequest2);

        }
    }
  }

  public static function initGAuth (conf : Dynamic, app: Dynamic, redisClient : Dynamic, apiBind : ApiBinding) : Dynamic {

      switch (getConfKey(conf, 'GOOGLE_CLIENT_ID')) {
        case None: {
          trace("#app : no GAuth");
          return untyped function(req, res, next) { next(); }
        }
        case Some(s): {
          
          trace('#app : using Passport GAuth');    
          var gClientId = conf.get('GOOGLE_CLIENT_ID');
          var gClientSecret = conf.get('GOOGLE_CLIENT_SECRET');
          var gCbUrl = conf.get('GOOGLE_CALLBACK_URL');

          var google_strategy = require('passport-google-oauth').OAuth2Strategy;

          app.use(passport.initialize());
            app.use(passport.session());

          passport.serializeUser(function(user, done) {
            done(null, user);
          });

          passport.deserializeUser(function(obj, done) {
            done(null, obj);
          });
      
          untyped __js__("Main.passport.use(new google_strategy({
           clientID: gClientId,
            clientSecret: gClientSecret,
            callbackURL: gCbUrl,
            scope: [ 'email', 'profile', 'https://www.googleapis.com/auth/userinfo.email' ]
          },
          function(accessToken, refreshToken, profile, done) {
            if (profile._json.domain == apiBind.userDomain) 
             return done(null,profile);
             else
             return done(new Error('something bad happened'));
           }
          ))");
      
          app.get('/',
          untyped function(req, res) {
            res.send('<a href="/google">login with google</>');
          });

          app.get('/google',
          passport.authenticate('google',{scope: [ 'email', 'profile', 'https://www.googleapis.com/auth/userinfo.email' ]}),
          untyped function(req, res){
          });

          app.get('/callback', 
          passport.authenticate('google', untyped { failureRedirect: '/logout' }),
          untyped function(req, res) {
            req.session.status = true;
            res.redirect('/site');
          });

          app.get('/logout',
          untyped function(req, res) {
              req.session.status = false;
              res.redirect('/');
          });

          // ACTIVATE FRONT AUTH
          return untyped function(req, res, next) {
            if (req.session.status== true) {
              next(); 
            } else {
              res.redirect("/"); 
            }
          };
        }
    }
  }

  public static function main() {

    trace('#app : starting');

    var dn = Node.__dirname;
    
    // LOAD API SPEC
    var spec = loadSpec();        

    // Bind API yaml values to ApiBinding typedef
    var apiBind = initApiBinding(spec);

    // LOAD CONFIGURATION
    var conf = loadConfiguration();

    // INIT MONITORING
    initMonitoring(conf);

    // INIT DATABASE
    var db = initDb(conf);

    // INIT REDIS CLIENT
    var redisClient = initCacheClient(conf);

    /// INIT CACHE LEVELS
    //     DB CACHE
    var dbcacher = initDbCache(db, redisClient);

    //    OUTPUT CACHE
    var cacheo = initOutputCache(conf, redisClient);
    
    // INIT SWAGGER MIDDLEWARE
    var swaggerDoc = jsyaml.safeLoad(spec);
    swaggerTools.initializeMiddleware(swaggerDoc, function (middleware) {

      // EXPRESS
      var app : Application = new js.npm.Express();
      
      // INIT SESSION (optionnal)
      initSession(conf, app, redisClient);

      // INIT JWT (optionnal)
      initJWT(conf, app, redisClient);
      
      // PASSPORT / GOOGLE TOKEN AUTH (optionnal). 
      // otherwise websiteAuth will be an empty middleware (only containing next();)
      var websiteAuth = initGAuth(conf, app, redisClient, apiBind);
      
      // COMPANION WEBSITE
      app.use('/site', websiteAuth , new js.npm.express.Static(dn+'/site'));

      app.use(BodyParser.json());
      app.use(BodyParser.urlencoded({extended: true}));
      
      // SWAGGER API DOC
      app.use('/doc', new js.npm.express.Static(dn+'/doc'));
      app.use('/haxedoc', new js.npm.express.Static(dn+'/pages'));
      app.use('/api.yaml', new js.npm.express.Static(dn+'/api.yaml'));
 
      // ROUTES SCAFOLDING FROM DOC 
      /**************************************************/
      // YOU CAN WRITE your BUSINESS CODE IN Business Class
      // ie : Business.get_method = function(req,res) {...}
      /**************************************************/
      // Hacks.. use summary to keep ttl and other stuff
       
      apiBind
      .operations
      .map( function(operation) {
            var apiOp = new ApiOperation(operation);
            var args  = apiOp.getCacheArgs();
            var extra = apiOp.getExtraParams();
            var path  = apiOp.getPath();
            var opId = operation.operation.operationId;
            var opMethod = operation.operation.httpMethod + '_' + opId;
            
            var cacheExpire = function(req, res, next) {
                next();
            };
            
            if (args.ttl != '0') 
                cacheExpire = cacheo.route({ expire: args.ttl });
              
            var verb   = Reflect.field(app, operation.operation.httpMethod );    
            var method = Reflect.field(Business, opMethod );  
            
            trace('publising api route : ' + path + ' binds ' + opMethod);
            
            Reflect.callMethod(
                app, 
                verb, 
                [
                    conf.get('BASE_URL')+path, 
                    untyped cacheExpire,
                    function(req : Request, res : Response){ 
                        Reflect.callMethod(Business, method, [ db, req, res, dbcacher, cacheo, extra ]);
                    }
                ]
            );           
      });	
      
      //LEGACY API BOOSTER
      if (apiBind.legacyDomain!='') { 
        // !TODO: we set a ridiculously long default caching time : 10 days. 
        //cache invalidation should be done using event subscriptions in your yaml file !
        var legacyCacheExpire = cacheo.route(untyped { expire: 3600*24*10 });
        app.use('/api/legacy', untyped legacyCacheExpire, untyped function(req : Request, res : Response){ 
          var request = require('request');
          var url= ""+req.url;
          var pipe  = req.pipe(request(url));
          pipe.on('end',function() { 
            res.send(pipe.response);
          });
        });
      }

      app.use(middleware.swaggerMetadata());
      app.use(middleware.swaggerValidator());
    
      var apiPort = Std.parseInt(conf.get('API_PORT'));
      app.listen(apiPort);
      trace('api running on port '+apiPort);

    });
  }
}

class ApiOperation {
    
  var txtArgs   : String;
  var original       : Dynamic;
  var path      : String;
  var urlParams : Dynamic;
  var extraParams     : Dynamic; 
  var summary : Dynamic;

  public function new(t : Dynamic){
    original = t;
	path =  original.operation.path;     
    summary = haxe.Json.parse(StringTools.replace(original.operation.summary,"'",'"'));
    
    var r = ~/\{([^}]+)\}/g;
    urlParams = [];
    r.map(path, function(r) {
      var match = r.matched(0);
      switch (match) {
          default: 
            var f = match;
            f   = StringTools.replace(f,'{',':');
            f   = StringTools.replace(f,'}','');
            urlParams.push(f); 
            return match;
      };
    });
    
    path   = StringTools.replace(path,'{',':');
    path   = StringTools.replace(path,'}','');
    
    // extraParams will hold all our query parameters
    extraParams = { 'url_params' : urlParams , 'ttl' : summary.ttl, 'xttl' : summary.xttl, 'cachekey' :  summary.cachekey, 'xcachekey' : summary.xcachekey };    
  }
 
  public function getCacheArgs() {
    return summary;
  }

  public function getExtraParams() {
    return extraParams;
  }

  public function getPath() {
    return path;
  }

}