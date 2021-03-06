/*
 * Adds listeners to change themes whenever:
 * - User toggles the theme-switcher checkbox
 * - User changes their OS color scheme preference (and hasn't toggled the checkbox)
 * */

function setTwitterQuotebackThemes(colorMode) {
  const tweets = document.getElementsByClassName('twitter-tweet');
  for (let element of tweets) {
    element.setAttribute('data-theme', colorMode);
  }
  const quotes = document.querySelectorAll('.quoteback');

  const quotebackSetting = colorMode === 'dark' ? 'true' : 'false';
  for (let element of quotes) {
    element.setAttribute('darkmode', quotebackSetting);
  }
}

(function() {

  // setup checkbox to change theme when checked / unchecked
  checkbox = document.getElementById("theme-switcher");
  if (document.documentElement.style.getPropertyValue('--bg') === STYLES.dark['--bg']) {
    checkbox.checked = true;
  }
  setTwitterQuotebackThemes(checkbox.checked ? 'dark' : 'light');
  checkbox.addEventListener('change', function() {
    const colorMode = this.checked ? 'dark' : 'light';
    localStorage.setItem('theme', colorMode); // store user preference
    setCSSProperties(colorMode);
  });

  // change theme if prefers-color-scheme changes (and no user preference)
  const mql = window.matchMedia('(prefers-color-scheme: dark)');
  mql.addEventListener('change', e => {
    if (localStorage.getItem('theme') === null) {
      checkbox.checked = e.matches;
      setCSSProperties(e.matches ? 'dark' : 'light');
    }
  })
})();
