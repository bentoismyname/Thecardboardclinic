/* Before / after slider: drag (or use arrow keys) to reveal the card before and after treatment. */
(()=>{'use strict';
const el=document.getElementById('baSlider'),range=document.getElementById('baRange');
if(!el||!range)return;
const tags=el.querySelectorAll('.ba-tag');
const set=v=>{v=Math.max(0,Math.min(100,+v));el.style.setProperty('--pos',v+'%');
  tags[0].style.opacity=v<12?0:1;tags[1].style.opacity=v>88?0:1;};
range.addEventListener('input',()=>set(range.value));
set(range.value);
// a gentle one-time sweep the first time the slider comes into view, so people see it moves
if(!matchMedia('(prefers-reduced-motion: reduce)').matches&&'IntersectionObserver' in window){
  let touched=false;range.addEventListener('pointerdown',()=>touched=true,{once:true});
  const io=new IntersectionObserver(es=>{if(!es[0].isIntersecting)return;io.disconnect();
    const keys=[[0,50],[600,22],[1300,78],[2000,50]],t0=performance.now();
    const step=now=>{if(touched)return;const t=now-t0;let i=keys.findIndex(k=>k[0]>t);if(i<0){set(50);range.value=50;return}
      const [ta,va]=keys[i-1],[tb,vb]=keys[i],u=(t-ta)/(tb-ta),e=u<.5?2*u*u:1-Math.pow(-2*u+2,2)/2,v=va+(vb-va)*e;
      set(v);range.value=v;requestAnimationFrame(step)};
    setTimeout(()=>requestAnimationFrame(step),300)},{threshold:.5});
  io.observe(el);
}
})();

/* Reviews: arrow buttons + progress bar for the side-scrolling cards */
(()=>{'use strict';
const track=document.getElementById('reviewList'),prev=document.getElementById('rvPrev'),next=document.getElementById('rvNext'),bar=document.getElementById('rvBar');
if(!track||!prev||!next||!bar)return;
const step=()=>{const c=track.querySelector('.rv-card');return c?c.getBoundingClientRect().width+20:300};
const update=()=>{const max=track.scrollWidth-track.clientWidth;const vis=track.scrollWidth?track.clientWidth/track.scrollWidth:1;
  bar.style.width=Math.max(12,Math.min(100,vis*100))+'%';
  bar.style.transform=`translateX(${max>0?(track.scrollLeft/max)*(100/Math.min(1,vis)-100):0}%)`;
  prev.disabled=track.scrollLeft<=2;next.disabled=track.scrollLeft>=max-2;};
prev.addEventListener('click',()=>track.scrollBy({left:-step()}));
next.addEventListener('click',()=>track.scrollBy({left:step()}));
track.addEventListener('scroll',update,{passive:true});addEventListener('resize',update);
document.addEventListener('reviews:rendered',()=>requestAnimationFrame(update));
new MutationObserver(update).observe(track,{childList:true});
update();
})();
