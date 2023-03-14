//document.documentElement.className = "dark";
//document.documentElement.style = "color-scheme: dark; overflow: hidden;";
//

function activateDarkMode() {
  console.log("mode changing!")
}
const darkModePreference = window.matchMedia("(prefers-color-scheme: dark)");
darkModePreference.addEventListener("change", e => e.matches && activateDarkMode());

