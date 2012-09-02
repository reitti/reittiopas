/**
 * @license handlebars hbs 0.2.1 - Alex Sexton, but Handlebars has it's own licensing junk
 *
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/require-cs for details on the plugin this was based off of
 */

define([],function(){return{get:function(){return Handlebars},write:function(e,t,n){if(t+customNameExtension in buildMap){var r=buildMap[t+customNameExtension];n.asModule(e+"!"+t,r)}},version:"1.0.3beta",load:function(e,t,n,r){}}})