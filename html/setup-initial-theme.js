/* Gets the initial color preferences from the user,
 * then sets the CSS style variables appropriately. */

STYLES = {
  dark: {
    ['--title-font']: '"Fira Sans", sans-serif',
    ['--font']: '"Lato", sans-serif',
    ['--bg']: '#181818',
    ['--text']: '#efefef',
    ['--nebula-logo']: '#fff',
    ['--references']: '#222',
    ['--code-border']: '#333',
    ['--code']: '#181818',
    // ['--code-label']: '#181818',
    ['--code-output']: '#222',
    ['--inline-code']: '#222',
    ['--section-border']: '#333',
    ['--tippy']: '#222',
    ['--tippy-border']: '#222',
    ['--tippy-shadow']: 'none',
    ['--tippy-arrow-before']: '#222',
    ['--tippy-arrow-after']: '#222',
    ['--switch-icon']: '\'☼️\'',
    ['--highlight-color']: '#444',
  },
  light: {
    ['--title-font']: '"Fira Sans", sans-serif',
    ['--font']: '"Lato", sans-serif',
    ['--bg']: '#fff',
    ['--text']: '#2b2b2b',
    ['--nebula-logo']: '#000',
    ['--references']: '#eee',
    ['--code-border']: '#e6e6e6',
    ['--code']: '#f2f2f2',
    // ['--code-label']: '#f2f2f2',
    ['--code-output']: '#e3e3e3',
    ['--inline-code']: '#eee',
    ['--section-border']: '#e5e7eb',
    ['--tippy']: '#fff',
    ['--tippy-border']: 'rgba(0,8,16,.15)',
    ['--tippy-shadow']: '0 4px 14px -2px rgba(0,8,16,.08)',
    ['--tippy-arrow-before']: '#fff',
    ['--tippy-arrow-after']: 'rgba(0,8,16,.2)',
    ['--switch-icon']: '\'☽\'',
    ['--highlight-color']: '#eee',
  }
}

function setCSSProperties(colorMode) {
  Object.entries(STYLES[colorMode]).forEach(([prop, value]) => {
    document.documentElement.style.setProperty(prop, value)
  });
}

// taken from https://www.joshwcomeau.com/react/dark-mode/
function getInitialColorMode() {
  const persistedColorPreference = localStorage.getItem('theme');
  const hasPersistedPreference = typeof persistedColorPreference === 'string';
  // If the user has explicitly chosen light or dark,
  // let's use it. Otherwise, this value will be null.
  if (hasPersistedPreference) {
    return persistedColorPreference;
  }

  // gonna ignore the fancier logic below for now - i prefer my garden in dark by default
  return 'dark'

  // * // If they haven't been explicit, let's check the media
  // // query
  // const mql = window.matchMedia('(prefers-color-scheme: dark)');
  // const hasMediaQueryPreference = typeof mql.matches === 'boolean';
  // if (hasMediaQueryPreference) {
  //   return mql.matches ? 'dark' : 'light';
  // }
  // // If they are using a browser/OS that doesn't support
  // // color themes, let's default to 'light'.
  // return 'light';
}


(function () {
  const initialColorMode = getInitialColorMode();
  setCSSProperties(initialColorMode);
})();
