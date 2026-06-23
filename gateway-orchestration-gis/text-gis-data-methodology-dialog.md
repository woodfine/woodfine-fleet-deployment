# Data & Methodology Dialog copy (revision)

This document is the revised, ready-to-paste copy for the on-map **Data & Methodology**
dialog on `gis.woodfinegroup.com` (MapLibre GL JS + PMTiles map; OpenFreeMap *positron*
basemap; T1/T2/T3 co-location tier dots with proximity rings; NA and EU frames).

It replaces the May 2026 `text-gis-data-methodology-dialog` draft. The revision addresses
three findings from the 2026-06-20 map UX/tech audit:

- **F14** — no data provenance or vintage was visible on the map face, and the audit could
  not confirm the DATA modal was wired rather than a placeholder. This draft supplies (a) a
  one-line provenance string for the persistent map face, and (b) the full modal copy with
  every source named and dated.
- **F13** — point estimates were rendered as if they were measurements, with a confidence
  flag computed but never shown. This draft adds explicit per-estimate confidence and error
  framing.
- **F25** — the spend surface chains three layers of estimation with no stated error, and
  the H3 res-7 aggregation introduces a modifiable-areal-unit (MAUP) effect that was
  unacknowledged. This draft states the estimation chain and the MAUP caveat in plain
  language.

The copy is organised as it should render in the modal: a tabbed dialog with **Sources**,
**Method**, and **Caveats & Confidence** tabs, preceded by the map-face provenance line that
opens the modal on click.

---

## 0. Map-face provenance line (F14)

This is the persistent attribution string that must appear on the map itself — not only in
the modal — bottom-left, in small print, alongside the basemap copyright. The audit flagged
that the only on-map attribution today is the OSM licence notice, which is a legal obligation,
not a provenance statement. The line is clickable and opens the **Data & Methodology** dialog.

**Render exactly (substitute the live build month):**

> Data: WorldPop 2026, OSM, Kontur CC-BY — updated 2026-06 · Method ⓘ

**Notes for engineering:**

- `2026-06` is the **build month of the data layers**, not the page-load date. It must be
  emitted by the tile/data pipeline into a `build_meta` field and read at render time. Do not
  hard-code it; a stale date is worse than no date for a credibility audience.
- Keep the basemap line separate and complete: `© OpenFreeMap · © OpenStreetMap contributors`.
  The provenance line above is additive to, not a replacement for, the licence attribution.
- The `Method ⓘ` affordance is the click target that opens the modal. On mobile it remains
  tappable at ≥44×44 px per the F7 bottom-sheet work.

---

## 1. Modal — Sources tab

