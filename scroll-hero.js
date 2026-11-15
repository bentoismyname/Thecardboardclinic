/* Cardboard Clinic — one continuous scroll on a plain background.
 *  A  .00–.06  worn card + headline + damage boxes
 *  B  .04–.26  the card spins a full 360° and lands as the restored card
 *  C  .13–.44  it slides to the side; hero copy + header appear
 *  D  .44–.54  copy fades, the same card flies to the middle and faces forward
 *  E  .54–1.0  it lies down and opens into its six layers, then closes again */
(()=>{'use strict';
const $=id=>document.getElementById(id);
const hero=$('home'),stage=$('ccStage');
if(!hero||!stage)return;
const intro=$('ccIntro'),worn=$('ccWorn'),white=$('ccWhite'),shadow=$('ccShadow'),svg=$('ccLines'),
      loupes=[...document.querySelectorAll('.cc-loupe')],wrap=$('ccCardWrap'),card=$('ccCard'),shine=$('ccShine'),frontNew=$('ccFrontNew'),
      copy=$('ccCopy'),disc=$('ccDisclose'),head=$('clHead'),stack=$('clStack'),lsvg=$('clLines');
const layers=[...stack.children];
layers.forEach(l=>{['r','l'].forEach(s=>{const a=document.createElement('i');a.className='cl-anchor cl-anchor-'+s;l.appendChild(a)})});                               // bottom (back print) → top (coating)
const labels=[...document.querySelectorAll('#clLabels li')];    // 01 coating → 06 back print
const clamp=(v,a=0,b=1)=>Math.min(b,Math.max(a,v));
const seg=(p,a,b)=>clamp((p-a)/(b-a));
const ease=t=>t<.5?4*t*t*t:1-Math.pow(-2*t+2,3)/2;
const out=t=>1-Math.pow(1-t,3);
const lerp=(a,b,t)=>a+(b-a)*t;
const reduce=matchMedia('(prefers-reduced-motion: reduce)').matches;
const header=document.querySelector('header'),body=document.body;
const setHdr=()=>{if(header)document.documentElement.style.setProperty('--cc-hdr',header.offsetHeight+'px')};
setHdr();

// The opening (worn card + spin) plays once per browser. After that the page starts on the restored card.
const START=.37;let played=false;try{played=localStorage.getItem('cc_intro_played')==='1'}catch(e){}
if(played)hero.classList.add('cc-played');
let lastP=0,shineAt=0;
const isResting=v=>v>=.37&&v<=.42;
function playShine(){const now=Date.now();if(reduce||now-shineAt<1800)return;shineAt=now;
  shine.classList.remove('cc-idle-shine');wrap.classList.remove('cc-idle-glow');void shine.offsetWidth;
  shine.classList.add('cc-idle-shine');wrap.classList.add('cc-idle-glow');
  setTimeout(()=>{shine.classList.remove('cc-idle-shine');wrap.classList.remove('cc-idle-glow')},1700);}
function render(p){if(isResting(p)&&!isResting(lastP)&&lastP>p)setTimeout(playShine,250); // scrolled back up to the card
lastP=p;
  const W=stage.clientWidth,H=stage.clientHeight,mobile=W<760;
  const ch=mobile?H*.4:Math.min(H*.6,540), cw=ch*.7104;
  [worn,wrap,shadow,stack].forEach(el=>el.style.setProperty('--cw',cw+'px'));
  const sr=stage.getBoundingClientRect();

  // ---- A: worn card + headline + inspection boxes ----
  const introO=1-seg(p,.02,.06);
  intro.style.opacity=introO;intro.style.transform=`translateX(-50%) translateY(${-30*seg(p,0,.06)}px)`;
  const wx=W/2, wy=mobile?H*.56:H*.6;
  worn.style.display='none';white.style.opacity=0;           // the 3D card below carries the worn face now
  // inspection boxes sitting on the worn card: each shows its spot magnified, with the problem written inside
  const D=cw*(mobile?.42:.31), Z=mobile?2.2:2.4;
  const L=wx-cw/2,T=wy-ch/2;
  loupes.forEach(el=>{
    const fx=+el.dataset.fx,fy=+el.dataset.fy;
    const bx=clamp(L+fx*cw,L+D/2+cw*.02,L+cw-D/2-cw*.02), by=clamp(T+fy*ch,T+D/2+ch*.015,T+ch-D/2-ch*.015);
    el.style.setProperty('--d',D+'px');
    el.style.transform=`translate(${bx-D/2}px,${by-D/2}px)`;el.style.opacity=introO;
    const k=Z, lens=el.firstElementChild, ux=fx, uy=fy;  // the damaged spot sits in the middle of its box
    lens.style.backgroundSize=`${cw*k}px ${ch*k}px`;
    lens.style.backgroundPosition=`${D/2-ux*cw*k}px ${D/2-uy*ch*k}px`;
  });
  svg.innerHTML='';

  // ---- B + C + D: flip over to the restored side, slide to the side, then fly to the middle ----
  const flip=ease(seg(p,.04,.26)),settle=ease(seg(p,.20,.33)),fly=ease(seg(p,.44,.54));
  const sx=mobile?W/2:W*.64, sy=mobile?H*.34:H*.5;          // settled hero position
  const mx=W/2, my=mobile?H*.46:H*.54;                       // middle, where it breaks apart
  const ls=mobile?.54:.84;                                   // card size while showing the layers
  let scale=lerp(1,mobile?.72:.82,settle)*(1+.06*Math.sin(flip*Math.PI));
  scale=lerp(scale,ls,fly);
  const cx=lerp(lerp(wx,sx,settle),mx,fly), cy=lerp(lerp(wy,sy,settle),my,fly);
  const bob=Math.sin(p*60)*4*settle*(1-fly)*seg(p,.26,.3);
  wrap.style.opacity=p<.54?1:0;
  wrap.style.transform=`translate(${cx-cw/2}px,${cy-ch/2+bob}px) scale(${scale})`;
  const rotY=360*flip+lerp(0,mobile?-14:-26,settle)*(1-fly);
  frontNew.style.opacity=360*flip>=180?1:0;               // front face shows the restored card once it has turned away
  const rotX=lerp(0,mobile?8:12,settle)*(1-fly)+Math.sin(flip*Math.PI)*8;
  const rotZ=lerp(0,mobile?-6:-14,settle)*(1-fly);
  card.style.transform=`rotateX(${rotX}deg) rotateY(${rotY}deg) rotateZ(${rotZ}deg)`;
  const sh=seg(p,.255,.275)*(1-seg(p,.345,.365));shine.style.opacity=sh;
  shine.style.transform='translateX('+lerp(-95,95,ease(seg(p,.255,.365)))+'%)';
  wrap.style.filter=sh>0?`drop-shadow(0 0 ${26*sh}px rgba(255,255,255,${.75*sh})) brightness(${1+.12*sh})`:'none';
  const edge=Math.abs(Math.cos(rotY*Math.PI/180));
  // shadow sits under the card's real on-screen outline (follows the tilt and the spin)
  const cr=card.getBoundingClientRect(),srr=stage.getBoundingClientRect();
  const shW=Math.max(cr.width*.82,8), shX=cr.left-srr.left+cr.width/2, shY=cr.bottom-srr.top+(mobile?14:22)+Math.max(0,-bob)*.4;
  shadow.style.transform=`translate(${shX-cw/2}px,${shY-13}px) scaleX(${shW/cw})`;
  shadow.style.opacity=p<.54?lerp(.55,1,edge):0;
  const c=out(seg(p,.31,.37))*(1-seg(p,.42,.46));
  copy.style.opacity=c;copy.style.pointerEvents=c>.5?'auto':'none';
  copy.style.transform=(mobile?'':'translateY(-50%) ')+`translateY(${lerp(24,0,out(seg(p,.31,.37)))-20*seg(p,.42,.46)}px)`;
  disc.style.opacity=0;

  // ---- E: six layers ----
  const inLayers=p>=.54;
  stack.style.visibility=inLayers?'visible':'hidden';
  const lie=ease(seg(p,.54,.60))*(1-ease(seg(p,.95,1)));
  const open=ease(seg(p,.58,.70))*(1-ease(seg(p,.86,.93)));
  const lx0=lerp(mx,mobile?W*.34:W*.55,ease(seg(p,.54,.60))*(1-ease(seg(p,.95,1))));
  const sy0=lerp(my,mobile?my:H*.55,lie);
  stack.style.transform=`translate(${lx0-cw/2}px,${sy0-ch/2}px) scale(${ls}) rotateX(${58*lie}deg) rotateZ(${-34*lie}deg)`;
  const g=(mobile?90:Math.min(88,H*.1))*open;
  layers.forEach((el,i)=>{const o=i-(layers.length-1)/2;el.style.transform=`translateZ(${o*g+o*.6}px)`});
  head.style.opacity=seg(p,.50,.56)*(1-seg(p,.96,1));
  const show=seg(p,.66,.73)*(1-seg(p,.82,.86));
  let ll='';
  labels.forEach((li,n)=>{
    const o=clamp(show*1.6-n*.12);
    li.style.opacity=o;
    if(o<=.01)return;
    const layer=layers[layers.length-1-n],r=layer.getBoundingClientRect();
    const side=mobile?'right':(n%2?'left':'right'); li.dataset.side=side;
    // dot sits on the layer's own visible front edge (the part not hidden by the layer above)
    const an=layer.querySelector(side==='right'?'.cl-anchor-r':'.cl-anchor-l').getBoundingClientRect();
    const ax=an.left-sr.left, ly=an.top-sr.top;
    const lw=li.offsetWidth;
    const lxx=side==='right'?r.right-sr.left+(mobile?10:70):r.left-sr.left-(mobile?18:70)-lw;
    const lyy=ly-(mobile?28:44);
    li.style.transform=`translate(${lxx}px,${lyy+(1-o)*10}px)`;
    const ex=side==='right'?lxx:lxx+lw, ey=lyy+(mobile?32:49);
    ll+=`<line x1="${ax}" y1="${ly}" x2="${ex}" y2="${ey}" opacity="${o}"/><rect x="${ax-3.5}" y="${ly-3.5}" width="7" height="7" opacity="${o}"/>`;
  });
  lsvg.innerHTML=ll;

  body.classList.toggle('cc-intro',p<.33);
}
let ticking=false;
function onScroll(){
  if(ticking)return;ticking=true;
  requestAnimationFrame(()=>{ticking=false;
    const onHome=!!hero.offsetHeight;
    body.classList.toggle('cc-home',onHome);
    if(!onHome){body.classList.remove('cc-intro','cc-past');return} // portal/staff view
    const r=hero.getBoundingClientRect(),total=hero.offsetHeight-innerHeight;
    body.classList.toggle('cc-past',r.bottom<=(header?header.offsetHeight:0)+1);
    const q=clamp(-r.top/total);let p=played?START+(1-START)*q:q;
    if(!played&&!reduce&&p>=START){
      // the intro has now played: remember it, and cut it out of the page so it can't be scrolled back to
      played=true;try{localStorage.setItem('cc_intro_played','1')}catch(e){}
      const top0=scrollY+r.top;hero.classList.add('cc-played');
      const nt=hero.offsetHeight-innerHeight;
      scrollTo({top:top0+((p-START)/(1-START))*nt,behavior:'instant'});
    }
    render(reduce?.5:p);
  });
}
addEventListener('scroll',onScroll,{passive:true});addEventListener('resize',()=>{setHdr();onScroll()});addEventListener('hashchange',()=>setTimeout(onScroll,50));
if(document.fonts)document.fonts.ready.then(onScroll);
onScroll();

// While the restored card rests beside the headline, a shine sweeps across it every 10–20 seconds.
(function idleShine(){
  if(reduce)return;
  const next=()=>setTimeout(run,10000+Math.random()*10000);
  function run(){
    if(isResting(lastP)&&!document.hidden&&hero.offsetHeight)playShine();
    next();
  }
  next();
})();
})();
