/**
 * Generated by Apache Royale Compiler from Main.as
 * Main
 *
 * @fileoverview
 *
 * @suppress {missingRequire|checkTypes|accessControls}
 */

goog.provide('Main');
goog.require('ParticleTest');
/* Royale Dependency List: ParticleTest*/




/**
 * @constructor
 */
Main = function() {
  var /** @type {openfl.display.Stage} */ stage = new openfl.display.Stage(550, 400, 0xFFFFFF, ParticleTest);
  document.body.appendChild(stage.element);
};


/**
 * Prevent renaming of class. Needed for reflection.
 */
goog.exportSymbol('Main', Main);


/**
 * Metadata
 *
 * @type {Object.<string, Array.<Object>>}
 */
Main.prototype.ROYALE_CLASS_INFO = { names: [{ name: 'Main', qName: 'Main', kind: 'class' }] };



/**
 * Reflection
 *
 * @return {Object.<string, Function>}
 */
Main.prototype.ROYALE_REFLECTION_INFO = function () {
  return {
    variables: function () {return {};},
    accessors: function () {return {};},
    methods: function () {
      return {
        'Main': { type: '', declaredBy: 'Main'}
      };
    }
  };
};