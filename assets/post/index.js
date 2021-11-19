function getParameter(name) {
  var match = new RegExp("[?&]" + encodeURIComponent(name) + "=([^&]*)").exec(
    location.search
  );
  return match ? decodeURIComponent(match[1]) : null;
}

function render() {
  var post = getParameter("a");
  var main = document.getElementById("main");
  main.innerHTML = post;
}

render();
