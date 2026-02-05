#!/usr/bin/env python3
"""
Reddit scraper for Verbum Dei marketing.
Finds posts in Traditional Latin Mass / Catholic prayer communities
where the app could be organically promoted.

Uses Reddit's public JSON API (no auth needed, rate-limited).
"""

import json
import time
import urllib.request
import urllib.error
from datetime import datetime, timezone
from pathlib import Path

# Target subreddits for Traditional Latin Mass / Catholic Latin prayer audience
SUBREDDITS = [
    # Core TLM / Traditional Catholic
    "TraditionalCatholics",     # ~30k - Traditional Catholic community
    "LatinMass",                # Dedicated TLM subreddit
    "Catholicism",              # ~300k - Largest Catholic sub, many TLM fans
    "Catholic",                 # General Catholic
    
    # Latin language
    "latin",                    # Latin language learners/enthusiasts
    "liturgics",                # Liturgy discussion
    
    # Catholic devotion & prayer
    "CatholicPrayers",          # Prayer requests and devotions
    "CatholicMemes",            # Memes - good for casual brand awareness
    "CatholicDating",           # Niche but engaged community
    
    # Religious apps / Bible study
    "CatholicBible",            # Bible study
    "divineoffice",             # Liturgy of the Hours
    "Rosary",                   # Rosary devotion
    
    # Broader Christian with Catholic overlap
    "Christianity",             # Large, some Catholic users
    "OrthodoxChristianity",     # Appreciate liturgical tradition
    
    # App promotion friendly
    "iOSProgramming",           # Dev community, app showcase
    "AppHookup",                # App deals/promos
    "SideProject",              # Indie dev projects
]

# Keywords that signal high-opportunity posts
KEYWORDS = [
    "latin mass", "traditional latin", "tridentine", "extraordinary form",
    "latin prayers", "latin bible", "vulgate", "vulgata", "douay rheims",
    "rosary in latin", "pater noster", "ave maria", "salve regina",
    "liturgy of the hours", "divine office", "breviary",
    "catholic app", "bible app", "prayer app",
    "learn latin", "church latin", "ecclesiastical latin",
    "missal", "traditional catholic", "FSSP", "ICKSP", "SSPX",
    "novus ordo", "ad orientem", "summorum pontificum",
]

HEADERS = {
    "User-Agent": "VerbumDei-MarketResearch/1.0 (by /u/verbum-dei-app)"
}


def fetch_subreddit(sub: str, sort: str = "new", limit: int = 25) -> list[dict]:
    """Fetch posts from a subreddit using public JSON API."""
    url = f"https://www.reddit.com/r/{sub}/{sort}.json?limit={limit}"
    req = urllib.request.Request(url, headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode())
        posts = []
        for child in data.get("data", {}).get("children", []):
            d = child["data"]
            posts.append({
                "subreddit": sub,
                "title": d.get("title", ""),
                "selftext": d.get("selftext", "")[:500],
                "score": d.get("score", 0),
                "num_comments": d.get("num_comments", 0),
                "permalink": f"https://reddit.com{d.get('permalink', '')}",
                "created_utc": d.get("created_utc", 0),
                "author": d.get("author", ""),
                "flair": d.get("link_flair_text", ""),
                "url": d.get("url", ""),
            })
        return posts
    except (urllib.error.URLError, urllib.error.HTTPError, json.JSONDecodeError) as e:
        print(f"  ⚠ Failed r/{sub}: {e}")
        return []


def score_post(post: dict) -> int:
    """Score a post for marketing opportunity (0-100)."""
    text = (post["title"] + " " + post["selftext"]).lower()
    score = 0
    
    # Keyword matches
    matches = sum(1 for kw in KEYWORDS if kw in text)
    score += min(matches * 12, 50)
    
    # Engagement signals
    if post["num_comments"] >= 10:
        score += 15
    elif post["num_comments"] >= 3:
        score += 8
    
    # Recency (within 48h)
    age_hours = (time.time() - post["created_utc"]) / 3600
    if age_hours < 6:
        score += 20
    elif age_hours < 24:
        score += 12
    elif age_hours < 48:
        score += 5
    
    # Question posts (good for helpful replies)
    if any(q in text for q in ["?", "looking for", "recommend", "anyone know", "best app", "suggestion"]):
        score += 10
    
    return min(score, 100)