> ### Where this map's data comes from
>
> This map combines open geospatial and demographic data into a single view of where
> anchor retailers cluster. Every layer below is open-licensed; attribution and licence
> terms are listed in full in the data manifest linked at the foot of this dialog.
>
> **Retail and civic locations — OpenStreetMap**
> Store locations for the tracked anchor chains, and civic points of interest (hospitals,
> universities, airports), are sourced from OpenStreetMap via the Overpass API and matched to
> Wikidata brand identifiers. Civic points are supplemented by Overture Maps Foundation Places.
> *Licence: ODbL 1.0 (OSM) / CDLA-Permissive-2.0 (Overture Places). © OpenStreetMap
> contributors; © Overture Maps Foundation.*
> *Vintage: refreshed each pipeline run; current build 2026-06.*
>
> **Population — WorldPop 2026 (100 m grid)**
> Residential population is taken from the WorldPop 2026 global 100-metre population grid and
> aggregated to H3 resolution-7 hexagonal cells (≈5 km² each). Only cells within a cluster's
> modelled catchment are displayed.
> *Licence: CC BY 4.0. Attribution: WorldPop (www.worldpop.org).*
> *Vintage: WorldPop 2026 release.*
>
> **Population density reference — Kontur Population**
> Where shown, the supporting population-density reference layer is derived from the Kontur
> Population dataset (a global H3 population layer built on Meta/WorldPop/GHSL inputs).
> *Licence: CC BY 4.0. Attribution: © Kontur.*
> *Vintage: Kontur Population (2023 release), held on disk for 13 countries.*
>
> **Mobility — observed and synthetic origin-destination data**
> Where commuter/mobility flows inform a trade area, they draw on published origin-destination
> sources: US LEHD LODES (work O-D), Spain's MITMA mobility study, and the WorldMove synthetic
> mobility dataset. No individual-level location data is used; all mobility inputs are
> aggregated or synthetic.
> *Licences: public-domain / open government (LODES, MITMA); CC BY 4.0 (WorldMove). Attribution:
> US Census LEHD; MITMA; Yuan et al. (2025), "WorldMove".*
> *Vintage: LODES 2021–2022; MITMA 2022; WorldMove 2025. Mobility-derived trade areas are being
> rolled out per region — see Caveats.*
>
> **Household spending proxies — national statistical agencies**
> Per-capita retail-spend multipliers are taken from national household-expenditure surveys:
> Statistics Canada (Household Spending), Eurostat Household Budget Survey, INEGI (Mexico), and
> the equivalent US Bureau of Labor Statistics Consumer Expenditure series.
> *Licences: each agency's open data licence (StatCan Open Licence; CC BY 4.0 for Eurostat; INEGI
> terms of free use). Attribution per agency; this is not an endorsement by any agency.*
> *Vintage: most recent published survey year per country.*
>
> **Countries covered:** United States, Canada, Mexico, Great Britain, France, Germany,
> Netherlands, Austria, Poland, Portugal, Greece, Italy, Spain, plus the Nordics (Denmark,
> Norway, Finland, Iceland, Sweden) where anchor coverage exists.

---

## 2. Modal — Method tab

> ### How the numbers are built
>
> **Co-location clusters.** Anchor stores (warehouse clubs, hypermarkets, large-format
> lifestyle and hardware retailers) are clustered by spatial proximity. A cluster is a group of
> qualifying anchors close enough to function as one retail destination. Smaller stores can join
> a cluster but cannot start one. Neighbourhood grocery formats (for example discount-grocery
> chains) are deliberately excluded so the map shows destination retail districts, not every
> corner store.
>
> **Tiers (T1 / T2 / T3).** Tiers describe the **composition and depth** of a cluster — how
> many and which kinds of anchors co-locate — ranked from T1 (strongest co-location) to T3.
> A higher tier means a deeper anchor mix, *not* a guaranteed better-performing site. Tier is a
> descriptive label, not an investment recommendation.
>
> **Trade areas (catchments).** Each cluster is shown with one or more catchment zones. The
> default catchment is a **modelled distance band** measured from the cluster centre; where
> mobility data exists for the country, the catchment is refined toward an **observed
> origin-destination trade area** rather than a plain circle. The distance bands and the
> mobility-derived areas are labelled distinctly on the map; a straight-line band is never
> described as an observed catchment.
>
> **Population and spend within a trade area.** Inside each catchment, WorldPop population is
> summed across the H3 res-7 cells. Estimated annual retail spend is then derived by applying
> the per-capita-spend multiplier for that country and retail category (grocery, home
> improvement / hardware, warehouse / wholesale) to the catchment population. Spend is expressed
> in local currency; cross-country comparisons are directional only.
>
> **The spend estimation chain (read this before quoting a dollar figure).** A spend number on
> this map is the product of three estimation steps, each with its own error:
> 1. WorldPop redistributes census counts to a 100 m grid (a dasymetric model — itself an
>    estimate, not a headcount);
> 2. that grid is aggregated to H3 res-7 cells and clipped to the catchment;
> 3. a single national per-capita multiplier is applied uniformly within the country.
> Because the multiplier is uniform within a country, the map does **not** capture local income
> variation — a wealthy and a low-income catchment of equal population return the same spend
> estimate. Treat spend as an order-of-magnitude comparison between catchments, not a precise
> revenue forecast.
>
> **Aggregation unit and the MAUP caveat (F25).** All demographic and spend figures are computed
> on H3 res-7 hexagons (≈5 km²). The choice of cell size and boundary changes the totals — the
> modifiable-areal-unit problem. A catchment edge that bisects a dense hexagon will include or
> exclude the whole cell's population. Figures are therefore approximations tied to the H3 res-7
> grid, not exact counts; a finer grid would shift them.
>
> **Distance and projection.** The map renders in Web Mercator, which distorts area and
> distance with latitude — a 35 km ring at 60°N covers less ground on screen than at 25°N.
> Catchment radii and areas are computed geodesically (true ground distance), not from screen
> circles, so the underlying numbers are projection-independent even though the drawn ring is not.

