// HACK: insert citation for web article as a superscript to the
// document title
(function () {
  const link = document.querySelector('.no-display sup');
  if (!link) return;
  link.remove();
  const title = document.querySelector('.title');
  title.insertBefore(link, title.children[0]);
})();
