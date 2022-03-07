codes = document.querySelectorAll('div.language-r > div > pre.highlight > code, div.language-sh > div > pre.highlight > code, div.language-bash > div > pre.highlight > code, div.language-js > div > pre.highlight > code');
countID = 0;
codes.forEach((code) => {

  code.setAttribute("id", "code" + countID);
  
  let btn = document.createElement('button');
  btn.innerHTML = "Copy";
  btn.className = "btn-copy";
  btn.setAttribute("data-clipboard-action", "copy");
  btn.setAttribute("data-clipboard-target", "#code" + countID);
  
  let div = document.createElement('div');
  div.appendChild(btn);
  
  code.before(div);

  countID++;
}); 

clipboard = new ClipboardJS('.btn-copy');
