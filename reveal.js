/* Section entrance: as each section scrolls into view, its parts come in one after another —
 * small label → heading → subheading (sliding in from the left), then the cards rise in, staggered. */
(()=>{'use strict';
if(matchMedia('(prefers-reduced-motion: reduce)').matches||!('IntersectionObserver' in window))return;
const root=document.getElementById('publicView');if(!root)return;
const TEXT='.eyebrow,.cl-eyebrow,h2,.rv-quote,.rv-side p,.section-intro p,.ba-copy p,.ba-copy .cc-link,.ba-note,.restored-inner p,.queue-grid > div:first-child p,.queue-grid > div:first-child .btn,.rv-foot';
const CARDS='.pf-case,.service-card,.price-layout > *,.queue-card,.portfolio-grid > *,.step,.faq details,.rv-card,.ba-slider,.restored-number,.restored-inner > div:last-child';
const sections=[...root.querySelectorAll(':scope > section')].filter(s=>s.id!=='home');
function mark(sec){
  let i=0;
  const text=[...sec.querySelectorAll(TEXT)].filter(el=>!el.closest('.panel,.service-card,.queue-card,.rv-card,.step,details'));
  // keep reading order: label, heading, then the rest
  text.sort((a,b)=>a.compareDocumentPosition(b)&Node.DOCUMENT_POSITION_FOLLOWING?-1:1);
  text.forEach(el=>{if(el.dataset.rv)return;el.dataset.rv='text';el.style.setProperty('--rv-d',(i++*110)+'ms')});
  const base=i*110+80;let k=0;
  sec.querySelectorAll(CARDS).forEach(el=>{if(el.dataset.rv)return;el.dataset.rv='card';el.style.setProperty('--rv-d',(base+Math.min(k++,8)*90)+'ms')});
}
sections.forEach(s=>{s.classList.add('rv-ready');mark(s)});
const io=new IntersectionObserver(es=>es.forEach(e=>{if(!e.isIntersecting)return;mark(e.target);e.target.classList.add('rv-in');io.unobserve(e.target)}),{threshold:.18,rootMargin:'0px 0px -8% 0px'});
sections.forEach(s=>io.observe(s));
// cards that appear later (reviews, portfolio) join in
new MutationObserver(()=>sections.forEach(s=>{if(s.classList.contains('rv-in'))s.querySelectorAll(CARDS).forEach(el=>{if(!el.dataset.rv){el.dataset.rv='card';el.style.setProperty('--rv-d','0ms')}});else mark(s)})).observe(root,{childList:true,subtree:true});
})();
