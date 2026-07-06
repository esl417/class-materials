# AEO Content Guide — how to write the AI/bot version of your pages

> **What this is.** The reference that governs *how* the bot-surface pages should be
> written so AI answer engines (ChatGPT, Perplexity, Google AI Mode) can read, trust, and
> **cite** them. In Class 3 you build a dual-surface site — a normal site for humans and a
> separate, AI-optimized version of each page. This document is the standard for that second
> version.
>
> **For Claude:** when you generate or revise the `llm/` bot pages, follow the rules here.
> The load-bearing ones: write **answer-first**; break content into **50–150 word,
> semantically-complete chunks**; phrase key claims as **semantic triples**
> (subject–predicate–object); be **entity-rich** and **citation-worthy**; keep every page's
> canonical pointing at its human URL. The later sections (query fan-out, passage-level
> retrieval, relevance engineering, EEAT-as-vectors) are the *why* behind those rules —
> read them so the pages you write are engineered for machine-mediated relevance, not just
> keyword-stuffed.
>
> **For the student:** you don't need to read this — Claude does. It's here so the AI version
> of your site is written to a real standard, not guessed at.
>
> *Source note: the advanced sections synthesize public analysis by Mike King and Francine
> Monahan (iPullRank) on how AI search works; see the sources at the end.*

---

## Content Strategy

### Answer-Focused Content
- **Core Principle:** AI search needs direct answers to questions, not just indexed content
- Content must explicitly answer the questions users ask LLMs
- Long-form content is good for traditional SEO, but AI search requires:
  - Crisp summary at the top
  - Content broken into clear chunks/sections below

### Help Center & FAQ Optimization
- Identify questions people are actually asking (check search queries, Reddit, forums)
- Ensure content directly answers these questions
- Structure answers for easy AI parsing

### Blog Content Requirements
- **Unique Data & POV:** AI search prioritizes unique perspectives and original data
- Review all blog posts to ensure they're unique and demonstrate expertise
- Add expertise credentials at the top of each article (consider author bio or credentials section)

### Keyword Research Process
1. Find target keywords using tools (Clearscope, Surfer SEO)
2. Use ChatGPT to convert keywords into natural questions
3. Input questions into Surfer/Clearscope to analyze gaps
4. Group missing keywords into themed clusters
5. Create content that fulfills each theme
6. Research Reddit comparisons for user language and pain points

## Technical Implementation

### Schema & Structured Data
- Ensure schema markup is comprehensive (already implemented)
- Verify bots can render pages and see structured data
- Focus on answering questions you want to be found for

### Dual Web Strategy (Priority)
- **Setup:** Serve different versions via CDN layer (Cloudflare)
- Main site for humans (styled, interactive)
- Bot-facing site for AI/crawlers (this repository)
- **Note:** May require site refactor to move off current landing page structure
- **Important:** Cloudflare automatically blocks some AI bots by default - verify settings

### Analytics & Monitoring
- Check weblogs to see if AI bots are crawling the site
- Monitor Google Analytics for referral traffic from AI sources
- Track which AI systems are accessing content

## Tools & Resources

### SEO Tools
- **Clearscope/Surfer SEO:** Fill in missing questions and keywords
- **Universal link verifier:** Find tool to verify all links work (for research reports)

### Content Distribution
- Explore Claude Code browser for automated LinkedIn posting
- Research "I Pull Rank" agency blog (technical content by Mike King)

## Immediate Action Items

### High Priority
1. ✅ Dual web setup via Cloudflare (check bot blocking settings)
2. ⬜ Publish comparison blog post
3. ⬜ Add expertise/credentials to blog articles
4. ⬜ Review weblogs for AI bot traffic
5. ⬜ Set up Google Analytics tracking for AI referral traffic

### Content Tasks
6. ⬜ Audit blog posts for uniqueness and expert perspective
7. ⬜ Add crisp summaries to top of long-form content
8. ⬜ Break long content into clear, AI-parseable chunks
9. ⬜ Keyword research → questions → gap analysis workflow
10. ⬜ Reddit research for comparison content and user language

### Technical Tasks
11. ⬜ Verify Cloudflare AI bot settings
12. ⬜ Find and implement universal link verifier tool
13. ⬜ Explore LinkedIn automation with Claude Code

---

---

## Advanced Technical Insights from Mike King (iPullRank)

### How AI Mode Actually Works

#### Query Fan-Out System
- AI Mode generates **dozens to hundreds of synthetic queries** from your original query
- Types of synthetic queries generated:
  - **Related queries:** Semantically adjacent topics via Knowledge Graph
  - **Implicit queries:** What user likely meant but didn't say
  - **Comparative queries:** Product/entity comparisons for decision-making
  - **Recent queries:** Prior user searches for context
  - **Personalized queries:** Based on user's location, interests, behavioral history
  - **Reformulation queries:** Lexical rewrites maintaining core intent
  - **Entity-expanded queries:** Broader/narrower entity relationships

