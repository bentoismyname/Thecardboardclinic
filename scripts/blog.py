"""Builds the static blog pages in blog/ from the posts below.
Run: python3 -I scripts/blog.py   (from the project folder), then commit blog/.
To add a post, append to POSTS and run again."""
import html, json, os, re

SITE = "https://www.thecardboardclinic.com"
WA = "https://wa.me/6598221113"
PUBLISHED = "2026-11-27"

POSTS = [
dict(
 slug="can-a-dented-pokemon-card-be-fixed",
 title="Can a Dented Pokémon Card Be Fixed?",
 seo_title="Can a Dented Pokémon Card Be Fixed? Card Dent Repair in Singapore",
 desc="Dents, dings and pressure marks on Pokémon and other trading cards: what causes them, what home fixes risk, and what professional dent reduction can realistically do.",
 kicker="Dents",
 image="/assets/cases/case-02-before.webp",
 pair=("/assets/cases/case-02-before.webp", "/assets/cases/case-02-after.webp", "A real customer card with an edge dent, before and after treatment at Cardboard Clinic."),
 body="""
<p class="bl-lede">A dent is one of the most common problems we see on Pokémon and other trading cards, and one of the most fixable. Here is what a dent actually is, why home fixes often make it worse, and what you can realistically expect from professional dent reduction in Singapore.</p>

<h2>What a dent really is</h2>
<p>A trading card is not a single sheet. It is several thin layers pressed together: a protective coating, the printed front, paper stock, a dark core layer and the printed back. When something presses into the card, such as a fingernail, the edge of a toploader or a heavy box, the paper fibres in those layers are squashed together. The ink and coating usually stay intact, but the surface now has a low spot that catches the light.</p>
<p>That is why a dent can look terrible under a lamp and almost disappear when you tilt the card. It is a change in shape, not missing material, and that is exactly why it can often be improved.</p>

<h3>The common types</h3>
<ul>
<li><strong>Surface indents:</strong> small pressure marks on the face, often from writing on something placed on top of the card.</li>
<li><strong>Edge dings:</strong> a dent along an edge, usually from the card being knocked or pushed into a sleeve or toploader.</li>
<li><strong>Corner dents:</strong> a corner pushed in or bent slightly, often with the layers starting to lift.</li>
<li><strong>Roller or print lines:</strong> lines from the factory. These are not damage and usually cannot be changed.</li>
</ul>

<h2>Why home fixes are risky</h2>
<p>You will find plenty of videos showing cards being steamed, put in the fridge, ironed or left under a pile of books. Some of them work on some cards. Many of them quietly cause new problems, especially in Singapore's humidity.</p>
<ul>
<li><strong>Water and steam</strong> can leave tide marks, cloud the surface coating or make the layers swell unevenly, which turns a small dent into a wavy card.</li>
<li><strong>Heat</strong> can soften the coating and the holofoil. On holo and full-art cards that can mean a change in texture that is far more obvious than the original dent.</li>
<li><strong>Heavy books</strong> spread pressure unevenly. The dent may soften, but the card can pick up a curl or new marks from the book's surface.</li>
<li><strong>Too much at once.</strong> Most damage happens when someone tries several fixes in a row on the same card.</li>
</ul>
<p>If a card is worth more to you than a few dollars, it is worth getting an opinion before trying anything.</p>

<h2>What professional dent reduction can do</h2>
<p>Professional dent reduction works with the card rather than against it: controlled moisture, gentle and even pressure, and plenty of time, with the card checked at every stage. The goal is to let the squashed fibres relax back toward their original shape without marking the surface or changing the card.</p>
""",
 pair_after=True,
 body2="""
<p>What to expect, honestly:</p>
<ul>
<li><strong>Reduced, not erased.</strong> Most dents can be made much less visible. Some disappear to the eye. Deep dents with broken fibres usually leave a trace.</li>
<li><strong>Every card is different.</strong> Card stock, coating, holofoil and the age of the dent all change the result, which is why we look at photos first.</li>
<li><strong>Time matters.</strong> Good results come from slow, controlled work, not a quick press.</li>
</ul>
<p>You can see real before and after results, photographed in hand, on our <a href="/#portfolio">portfolio page</a>.</p>

<div class="bl-note"><strong>Thinking about grading?</strong> Grading companies make their own decisions, and some treatments may lead a grader to treat a card as altered. Read <a href="/blog/card-restoration-and-grading/">our guide to restoration and grading</a> before you decide, and ask us about your specific card.</div>

<h2>How to get your dented card assessed</h2>
<ol>
<li>Take clear photos of the front and the back, plus a close-up of the dent with a light coming in from the side so the dent shows up.</li>
<li><a href="WA_LINK">Send them to us on WhatsApp</a>. The first photo assessment is free.</li>
<li>We tell you honestly whether treatment is likely to help, and give you a clear price before any work starts. You can see starting prices on our <a href="/#pricing">pricing page</a>.</li>
</ol>
""",
 faq=[
  ("Can a dent in a Pokémon card be completely removed?", "Sometimes it becomes invisible to the eye, but more often it is reduced rather than erased. Deep dents where the paper fibres have broken usually leave a trace. We tell you what is realistic from photos before any work starts."),
  ("Is it safe to fix a card dent at home?", "Home methods such as steam, heat or heavy books can work on some cards, but they often cause water marks, coating damage or warping, especially in humid weather. If the card matters to you, get an opinion first."),
  ("How much does card dent repair cost in Singapore?", "Dent reduction has a set starting price, and structural work is scaled to the card's current ungraded value. You can see the starting prices and an estimate calculator on our pricing page, and we confirm a clear price before any work."),
  ("Will fixing a dent help my card get a better grade?", "No grade is ever guaranteed. Grading companies decide independently, and some treatments may lead a card to be treated as altered. We explain the possible grading implications for your card before you agree to anything."),
 ],
),
dict(
 slug="creased-trading-card-repair",
 title="Creased Trading Card? What Can and Can't Be Fixed",
 seo_title="Creased Trading Card Repair: What Can and Can't Be Fixed | Singapore",
 desc="Light creases, hard creases, whitening and layer separation on Pokémon and other trading cards: what crease repair can improve, what it can't, and how to decide.",
 kicker="Creases",
 image="/assets/cases/case-03-before.webp",
 pair=("/assets/cases/case-03-before.webp", "/assets/cases/case-03-after.webp", "A real customer card with a surface crease, before and after treatment at Cardboard Clinic."),
 body="""
<p class="bl-lede">A crease is the damage collectors dread most. The good news is that many creases can be softened a great deal. The honest news is that some parts of a crease cannot be undone. Knowing which is which helps you decide whether treatment is worth it.</p>

<h2>Dent or crease?</h2>
<p>A dent is a low spot where the paper has been squashed. A crease is a line where the card has been folded, even slightly, so the layers have been bent past the point where they spring back. Hold the card at an angle to a light. A dent looks like a soft dip. A crease looks like a line, often with a ridge on one side and a valley on the other.</p>

<h2>The four kinds of crease</h2>
<h3>1. Light surface creases</h3>
<p>A faint line you mostly see under a light, with the coating and ink intact. These usually respond well to treatment and can often be made very hard to see.</p>
<h3>2. Hard creases</h3>
<p>A clear fold line you can see straight on and feel with a finger. These can usually be flattened and softened a lot, but the line rarely vanishes completely, because the fibres along the fold have been broken.</p>
<h3>3. Creases with whitening or cracked ink</h3>
<p>When a fold is sharp enough, the ink and coating crack and the white paper underneath shows through as a thin line. Flattening the crease can make it much less obvious, but the missing ink does not grow back. We will not repaint or recolour a card to hide it.</p>
<h3>4. Layer separation</h3>
<p>Bad folds and corner damage can split the card's layers apart, so the edge looks thick or the corner feels soft. This needs specialist work and an honest conversation about the likely result before anything is done.</p>
""",
 pair_after=True,
 body2="""
<h2>What crease repair actually does</h2>
<p>Crease reduction uses the same principles as dent work: controlled moisture, careful, even pressure and patience. The aim is to relax the fold and bring the surface back to flat, so light no longer catches the line. It is slow work done in stages, with the card checked throughout.</p>
<ul>
<li><strong>What usually improves:</strong> the ridge and valley of the fold, how visible the line is at an angle, and how the card sits in a sleeve or toploader.</li>
<li><strong>What usually stays:</strong> whitening where ink has cracked off, any colour loss, and a faint trace of a hard fold.</li>
</ul>

<h2>Is it worth fixing?</h2>
<p>That depends on what the card means to you. Some collectors want a favourite card to look and sit right again. Others care mostly about grading, which brings in different questions. Read <a href="/blog/card-restoration-and-grading/">our guide to restoration and grading</a> before you decide.</p>
<p>A simple rule: if the crease bothers you every time you look at the card, and the photos suggest it is the treatable kind, it is usually worth asking.</p>

<h2>Before you do anything</h2>
<ul>
<li>Do not try to bend the card back the other way. That often doubles the damage.</li>
<li>Do not wet or iron the card.</li>
<li>Put it in a soft sleeve and a rigid toploader so the crease does not get worse.</li>
<li>Take photos of the front, the back, and the crease with light from the side, then <a href="WA_LINK">send them to us on WhatsApp</a> for a free first assessment.</li>
</ul>
<p>See real results on our <a href="/#portfolio">portfolio page</a> and starting prices on our <a href="/#pricing">pricing page</a>.</p>
""",
 faq=[
  ("Can a creased Pokémon card be fixed?", "Many creases can be softened a lot, and light surface creases can often be made hard to see. Hard creases usually leave a faint trace, and whitening where the ink has cracked cannot be reversed."),
  ("Can you fix whitening on a crease?", "Flattening the crease can make whitening less obvious, but the missing ink does not come back. We do not repaint or recolour cards to hide it."),
  ("What is the difference between a dent and a crease?", "A dent is a squashed low spot in the paper. A crease is a fold line where the layers have been bent past the point of springing back, often with a ridge and a valley."),
  ("How long does crease repair take?", "It depends on the card and the crease. Treatment is done in stages with time to settle in between. Our queue page on the homepage shows current estimated waiting times."),
 ],
),
dict(
 slug="store-trading-cards-singapore-humidity",
 title="How to Store Trading Cards in Singapore's Humidity",
 seo_title="How to Store Trading Cards in Singapore's Humidity (and Stop Warping)",
 desc="Singapore's humid weather makes Pokémon and other trading cards curl, warp and stick. Here is how to store your collection so it stays flat and clean.",
 kicker="Storage",
 image="/assets/collector-workbench.webp",
 pair=None,
 body="""
<p class="bl-lede">Most of the warped and curled cards we see in Singapore were never dropped or bent. They were simply stored in the wrong place. Our weather is warm and humid all year, and paper soaks up moisture from the air. Here is how to keep your collection flat, clean and safe.</p>

<h2>Why humidity is the enemy</h2>
<p>Paper takes in moisture when the air is damp and gives it back when the air is dry. As it does, it swells and shrinks. A trading card is made of several layers that do not all react at the same speed, so when humidity changes, one side of the card moves more than the other and the card curls.</p>
<ul>
<li><strong>Holo and foil cards curl most.</strong> The foil layer barely moves while the paper behind it swells, so foil cards often bow toward the front.</li>
<li><strong>Fast swings are worse than steady damp.</strong> Moving cards between an air-conditioned room and a humid one, again and again, is a common cause of curl.</li>
<li><strong>Long-term damp</strong> can lead to musty smells, surface spotting and sleeves sticking to the card.</li>
</ul>

<h2>The basics: sleeves, toploaders and binders</h2>
<ul>
<li>Use a soft <strong>penny sleeve</strong> first, then a <strong>toploader</strong> or semi-rigid holder for anything you care about.</li>
<li>Choose acid-free, PVC-free sleeves and binder pages. Old PVC pages can leave residue on cards over time.</li>
<li>Do not overfill binder pockets or force cards into tight toploaders. That is how edge dents start.</li>
<li>Store toploaders and boxes upright, not under heavy stacks.</li>
</ul>

<h2>Control the air around your cards</h2>
<p>In Singapore, the single most useful thing you can do for a valuable collection is to keep it in a dry, steady place.</p>
<ul>
<li><strong>A dry box or dry cabinet</strong>, the kind used for cameras, works very well. Many collectors keep it at a moderate setting, roughly 45 to 55% relative humidity. Do not go very dry, as that can make cards brittle and curl the other way.</li>
<li><strong>A sealed box with silica gel packs</strong> is a cheap alternative. Use a small hygrometer to check the level, and dry out or replace the packs when they are saturated.</li>
<li>Keep cards away from windows, direct sun, the kitchen and bathroom, and the direct airflow of an air-conditioner.</li>
<li>When you take cards out of a dry box, let them settle in their sleeves before handling, rather than moving them back and forth all day.</li>
</ul>

<h2>Graded slabs are not immune</h2>
<p>A slab protects against handling, but the card inside still responds to humidity over time, and condensation can form if a slab moves quickly from a cold room into warm air. Store slabs upright in a dry, steady place too.</p>

<h2>If a card has already curled</h2>
<p>A mild curl from humidity often relaxes on its own after a few days in a toploader in a steady, moderately dry place. Do not try to iron it, bend it back or put it in the fridge. If the curl stays, or the card has started to warp with ripples or soft areas, <a href="WA_LINK">send us photos on WhatsApp</a>. Warping and curling is something we assess and treat case by case, and the first photo assessment is free.</p>
""",
 pair_after=False,
 body2="",
 faq=[
  ("What humidity should trading cards be stored at?", "Many collectors aim for a moderate, steady level, roughly 45 to 55% relative humidity. Very dry storage can make cards brittle, and very damp storage leads to curl and spotting. Steady matters as much as the number."),
  ("Why do my holo Pokémon cards curl?", "The foil layer reacts to humidity differently from the paper behind it. When the paper swells in humid air and the foil does not, the card bows. Steady, moderately dry storage helps a lot."),
  ("Is a dry cabinet worth it for trading cards in Singapore?", "For a valuable collection, yes. A camera-style dry box or cabinet keeps humidity steady, which prevents most curl and warping. A sealed box with silica gel and a hygrometer is a cheaper alternative."),
  ("Can a warped card be flattened?", "Mild curl often relaxes in a toploader in steady conditions. Persistent warping can often be treated, case by case. Send photos for a free first assessment before trying anything at home."),
 ],
),
dict(
 slug="card-restoration-and-grading",
 title="Card Restoration and Grading: What Collectors Should Know",
 seo_title="Card Restoration and Grading (PSA, BGS, CGC): What Collectors Should Know",
 desc="Thinking of repairing a Pokémon or sports card before grading? Here is what restoration can and can't do, how graders may view treated cards, and how to decide.",
 kicker="Grading",
 image="/assets/portfolio-hero.webp",
 pair=None,
 body="""
<p class="bl-lede">One of the first questions collectors ask us is: if you fix my card, will it grade higher? The honest answer is that nobody can promise that. Here is what restoration can and cannot do, how grading companies may see a treated card, and how to make a sensible decision.</p>

<div class="bl-note">Cardboard Clinic is an independent service. We are not affiliated with PSA, BGS, CGC or any card publisher, and grading companies make their own decisions.</div>

<h2>Repair and grading are different goals</h2>
<p>Repair is about the card itself: easing a dent, softening a crease, cleaning a surface, flattening a curl, so the card looks and sits right again. Grading is a third party's opinion of a card's condition and authenticity at a point in time. A card can look much better after treatment and still not receive the grade its owner hoped for.</p>

<h2>How graders may view treated cards</h2>
<p>Each grading company sets its own standards, and those standards can change. In general:</p>
<ul>
<li>Cards that show evidence of <strong>alteration</strong>, such as trimming, recolouring, added substances or certain kinds of surface work, may be marked as altered, given a qualifier, or not graded at all.</li>
<li>Some treatments, such as pressing out a dent, are a debated grey area. Graders may or may not detect them, and may or may not treat them as alteration.</li>
<li>Surface cleaning of loose dust and contamination is generally seen differently from treatments that change the card's structure, but the final call is always the grader's.</li>
</ul>
<p>Before submitting a treated card, read the grading company's current published policies, and be honest about any work done if they ask.</p>

<h2>What we will and won't do</h2>
<ul>
<li>We <strong>do not</strong> trim, recolour, repaint or add fillers to cards.</li>
<li>We <strong>do not</strong> guarantee any grade, and we do not quote prices based on a hoped-for graded value. Our pricing uses the card's current ungraded value.</li>
<li>We <strong>do</strong> explain the possible grading implications for your specific card before any work, and every card needs your signed consent before treatment starts.</li>
<li>We <strong>do</strong> photograph and record the condition before and after, so you have an honest record of what was done.</li>
</ul>

<h2>Slab extraction</h2>
<p>If a graded card needs treatment, it has to come out of its slab first. Removing a card from a slab carries a small risk and permanently ends that grade, so we only do it with the owner's clear consent and an understanding of the risk.</p>

<h2>So, is restoration worth it before grading?</h2>
<p>It can be, when your main goal is a card that looks and feels right, and any grade is a bonus. It is usually not worth it if the whole point is to flip the card for a higher grade, because no outcome is guaranteed and the card may be flagged.</p>
<p>A good way to decide:</p>
<ol>
<li>Ask yourself whether you would be happy with the card after treatment even if it never went into a slab.</li>
<li>Check what the card is worth today, ungraded, not what it might be worth as a 10.</li>
<li><a href="WA_LINK">Send us photos on WhatsApp</a>. We will tell you honestly what treatment can do for that card and what it might mean for grading.</li>
</ol>
<p>More reading: <a href="/blog/can-a-dented-pokemon-card-be-fixed/">can a dented card be fixed?</a> and <a href="/blog/creased-trading-card-repair/">what crease repair can and can't do</a>.</p>
""",
 pair_after=False,
 body2="",
 faq=[
  ("Will restoring my card get it a higher PSA grade?", "No grade can be guaranteed. Grading companies decide independently, and some treatments may lead a card to be marked as altered or not graded. Restoration is best when you want the card itself to look right."),
  ("Can grading companies detect card pressing?", "Sometimes. Pressing is a grey area: it may or may not be detected, and graders may or may not treat it as alteration. Check the grading company's current policy before submitting a treated card."),
  ("Do you trim or recolour cards?", "No. We do not trim, recolour, repaint or add fillers to cards."),
  ("Can you remove a card from a graded slab?", "Yes, with the owner's consent. Removing a card from a slab carries a small risk and ends that grade permanently, so we explain this before doing it."),
 ],
),
]