---

## 3. Modal — Caveats & Confidence tab (F13)

> ### What these estimates can and cannot tell you
>
> **Every figure on this map is a modelled estimate, not a measurement.** Population, spend,
> and tier are computed from the open inputs above. They are intended to support comparison and
> shortlisting, not to replace site-level due diligence.
>
> **Confidence is shown, not hidden.** Each cluster carries a confidence indicator derived from
> the completeness and agreement of its underlying data (anchor-match certainty, population-grid
> coverage, and mobility availability). Lower-confidence clusters are rendered with reduced
> opacity or a hollow marker so the eye can tell a well-evidenced district from a thin one.
> Where a confidence flag is shown in a cluster's detail panel, treat lower-confidence figures
> as indicative only.
>
> **Indicative error bands.** Because the estimates are modelled, point figures should be read
> with a margin:
> - **Population** within a catchment: typically within roughly ±10–15% of the WorldPop 2026
>   modelled value, before MAUP effects at the catchment edge.
> - **Spend**: a wider band — the three-step estimation chain and the uniform per-capita
>   assumption mean spend should be read as order-of-magnitude, not to the dollar.
> - **Cluster count and tier**: clustering is descriptive, not statistical. The number of
>   clusters depends on the chosen proximity parameters; sensitivity testing moved the North
>   American cluster count across a wide range under different settings. The parameters and their
>   sensitivity are published in the methodology topics.
>
> *(The specific ±% figures above are placeholders pending the engineering team confirming the
> error budget actually computed in the pipeline. They must be replaced with the figures from
> the confidence model before this copy ships — see the engineering note below.)*
>
> **Privacy.** No individual-level tracking and no personally identifiable information are used.
> All mobility data is synthetic or aggregated.
>
> **Not for navigation or critical planning.** This data is provided "as is" for location
> intelligence. It is not intended for real-time navigation or critical-infrastructure planning,
> and Woodfine Group does not guarantee the precision of individual retailer coordinates or
> synthesised economic metrics.
>
> **Forward-looking layers.** Mobility-derived (observed) trade areas and a daytime/workplace
> population view are planned and intended to expand per region as the underlying data is
> integrated; availability varies by country today. Until a country's mobility data is live, its
> catchments are modelled distance bands.
>
> [Full data manifest and licence terms →](DATA-MANIFEST.md)

---

## 4. Engineering note — verify the modal is wired, not placeholder (F14)

The 2026-06-20 audit could not confirm that the live **Data & Methodology** dialog is wired to
real content; the tabs may be placeholders. Before this copy is treated as shipped:

1. **Confirm the modal opens** from both the map-face `Method ⓘ` affordance (§0) and any
   existing "Data" button, on desktop and on the mobile bottom sheet.
2. **Confirm each tab renders real copy** — Sources, Method, Caveats & Confidence — and is not a
   stub or lorem placeholder. The audit logged this as the specific open question.
3. **Wire the build month dynamically.** The `updated YYYY-MM` token in the provenance line and
   the per-source vintages must be read from a pipeline-emitted `build_meta`, not hard-coded.
4. **Wire the confidence indicator (F13).** The cluster confidence flag already computed in the
   pipeline must drive the opacity / hollow-marker rendering described in §3, and the detail
   panel must surface it per cluster. If the flag is computed but unused today, that is the gap
   to close.
5. **Replace the placeholder error bands** in §3 with the actual error budget from the
   confidence model once it is confirmed; do not ship the illustrative ±% figures as if they
   were measured.

Until items 1–5 are confirmed, this remains draft copy with one open question carried in the
frontmatter: *confirm the live DATA modal is wired and not placeholder tabs.*
