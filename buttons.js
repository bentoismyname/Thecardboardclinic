/* Button hover: the label rolls up and a copy slides in from below while the colour changes. */
(()=>{'use strict';
const SEL='.hp-btn,.cc-link,header .nav-actions .btn,.gp-btn,.au-btn,.pf-back';
function roll(el){
  if(el.dataset.roll||!el.textContent.trim())return;
  el.dataset.roll='1';
  const html=el.innerHTML;
  el.innerHTML=`<span class="roll"><span class="roll-a">${html}</span><span class="roll-b" aria-hidden="true">${html}</span></span>`;
}
const run=root=>root.querySelectorAll&&root.querySelectorAll(SEL).forEach(roll);
run(document);
new MutationObserver(ms=>ms.forEach(m=>m.addedNodes.forEach(n=>{if(n.nodeType!==1)return;if(n.matches?.(SEL))roll(n);run(n)}))).observe(document.body,{childList:true,subtree:true});
})();
