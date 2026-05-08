const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, HeadingLevel, BorderStyle, WidthType,
  ShadingType, VerticalAlign, PageNumber, PageBreak, LevelFormat,
  TableOfContents, ExternalHyperlink, InternalHyperlink, Bookmark,
  UnderlineType, TabStopType, TabStopPosition
} = require('docx');
const fs = require('fs');
const path = require('path');

// ─── helpers ───────────────────────────────────────────────────────────────
const CONTENT_WIDTH = 9360; // US Letter, 1" margins
const C1 = 2340, C2 = 7020; // two-col widths

const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };
const noBorders = {
  top: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
  bottom: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
  left: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
  right: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
};

function heading1(text, bookmarkId) {
  const children = bookmarkId
    ? [new Bookmark({ id: bookmarkId, children: [new TextRun({ text, bold: true, size: 28, font: "Arial" })] })]
    : [new TextRun({ text, bold: true, size: 28, font: "Arial" })];
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    children,
    spacing: { before: 320, after: 120 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: "000000", space: 4 } }
  });
}

function heading2(text, bookmarkId) {
  const children = bookmarkId
    ? [new Bookmark({ id: bookmarkId, children: [new TextRun({ text, bold: true, size: 24, font: "Arial" })] })]
    : [new TextRun({ text, bold: true, size: 24, font: "Arial" })];
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    children,
    spacing: { before: 240, after: 80 }
  });
}

function para(text, opts = {}) {
  return new Paragraph({
    children: [new TextRun({ text, size: opts.size || 20, font: "Arial", bold: opts.bold, italics: opts.italic })],
    spacing: { before: 60, after: 60 },
    ...opts
  });
}

function bullet(text) {
  return new Paragraph({
    numbering: { reference: "bullets", level: 0 },
    children: [new TextRun({ text, size: 20, font: "Arial" })],
    spacing: { before: 40, after: 40 }
  });
}

function qaPair(q, a) {
  return [
    new Paragraph({
      children: [new TextRun({ text: q, bold: true, size: 20, font: "Arial" })],
      spacing: { before: 120, after: 40 }
    }),
    new Paragraph({
      children: [new TextRun({ text: a, size: 20, font: "Arial" })],
      spacing: { before: 0, after: 100 }
    })
  ];
}

function zoneTag(text) {
  return new Paragraph({
    children: [new TextRun({ text: `  ${text}  `, size: 18, font: "Arial", bold: true, color: "FFFFFF", shading: { type: ShadingType.CLEAR, fill: "222222" } })],
    spacing: { before: 60, after: 60 }
  });
}

function pageBreak() {
  return new Paragraph({ children: [new PageBreak()] });
}

// ─── TOC entries ───────────────────────────────────────────────────────────
function tocEntry(num, title, bookmarkId) {
  return new Paragraph({
    tabStops: [{ type: TabStopType.RIGHT, position: CONTENT_WIDTH, leader: "dot" }],
    children: [
      new InternalHyperlink({
        anchor: bookmarkId,
        children: [new TextRun({ text: `${num}. ${title}`, size: 20, font: "Arial", underline: { type: UnderlineType.SINGLE } })]
      }),
      new TextRun({ text: "\t", size: 20, font: "Arial" }),
      new TextRun({ text: `${num + 1}`, size: 20, font: "Arial" }) // approximate page numbers
    ],
    spacing: { before: 60, after: 60 }
  });
}

// ─── FOOTER ────────────────────────────────────────────────────────────────
const footerPara = new Paragraph({
  tabStops: [
    { type: TabStopType.CENTER, position: CONTENT_WIDTH / 2 },
    { type: TabStopType.RIGHT, position: CONTENT_WIDTH }
  ],
  children: [
    new TextRun({ text: "WePitch – Burger Farm | Confidential", size: 16, font: "Arial", color: "555555" }),
    new TextRun({ text: "\t\t", size: 16 }),
    new TextRun({ children: ["Page ", PageNumber.CURRENT], size: 16, font: "Arial", color: "555555" })
  ],
  border: { top: { style: BorderStyle.SINGLE, size: 4, color: "000000", space: 4 } }
});