def esc(s): return html.escape(s, quote=True)

def head(title, desc, url, image, extra_ld):
    return f"""<!DOCTYPE html>
<html lang="en-SG">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)}</title>
<meta name="description" content="{esc(desc)}">
<link rel="canonical" href="{url}">
<meta name="robots" content="index,follow,max-image-preview:large">
<meta property="og:type" content="article"><meta property="og:site_name" content="Cardboard Clinic"><meta property="og:locale" content="en_SG">
<meta property="og:title" content="{esc(title)}"><meta property="og:description" content="{esc(desc)}"><meta property="og:url" content="{url}"><meta property="og:image" content="{SITE}{image}">
<meta name="twitter:card" content="summary_large_image"><meta name="twitter:title" content="{esc(title)}"><meta name="twitter:description" content="{esc(desc)}"><meta name="twitter:image" content="{SITE}{image}">
<meta name="theme-color" content="#175c59">
<link rel="icon" href="/assets/icon.png">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Nunito:wght@700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/blog/blog.css">
{''.join(f'<script type="application/ld+json">{json.dumps(x, ensure_ascii=False)}</script>' for x in extra_ld)}
</head>
<body>
<header class="bl-head"><div class="wrap"><a href="/" aria-label="Cardboard Clinic home"><img src="/assets/logo.png" width="208" height="73" alt="Cardboard Clinic"></a>
<nav class="bl-nav"><a class="bl-hide" href="/#pricing">Pricing</a><a class="bl-hide" href="/#portfolio">Portfolio</a><a class="on" href="/blog/">Blog</a><a class="bl-login" href="/#portal">Log in</a></nav></div></header>
"""

