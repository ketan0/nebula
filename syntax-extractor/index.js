var fs = require('fs');
var cheerio = require('cheerio').default;
var css = require('css');
var Set = require('jsclass/src/set').Set;

var postsPath  = __dirname + '/../html';

var syntaxOrgFile  = __dirname + '/' + process.argv.slice(2)[0] + '.css';
var syntaxFinalFile = __dirname + '/../css/syntax.css';

function getSrcClasses(file, classes) {
  fs.readFile(file, 'utf-8', function(err, contents) {
    var $ = cheerio.load(contents);
    // var classes = new Set();
    $('.org-src-container').each(function(index, element) {
      addClassesToSet(element, classes);
    });
    searchClasses(classes);
  });
}

function searchClasses(classes) {
  fs.readFile(syntaxOrgFile, 'utf-8', function(err, contents) {
    var cssDeclarations = css.parse(contents);
    var rules = cssDeclarations.stylesheet.rules;
    var tokens = [];

    for (var i = 0; i < rules.length; i++) {
      var selectors = new Set(rules[i].selectors);
      if (!classes.intersection(selectors).isEmpty())
        tokens.push(rules[i]);
    }

    cssDeclarations.stylesheet.rules = tokens;
    var fileContent = css.stringify(cssDeclarations);
    fs.writeFile(syntaxFinalFile, fileContent, function(err){
      if(err) {
        console.log("File not saved " + err);
      }});
  });
}

function addClassesToSet(element, set) {
  var el = cheerio(element);
  set.add('.' + el.attr('class'));
  el.children().each(function(index, element) {
    addClassesToSet(element, set);
  });
  return set;
}

const classes = new Set();

fs.readdir(postsPath, function(err, files) {
  files
    .filter(function(file) { return file.substr(-5) === '.html'; })
    .map(function(file) { getSrcClasses(postsPath + '/' + file, classes); });
});