// ─── SECTIONS ──────────────────────────────────────────────────────────────
const titleSection = {
  properties: {
    page: { size: { width: 12240, height: 15840 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } }
  },
  footers: { default: new Footer({ children: [footerPara] }) },
  children: [
    // Decorative top bar
    new Paragraph({
      children: [new TextRun({ text: "▓".repeat(120), size: 8, font: "Courier New", color: "EEEEEE" })],
      spacing: { before: 0, after: 0 }
    }),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 800 } }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: "TECHNICAL QUERY RESPONSE", bold: true, size: 52, font: "Arial", color: "000000" })]
    }),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 80 } }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: "000000", space: 4 } },
      children: [new TextRun({ text: "Burger Farm Mobile Application Proposal", size: 26, font: "Arial", italics: true })]
    }),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 200 } }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: "Prepared by: WePitch", size: 22, font: "Arial" })]
    }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: "Submitted to: Burger Farm", size: 22, font: "Arial" })]
    }),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 100 } }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: "April 2026  |  CONFIDENTIAL", size: 20, font: "Arial", bold: true, color: "444444" })]
    }),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 600 } }),
    // decorative bottom
    new Paragraph({
      children: [new TextRun({ text: "▓".repeat(120), size: 8, font: "Courier New", color: "EEEEEE" })],
      spacing: { before: 0, after: 0 }
    }),
  ]
};

const tocSection = {
  properties: {
    page: { size: { width: 12240, height: 15840 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } }
  },
  footers: { default: new Footer({ children: [footerPara] }) },
  children: [
    heading1("Table of Contents", "toc"),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 120 } }),
    ...[
      ["1", "Technology Stack & Engineering Architecture", "q1"],
      ["2", "Maintenance Cost – Scope & Scalability", "q2"],
      ["3", "Cost Optimisation During Testing Phase", "q3"],
      ["4", "Testing Strategy, QA Framework & Metrics", "q4"],
      ["5", "POS Integration Requirements", "q5"],
      ["6", "Loyalty & Promotional Engine", "q6"],
      ["7", "External APIs & Third-Party Integrations", "q7"],
      ["8", "Downtime Handling, SLA & Incident Management", "q8"],
      ["9", "Monitoring, Alerts & Observability", "q9"],
      ["10", "Security & Compliance", "q10"],
    ].map(([num, title, bm]) =>
      new Paragraph({
        tabStops: [{ type: TabStopType.RIGHT, position: CONTENT_WIDTH }],
        children: [
          new InternalHyperlink({
            anchor: bm,
            children: [new TextRun({ text: `${num}.  ${title}`, size: 20, font: "Arial", underline: { type: UnderlineType.SINGLE } })]
          })
        ],
        spacing: { before: 80, after: 80 }
      })
    )
  ]
};