**Implication:** Ranking #1 for your target keyword only gives you ~25% chance of appearing in AI Overview. You must rank for the **hidden subqueries** Google generates.

#### Passage-Level Retrieval (Not Page-Level)
- Google retrieves and ranks at the **passage level**, not full pages
- Each passage is converted to vector embeddings
- Passages are compared via **pairwise LLM ranking** (not traditional TF-IDF/BM25)
- Two passages compared head-to-head: "Which is more relevant?"
- Winner chosen by model reasoning, not keyword density

**Implication:** Engineer passages that can outperform competitors in direct LLM evaluations.

#### User Embedding & Personalization
- Every user has a persistent **user embedding** (vectorized behavioral profile)
- Built from: prior queries, clicks, content interests, device interactions, Gmail data
- Same query from two users = different results based on their profiles
- Personalization affects: query interpretation, synthetic query generation, passage retrieval, response synthesis

**Implication:** Logged-out rank tracking is meaningless for AI Mode. Responses are 1:1 personalized.

#### Multi-Stage LLM Processing
- AI Mode uses **multiple specialized LLMs** (not one monolithic model)
- Different models for: summarization, comparison, translation, structured data extraction, reasoning
- Models selected based on query classification and perceived user need
- Final synthesis combines outputs from multiple models

### Content Engineering for AI Mode

#### Four Strategic Pillars

**1. Fit the Reasoning Target**
- Passages must be **semantically complete in isolation**
- Explicitly articulate comparisons and tradeoffs
- Readable without redundancy
- Example: "The Tesla Model Y offers 330 miles of range, advanced driver assistance, and a spacious interior. Compared to the Ford Mustang Mach-E, it provides more range but less trunk space."

**2. Be Fan-Out Compatible**
- Include clearly named entities that map to Knowledge Graph
- Reflect common user intents (evaluation, comparison, constraint-based exploration)
- Use intent-aligned phrasing: "If you're shopping for a reliable EV under $50K..."

**3. Be Citation-Worthy**
- Present factual, attributable, verifiable information
- Use quantitative data, named sources
- Structure as semantic triples (subject-predicate-object)
- Example: "The 2024 Ioniq 5 has an EPA-estimated range of 303 miles. Source: U.S. Department of Energy, March 2024."

**4. Be Composition-Friendly**
- Structure in scannable, modular formats (lists, bullets, headings)
- Use answer-first phrasing
- Include FAQs, TL;DRs, semantic markup
- Make content easily extractable and remixable

#### Structural Requirements for Passages

| Characteristic | Why It Matters | What It Looks Like |
|---------------|----------------|-------------------|
| **Semantically Complete in Isolation** | LLMs retrieve at passage level, not whole page | Self-contained answers with full context |
| **Explicit Comparisons/Tradeoffs** | AI Mode makes decisions for users | "X is ideal for Y due to Z, while A excels in B" |
| **Entity-Rich & KG-Aligned** | Enables query fan-out matching | Specific brand, product, category names |
| **Structured in Scannable Chunks** | LLMs recombine pieces, not full documents | Pros/cons lists, bullet points, clear headings |
| **Readable & No Redundancy** | Redundancy weakens LLM performance | Concise, non-repetitive language |
| **Answer-Oriented** | LLMs asked direct questions | "Yes, the federal tax credit applies if..." |

### Multimodal Content Strategy

- AI Mode is **natively multimodal**: video, audio, transcripts, imagery, cross-language
- Your competitive set now includes content in different formats and languages
- Google can transcribe videos, extract podcast claims, interpret diagrams
- Format matters as much as content itself
- System classifies ideal output modality early in process
- May prioritize relevant video clip over more accurate article

**Implication:** Build content ecosystems across all formats, not just text pages.

### What Traditional SEO Tools Are Missing

Current SEO software operates on:
- Sparse retrieval (TF-IDF, BM25) instead of dense retrieval (vector embeddings)
- Page-level analysis instead of passage-level
- Single keyword targeting instead of query clusters
- Lexical scoring instead of semantic similarity
- Logged-out rank tracking instead of persona-based

**What you actually need:**
1. **Vector embeddings** for queries, passages, documents
2. **Passage-level semantic similarity scoring** vs. competitors
3. **Query fan-out simulation** to identify synthetic queries
4. **Pairwise passage comparison** to test LLM preferences
5. **Persona-based rank tracking** with behavioral context
6. **Reasoning chain simulation** to see where content falls out

### Matrixed Ranking Strategy

**Process:**
1. Generate synthetic queries using query fan-out simulation
2. Pull rankings and landing pages for all subqueries
3. Generate vector embeddings for queries and all passages in your documents
4. Find most relevant passages via cosine similarity
5. Compare your passage embeddings to citation embeddings
6. Engineer relevance for passages with lower scores