FOOT = f"""<footer class="bl-foot"><div class="wrap"><span>© 2026 Cardboard Clinic · Trading card repair in Singapore</span><span><a href="/">Home</a> · <a href="/#pricing">Pricing</a> · <a href="/#portfolio">Portfolio</a> · <a href="/blog/">Blog</a> · <a href="{WA}">WhatsApp 9822 1113</a></span></div></footer>
</body></html>
"""

def org():
    return {"@type": "Organization", "name": "Cardboard Clinic", "url": SITE + "/", "logo": SITE + "/assets/logo.png"}

def article(p, others):
    url = f"{SITE}/blog/{p['slug']}/"
    ld = [
        {"@context": "https://schema.org", "@type": "BlogPosting", "headline": p["title"], "description": p["desc"],
         "image": SITE + p["image"], "datePublished": PUBLISHED, "dateModified": PUBLISHED,
         "author": org(), "publisher": org(), "mainEntityOfPage": url, "inLanguage": "en-SG"},
        {"@context": "https://schema.org", "@type": "FAQPage", "mainEntity": [
            {"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in p["faq"]]},
        {"@context": "https://schema.org", "@type": "BreadcrumbList", "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "Home", "item": SITE + "/"},
            {"@type": "ListItem", "position": 2, "name": "Blog", "item": SITE + "/blog/"},
            {"@type": "ListItem", "position": 3, "name": p["title"], "item": url}]},
    ]
    pair = ""
    if p["pair"]:
        b, a, cap = p["pair"]
        pair = f'<figure class="bl-fig pair"><img src="{b}" alt="Before treatment" loading="lazy"><img src="{a}" alt="After treatment" loading="lazy"><figcaption>{esc(cap)} Left: before. Right: after. Results vary by card.</figcaption></figure>'
    hero_img = "" if p["pair"] else f'<figure class="bl-fig"><img src="{p["image"]}" alt="" loading="lazy"></figure>'
    body = p["body"] + (pair if p.get("pair_after") else "") + p["body2"]
    body = body.replace("WA_LINK", WA)
    faq = "".join(f"<details><summary>{esc(q)}</summary><p>{esc(a)}</p></details>" for q, a in p["faq"])
    more = "".join(f'<li><a href="/blog/{o["slug"]}/">{esc(o["title"])}</a></li>' for o in others)
    words = len(re.sub(r"<[^>]+>", " ", body).split())
    return head(p["seo_title"], p["desc"], url, p["image"], ld) + f"""<main class="bl-art">
<p class="bl-crumb"><a href="/">Home</a> › <a href="/blog/">Blog</a> › {esc(p['kicker'])}</p>
<span class="bl-eyebrow">{esc(p['kicker'])}</span>
<h1>{esc(p['title'])}</h1>
<p class="bl-meta">By Cardboard Clinic · {max(3, round(words/220))} min read</p>
{hero_img}{body}
<section class="bl-faq"><h2>Common questions</h2>{faq}</section>
<section class="bl-cta"><h2>Got a card that needs some help?</h2><p>Send clear photos of the front, back and the problem area. The first photo assessment is free, and you get a clear price before any work starts.</p><a class="bl-btn" href="{WA}">WhatsApp us · 9822 1113</a><a class="bl-btn alt" href="/#pricing">See prices</a></section>
<section class="bl-more"><h2>More from the blog</h2><ul>{more}</ul></section>
</main>
""" + FOOT

def index():
    url = f"{SITE}/blog/"
    ld = [{"@context": "https://schema.org", "@type": "Blog", "name": "Cardboard Clinic Blog", "url": url, "publisher": org(),
           "blogPost": [{"@type": "BlogPosting", "headline": p["title"], "url": f"{SITE}/blog/{p['slug']}/", "datePublished": PUBLISHED} for p in POSTS]}]
    cards = "".join(f'<a class="bl-card" href="/blog/{p["slug"]}/"><img src="{p["image"]}" alt="" loading="lazy"><div><small>{esc(p["kicker"])}</small><h2>{esc(p["title"])}</h2><p>{esc(p["desc"])}</p></div></a>' for p in POSTS)
    return head("Trading Card Care Blog | Cardboard Clinic Singapore",
                "Guides on fixing dented and creased trading cards, storing cards in Singapore's humidity, and what restoration means for grading.",
                url, "/assets/og-image.jpg", ld) + f"""<main class="wrap">
<section class="bl-hero"><span class="bl-eyebrow">Card care blog</span><h1>Guides for collectors who care about their cards.</h1><p>Honest advice on dents, creases, storage and grading from a trading card repair clinic in Singapore.</p></section>
<section class="bl-grid">{cards}</section>
</main>
""" + FOOT

root = os.getcwd()
os.makedirs("blog", exist_ok=True)
open("blog/index.html", "w").write(index())
for p in POSTS:
    os.makedirs(f"blog/{p['slug']}", exist_ok=True)
    open(f"blog/{p['slug']}/index.html", "w").write(article(p, [o for o in POSTS if o is not p]))

urls = [("", "weekly", "1.0"), ("blog/", "weekly", "0.8")] + [(f"blog/{p['slug']}/", "monthly", "0.7") for p in POSTS]
open("sitemap.xml", "w").write('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' +
    "".join(f"  <url><loc>{SITE}/{u}</loc><lastmod>{PUBLISHED}</lastmod><changefreq>{c}</changefreq><priority>{pr}</priority></url>\n" for u, c, pr in urls) + "</urlset>\n")
print("built", len(POSTS), "posts")
