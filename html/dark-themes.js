function changeDarkThemes() {
  if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    const tweets = document.getElementsByClassName('twitter-tweet');
    for (let element of tweets) {
      element.setAttribute('data-theme', 'dark');
    }
    const quotes = document.querySelectorAll('.quoteback');
    for (let element of quotes) {
      element.setAttribute('darkmode', 'true');
    }
  }
}

changeDarkThemes();