**Focus areas for passage improvement:**
- Semantic chunking and completeness
- Statistical/quantitative data
- Readability and conciseness
- Semantic triples (structured claims)

### Strategic Shift Required

**From:** Optimizing for traffic and rankings
**To:** Engineering for machine-mediated relevance

**New KPIs:**
- Share of voice within AI surfaces
- Sentiment and citation prominence in generative responses
- Attribution influence modeling (not last-click)

**New Capabilities Needed:**
- **Semantic Architecture:** Machine-readable, recombinable knowledge assets
- **Content Portfolio Governance:** Diversified, performance-monitored, pruned for relevance decay
- **Model-Aware Editorial:** Content designed for LLM interpretation, citation, embedding distance

### Tools & Resources

- **Qforia:** Query fan-out simulation tool (uses Gemini 2.5 Pro)
- **Profound:** Conversational search analytics for AI surfaces (tracks citations, sentiment, visibility)
- **Screaming Frog:** Can generate vector embeddings during crawls (requires custom JS for passage-level)
- **MarketBrew:** Closest to personalized retrieval simulation
- **Datos/Similarweb:** Clickstream data for query journeys

### Critical Warnings

- **Zero-click future:** AI Mode behaves like ChatGPT/Perplexity - users get answers without clicking
- **Search becomes branding channel:** ~70/30 performance/brand inverting to 30/70
- **Not everyone survives:** Like Panda/Penguin era, some SEOs won't cross this chasm
- **Cloudflare blocks AI bots:** Check settings - default configuration may block crawlers you want
- **No GSC data:** AI Mode traffic shows as Direct due to noreferrer tag

---

## Relevance Engineering Framework (iPullRank)

### What is Relevance Engineering?

**Definition:** The art and science of improving visibility for any search surface by treating it as an **engineering problem, not an optimization exercise**.

**Core Principle:** You have to **build** something rather than tweak something. Whether it's software, content, or relationships across the internet, it's all a form of engineering.

**Integration Points:** Information retrieval + user experience + AI + content strategy + digital PR

### Why Traditional SEO is Broken

**The Problem:**
- SEO keeps trying to force-fit everything into outdated frameworks
- Traditional SEO: "Optimize keywords in title/H1, build more links"
- Modern Search: Semantic query fan-out, passage-level retrieval, vector embeddings
- **82% of Google AI Overview citations come from deep pages**, not homepage/top-level pages

**The Gap:**
- Traditional SEO software uses **lexical search** (TF-IDF, BM25) - counting words
- Modern AI search uses **semantic search** (vector embeddings) - capturing meaning
- Google shifted to semantic with Hummingbird (2013), but SEO tools haven't caught up

**What's Missing in Traditional SEO:**
- Page-level thinking instead of passage-level
- Keyword density instead of semantic similarity
- Guesswork instead of quantitative relevance scores
- Optimization instead of engineering

### Relevance is Quantitative, Not Subjective

**Mathematical Approach:**
- Documents and queries are plotted in **multidimensional vector space**
- The closer a document vector is to a query vector, the more relevant it is
- Relevance can be **scored mathematically** using cosine similarity
- This eliminates "best guess SEO" in favor of data-driven decisions

**Practical Application:**
- **Don't publish content** that scores poorly in cosine similarity to target topic
- **Don't pursue backlinks** from sites lacking topical alignment
- Measure relevance before deployment, not after failure

### Fraggles: The Unit of AI Overview Content

**What are Fraggles?**
- **Fragmented passages** that populate AI Overviews
- Short, semantically complete text chunks extracted from your pages
- The answer units that LLMs cite and recombine

**How to Engineer for Fraggles:**
- Arrange content in **easy-to-find simple phrases** that answer specific questions
- Break content into **50-150 word paragraphs** (distinct semantic concepts)
- Each fraggle should be **self-contained** and extractable
- Use clear headings to separate fraggle-ready sections

### Content Structure for Vector Embeddings

**1. Clearly Structure Content into Semantic Units**
- Break down into concise paragraphs covering clearly defined topics
- **50-150 words per paragraph** captures distinct concepts cleanly
- Long paragraphs blend multiple ideas → less specific embeddings
- Use headings and subheadings to separate sections

**2. Use Explicit Semantic Triples (Subject-Predicate-Object)**
- Embedding models capture relationships best when explicitly outlined
- Structure claims as: **[Subject] [Predicate] [Object]**
- Example: "The 2024 Ioniq 5 [subject] has [predicate] 303 miles of range [object]"
- Semantic triples **significantly boost retrieval accuracy** and citation likelihood

