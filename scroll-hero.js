/* Cardboard Clinic — one continuous scroll on a plain background.
 *  A  .00–.06  worn card + headline + damage loupes
 *  B  .05–.21  zoom into the worn card until it fills the screen and fades to white
 *  C  .20–.54  the restored card pulls back out, spins, settles right; hero copy + header appear
 *  D  .54–.64  copy fades, the same card flies to the middle and faces forward
 *  E  .64–1.0  it lies down and opens into its six layers (labels, specs), then closes again */
(()=>{'use strict';
const $=id=>document.getElementById(id);
const hero=$('home'),stage=$('ccStage');
if(!hero||!stage)return;
const intro=$('ccIntro'),worn=$('ccWorn'),white=$('ccWhite'),shadow=$('ccShadow'),svg=$('ccLines'),
      loupes=[...document.querySelectorAll('.cc-loupe')],wrap=$('ccCardWrap'),card=$('ccCard'),shine=$('ccShine'),
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

function render(p){
  const W=stage.clientWidth,H=stage.clientHeight,mobile=W<760;
  const ch=mobile?H*.4:Math.min(H*.6,540), cw=ch*.7104;
  [worn,wrap,shadow,stack].forEach(el=>el.style.setProperty('--cw',cw+'px'));
  const sr=stage.getBoundingClientRect();

  // ---- A + B: worn card, loupes, zoom into it ----
  const introO=1-seg(p,.02,.06);
  intro.style.opacity=introO;intro.style.transform=`translateX(-50%) translateY(${-30*seg(p,0,.06)}px)`;
  const wx=W/2, wy=mobile?H*.56:H*.6;
  const z=ease(seg(p,.05,.20)), zs=Math.pow(16,z);
  worn.style.transformOrigin='50% 48%';
  worn.style.transform=`translate(${wx-cw/2}px,${wy-ch/2}px) scale(${zs})`;
  worn.style.opacity=p<.21?1:0;
  const wo=seg(p,.14,.20)*(1-seg(p,.22,.28));
  white.style.opacity=wo;
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

  // ---- C + D: restored card ----
  const back=out(seg(p,.20,.30));
  const spin=ease(seg(p,.29,.41)),settle=ease(seg(p,.33,.45)),fly=ease(seg(p,.56,.64));
  let scale=Math.pow(9,1-back)*lerp(1,mobile?.72:.82,settle);
  const sx=mobile?W/2:W*.64, sy=mobile?H*.34:H*.5;          // settled hero position
  const mx=W/2, my=mobile?H*.46:H*.54;                       // middle, where it breaks apart
  let cx=lerp(lerp(W/2,sx,settle),mx,fly), cy=lerp(lerp(wy,sy,settle),my,fly);
  const ls=mobile?.54:.84;                                      // card size while showing the layers
  scale=lerp(scale,ls,fly);
  const bob=Math.sin(p*60)*5*seg(p,.28,.34)*(1-settle*.7)*(1-fly);
  wrap.style.opacity=p>=.20&&p<.64?1:0;
  wrap.style.transform=`translate(${cx-cw/2}px,${cy-ch/2+bob}px) scale(${scale})`;
  const rotY=360*spin+lerp(0,mobile?-14:-26,settle)*(1-fly);
  const rotX=(lerp(0,mobile?8:12,settle)+Math.sin(spin*Math.PI)*10)*(1-fly);
  const rotZ=lerp(0,mobile?-6:-14,settle)*(1-fly);
  card.style.transform=`rotateX(${rotX}deg) rotateY(${rotY}deg) rotateZ(${rotZ}deg)`;
  shine.style.opacity=seg(p,.45,.48)*(1-seg(p,.52,.55));
  shine.style.transform='translateX('+lerp(-50,60,seg(p,.45,.55))+'%)';
  const edge=Math.abs(Math.cos(rotY*Math.PI/180));
  const sh=p<.21?introO*(1-z*4):(p<.64?seg(p,.27,.33)*lerp(.6,1,edge):0);
  const shy=p<.21?wy+ch/2+34:cy+ch*scale/2+40*scale-bob*.5, shx=p<.21?wx:cx, shs=p<.21?1:lerp(.3,1,edge)*scale;
  shadow.style.transform=`translate(${shx-cw/2}px,${shy}px) scaleX(${shs})`;shadow.style.opacity=clamp(sh);
  const c=out(seg(p,.41,.47))*(1-seg(p,.54,.58));
  copy.style.opacity=c;copy.style.pointerEvents=c>.5?'auto':'none';
  copy.style.transform=(mobile?'':'translateY(-50%) ')+`translateY(${lerp(24,0,out(seg(p,.41,.47)))-20*seg(p,.54,.58)}px)`;
  disc.style.opacity=seg(p,.44,.50)*(1-seg(p,.60,.64))+seg(p,.66,.72)*(1-seg(p,.96,1));

  // ---- E: six layers ----
  const inLayers=p>=.64;
  stack.style.visibility=inLayers?'visible':'hidden';
  const lie=ease(seg(p,.64,.70))*(1-ease(seg(p,.95,1)));
  const open=ease(seg(p,.68,.79))*(1-ease(seg(p,.88,.95)));
  const lx0=lerp(mx,mobile?W*.34:W*.55,ease(seg(p,.64,.70))*(1-ease(seg(p,.95,1))));
  const sy0=lerp(my,mobile?my:H*.55,lie);
  stack.style.transform=`translate(${lx0-cw/2}px,${sy0-ch/2}px) scale(${ls}) rotateX(${58*lie}deg) rotateZ(${-34*lie}deg)`;
  const g=(mobile?90:Math.min(88,H*.1))*open;
  layers.forEach((el,i)=>{const o=i-(layers.length-1)/2;el.style.transform=`translateZ(${o*g+o*.6}px)`});
  head.style.opacity=seg(p,.60,.66)*(1-seg(p,.96,1));
  const show=seg(p,.76,.83)*(1-seg(p,.86,.89));
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

  body.classList.toggle('cc-intro',p<.43);
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
    render(reduce?.5:clamp(-r.top/total));
  });
}
addEventListener('scroll',onScroll,{passive:true});addEventListener('resize',()=>{setHdr();onScroll()});addEventListener('hashchange',()=>setTimeout(onScroll,50));
if(document.fonts)document.fonts.ready.then(onScroll);
onScroll();
})();
