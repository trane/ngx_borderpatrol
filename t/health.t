use lib 'lib';
use Test::Nginx::Socket;

$ENV{TEST_NGINX_MEMCACHED_PORT} ||= 11211;

repeat_each(1);

plan tests => repeat_each() * (1 * blocks());

run_tests();

__DATA__

=== TEST 1: heath controller success
--- main_config
--- http_config
init_by_lua 'bp_version = "0.6.666"
             health_checks = {account="/account/health", business="/business/health"}';
lua_package_path "./build/usr/share/borderpatrol/?.lua;./build/usr/share/lua/5.1/?.lua;;";
lua_package_cpath "./build/usr/lib/lua/5.1/?.so;;";
--- config
    location = /session/health {
      internal;
      set $memc_cmd $arg_cmd;
      set $memc_exptime $arg_exptime;
      memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }

    location /health {
      content_by_lua_file '../../build/usr/share/borderpatrol/health_check.lua';
    }

    location /account/health {
      return 200 "{\"version\": \"1.2.3\"}";
    }

    location /business/health {
      return 200 "{\"version\": \"2.3.4\"}";
    }

--- request
    GET /health
--- error_code: 200

=== TEST 2: heath controller failure
--- main_config
--- http_config
init_by_lua 'bp_version = "0.6.666"
             health_checks = {account="/account/health", business="/business/health"}';
lua_package_path "./build/usr/share/borderpatrol/?.lua;./build/usr/share/lua/5.1/?.lua;;";
lua_package_cpath "./build/usr/lib/lua/5.1/?.so;;";
--- config
    location = /session/health {
      internal;
      set $memc_cmd $arg_cmd;
      set $memc_exptime $arg_exptime;
      memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }

    location /health {
      content_by_lua_file '../../build/usr/share/borderpatrol/health_check.lua';
    }

    location /account/health {
      return 200 "{\"version\": \"1.2.3\"}";
    }

    location /business/health {
      return 500 "{\"version\": \"2.3.4\"}";
    }
--- request
    GET /health
--- error_code: 500