**3. Incorporate Rich Contextual Keywords and Entities**
- Explicitly mention related keywords, synonyms, entities
- Increases chance of being retrieved and accurately cited
- Maps to Knowledge Graph for query fan-out compatibility

**4. Provide Unique, Highly Specific, or Exclusive Insights**
- Unique content/proprietary data increases authoritative citations
- Generic rehashed content won't get cited in RAG pipelines
- Original research, data, perspectives win

**5. Avoid Ambiguity**
- Clearly defined, straightforward sentences reduce embedding noise
- Reduce retrieval errors by being explicit
- No vague pronouns or implied references

### EEAT in the Vector Embedding Era

**What EEAT Actually Is:**
- Google creates **vector representations of authors**
- Looks at all content you write → creates average vector representing your work
- If you write 100 pages and 60 are about SEO → **mathematically labeled as SEO expert**

**How It Works:**
- **Author-level vectors:** Average of all content an author creates
- **Site-level vectors:** Average of all page vectors on a site
- **Entity-level vectors:** Representation of brands/organizations
- Google compares these vectors to determine expertise alignment

**What It's NOT:**
- Not about author bios (helpful for disambiguation, but not the core signal)
- Not about keyword stuffing credentials
- Not about one-off "expert" articles

**Implication:**
- Consistent topical focus across body of work = mathematical expertise
- Dilution kills relevance (sneaker site publishing about bananas tanks site focus score)
- AI-generated content without strategic alignment triggers negative signals

### Structured Data in the AI Era

**Why It Matters More Now:**
- AI and ML rely heavily on structured data to understand, categorize, connect information
- Makes content more accessible to AI-driven experiences
- Future-proofs content as Google integrates LLMs

**Three Emerging Models:**
1. **Knowledge Graph-enhanced LLMs:** Use KG data during pre-training/inference for factually grounded responses
2. **LLM-augmented Knowledge Graphs:** LLMs enhance KG data, filling missing connections
3. **Synergized LLMs + KGs:** Combined approach where both work together dynamically

**Action:**
- Already implemented schema markup (✅)
- Continue expanding structured data coverage
- Focus on FAQPage, Article, HowTo schemas

### The Zero-Click Future & New KPIs

**Reality Check:**
- AI Mode behaves like ChatGPT/Perplexity - users get answers **without clicking**
- Search shifting from performance channel → **branding channel**
- ~70/30 performance/brand ratio **inverting to 30/70**
- AI Mode traffic shows as **Direct** (noreferrer tag) - no GSC data

**New Success Metrics:**
- **Share of voice** within AI surfaces (not traffic)
- **Citation prominence** and sentiment in AI responses
- **Attribution influence modeling** (not last-click)
- **Fraggle extraction rate** from your content

**Strategic Shift Required:**
- From: Traffic and rankings
- To: Machine-mediated relevance and citation authority

### Relevance Engineering Workflow

**Engineering Discipline Applied to Content:**
1. Information structured to make intuitive sense to users
2. Content decisions based on **measurable objectives** (relevance scores)
3. Results analyzed **systematically**, not anecdotally
4. Success patterns can be **replicated and scaled**

**Quality Built Into Core Methodology:**
- Content treated as part of scientific system, not marketing tactic
- Incorporates workflows where everything serves clear purpose
- Engineering discipline replaces improvisation

**New Capabilities Needed:**
- **Semantic Architecture:** Machine-readable, recombinable knowledge assets
- **Content Portfolio Governance:** Performance-monitored, pruned for relevance decay
- **Model-Aware Editorial:** Content designed for LLM interpretation

### Practical Implementation Checklist

**Immediate Actions:**
- [ ] Structure all content in **50-150 word semantic chunks**
- [ ] Rewrite key passages as **semantic triples** (subject-predicate-object)
- [ ] Add **explicit entity names** to all passages (no vague pronouns)
- [ ] Create **fraggle-ready FAQ sections** on all pages
- [ ] Test passages with cosine similarity scoring (use LLM APIs)
- [ ] Focus author content on **consistent topical areas** for EEAT
- [ ] Ensure unique insights/data in every piece of content
- [ ] Expand structured data (schema markup) coverage
- [ ] Track citations in AI tools manually (or use Profound)

**Long-term Strategy:**
- Shift KPIs from traffic → citation authority
- Build content portfolio with diversified formats (text, video, audio)
- Establish relevance scoring system before content deployment
- Create author topical focus areas for mathematical expertise
- Engineer content for zero-click success (branding over performance)

---

## Notes
- This bot-facing site (current repository) is already optimized for AI crawlers
- Next step: ensure human-facing site and bot-facing site work together via dual web strategy
- Remember: AI needs answers, not just keywords
- **Sources:**
  - Mike King, iPullRank - "How AI Mode Works" (technical analysis based on Google patents)
  - Francine Monahan, iPullRank - "Relevance Engineering: The Future of Search"