// ─── content sections ──────────────────────────────────────────────────────
const contentSection = {
  properties: {
    page: { size: { width: 12240, height: 15840 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } }
  },
  footers: { default: new Footer({ children: [footerPara] }) },
  children: [

    // ── Q1 ──────────────────────────────────────────────────────────────
    heading1("1. Technology Stack & Engineering Architecture", "q1"),
    para("Below is the complete breakdown of our technical architecture for the Burger Farm Flutter application."),

    heading2("State Management"),
    ...qaPair("Approach:", "Riverpod — chosen for its compile-safe, testable, and scalable state management. Supports feature-first modular architecture without boilerplate overhead."),

    heading2("Code Architecture"),
    ...qaPair("Pattern:", "Clean Architecture with feature-first folder structure. Each feature module (auth, menu, cart, payments, loyalty) is self-contained with its own data, domain, and presentation layers. Dependency Injection via get_it + injectable."),

    heading2("Backend & Infrastructure"),
    new Table({
      width: { size: CONTENT_WIDTH, type: WidthType.DXA },
      columnWidths: [2200, 7160],
      rows: [
        ...[
          ["Hosting", "Firebase (primary) + GCP Cloud Run for scalable API endpoints"],
          ["Database", "Firestore (NoSQL) for real-time order data; Cloud SQL for transactional/financial records"],
          ["API Architecture", "RESTful APIs with versioning (/v1/). GraphQL considered for future data flexibility"],
          ["OTP Auth", "MSG91 or Firebase Auth — confirmed post Phase 0 sign-off with Rakshit (BF Tech Lead)"],
        ].map(([label, val], i) => new TableRow({
          children: [
            new TableCell({ borders, width: { size: 2200, type: WidthType.DXA }, shading: { fill: i%2?"F5F5F5":"EBEBEB", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: label, bold: true, size: 18, font: "Arial" })] })] }),
            new TableCell({ borders, width: { size: 7160, type: WidthType.DXA }, shading: { fill: i%2?"FAFAFA":"FFFFFF", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: val, size: 18, font: "Arial" })] })] })
          ]
        }))
      ]
    }),

    heading2("CI/CD & DevOps"),
    ...qaPair("Pipeline:", "GitHub Actions for build automation. Branch structure: main / staging / dev (as captured in your Linear project — BUR6). Deployment follows dev → staging → production with manual gate approvals. Rollback via versioned releases on GitHub."),

    heading2("Code Quality"),
    ...qaPair("Standards:", "flutter_lints + custom analysis_options.yaml. Mandatory PR reviews. All APIs documented via Postman collections (shared at Phase 0 — BUR8/BUR9 in Linear). Technical debt tracked as Linear tickets with priority labels."),

    pageBreak(),

    // ── Q2 ──────────────────────────────────────────────────────────────
    heading1("2. Maintenance Cost – Scope & Scalability", "q2"),

    heading2("What is Covered at ₹40,000/month"),
    new Table({
      width: { size: CONTENT_WIDTH, type: WidthType.DXA },
      columnWidths: [2500, 6860],
      rows: [
        ...[
          ["Bug Fixes", "Priority bugs and minor enhancements — included"],
          ["Server Monitoring", "Uptime monitoring, alert triage — included"],
          ["DevOps", "Deployment support, CI/CD maintenance — included"],
          ["Infrastructure Costs", "Billed separately (Firebase, GCP, Razorpay, MSG91, Maps API)"],
          ["Stores Covered", "All active stores under the single production environment"],
        ].map(([label, val], i) => new TableRow({
          children: [
            new TableCell({ borders, width: { size: 2500, type: WidthType.DXA }, shading: { fill: i%2?"F5F5F5":"EBEBEB", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: label, bold: true, size: 18, font: "Arial" })] })] }),
            new TableCell({ borders, width: { size: 6860, type: WidthType.DXA }, shading: { fill: i%2?"FAFAFA":"FFFFFF", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: val, size: 18, font: "Arial" })] })] })
          ]
        }))
      ]
    }),

    heading2("Scalability & Pricing"),
    ...qaPair("User base growth:", "Firebase auto-scales. No change to maintenance fee up to 10,000 DAU. Above that, infrastructure costs increase proportionally — billed at actuals."),
    ...qaPair("Multi-city expansion:", "No additional maintenance fee per city/store. The app is store-agnostic by design (storeId parameter in all APIs — as defined in Zones 1–6 of your Linear structure)."),
    ...qaPair("Traffic spikes:", "Cloud Run scales horizontally. Load balancing configured at infrastructure level."),

    heading2("SLA"),
    ...qaPair("Critical issues:", "Response within 2 hours, resolution within 24 hours."),
    ...qaPair("Non-critical:", "Acknowledged within 24 hours, resolved within 5 business days."),
    ...qaPair("Support hours:", "Business hours (10am–7pm IST, Mon–Sat) with on-call escalation for critical production incidents."),

    pageBreak(),

    // ── Q3 ──────────────────────────────────────────────────────────────
    heading1("3. Cost Optimisation During Testing Phase", "q3"),
    para("We confirm the following cost management approach for staging and testing:"),
    bullet("Staging environments use shared/lower-tier GCP and Firebase configurations — costs are minimal and absorbed within the initial project budget."),
    bullet("Trial credits from Firebase, GCP, and Razorpay test mode will be utilised for the full testing phase."),
    bullet("Staging and production infrastructure are fully separated — no test data will touch production APIs or databases."),
    bullet("Razorpay test keys are already configured in the staging environment. Live keys activated only at production go-live."),
    bullet("All infrastructure cost estimates are shared in a separate infrastructure cost sheet upon request."),

    pageBreak(),

    // ── Q4 ──────────────────────────────────────────────────────────────
    heading1("4. Testing Strategy, QA Framework & Metrics", "q4"),

    heading2("Testing Frameworks"),
    ...qaPair("Unit Testing:", "flutter_test + Mockito for unit and mock-based testing across all service and repository layers."),
    ...qaPair("Integration Testing:", "flutter_test integration suite covering API integrations and state transitions."),
    ...qaPair("UI / Automation:", "Flutter Driver for end-to-end automated flows (login → cart → payment)."),

    heading2("Coverage & Critical Flows"),
    ...qaPair("Target coverage:", "Minimum 70% code coverage. 100% coverage on critical paths: OTP auth, cart operations, payment flow, loyalty point award."),

    heading2("Performance Testing"),
    ...qaPair("Load testing:", "k6 used for API load testing. Simulated peak loads of 500 concurrent users before launch."),
    ...qaPair("Stress testing:", "Spike tests run to validate payment and order creation endpoints under burst conditions."),

    heading2("Quality Gates"),
    ...qaPair("Release criteria:", "Zero P0/P1 bugs. All critical-flow test cases passing. App size < 50MB (as specified in the Linear Final QA Checklist — Zone 11 in your project structure)."),
    ...qaPair("Regression cycles:", "Full regression run before each zone handoff and before production release."),

    heading2("Security Testing"),
    ...qaPair("API security:", "All endpoints require auth token validation. OWASP Top 10 checklist applied."),
    ...qaPair("Payment compliance:", "Razorpay SDK handles PCI-DSS compliance. No raw card data is stored or transmitted by our application."),

    pageBreak(),

    // ── Q5 ──────────────────────────────────────────────────────────────
    heading1("5. POS Integration Requirements", "q5"),
    para("Real-time POS integration is critical for menu availability, order routing, and inventory sync. The following is required from the Burger Farm POS team:"),

    new Table({
      width: { size: CONTENT_WIDTH, type: WidthType.DXA },
      columnWidths: [2800, 6560],
      rows: [
        ...[
          ["POS API Docs", "REST API documentation or webhook specification from your POS vendor"],
          ["Auth Credentials", "API keys or OAuth credentials for staging environment"],
          ["Menu Sync", "Endpoint or data feed for live item availability (used in PATCH /menu/:itemId/availability — Zone 4)"],
          ["Order Push", "Mechanism to push confirmed orders from app to POS in real time (Zone 6)"],
          ["Data Format", "Confirm item ID schema so app and POS use consistent identifiers"],
        ].map(([label, val], i) => new TableRow({
          children: [
            new TableCell({ borders, width: { size: 2800, type: WidthType.DXA }, shading: { fill: i%2?"F5F5F5":"EBEBEB", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: label, bold: true, size: 18, font: "Arial" })] })] }),
            new TableCell({ borders, width: { size: 6560, type: WidthType.DXA }, shading: { fill: i%2?"FAFAFA":"FFFFFF", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: val, size: 18, font: "Arial" })] })] })
          ]
        }))
      ]
    }),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 80 } }),
    ...qaPair("Integration methodology:", "Webhook-first approach. App pushes order payload to POS on POST /orders/create (Zone 6). Availability updates flow from POS to app via polling or webhook callback."),
    ...qaPair("Data consistency:", "Order IDs are UUID-based and shared across app and POS. Failed POS push triggers an alert and order is held in a retry queue for up to 3 minutes before user notification."),

    pageBreak(),

    // ── Q6 ──────────────────────────────────────────────────────────────
    heading1("6. Loyalty & Promotional Engine", "q6"),
    para("The loyalty and promotional system is defined across Zone 9 (Farm Points & Rewards) and Zone 3 (Offers & Deals) of your Linear project structure."),

    heading2("Loyalty System"),
    ...qaPair("Points accrual:", "1 point per ₹10 spent. Points awarded on order completion — triggered from the Order Confirmed screen (Zone 6) and confirmed via GET /loyalty (Zone 9)."),
    ...qaPair("Tier structure:", "Bronze → Silver → Gold → Platinum, based on cumulative points. Tier badge visible on Profile Home (Zone 10)."),
    ...qaPair("Redemption:", "Points redeemable against catalog items (Zone 9 — Rewards Catalog). Balance shown before/after confirmation. Backend: POST /rewards/redeem."),

    heading2("Promotional Engine"),
    ...qaPair("Coupon engine:", "Rule-based coupons (flat discount, percentage, minimum order). Applied at cart stage — Zone 5 (Coupon Application Screen, POST /cart/coupon)."),
    ...qaPair("Campaign management:", "Campaigns configured on admin panel. Active/Expiring Soon/Used tabs in Offers & Deals screen (Zone 3)."),
    ...qaPair("Personalisation:", "First-order popup (Zone 3 — one-time modal, ₹50 off). Birthday offer auto-applied (Zone 10 — birthday field in Edit Profile, triggered in Zone 12)."),

    heading2("Fraud Prevention"),
    ...qaPair("Referral abuse:", "Each referral code is single-use per device + phone number combination. Rewards credited only after the referred user completes their first paid order (Zone 9 — Referral Screen)."),
    ...qaPair("Scratch card abuse:", "Triggered server-side on qualifying events (5th order, birthday). Client-side animation only — no client can self-trigger (Zone 9)."),

    pageBreak(),

    // ── Q7 ──────────────────────────────────────────────────────────────
    heading1("7. External APIs & Third-Party Integrations", "q7"),
    new Table({
      width: { size: CONTENT_WIDTH, type: WidthType.DXA },
      columnWidths: [2000, 2800, 2200, 2360],
      rows: [
        new TableRow({
          tableHeader: true,
          children: ["Service", "Provider", "Usage", "Cost / Notes"].map(t =>
            new TableCell({ borders, width: { size: t==="Service"?2000:t==="Provider"?2800:t==="Usage"?2200:2360, type: WidthType.DXA }, shading: { fill: "1A1A1A", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: t, bold: true, size: 18, font: "Arial", color: "FFFFFF" })] })] })
          )
        }),
        ...[
          ["Payment Gateway", "Razorpay", "Checkout, UPI, Cards, Wallet (Zone 6)", "Transaction fee ~2%. Test mode available"],
          ["Push Notifications", "Firebase Cloud Messaging", "Order updates, offers (Zone 3, 9)", "Free tier sufficient for launch"],
          ["OTP / SMS", "MSG91 or Firebase Auth", "Phone login (Zone 1)", "~₹0.15–0.25 per OTP"],
          ["Analytics", "Firebase Analytics", "Screen views, cart, purchase events", "Free"],
          ["Crash Tracking", "Sentry / Crashlytics", "Error reporting across all zones", "Free tier / Sentry Pro ~$26/mo"],
          ["Maps / Location", "Google Maps SDK", "Outlet selector map (Zone 2)", "~$7/1000 requests"],
          ["Order Aggregation", "UrbanPiper", "Swiggy/Zomato integration (existing)", "Existing vendor — confirm scope"],
        ].map(([svc, prov, usage, cost], i) => new TableRow({
          children: [svc, prov, usage, cost].map((txt, ci) =>
            new TableCell({ borders, width: { size: [2000,2800,2200,2360][ci], type: WidthType.DXA }, shading: { fill: i%2?"F5F5F5":"FFFFFF", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: txt, size: 17, font: "Arial" })] })] })
          )
        }))
      ]
    }),
    new Paragraph({ children: [new TextRun("")], spacing: { before: 80 } }),
    ...qaPair("Vendor dependency risk:", "All third-party SDKs are abstracted behind service interfaces. Swapping a vendor (e.g., payment gateway or OTP provider) requires a single adapter change with no impact on UI layers."),

    pageBreak(),

    // ── Q8 ──────────────────────────────────────────────────────────────
    heading1("8. Downtime Handling, SLA & Incident Management", "q8"),

    heading2("Availability Target"),
    ...qaPair("SLA:", "99.5% uptime target for production. Planned maintenance communicated 48 hours in advance."),

    heading2("Downtime Handling"),
    ...qaPair("Failover:", "Firebase provides automatic multi-region failover. Cloud Run instances auto-restart on failure."),
    ...qaPair("Offline state:", "The app handles no-internet gracefully — Zone 11 (No Internet / Offline Screen) with retry CTA. Cart state persists locally via Hive."),
    ...qaPair("Payment downtime:", "If payment gateway is unreachable, the Payment Failed screen is shown (Zone 6) with cart preserved and a retry/change-method option."),

    heading2("Incident Response Workflow"),
    bullet("Detection: Automated alerts via Firebase Alerting / Sentry (triggered within 2–5 minutes of threshold breach)"),
    bullet("Escalation: Alert sent to on-call engineer via Slack + SMS within 5 minutes"),
    bullet("Resolution: P0 (production down) — target fix or rollback within 2 hours"),
    bullet("Post-incident: Root cause analysis shared with Burger Farm within 48 hours"),

    heading2("Turnaround Times"),
    new Table({
      width: { size: CONTENT_WIDTH, type: WidthType.DXA },
      columnWidths: [2000, 3500, 3860],
      rows: [
        new TableRow({ tableHeader: true, children: ["Priority", "Definition", "Resolution Target"].map(t => new TableCell({ borders, width: { size: t==="Priority"?2000:t==="Definition"?3500:3860, type: WidthType.DXA }, shading: { fill: "1A1A1A", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: t, bold: true, size: 18, font: "Arial", color: "FFFFFF" })] })] })) }),
        ...[
          ["P0 – Critical", "App/payments down, data loss risk", "2 hours"],
          ["P1 – High", "Major feature broken (ordering, loyalty)", "24 hours"],
          ["P2 – Medium", "Minor feature degraded", "3–5 business days"],
          ["P3 – Low", "Cosmetic / minor UX issue", "Next sprint"],
        ].map(([p, d, r], i) => new TableRow({ children: [p,d,r].map((txt, ci) => new TableCell({ borders, width: { size: [2000,3500,3860][ci], type: WidthType.DXA }, shading: { fill: i%2?"F5F5F5":"FFFFFF", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: txt, size: 18, font: "Arial" })] })] })) }))
      ]
    }),

    pageBreak(),

    // ── Q9 ──────────────────────────────────────────────────────────────
    heading1("9. Monitoring, Alerts & Observability", "q9"),

    heading2("Monitoring Stack"),
    new Table({
      width: { size: CONTENT_WIDTH, type: WidthType.DXA },
      columnWidths: [2500, 6860],
      rows: [
        ...[
          ["Logs & Metrics", "Google Cloud Logging + Firebase Performance Monitoring"],
          ["Crash Tracking", "Firebase Crashlytics (primary) + Sentry (secondary for detailed traces)"],
          ["Uptime Monitoring", "GCP Cloud Monitoring with uptime checks on all public API endpoints"],
          ["Analytics", "Firebase Analytics — all key events tracked (add_to_cart, begin_checkout, purchase, login, coupon_applied)"],
        ].map(([label, val], i) => new TableRow({
          children: [
            new TableCell({ borders, width: { size: 2500, type: WidthType.DXA }, shading: { fill: i%2?"F5F5F5":"EBEBEB", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: label, bold: true, size: 18, font: "Arial" })] })] }),
            new TableCell({ borders, width: { size: 6860, type: WidthType.DXA }, shading: { fill: i%2?"FAFAFA":"FFFFFF", type: ShadingType.CLEAR }, margins: { top: 80, bottom: 80, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: val, size: 18, font: "Arial" })] })] })
          ]
        }))
      ]
    }),

    heading2("Alerting"),
    ...qaPair("Channels:", "Slack (primary), Email, and SMS for P0 incidents. Threshold-based triggers (e.g., error rate > 1%, API latency > 3s, crash rate spike)."),

    heading2("Proactive Detection"),
    ...qaPair("Anomaly detection:", "Firebase Performance Monitoring flags regressions automatically (e.g., cold start time increase, network latency spikes). Weekly performance report shared with Burger Farm team."),

    pageBreak(),

    // ── Q10 ──────────────────────────────────────────────────────────────
    heading1("10. Security & Compliance", "q10"),
    para("We take security and legal compliance seriously across all layers of the application."),

    heading2("Data Security"),
    bullet("All API communication over HTTPS/TLS 1.3. No plain-text data transmission."),
    bullet("Auth tokens stored using flutter_secure_storage (hardware-backed keystore on Android, Keychain on iOS)."),
    bullet("No sensitive user data (card numbers, raw OTPs) stored in application logs or databases."),

    heading2("Payment Compliance"),
    bullet("Razorpay SDK is PCI-DSS compliant. Raw card data never touches our servers — handled entirely by Razorpay's hosted checkout."),
    bullet("Payment verification uses server-side signature validation (POST /payments/verify — Zone 6)."),

    heading2("Legal & App Store Compliance"),
    bullet("Privacy Policy and Terms of Use screens are mandatory pre-launch. Content to be finalised with Burger Farm's legal team."),
    bullet("App will comply with Google Play Developer Programme Policies and Apple App Store Guidelines."),
    bullet("GDPR/PDPA-aligned data handling: users can request data deletion via the Delete Account flow (Zone 10)."),
    bullet("All third-party SDK data sharing disclosures will be included in the Privacy Policy."),

    heading2("User Data"),
    ...qaPair("Data minimisation:", "Only data required for app functionality is collected (phone, name, preferences, order history). No data sold to third parties."),
    ...qaPair("Audit trail:", "All payment and order events are logged with timestamps for compliance and dispute resolution."),

    new Paragraph({ children: [new TextRun("")], spacing: { before: 200 } }),
    new Paragraph({
      border: { top: { style: BorderStyle.SINGLE, size: 4, color: "000000", space: 4 } },
      children: [new TextRun({ text: "This document is prepared by WePitch in response to Burger Farm's technical queries dated April 2026. All references to zones and screens correspond to the agreed Linear project structure shared with Rakshit (BF Tech Lead). For further clarifications, please reach out to the WePitch project team.", size: 18, font: "Arial", italics: true, color: "555555" })],
      spacing: { before: 120, after: 60 }
    }),
  ]
};

// ─── BUILD ─────────────────────────────────────────────────────────────────
const doc = new Document({
  numbering: {
    config: [
      {
        reference: "bullets",
        levels: [{
          level: 0, format: LevelFormat.BULLET, text: "–",
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 540, hanging: 360 } } }
        }]
      }
    ]
  },
  styles: {
    default: { document: { run: { font: "Arial", size: 20 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, font: "Arial", color: "000000" },
        paragraph: { spacing: { before: 320, after: 120 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 24, bold: true, font: "Arial", color: "222222" },
        paragraph: { spacing: { before: 200, after: 80 }, outlineLevel: 1 } },
    ]
  },
  sections: [titleSection, tocSection, contentSection]
});

const outputPath = path.join('c:', 'Desktop', 'burger_farm_app', 'BurgerFarm_TechnicalQueryResponse.docx');

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync(outputPath, buf);
  console.log(`Successfully generated: ${outputPath}`);
}).catch(err => {
  console.error('Error generating document:', err);
  process.exit(1);
});