def run_scrape():
    """Run the full scrape and generate reports."""
    print("🔍 Scraping Reddit for Verbum Dei marketing opportunities...\n")
    
    all_posts = []
    for sub in SUBREDDITS:
        print(f"  Scanning r/{sub}...")
        posts = fetch_subreddit(sub, sort="new", limit=25)
        # Also check hot posts
        hot = fetch_subreddit(sub, sort="hot", limit=10)
        
        seen = {p["permalink"] for p in posts}
        for h in hot:
            if h["permalink"] not in seen:
                posts.append(h)
        
        for p in posts:
            p["opportunity_score"] = score_post(p)
        
        all_posts.extend(posts)
        time.sleep(2)  # Rate limit: ~1 req/2s for public API
    
    # Sort by opportunity score
    all_posts.sort(key=lambda x: x["opportunity_score"], reverse=True)
    
    # Filter to relevant posts (score > 0)
    relevant = [p for p in all_posts if p["opportunity_score"] > 0]
    high = [p for p in relevant if p["opportunity_score"] >= 40]
    medium = [p for p in relevant if 20 <= p["opportunity_score"] < 40]
    
    # Generate reports
    ts = datetime.now().strftime("%Y-%m-%d")
    report_dir = Path(__file__).parent / "reddit-scrapes"
    report_dir.mkdir(exist_ok=True)
    
    # JSON report
    json_path = report_dir / f"scrape-{ts}.json"
    with open(json_path, "w") as f:
        json.dump({
            "date": ts,
            "total_scanned": len(all_posts),
            "high_opportunity": len(high),
            "medium_opportunity": len(medium),
            "subreddits": SUBREDDITS,
            "posts": relevant[:50],
        }, f, indent=2)
    
    # Markdown report
    md_path = report_dir / f"scrape-{ts}.md"
    lines = [
        f"# Reddit Scrape Report - {ts}\n",
        f"**App:** [Verbum Dei](https://apps.apple.com/us/app/verbum-dei-latin-bible-prayer/id6745453748)\n",
        f"Total posts scanned: {len(all_posts)}",
        f"High opportunity (≥40): {len(high)}",
        f"Medium opportunity (20-39): {len(medium)}\n",
        "## Subreddits Monitored\n",
    ]
    for sub in SUBREDDITS:
        lines.append(f"- r/{sub}")
    
    lines.append("\n## 🔥 High Opportunity\n")
    for p in high[:15]:
        age = (time.time() - p["created_utc"]) / 3600
        lines.append(f"### [{p['title'][:80]}]({p['permalink']})")
        lines.append(f"- r/{p['subreddit']} | ⬆ {p['score']} | 💬 {p['num_comments']} | Score: {p['opportunity_score']} | {age:.0f}h ago")
        if p["selftext"]:
            lines.append(f"- Preview: {p['selftext'][:150]}...")
        lines.append("")
    
    lines.append("\n## 📋 Medium Opportunity\n")
    for p in medium[:15]:
        age = (time.time() - p["created_utc"]) / 3600
        lines.append(f"- [{p['title'][:80]}]({p['permalink']}) — r/{p['subreddit']} | Score: {p['opportunity_score']} | {age:.0f}h ago")
    
    lines.append("\n## 💡 Suggested Engagement Strategy\n")
    lines.append("""1. **r/TraditionalCatholics, r/LatinMass** — Core audience. Share prayer cards, answer questions about Latin prayers
2. **r/Catholicism** — Huge reach. Comment helpfully on prayer/liturgy threads, mention app naturally
3. **r/latin** — Language learners interested in ecclesiastical Latin
4. **r/CatholicPrayers, r/Rosary** — Share Latin prayer content, be genuinely helpful
5. **r/SideProject, r/iOSProgramming** — Share the dev story, get feedback
6. **r/AppHookup** — Announce the app (if free/on sale)

**Rules:** Never spam. Add value first. Mention the app only when genuinely relevant.""")
    
    with open(md_path, "w") as f:
        f.write("\n".join(lines))
    
    print(f"\n✅ Done! Scanned {len(all_posts)} posts across {len(SUBREDDITS)} subreddits")
    print(f"   🔥 High opportunity: {len(high)}")
    print(f"   📋 Medium opportunity: {len(medium)}")
    print(f"   📄 Reports: {json_path.name}, {md_path.name}")
    
    return all_posts, high, medium


if __name__ == "__main__":
    run_scrape()
